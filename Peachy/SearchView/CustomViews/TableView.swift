import AppKit

class TableView: NSTableView {
    override func keyDown(with event: NSEvent) {
        if let clipView = enclosingScrollView?.contentView as? ClipView,
           (125...126).contains(event.keyCode) && // down arrow and up arrow
            event.modifierFlags.intersection([.option, .shift]).isEmpty {
            clipView.isScrollAnimationEnabled = false
            super.keyDown(with: event)
            clipView.isScrollAnimationEnabled = true
        } else {
            super.keyDown(with: event)
        }
    }
}

class ClipView: NSClipView {
    
    var isScrollAnimationEnabled: Bool = true
    
    override func scroll(to newOrigin: NSPoint) {
        if isScrollAnimationEnabled {
            super.scroll(to: newOrigin)
        } else {
            setBoundsOrigin(newOrigin)
            documentView?.enclosingScrollView?.flashScrollers()
        }
    }
}
