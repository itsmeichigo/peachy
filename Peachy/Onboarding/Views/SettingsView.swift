import SwiftUI

struct SettingsView: View {
    var body: some View {
        Text("Some basic settings to get started")
        Button(action: {
            AppState.updateDoneState()
            relaunch()
        }, label: {
            Text("Relaunch 🚀")
        })
    }
    
    func relaunch() {
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        
        NSWorkspace.shared.openApplication(at: Bundle.main.bundleURL, configuration: configuration) {
            _, error in
            DispatchQueue.main.async {
                if let error = error {
                    NSApp.presentError(error)
                    return
                }
                NSApp.terminate(self)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
