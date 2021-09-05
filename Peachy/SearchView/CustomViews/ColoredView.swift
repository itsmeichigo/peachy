import AppKit

@IBDesignable class ColoredView: NSView {
    @IBInspectable var backgroundColor: NSColor = .clear
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        backgroundColor.set()
        dirtyRect.fill()
    }
}
