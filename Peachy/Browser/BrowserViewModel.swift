import Combine
import Foundation
import AppKit
import SwiftUI

final class BrowserViewModel: NSObject, ObservableObject {
    private let appStateManager: AppStateManager
    private let kaomojiStore: KaomojiStore
    private var subscriptions: Set<AnyCancellable> = []

    private let searchItem = NSSearchToolbarItem(itemIdentifier: .browserSearch)
    
    weak var parentWindow: NSWindow? {
        didSet {
            updateContentTitle()
        }
    }

    init(appStateManager: AppStateManager) {
        self.appStateManager = appStateManager
        self.kaomojiStore = .shared
        super.init()
        updateKaomojiList()
        configureSearchItem()
    }

    @Published private(set) var query: String = ""
    @Published private(set) var displayMode: BrowserDisplayMode = .grid
    @Published var selectedTag: String?
    @Published var kaomojis: [Kaomoji] = []
    let kaomojiTags: [String] = {
        [""] + KaomojiTags.all
    }()

    func makeSearchFieldResignFirstResponder() {
        parentWindow?.makeFirstResponder(nil)
    }

    static func copyToPasteBoard(content: String) {
        let pasteBoard = NSPasteboard.general
        pasteBoard.clearContents()
        pasteBoard.writeObjects([content as NSString])
    }

    private func updateKaomojiList() {
        kaomojiStore.$allKaomojis.combineLatest($query, $selectedTag)
            .map { items, query, tag -> [Kaomoji] in
                if !query.isEmpty {
                    let normalized = query.lowercased()
                    return items.filter { $0.tags.first { $0.contains(normalized) } != nil }
                } else if let tag = tag, !tag.isEmpty {
                    return items.filter { $0.tags.contains(tag) }
                } else {
                    return items
                }
            }
            .assign(to: &$kaomojis)
    }

    private func updateContentTitle() {
        $query.combineLatest($selectedTag)
            .map { query, tag -> String in
                if !query.isEmpty {
                    return "Search all"
                } else if let tag = tag, !tag.isEmpty {
                    return "#\(tag)"
                } else {
                    return "All"
                }
            }
            .sink { [weak self] title in
                self?.parentWindow?.title = title
            }
            .store(in: &subscriptions)

        $kaomojis
            .map { "\($0.count) items" }
            .sink { [weak self] content in
                self?.parentWindow?.subtitle = content
            }
            .store(in: &subscriptions)
    }

    private func configureSearchItem() {
        searchItem.searchField.addConstraint(NSLayoutConstraint(item: searchItem.searchField, attribute: .width, relatedBy: .lessThanOrEqual, toItem: nil, attribute: .width, multiplier: 1, constant: 200) )
        searchItem.searchField.delegate = self
    }
}

extension BrowserViewModel: NSSearchFieldDelegate {
    func controlTextDidChange(_ notification: Notification) {
        guard let field = notification.object as? NSSearchField, field == searchItem.searchField else { return }
        query = field.stringValue
    }
}

extension BrowserViewModel: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        if #available(macOS 12, *) {
            return [.browserSidebar, .browserDisplayMode, .browserSearch]
        } else {
            return [.browserSidebar, .flexibleSpace, .browserSearch]
        }
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        if #available(macOS 12, *) {
            return [.browserSidebar, .browserDisplayMode, .browserSearch]
        } else {
            return [.browserSidebar, .flexibleSpace, .browserSearch]
        }
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case .browserSidebar:
            let button = NSButton(image: NSImage(systemSymbolName: .sidebar, accessibilityDescription: "Side bar icon")!, target: self, action: #selector(toggleSidebar))
            button.bezelStyle = .texturedRounded
            let item = customToolbarItem(itemIdentifier: itemIdentifier, label: "Sidebar", paletteLabel: "Sidebar", toolTip: "Toggle sidebar", itemContent: button)
            item?.isNavigational = true
            return item
        case .flexibleSpace:
            return NSToolbarItem(itemIdentifier: .space)
        case .browserSearch:
            return searchItem
        case .browserDisplayMode:
            let images: [NSImage] = BrowserDisplayMode.allCases.map(\.iconImage)
            let labels: [String] = BrowserDisplayMode.allCases.map(\.label)
            let toolbarItem = NSToolbarItemGroup(itemIdentifier: itemIdentifier, images: images, selectionMode: .selectOne, labels: labels, target: self, action: #selector(toolbarPickerDidSelectItem))
            toolbarItem.label = "Display Mode"
            toolbarItem.paletteLabel = "Display Mode"
            toolbarItem.toolTip = "Change the display mode"
            toolbarItem.selectedIndex = 0
            return toolbarItem
        default:
            return nil
        }
    }

    @objc
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    @objc private func toolbarPickerDidSelectItem(sender: Any) {
        if let toolbarItemGroup = sender as? NSToolbarItemGroup {
            displayMode = BrowserDisplayMode(rawValue: toolbarItemGroup.selectedIndex) ?? .grid
        }
    }

    private func customToolbarItem(
        itemIdentifier: NSToolbarItem.Identifier,
        label: String,
        paletteLabel: String,
        toolTip: String,
        itemContent: NSButton) -> NSToolbarItem? {
        
        let toolbarItem = NSToolbarItem(itemIdentifier: itemIdentifier)
        
        toolbarItem.label = label
        toolbarItem.paletteLabel = paletteLabel
        toolbarItem.toolTip = toolTip
        
        toolbarItem.view = itemContent
        
        // We actually need an NSMenuItem here, so we construct one.
        let menuItem: NSMenuItem = NSMenuItem()
        menuItem.submenu = nil
        menuItem.title = label
        toolbarItem.menuFormRepresentation = menuItem
        
        return toolbarItem
    }

}

enum BrowserDisplayMode: Int, CaseIterable {
    case grid
    case list

    var iconImage: NSImage {
        switch self {
        case .grid:
            return NSImage(systemSymbolName: .grid, accessibilityDescription: "Grid icon")!
        case .list:
            return NSImage(systemSymbolName: .list, accessibilityDescription: "List icon")!
        }
    }

    var label: String {
        switch self {
        case .grid:
            return "Grid"
        case .list:
            return "List"
        }
    }
}
