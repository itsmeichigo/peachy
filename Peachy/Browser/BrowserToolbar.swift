import Foundation
import AppKit

extension NSImage.Name {
    static let sidebar = "sidebar.squares.leading"
    static let grid = "square.grid.2x2"
    static let list = "list.bullet"
}

extension NSToolbarItem.Identifier {
    static let browserSidebar = NSToolbarItem.Identifier(rawValue: "BrowserSideBar")
    static let browserSearch = NSToolbarItem.Identifier(rawValue: "BrowserSearch")
    static let browserDisplayMode = NSToolbarItem.Identifier(rawValue: "BrowserDisplayMode")
}

extension NSToolbar {
    static let browserToolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "BrowserToolbar")
        toolbar.displayMode = .iconOnly
        
        return toolbar
    }()
}
