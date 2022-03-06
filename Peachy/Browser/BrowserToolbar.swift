import Foundation
import AppKit

extension NSImage.Name {
    static let sidebar = "sidebar.squares.leading"
}

extension NSToolbarItem.Identifier {
    static let sidebar = NSToolbarItem.Identifier(rawValue: "SideBar")
}

extension NSToolbar {
    static let browserToolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "BrowserToolbar")
        toolbar.displayMode = .iconOnly
        
        return toolbar
    }()
}

extension AppDelegate: NSToolbarDelegate {
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.sidebar]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [.sidebar]
    }
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        switch itemIdentifier {
        case NSToolbarItem.Identifier.sidebar:
            let button = NSButton(image: NSImage(systemSymbolName: .sidebar, accessibilityDescription: "Side bar icon")!, target: nil, action: #selector(toggleSidebar))
            button.bezelStyle = .texturedRounded
            return customToolbarItem(itemIdentifier: .sidebar, label: "Sidebar", paletteLabel: "Sidebar", toolTip: "Toggle sidebar", itemContent: button)
        default:
            return nil
        }
    }

    @objc func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    func customToolbarItem(
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
