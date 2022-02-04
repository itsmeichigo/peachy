import Foundation
import SwiftUI

enum OnboardingPage: CaseIterable {
    case welcome
    case permission
    case pilot
    
    static let freshOnboarding = OnboardingPage.allCases
    static let needsPermission: [OnboardingPage] = [.permission, .pilot]
}
