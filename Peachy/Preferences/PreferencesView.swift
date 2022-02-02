import LaunchAtLogin
import SwiftUI

struct PreferencesView: View {
    @State private var triggerKey: String
    @State private var exceptions: AppExceptions
    @State private var selectedAppBundleID: String?
    @State private var exceptionListInFocus: Bool = false
    @FocusState private var triggerKeyFieldInFocus: Bool
    @ObservedObject private var launchAtLogin = LaunchAtLogin.observable

    private let preferences: AppPreferences
    
    init(preferences: AppPreferences) {
        self.preferences = preferences
        self.exceptions = preferences.appExceptions
        self.triggerKey = preferences.triggerKey
    }

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

                TextField("", text: $triggerKey, onCommit: {
                    if triggerKey.count > 1 || triggerKey.isEmpty {
                        triggerKey = preferences.triggerKey
                    } else {
                        preferences.updateTriggerKey(triggerKey)
                    }
                })
                .font(.headline)
                .multilineTextAlignment(.center)
                .frame(width: 40, height: 30)
                .focused($triggerKeyFieldInFocus)
                .onChange(of: triggerKeyFieldInFocus) { newValue in
                    if newValue {
                        exceptionListInFocus = false
                    }
                }
                
                Text("Disable Peachy within these apps:")
                    .padding(.top, 10)
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(exceptions.sorted(by: >), id: \.key) { (id, name) in
                                Text(name)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .frame(width: 300, alignment: .leading)
                                    .background(id == selectedAppBundleID ?
                                                Color(NSColor.controlAccentColor) :
                                                    Color( NSColor.controlBackgroundColor))
                                    .onTapGesture {
                                        selectedAppBundleID = id
                                        triggerKeyFieldInFocus = false
                                        exceptionListInFocus = true
                                    }
                            }
                        }
                    }
                }
                .frame(width: 300, height: 100, alignment: .leading)
                .fixedSize()
                .background(Color(NSColor.controlBackgroundColor))
                .border(exceptionListInFocus ? Color(NSColor.selectedControlColor) : Color.clear, width: 4)
                .animation(.easeOut, value: exceptionListInFocus)
                .cornerRadius(4)
                
                HStack(spacing: 8) {
                    Button("+") {
                        openFileBrowser()
                    }
                    .help("Add a new app to the exception list")

                    Button("−") {
                        guard let selectedAppBundleID = selectedAppBundleID else {
                            return
                        }
                        exceptions.removeValue(forKey: selectedAppBundleID)
                        preferences.updateAppExceptions(exceptions)
                    }
                    .help("Remove the selected app from the exception list")
                    .keyboardShortcut(.delete, modifiers: [])
                }
                .font(.title2)
                .buttonStyle(.borderless)
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
        .frame(width: 500, height: 300)
    }

    func openFileBrowser() {
        let dialog = NSOpenPanel();
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = false
        dialog.canChooseDirectories = false
        dialog.allowedContentTypes = [.application]
        dialog.directoryURL = URL(string: "/Applications/")
        
        if dialog.runModal() ==  NSApplication.ModalResponse.OK,
           let result = dialog.url {
            do {
                let values = try result.resourceValues(forKeys: [.localizedNameKey])
                if let name = values.localizedName,
                   let bundle = Bundle(path: result.path)?.bundleIdentifier {
                    exceptions[bundle] = name
                    preferences.updateAppExceptions(exceptions)
                }
            } catch {}
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}
