import Carbon
import Cocoa
import Combine

protocol SearchPanelDelegate: AnyObject {
    func dismissPanel()
}

final class SearchPanel: NSPanel {
    weak var searchDelegate: SearchPanelDelegate?

    override var canBecomeKey: Bool { true }

    @objc func cancel(_ sender: Any?) {
        searchDelegate?.dismissPanel()
    }
}

protocol KeyEventDelegate: AnyObject {
    func handleEvent(_ event: NSEvent)
}

final class SearchWindowController: NSWindowController {
    
    @Published var query = ""
    var frameOrigin: NSPoint = .zero
    weak var selectionDelegate: ItemSelectionDelegate?
    weak var keyEventDelegate: KeyEventDelegate?
    
    private static let nibName: NSNib.Name = "SearchWindowController"
    
    @IBOutlet private var itemTableController: ItemTableController!
    @IBOutlet private var searchImageView: NSImageView!
    @IBOutlet private var keywordTextField: NSTextField!
    @IBOutlet private var noResultTextField: NSTextField!
    
    private let kaomojiStore = KaomojiStore.shared

    private var cancellables = Set<AnyCancellable>()
    
    convenience init() {
        self.init(windowNibName: SearchWindowController.nibName)
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        configureFilter()
        configurePanel()
        
        itemTableController.selectionDelegate = selectionDelegate
    }
    
    override func showWindow(_ sender: Any?) {
        resetPanel()
        super.showWindow(sender)
    }
    
    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_DownArrow, kVK_UpArrow:
            itemTableController.triggerEvent(event)
        case kVK_Return:
            itemTableController.confirmSelection()
        default:
            keyEventDelegate?.handleEvent(event)
        }
    }

    func showRecentKaomojis(_ recentList: [String]) {
        let items = recentList.compactMap { content in
            kaomojiStore.allKaomojis.first(where: { $0.string == content })
        }
        if !items.isEmpty {
            itemTableController.refresh(items)
        }
    }
}

// MARK: - WindowDelegate
extension SearchWindowController: NSWindowDelegate {
    func windowDidResignKey(_ notification: Notification) {
        window?.orderOut(nil)
    }
}

// MARK: - Panel

private extension SearchWindowController {
    
    func resetPanel() {
        window?.setFrameOrigin(frameOrigin)
        window?.setContentSize(CGSize(width: 300.0, height: 200.0))
    }
    
    func configureFilter() {
        $query.combineLatest(kaomojiStore.$allKaomojis)
            .receive(on: DispatchQueue.main)
            .filter { !$0.0.isEmpty }
            .map { (query, items) -> [Kaomoji] in
                let normalized = query.lowercased()
                return items.filter { kaomoji in
                    kaomoji.tags.first { $0.contains(normalized) } != nil
                }
            }
            .sink { [weak self] items in
                self?.noResultTextField.isHidden = !items.isEmpty
                self?.itemTableController.refresh(items)
            }
            .store(in: &cancellables)
    }
    
    func configurePanel() {
        guard let panel = window else { return }
        
        panel.isMovable = true
        panel.collectionBehavior = [.ignoresCycle, .canJoinAllSpaces]
        panel.isMovableByWindowBackground = true
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.level = .screenSaver
        
        if let view = panel.contentView {
            view.wantsLayer = true
            view.layer?.cornerRadius = 8.0
        }
        
        searchImageView.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "A magnifying glass symbol")
        
        $query
            .sink { [weak self] query in
                self?.keywordTextField.stringValue = query
            }
            .store(in: &cancellables)
    }
}
