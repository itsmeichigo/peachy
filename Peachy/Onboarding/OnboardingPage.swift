import Foundation
import SwiftUI

enum OnboardingPage: CaseIterable {
    case welcome
    case permission
    case settings
    
    static let freshOnboarding = OnboardingPage.allCases
}
