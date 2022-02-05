import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var menu: NSMenu!
    
    var statusBar: NSStatusBar?
    var statusItem: NSStatusItem?
    
    var searchCoordinator: SearchCoordinator!
    var appPreferences: AppPreferences!
    let appStateManager = AppStateManager()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        appPreferences = AppPreferences()
        searchCoordinator = SearchCoordinator(preferences: appPreferences)

        if appStateManager.currentState.needsOnboarding {
            showOnboarding(pages: OnboardingPage.freshOnboarding)
        } else {
            checkAccessibilityPermission {
                self.startPeachy()
            }
        }
    }
    
    func checkAccessibilityPermission(proceedHandler: @escaping () -> Void) {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false] as CFDictionary
        if AXIsProcessTrustedWithOptions(options) {
            proceedHandler()
            return
        }
        showOnboarding(pages: OnboardingPage.needsPermission)
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
        let viewController = NSHostingController(rootView: PreferencesView(preferences: appPreferences))
        let window = NSWindow(contentViewController: viewController)
        window.title = "Preferences"
        window.applyCommonStyle()
        window.orderFrontRegardless()
        window.delegate = self
        NSApp.setActivationPolicy(.regular)
    }

    func showOnboarding(pages: [OnboardingPage]) {
        let onboardingViewModel = OnboardingViewModel(pages: pages) {
            NSApp.orderedWindows.first?.close()
            self.startPeachy()
        }
        let viewController = NSHostingController(rootView: OnboardingView(viewModel: onboardingViewModel))
        let window = NSWindow(contentViewController: viewController)
        window.applyCommonStyle()
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.orderFrontRegardless()
        window.delegate = self
        NSApp.setActivationPolicy(.regular)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
