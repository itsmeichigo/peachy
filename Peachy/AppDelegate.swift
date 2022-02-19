import AppCenter
import AppCenterAnalytics
import AppCenterCrashes
import Cocoa
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
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        appPreferences = AppPreferences()
        searchCoordinator = SearchCoordinator(preferences: appPreferences, appStateManager: appStateManager)
        configureAppCenter()

        if appStateManager.currentState.needsOnboarding {
            showOnboarding(pages: OnboardingPage.freshOnboarding)
        } else if !AppState.hasAXPermission {
            showOnboarding(pages: OnboardingPage.needsPermission)
        } else {
            showOnboarding(pages: [.pilot])
            startPeachy()
        }
    }

    func configureAppCenter() {
        AppCenter.start(withAppSecret: Secrets.appCenterAppSecret,
                        services: [Analytics.self, Crashes.self])
        Crashes.enabled = !appPreferences.optOutCrashReports
    }

    func startPeachy() {
        setupStatusBarItem()
        searchCoordinator.setupKeyListener()
    }
    
    func setupStatusBarItem() {
        statusBar = NSStatusBar()
        statusItem = statusBar?.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = NSImage(named: "peach")
        statusItem?.menu = menu
    }
    
    @IBAction func openPreferences(_ sender: Any) {
        preferencesWindow.orderFrontRegardless()
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showOnboarding(pages: [OnboardingPage]) {
        let onboardingViewModel = OnboardingViewModel(pages: pages, preferences: appPreferences, onPermissionGranted: {
            self.startPeachy()
        }, onPreferences: {
            NSApp.orderedWindows.first?.close()
            self.startPeachy()
            self.openPreferences(self)
        }, onCompletion: {
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
