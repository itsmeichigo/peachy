import Carbon
import Cocoa
import Combine
import Foundation

final class SearchCoordinator {
    @Published private var keyword: String?
    @Published private var frontmostApp: NSRunningApplication?

    private let searchWindowController: SearchWindowController
    private let exceptions = [
        "com.apple.dt.Xcode"
    ]
    private let triggerKey = ":"
    private var keywordSubscription: AnyCancellable?

    init() {
        self.searchWindowController = .init()
        searchWindowController.selectionDelegate = self
        searchWindowController.keyEventDelegate = self
        setupKeyListener()
        observeFrontmostApp()
        observeKeyword()
    }
}

// MARK: - Key Events
//
extension SearchCoordinator: KeyEventDelegate {
    func handleEvent(_ event: NSEvent) {
        if let char = event.characters,
           "a"..."z" ~= char,
           let key = keyword {
            keyword = key + char
            return
        }

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
        default:
            hideSearchWindow()
        }
    }
}

private extension SearchCoordinator {
    func setupKeyListener() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            self.handleGlobalEvent(event)
        }
    }

    func handleGlobalEvent(_ event: NSEvent) {
        guard let id = frontmostApp?.bundleIdentifier,
              !exceptions.contains(id) else {
                  return
              }
        let chars = event.characters?.lowercased()
        switch chars {
        case .some(triggerKey):
            keyword = ""
        case .some("a"..."z"):
            guard let key = keyword else {
                return
            }
            keyword = key + (chars ?? "")
        default:
            break
        }
    }
}

// MARK: - ItemSelectionDelegate conformance
//
extension SearchCoordinator: ItemSelectionDelegate {
    func handleSelection(_ item: Kaomoji) {
        guard let keyword = keyword, let app = frontmostApp else { return }
        replace(keyword: keyword, with: item.string, for: app)
        hideSearchWindow()
    }
}

// MARK: - Search window
//
private extension SearchCoordinator {
    /// Dismisses search if other app is activated
    ///
    func observeFrontmostApp() {
        NSWorkspace.shared.publisher(for: \.frontmostApplication)
            .removeDuplicates()
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.hideSearchWindow()
            })
            .assign(to: &$frontmostApp)
    }

    /// Filters kaomoji list and show drop down.
    ///
    func observeKeyword() {
        keywordSubscription = $keyword
            .compactMap { $0 }
            .sink { [weak self] word in
                guard !word.isEmpty else {
                    return
                }
                self?.reloadSearchWindow(for: word)
                self?.searchWindowController.query = word
            }
    }

    /// Dismisses search and resets keyword
    ///
    func hideSearchWindow() {
        keyword = nil
        searchWindowController.window?.orderOut(nil)
    }

    ///
    ///
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
}

// MARK: - Apple Events
private extension SearchCoordinator {
    /// Uses System Events to keystroke the specified character to the given app.
    ///
    func keyStroke(_ character: String, for app: NSRunningApplication) {
        guard let appName = app.localizedName else { return }
        let source = """
            tell application "System Events"
                tell application "\(appName)" to activate
                keystroke "\(character)"
            end tell
        """
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.sendAppleEvent(source: source)
        }
    }

    /// Uses System Events to keystroke and replace text with kaomoji.
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.sendAppleEvent(source: source)
        }
        
    }

    func sendAppleEvent(source: String) {
        if let script = NSAppleScript(source: source) {
            var error: NSDictionary?
            script.executeAndReturnError(&error)
            if let err = error {
                print(err)
            }
        }
    }
}

// MARK: - AX
//
private extension SearchCoordinator {
    /// Gets the front most app's focused element,
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

    /// Gets the front most app's focused element,
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
