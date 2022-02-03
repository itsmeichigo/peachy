import Foundation
import SwiftUI

enum OnboardingPage: CaseIterable {
    case permission
    case settings
    
    static let freshOnboarding = OnboardingPage.allCases
    
    @ViewBuilder
    var view: some View {
        switch self {
        case .permission:
            PermissionView()
        case .settings:
            SettingsView()
        }
    }
}
