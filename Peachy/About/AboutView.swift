import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack {
            Image("small-icon")
                .resizable()
                .frame(width: 120, height: 120)
            HStack {
                Text("Peachy")
                    .font(.title)
                    .bold()
                Button(action: {
                    let url = URL(string: Links.websiteURL)!
                    NSWorkspace.shared.open(url)
                }, label: {
                    Image(systemName: "info.circle.fill")
                })
                .buttonStyle(.plain)
                .font(.title2)
            }

            Text("Version \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)")
                .foregroundColor(.secondary)

            Spacer()
            Text("© 2022 Huong Do. All rights reserved.")
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(width: 320, height: 240)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
