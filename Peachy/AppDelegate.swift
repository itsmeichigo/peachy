import Carbon
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
        case .some(":"):
            self.keyword = ":"
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
    }

    func hideSearchWindow() {
        keyword = nil
        searchWindowController.window?.orderOut(nil)
    }

    func reloadSearchWindow(for word: String) {
        guard let app = frontmostApp,
              let frame = getTextSelectionBounds(for: app) else {
            return
        }
        searchWindowController.query = word.replacingOccurrences(of: ":", with: "")
        if searchWindowController.window?.isVisible == false {
            searchWindowController.frameOrigin = NSPoint(x: frame.origin.x + frame.size.width / 2, y: NSScreen.main!.frame.size.height - frame.origin.y - frame.size.height - 200)
            searchWindowController.showWindow(self)
        }
    }

    /// Find focused element and selected range to replace the range with kaomoji.
    ///
    func replace(keyword: String, with kaomoji: String, for app: NSRunningApplication) {
        let axApp = AXUIElementCreateApplication(app.processIdentifier)
        var focusedElement: CFTypeRef?
        guard
          AXUIElementCopyAttributeValue(axApp, kAXFocusedUIElementAttribute as CFString, &focusedElement)
            == .success else {
            return
        }
        
        var selectedRangeValue: CFTypeRef?
        guard AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue) == .success else {
            return
        }
        var selectedRange: CFRange = .init(location: 0, length: 0)
        AXValueGetValue(selectedRangeValue as! AXValue, AXValueType.cfRange, &selectedRange)
        var location: Int = selectedRange.location
        if selectedRange.length == 0 {
            location = max(location - keyword.count, 0)
        }

        var value: CFTypeRef?
        AXUIElementCopyAttributeValue(focusedElement as! AXUIElement, kAXValueAttribute as CFString, &value)
        var stringValue = value as! String
        let start = stringValue.index(stringValue.startIndex, offsetBy: location)
        let end = stringValue.index(start, offsetBy: keyword.count)
        stringValue.replaceSubrange(start..<end, with: "")
        stringValue.insert(contentsOf: kaomoji, at: start)
        print(stringValue)
        
        let result = AXUIElementSetAttributeValue(focusedElement as! AXUIElement, kAXValueAttribute as CFString, stringValue as CFTypeRef)
        guard result == .success else {
            return print(result.rawValue)
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
}
