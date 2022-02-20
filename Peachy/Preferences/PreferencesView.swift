import AppCenterCrashes
import LaunchAtLogin
import SwiftUI

struct PreferencesView: View {
    @State private var triggerKey: String
    @State private var exceptionAppIDs: [String]
    @State private var selectedAppIndex: Int?
    @State private var crashReportsEnabled: Bool

    @State private var currentSection: Int = 0
    @State private var exceptionListInFocus: Bool = false
    @ObservedObject private var launchAtLogin = LaunchAtLogin.observable

    private let preferences: AppPreferences
    
    init(preferences: AppPreferences) {
        self.preferences = preferences
        self.exceptionAppIDs = preferences.appExceptionIDs
        self.triggerKey = preferences.triggerKey
        self.crashReportsEnabled = !preferences.optOutCrashReports
    }

    var body: some View {
        VStack(spacing: 32) {
            Picker("Preferences", selection: $currentSection) {
                ForEach(Section.allCases) { section in
                    Text(section.name).tag(section.rawValue)
                }
            }
            .labelsHidden()
            .pickerStyle(.segmented)
            .fixedSize()

            switch Section(rawValue: currentSection) {
            case .some(.general):
                generalSettings
            case .some(.blockedApps):
                blockedApps
            default:
                EmptyView()
            }

            Spacer()
        }
        .onChange(of: currentSection) { _ in
            exceptionListInFocus = false
            selectedAppIndex = nil
        }
        .padding(.vertical, 32)
        .padding(.horizontal, 40)
        .frame(width: 500, height: 300)
    }
    
    private var generalSettings: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                Crashes.enabled = enabled
            }

            HStack(alignment: .center, spacing: 8) {
                Text("Trigger Key: ")
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
            }
        }
    }

    private var blockedApps: some View {
        VStack(alignment: .leading) {
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

private extension PreferencesView {
    enum Section: Int, CaseIterable, Identifiable {
        case general
        case blockedApps

        var id: Int {
            rawValue
        }

        var name: String {
            switch self {
            case .general:
                return "General"
            case .blockedApps:
                return "Exclusions"
            }
        }
    }
}
