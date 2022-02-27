import Foundation

typealias AppExceptions = [String: String]

final class AppPreferences {
    private let userDefaults: UserDefaults

    var triggerKey: String {
        userDefaults.triggerKey ?? Constants.defaultTriggerKey
    }

    var appExceptions: AppExceptions {
        userDefaults.appExceptions ?? Constants.defaultAppExceptions
    }

    var appExceptionIDs: [String] {
        userDefaults.appExceptionIDs ?? Constants.defaultAppExceptions.keys.sorted()
    }

    var optOutCrashReports: Bool {
        userDefaults.optOutCrashReports
    }

    var usesDoubleTriggerKey: Bool {
        userDefaults.usesDoubleTriggerKey
    }

    init(userDefaults: UserDefaults = .peachyDefaults) {
        self.userDefaults = userDefaults
    }

    func updateTriggerKey(_ key: String) {
        userDefaults.triggerKey = key
    }

    func updateAppExceptions(bundleID: String, name: String?) {
        var updatedExceptions = appExceptions
        var updatedIDs = appExceptionIDs
        if let name = name {
            updatedExceptions[bundleID] = name
            updatedIDs.append(bundleID)
        } else {
            updatedExceptions.removeValue(forKey: bundleID)
            updatedIDs.removeAll(where: { $0 == bundleID })
        }
        userDefaults.appExceptions = updatedExceptions
        userDefaults.appExceptionIDs = updatedIDs
    }

    func updateCrashReports(_ enabled: Bool) {
        userDefaults.optOutCrashReports = !enabled
    }

    func updateUsesDoubleTriggerKey(_ enabled: Bool) {
        userDefaults.usesDoubleTriggerKey = enabled
    }
}

private extension AppPreferences {
    enum Constants {
        static let defaultTriggerKey = ":"
        static let defaultAppExceptions = [
            "com.apple.dt.Xcode": "Xcode",
            "com.apple.Terminal": "Terminal"        ]
    }
}
