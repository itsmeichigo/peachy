import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Image("small-icon")
            Text("Peachy")
                .font(.title)
                .bold()
            Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)")
                .foregroundColor(.secondary)
        }
        .frame(width: 320, height: 240)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
