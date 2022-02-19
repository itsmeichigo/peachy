import AppCenterCrashes
import LaunchAtLogin
import SwiftUI

struct PreferencesView: View {
    @State private var triggerKey: String
    @State private var exceptionAppIDs: [String]
    @State private var selectedAppIndex: Int?
    @State private var exceptionListInFocus: Bool = false
    @State private var crashReportsEnabled: Bool
    @FocusState private var triggerKeyFieldInFocus: Bool
    @ObservedObject private var launchAtLogin = LaunchAtLogin.observable

    private let preferences: AppPreferences
    
    init(preferences: AppPreferences) {
        self.preferences = preferences
        self.exceptionAppIDs = preferences.appExceptionIDs
        self.triggerKey = preferences.triggerKey
        self.crashReportsEnabled = !preferences.optOutCrashReports
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .trailing, spacing: 8) {
                Text("Launch: ")
                Text("Crash Reports: ")
                Text("Trigger Key: ")
                    .padding(.top, 22)
                Text("Blocked Apps: ")
                    .padding(.top, 8)
            }
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: $launchAtLogin.isEnabled) {
                    Text("Launch Peachy at Login")
                }.toggleStyle(CheckboxToggleStyle())

                Toggle(isOn: $crashReportsEnabled) {
                    Text("Anonymously let us know when the app crashes")
                        .fixedSize(horizontal: false, vertical: true)
                }
                .toggleStyle(CheckboxToggleStyle())
                .onChange(of: crashReportsEnabled) { enabled in
                    preferences.updateCrashReports(enabled)
                }

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
                        selectedAppIndex = nil
                    }
                }
                
                Text("Disable Peachy within these apps:")
                VStack(alignment: .leading, spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            ForEach(Array(exceptionAppIDs.enumerated()), id: \.1) { (index, appID) in
                                preferences.appExceptions[appID].map(Text.init)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .frame(width: 300, alignment: .leading)
                                    .foregroundColor(index == selectedAppIndex ? Color(NSColor.selectedMenuItemTextColor) : Color(NSColor.textColor))
                                    .background(index == selectedAppIndex ?
                                                Color(NSColor.controlAccentColor) :
                                                    Color(NSColor.windowBackgroundColor))
                                    .onTapGesture {
                                        selectedAppIndex = index
                                        triggerKeyFieldInFocus = false
                                        exceptionListInFocus = true
                                    }
                            }
                        }
                    }
                }
                .frame(width: 300, height: 100, alignment: .leading)
                .fixedSize()
                .background(Color(NSColor.windowBackgroundColor))
                .border(exceptionListInFocus ? Color(NSColor.selectedControlColor) : Color.clear, width: 4)
                .animation(.easeOut, value: exceptionListInFocus)
                .cornerRadius(4)
                
                HStack(spacing: 0) {
                    Button("+") {
                        triggerKeyFieldInFocus = false
                        openFileBrowser()
                    }
                    .help("Add a new app to the exception list")
                    .frame(width: 20, height: 20)

                    Button("−") {
                        guard let index = selectedAppIndex else {
                            return
                        }
                        preferences.updateAppExceptions(bundleID: exceptionAppIDs[index], name: nil)
                        exceptionAppIDs.remove(at: index)
                        selectedAppIndex = nil
                    }
                    .help("Remove the selected app from the exception list")
                    .keyboardShortcut(.delete, modifiers: [])
                    .frame(width: 20, height: 20)

                    Button("") {
                        guard let index = selectedAppIndex,
                              index < exceptionAppIDs.count - 1 else {
                            return
                        }
                        selectedAppIndex = index + 1
                    }
                    .keyboardShortcut(.downArrow, modifiers: [])

                    Button("") {
                        guard let index = selectedAppIndex,
                              index > 0 else {
                            return
                        }
                        selectedAppIndex = index - 1
                    }
                    .keyboardShortcut(.upArrow, modifiers: [])
                }
                .font(.title2)
                .buttonStyle(.borderless)
                .background(
                    Color(NSColor.controlColor)
                        .clipShape(Rectangle())
                        .cornerRadius(4)
                        .shadow(color: Color(NSColor.separatorColor), radius: 2, x: 0, y: 1)
                        .overlay(
                            Rectangle()
                                .frame(width: 1, height: 10)
                                .foregroundColor(Color(NSColor.separatorColor))
                        )
                )
            }
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 16)
        .frame(width: 500, height: 300)
    }

    private func openFileBrowser() {
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
                   let bundleID = Bundle(path: result.path)?.bundleIdentifier,
                   !exceptionAppIDs.contains(bundleID) {
                    exceptionAppIDs.append(bundleID)
                    preferences.updateAppExceptions(bundleID: bundleID, name: name)
                }
            } catch {}
            
        } else {
            // User clicked on "Cancel"
            return
        }
    }
}
