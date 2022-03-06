import Foundation
import AppKit

extension NSImage.Name {
    static let sidebar = "sidebar.squares.leading"
}

extension NSToolbarItem.Identifier {
    static let sidebar = NSToolbarItem.Identifier(rawValue: "SideBar")
    static let search = NSToolbarItem.Identifier(rawValue: "Search")
}

extension NSToolbar {
    static let browserToolbar: NSToolbar = {
        let toolbar = NSToolbar(identifier: "BrowserToolbar")
        toolbar.displayMode = .iconOnly
        
        return toolbar
    }()
}
