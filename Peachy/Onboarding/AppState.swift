import Cocoa
import Foundation

enum AppState: Int {
    case fresh
    case newVersion
    case upToDate

    var needsOnboarding: Bool {
        return self != .upToDate
    }

    var hasAXPermission: Bool {
        let checkOptions = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false] as CFDictionary
        return AXIsProcessTrustedWithOptions(checkOptions)
    }
    
    static var current: AppState {
        return AppState(rawValue: UserDefaults.peachyDefaults.currentAppStateValue) ?? .fresh
    }
    
    static func updateDoneState() {
        UserDefaults.peachyDefaults.currentAppStateValue = AppState.upToDate.rawValue
    }
    
    static func resetState() {
        UserDefaults.peachyDefaults.currentAppStateValue = AppState.fresh.rawValue
    }
}
