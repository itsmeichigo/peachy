import AppCenterCrashes
import LaunchAtLogin
import SwiftUI

struct GeneralSettingsView: View {
    @State private var triggerKey: String
    @State private var crashReportsEnabled: Bool
    @State private var usesDoubleKeyTrigger: Bool

    private let preferences: AppPreferences

    init(preferences: AppPreferences) {
        self.preferences = preferences
        self.triggerKey = preferences.triggerKey
        self.crashReportsEnabled = !preferences.optOutCrashReports
        self.usesDoubleKeyTrigger = preferences.usesDoubleTriggerKey
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            LaunchAtLogin.Toggle("Launch Peachy at Login")
                .toggleStyle(CheckboxToggleStyle())

            Toggle(isOn: $crashReportsEnabled) {
                Text("Anonymously let us know when the app crashes")
                    .fixedSize(horizontal: false, vertical: true)
            }
            .toggleStyle(CheckboxToggleStyle())
            .onChange(of: crashReportsEnabled) { enabled in
                preferences.updateCrashReports(enabled)
                Crashes.enabled = enabled
            }

            HStack(alignment: .top, spacing: 6) {
                Text("Trigger Key: ")
                    .padding(.top, 8)
                VStack(alignment: .leading, spacing: 3) {
                    HStack(alignment: .center, spacing: 8) {
                        TextField("", text: $triggerKey, onCommit: {
                            updateTriggerKeyIfAppropriate()
                        })
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .frame(width: 40, height: 30)
                        .onDisappear {
                            updateTriggerKeyIfAppropriate()
                        }

                        Toggle(isOn: $usesDoubleKeyTrigger) {
                            Text("Use double key trigger")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .toggleStyle(CheckboxToggleStyle())
                        .onChange(of: usesDoubleKeyTrigger) { enabled in
                            preferences.updateUsesDoubleTriggerKey(enabled)
                        }
                    }

                    Text("Activate Peachy by typing this key preceding a keyword to search for kaomojis.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func updateTriggerKeyIfAppropriate() {
        if triggerKey.count > 1 || triggerKey.isEmpty {
            triggerKey = preferences.triggerKey
        } else {
            preferences.updateTriggerKey(triggerKey)
        }
    }
}

