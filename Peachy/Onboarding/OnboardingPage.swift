import Foundation
import SwiftUI

enum OnboardingPage: CaseIterable {
    case permission
    case settings
    
    static let freshOnboarding = OnboardingPage.allCases
    
    var view: some View {
        switch self {
        case .permission:
            return PermissionView().eraseToAnyView()
        case .settings:
            return SettingsView().eraseToAnyView()
        }
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
