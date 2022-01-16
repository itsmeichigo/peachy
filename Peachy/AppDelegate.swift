import Carbon
import Cocoa
import Combine

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    let exceptions = [
        "com.apple.dt.Xcode"
    ]
    let triggerKey = ":"

    @IBOutlet var menu: NSMenu!
    
    var statusBar: NSStatusBar?
    var statusItem: NSStatusItem?
    var cancellable: AnyCancellable?
    
    lazy var searchWindowController: SearchWindowController = .init(selectionDelegate: self)

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
            self.handleGlobalEvent(event)
        }
    }
    
    func observeFrontmostApp() {
        NSWorkspace.shared.publisher(for: \.frontmostApplication)
            .removeDuplicates()
            .handleEvents(receiveOutput: { _ in
                self.searchWindowController.window?.orderOut(nil)
            })
            .assign(to: &$frontmostApp)
    }

    /// Filter kaomoji list and show drop down.
    ///
    func observeKeyword() {
        cancellable = $keyword
            .compactMap { $0 }
            .sink { word in
                guard !word.isEmpty else {
                    return
                }
                self.reloadSearchWindow(for: word)
            }
    }
}

// MARK: - ItemSelectionDelegate
extension AppDelegate: ItemSelectionDelegate {
    func handleSelection(_ item: Kaomoji) {
        guard let keyword = keyword, let app = frontmostApp else { return }
        replace(keyword: keyword, with: item.string, for: app)
        hideSearchWindow()
    }
}

// MARK: - Helper methods
private extension AppDelegate {
    func handleGlobalEvent(_ event: NSEvent) {
        guard let id = frontmostApp?.bundleIdentifier,
              !exceptions.contains(id) else {
            return
        }
        let chars = event.characters?.lowercased()
        switch chars {
        case .some(triggerKey):
            self.keyword = ""
        case .some("a"..."z"):
            guard let key = keyword else {
                return
            }
            keyword = key + (chars ?? "")
        default:
            switch Int(event.keyCode) {
            case kVK_Delete:
                guard let key = keyword, !key.isEmpty else {
                    return
                }
                if key.count == 1 {
                    hideSearchWindow()
                } else {
                    keyword = String(key.prefix(key.count-1))
                }
            case kVK_DownArrow, kVK_UpArrow:
                searchWindowController.keyDown(with: event)
            case kVK_Return, kVK_Escape:
                searchWindowController.keyDown(with: event)
                hideSearchWindow()
            default:
                hideSearchWindow()
            }
        }
        searchWindowController.query = keyword ?? ""
    }

    func hideSearchWindow() {
        keyword = nil
        searchWindowController.window?.orderOut(nil)
    }

    func reloadSearchWindow(for word: String) {
        guard let app = frontmostApp else {
            return
        }

        if searchWindowController.window?.isVisible == false {
            var frameOrigin = NSPoint(x: NSScreen.main!.frame.size.width / 2 - 100, y: NSScreen.main!.frame.size.height / 2 - 100)
            if let frame = getTextSelectionBounds(for: app), frame.size != .zero {
                frameOrigin = NSPoint(x: frame.origin.x + frame.size.width / 2, y: NSScreen.main!.frame.size.height - frame.origin.y - frame.size.height - 200)
            } else if let frame = getFocusedElementFrame(for: app), frame.size != .zero {
                frameOrigin = NSPoint(x: frame.origin.x, y: NSScreen.main!.frame.size.height - frame.origin.y - frame.size.height - 200)
            }
            searchWindowController.frameOrigin = frameOrigin
            searchWindowController.showWindow(self)
        }
    }

    /// Use System Events to keystroke and replace text with kaomoji.
    ///
    func replace(keyword: String, with kaomoji: String, for app: NSRunningApplication) {
        guard let appName = app.localizedName else { return }
        let source = """
            tell application "System Events"
                tell application "\(appName)" to activate
                repeat \(keyword.count + 1) times
                    key code 123 using {shift down}
                end repeat
                set the clipboard to "\(kaomoji)"
                keystroke "v" using command down
                delay 0.2
                set the clipboard to ""
            end tell
        """
        
        if let script = NSAppleScript(source: source) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if let err = error {
                print(err)
            }
        }
    }

    /// Get the front most app's focused element,
    /// retrieve selected range and return the bound.
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

    /// Get the front most app's focused element,
    /// retrieve element's frame.
    func getFocusedElementFrame(for app: NSRunningApplication) -> CGRect? {
        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        var focusedElement: CFTypeRef?
        guard
          AXUIElementCopyAttributeValue(axApp, kAXFocusedUIElementAttribute as CFString, &focusedElement)
            == .success else {
            return nil
        }

        var positionValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXPositionAttribute as CFString, &positionValue) == .success else {
            return nil
        }
        var position: CGPoint = .zero
        AXValueGetValue(positionValue as! AXValue, AXValueType.cgPoint, &position)

        var sizeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSizeAttribute as CFString, &sizeValue) == .success else {
            return nil
        }
        var size: CGSize = .zero
        AXValueGetValue(sizeValue as! AXValue, AXValueType.cgSize, &size)

        return CGRect(origin: position, size: size)
    }
}
