import Cocoa
import Foundation

enum AppState: Int {
    case fresh
    case newVersion
    case upToDate

    var needsOnboarding: Bool {
        return self != .upToDate
    }

    static var hasAXPermission: Bool {
        let checkOptions = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: false] as CFDictionary
        return AXIsProcessTrustedWithOptions(checkOptions)
    }
}

final class AppStateManager {

    var currentState: AppState {
        return AppState(rawValue: userDefaults.currentAppStateValue) ?? .fresh
    }

    private let userDefaults: UserDefaults
    init(userDefaults: UserDefaults = .peachyDefaults) {
        self.userDefaults = userDefaults
    }

    func updateDoneState() {
        userDefaults.currentAppStateValue = AppState.upToDate.rawValue
    }

    func resetState() {
        userDefaults.currentAppStateValue = AppState.fresh.rawValue
    }
}
