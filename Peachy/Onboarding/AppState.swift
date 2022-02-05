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

    var recentKaomojis: [String] {
        userDefaults.recentKaomojis ?? []
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

    func addToRecentKaomojis(content: String) {
        var recentList: [String] = []
        let cachedList = recentKaomojis
        if !cachedList.isEmpty {
            recentList = Array(
                cachedList
                    .filter { $0 != content }
                    .prefix(10)
            )
        }
        
        recentList.insert(content, at: 0)
        userDefaults.recentKaomojis = recentList
    }
}
