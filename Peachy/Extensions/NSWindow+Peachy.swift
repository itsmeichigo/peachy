import Foundation
import AppKit

extension NSWindow {
    func applyCommonStyle() {
        styleMask = [.closable, .titled]
        collectionBehavior = [.fullScreenNone, .fullScreenAuxiliary, .fullScreenDisallowsTiling]
        standardWindowButton(.zoomButton)?.isEnabled = false
        center()
    }
}
