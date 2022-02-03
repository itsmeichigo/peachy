//
//  OnboardingPage.swift
//  cmd
//
//  Created by Huong Do on 03/03/2021.
//

import Foundation
import SwiftUI

enum OnboardingPage: CaseIterable {
  case welcome
  case feature
  case permission
  case settings
  
  static let freshOnboarding = OnboardingPage.allCases
  
  var shouldShowPreviousButton: Bool {
    switch self {
    case .feature, .permission, .settings:
      return true
    case .welcome:
      return false
    }
  }
  
  var shouldShowNextButton: Bool {
    switch self {
    case .welcome, .feature, .permission:
      return true
    case .settings:
      return false
    }
  }
  
  var view: some View {
    switch self {
    case .welcome:
      return WelcomeView().eraseToAnyView()
    case .feature:
      return FeatureView().eraseToAnyView()
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
