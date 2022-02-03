import SwiftUI

struct PermissionView: View {
    var body: some View {
        Text("Peachy needs Accessibility access.")
            .font(.title)
        
        Button("Open System Preferences") {
            NSWorkspace.shared.open(
                URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
}

struct PermissionView_Previews: PreviewProvider {
    static var previews: some View {
        PermissionView()
    }
}
