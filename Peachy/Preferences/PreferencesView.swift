import LaunchAtLogin
import SwiftUI

struct PreferencesView: View {
    @State private var triggerKey: String = ":"
    @State private var exceptions: [AppInformation] = [
        .init(name: "Xcode", bundleID: "com.apple.dt.Xcode")
    ]
    @State private var selectedApp: AppInformation?
    @ObservedObject private var launchAtLogin = LaunchAtLogin.observable
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .trailing, spacing: 8) {
                Text("Launch: ")
                Text("Trigger Key: ")
            }
            VStack(alignment: .leading, spacing: 6) {
                Toggle(isOn: $launchAtLogin.isEnabled) {
                    Text("Launch Peachy at Log In")
                }.toggleStyle(CheckboxToggleStyle())

                TextField("", text: $triggerKey)
                    .multilineTextAlignment(.center)
                    .frame(width: 50, height: 30)
                
                Text("Disable Peachy within these apps:")
                    .padding(.top, 16)
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(exceptions) { app in
                            Text(app.name)
                                .padding(8)
                                .frame(width: 300, alignment: .leading)
                                .background(app == selectedApp ?
                                            Color(NSColor.selectedTextBackgroundColor) :
                                                Color( NSColor.controlBackgroundColor))
                                .onTapGesture {
                                    selectedApp = app
                                }
                        }
                    }
                }
                .background(Color(NSColor.controlBackgroundColor))
                .frame(width: 300, height: 100, alignment: .leading)

                HStack(spacing: 2) {
                    Button("+") {
                        // TODO: show sheet to select app
                    }

                    Button("-") {
                        // TODO: remove selected app from exceptions
                    }
                }
                .font(.title3)
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
        .frame(width: 500, height: 300)
    }
}

struct AppInformation: Identifiable, Hashable {
    var id: String { bundleID }
    let name: String
    let bundleID: String
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
