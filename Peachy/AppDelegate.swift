import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet var menu: NSMenu!
    
    var statusBar: NSStatusBar?
    var statusItem: NSStatusItem?
    
    let searchCoordinator: SearchCoordinator = .init()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        checkAccessibilityPermission {
            self.setupStatusBarItem()
        }
    }
    
    func checkAccessibilityPermission(proceedHandler: @escaping () -> Void) {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false] as CFDictionary
        if AXIsProcessTrustedWithOptions(options) {
            proceedHandler()
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "Peachy needs accessibility access."
        alert.informativeText =
            "Navigate to System Preferences > Security & Privacy > Accessibility then select Peachy in the list to continue."
        alert.addButton(withTitle: "Open Settings & Quit")
        
        let button = alert.runModal()
        switch button {
        case .alertFirstButtonReturn:
            NSWorkspace.shared.open(
              URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            NSApp.terminate(nil)
        default:
            break
        }
    }
    
    func setupStatusBarItem() {
        statusBar = NSStatusBar()
        statusItem = statusBar?.statusItem(withLength: NSStatusItem.squareLength)
        statusItem?.button?.image = NSImage(named: "peach")
        statusItem?.menu = menu
    }
    
    @IBAction func openPreferences(_ sender: Any) {
        let viewController = NSHostingController(rootView: PreferencesView())
        let window = NSWindow(contentViewController: viewController)
        window.styleMask = [.closable, .titled]
        window.title = "Preferences"
        window.center()
        window.orderFrontRegardless()
        NSApp.setActivationPolicy(.regular)
        window.delegate = self
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
