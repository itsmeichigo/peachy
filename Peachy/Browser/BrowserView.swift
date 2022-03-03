import SwiftUI

struct BrowserView: View {
    var body: some View {
        HStack {
            Text("Tags")
            Text("Grid")
        }
        .frame(width: 640, height: 480)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
