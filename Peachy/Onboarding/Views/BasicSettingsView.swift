import SwiftUI

struct BasicSettingsView: View {
    private let preferences: AppPreferences
    private let onComplete: () -> Void

    init(preferences: AppPreferences, onComplete: @escaping () -> Void) {
        self.preferences = preferences
        self.onComplete = onComplete
    }

    var body: some View {
        VStack(spacing: 40) {
            Text("Basic Settings")
                .font(.largeTitle)
            
            GeneralSettingsView(preferences: preferences)
                .padding(.horizontal, 24)

            Spacer()

            Button("Save Settings", action: onComplete)
                .buttonStyle(OnboardingButton())

        }
        .padding(32)
    }
}
