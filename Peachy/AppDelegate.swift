import AppCenter
import AppCenterCrashes
import Cocoa
import LaunchAtLogin
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet private var menu: NSMenu!
    
    private var statusBar: NSStatusBar?
    private var statusItem: NSStatusItem?
    
    private var searchCoordinator: SearchCoordinator!
    private var appPreferences: AppPreferences!
    private let appStateManager = AppStateManager()
    
    private lazy var preferencesWindow: NSWindow = {
        let viewController = NSHostingController(rootView: PreferencesView(preferences: appPreferences))
        let window = NSWindow(contentViewController: viewController)
        window.title = "Preferences"
        window.applyCommonStyle()
        window.delegate = self
        return window
    }()

    private lazy var aboutWindow: NSWindow = {
        let viewController = NSHostingController(rootView: AboutView())
        let window = NSWindow(contentViewController: viewController)
        window.title = "About"
        window.applyCommonStyle()
        window.delegate = self
        return window
    }()

    private lazy var browserWindow: NSWindow = {
        let viewModel = BrowserViewModel(appStateManager: appStateManager)
        let view = BrowserView(viewModel: viewModel)
        let viewController = NSHostingController(rootView: view)

        let toolbar = NSToolbar.browserToolbar
        toolbar.delegate = viewModel

        let window = NSWindow(contentViewController: viewController)
        window.center()
        window.toolbar = toolbar
        window.toolbarStyle = .unified
        window.titlebarAppearsTransparent = true
        window.delegate = self
        viewModel.parentWindow = window
        return window
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        LaunchAtLogin.migrateIfNeeded()
        appPreferences = AppPreferences()
        searchCoordinator = SearchCoordinator(preferences: appPreferences, appStateManager: appStateManager)
        configureAppCenter()

        if appStateManager.currentState.needsOnboarding {
            showOnboarding(pages: OnboardingPage.freshOnboarding)
        } else if !AppState.hasAXPermission {
            showOnboarding(pages: OnboardingPage.needsPermission)
        } else {
            startPeachy()
        }
    }

    func configureAppCenter() {
        AppCenter.start(withAppSecret: Secrets.appCenterAppSecret,
                        services: [Crashes.self])
        Crashes.enabled = !appPreferences.optOutCrashReports
    }

    func startPeachy() {
        setupStatusBarItem()
        searchCoordinator.setupKeyListener()
    }
    
    func setupStatusBarItem() {
        statusBar = NSStatusBar()
        statusItem = statusBar?.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.image = NSImage(named: "peach")
        statusItem?.button?.frame = CGRect(x: 0, y: 0, width: 32, height: 16)
        statusItem?.menu = menu
    }
    
    @IBAction func openPreferences(_ sender: Any) {
        preferencesWindow.orderFrontRegardless()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func openReleaseNotes(_ sender: Any) {
        let url = URL(string: Links.releaseNotesURL)!
        NSWorkspace.shared.open(url)
    }

    @IBAction func openAbout(_ sender: Any) {
        aboutWindow.orderFrontRegardless()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    @IBAction func openBrowser(_ sender: Any) {
        browserWindow.orderFrontRegardless()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showOnboarding(pages: [OnboardingPage]) {
        let onboardingViewModel = OnboardingViewModel(pages: pages, preferences: appPreferences, onPermissionGranted: {
            self.startPeachy()
        }, onPreferences: {
            NSApp.orderedWindows.first?.close()
            self.openPreferences(self)
        }, onOpenBrowser: {
            NSApp.orderedWindows.first?.close()
            self.openBrowser(self)
        }, onCompletion: {
            self.appStateManager.updateDoneState()
            NSApp.orderedWindows.first?.close()
        })
        let viewController = NSHostingController(rootView: OnboardingView(viewModel: onboardingViewModel))
        let window = NSWindow(contentViewController: viewController)
        window.applyCommonStyle()
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.orderFrontRegardless()
        window.delegate = self
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
