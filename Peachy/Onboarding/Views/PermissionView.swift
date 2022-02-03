import SwiftUI

struct PermissionView: View {
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image("peach-colored")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 24)
                Text("Let's get started")
                    .font(.largeTitle)
            }
            .padding(.bottom, 24)
            
            Text("Peachy needs access to your computer's Accessibility features to work.")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(width: 320)

            Image("accessibility")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 320)
            
            Button("Grant Access") {
                NSWorkspace.shared.open(
                    URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
            }
        }
    }
}

struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView()
    }
}
