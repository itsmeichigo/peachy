import SwiftUI

struct PreferencesView: View {
    @State private var currentSection: Int = 0
    private let preferences: AppPreferences
    
    init(preferences: AppPreferences) {
        self.preferences = preferences
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
                GeneralSettingsView(preferences: preferences)
            case .some(.blockedApps):
                AppExceptionsView(preferences: preferences)
            default:
                EmptyView()
            }

            Spacer()
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 40)
        .frame(width: 400, height: 300)
        .background(Color(NSColor.windowBackgroundColor))
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
