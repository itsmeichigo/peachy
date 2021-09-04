import Cocoa
import Combine

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let exceptions = [
        "com.apple.dt.Xcode"
    ]

    @IBOutlet var menu: NSMenu!
    
    var statusBar: NSStatusBar?
    var statusItem: NSStatusItem?
    var cancellable: AnyCancellable?

    @Published var keyword: String?
    @Published var frontmostApp: NSRunningApplication?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        checkAccessibilityPermission {
            self.setupStatusBarItem()
            self.setupKeyListener()
            self.observeFrontmostApp()
            self.observeKeyword()
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
        statusItem?.button?.title = "🍑"
        statusItem?.menu = menu
    }

    func setupKeyListener() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            guard let chars = event.characters?.lowercased() else {
                return
            }
            guard let id = self.frontmostApp?.bundleIdentifier,
                  !self.exceptions.contains(id) else {
                return
            }
            switch chars {
            case ":":
                self.keyword = ""
            case "a"..."z":
                guard let key = self.keyword else {
                    return
                }
                self.keyword = key + chars
            default:
                self.keyword = nil
            }
        }
    }

    func observeFrontmostApp() {
        NSWorkspace.shared.publisher(for: \.frontmostApplication)
            .removeDuplicates()
            .handleEvents(receiveOutput: { _ in
                // TODO: remove drop down if needed
            })
            .assign(to: &$frontmostApp)
    }

    /// Filter kaomoji list and show drop down.
    ///
    func observeKeyword() {
        cancellable = $keyword
            .compactMap { $0 }
            .sink { word in
                guard let app = self.frontmostApp,
                      let frame = self.getTextSelectionBounds(for: app) else {
                    return
                }
                print(word)
                print(frame)
            }
    }

    /// Get the front most app's focused element,
    /// retrieve value and show drop down if needed.
    func getTextSelectionBounds(for app: NSRunningApplication) -> CGRect? {
        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        var focusedElement: CFTypeRef?
        guard
          AXUIElementCopyAttributeValue(axApp, kAXFocusedUIElementAttribute as CFString, &focusedElement)
            == .success else {
            return nil
        }
        
        var selectedRangeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue) == .success else {
            return nil
        }
        var selectedRange: CFRange = .init(location: 0, length: 0)
        AXValueGetValue(selectedRangeValue as! AXValue, AXValueType.cfRange, &selectedRange)
        var selectionBoundsValue: CFTypeRef?
        guard AXUIElementCopyParameterizedAttributeValue(focusedElement as! AXUIElement, kAXBoundsForRangeParameterizedAttribute as CFString, selectedRangeValue as! AXValue, &selectionBoundsValue) == .success else {
            return nil
        }
        var selectionBounds: CGRect = .zero
        AXValueGetValue(selectionBoundsValue as! AXValue, AXValueType.cgRect, &selectionBounds)
        return selectionBounds
    }
}

extension AXUIElement {
    func getAttribute(for name: String) -> CFTypeRef? {
        var value: CFTypeRef?
        AXUIElementCopyAttributeValue(self, name as CFString, &value)
        return value
    }
}
