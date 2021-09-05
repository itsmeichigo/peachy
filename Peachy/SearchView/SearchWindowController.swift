import Carbon
import Cocoa
import Combine

class SearchWindowController: NSWindowController {
    
    @Published var query = ""
    var frameOrigin: NSPoint = .zero
    
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
        
        itemTableController.selectionDelegate = self
    }
    
    override func showWindow(_ sender: Any?) {
        resetPanel()
        super.showWindow(sender)
    }
    
    func handleEvent(_ event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_DownArrow, kVK_UpArrow:
            itemTableController.triggerEvent(event)
        case kVK_Return:
            itemTableController.confirmSelection()
        case kVK_Escape:
            window?.orderOut(nil)
        default:
            break
        }
    }
}

// MARK: - WindowDelegate
extension SearchWindowController: NSWindowDelegate {
    func windowDidResignKey(_ notification: Notification) {
        window?.orderOut(nil)
    }
}

// MARK: - ItemSelectionDelegate

extension SearchWindowController: ItemSelectionDelegate {
    func handleSelection(_ item: Kaomoji) {
        window?.orderOut(nil)
        // TODO: paste kaomoji
    }
}

// MARK: - Close on ESC and other cancelation hotkeys

extension SearchWindowController {
    override func cancelOperation(_ sender: Any?) {
        window?.orderOut(nil)
    }
}

// MARK: - Panel

private extension SearchWindowController {
    
    func resetPanel() {
        query = ""
        window?.setFrameOrigin(frameOrigin)
    }
    
    func configureFilter() {
        $query.combineLatest(kaomojiStore.$allKaomojis)
            .receive(on: DispatchQueue.main)
            .map { (query, items) -> [Kaomoji] in
                guard !query.isEmpty else {
                    return []
                }
                
                let normalized = query.lowercased().replacingOccurrences(of: ":", with: "")
                return items.filter { kaomoji in
                    kaomoji.description?.contains(normalized) == true ||
                    kaomoji.tags.first { $0.contains(normalized) } != nil ||
                    kaomoji.aliases?.first { $0.contains(normalized) } != nil
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
        panel.setContentSize(CGSize(width: 250.0, height: 200.0))
        
        if let view = panel.contentView {
            view.wantsLayer = true
            view.layer?.cornerRadius = 8.0
        }
        
        panel.makeKeyAndOrderFront(self)
        panel.orderFrontRegardless()
        
        searchImageView.image = NSImage(systemSymbolName: "magnifyingglass", accessibilityDescription: "A magnifying glass symbol")
        
        $query.sink { [weak self] query in
            self?.keywordTextField.stringValue = query.replacingOccurrences(of: ":", with: "")
        }.store(in: &cancellables)
    }
}
