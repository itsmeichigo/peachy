import Foundation

typealias AppExceptions = [String: String]

final class AppPreferences {
    private let userDefaults: UserDefaults

    var triggerKey: String {
        userDefaults.string(forKey: Constants.triggerKeyPreferencesKey) ?? Constants.defaultTriggerKey
    }

    var appExceptions: AppExceptions {
        userDefaults.dictionary(forKey: Constants.appExceptionsPreferencesKey) as? AppExceptions ?? Constants.defaultAppExceptions
    }

    var appExceptionIDs: [String] {
        userDefaults.stringArray(forKey: Constants.appIDsPreferencesKey) ?? Constants.defaultAppExceptions.keys.sorted()
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func updateTriggerKey(_ key: String) {
        userDefaults.set(key, forKey: Constants.triggerKeyPreferencesKey)
    }

    func updateAppExceptions(bundleID: String, name: String?) {
        var updatedExceptions = appExceptions
        var updatedIDs = appExceptionIDs
        if let name = name {
            guard !updatedIDs.contains(bundleID) else {
                return
            }
            updatedExceptions[bundleID] = name
            updatedIDs.append(bundleID)
        } else {
            updatedExceptions.removeValue(forKey: bundleID)
            updatedIDs.removeAll(where: { $0 == bundleID })
        }
        userDefaults.set(updatedExceptions, forKey: Constants.appExceptionsPreferencesKey)
        userDefaults.set(updatedIDs, forKey: Constants.appIDsPreferencesKey)
    }
}

extension AppPreferences {
    private enum Constants {
        static let triggerKeyPreferencesKey = "com.ichigo.peachy.trigger-key"
        static let appIDsPreferencesKey = "com.ichigo.peachy.exception-ids"
        static let appExceptionsPreferencesKey = "com.ichigo.peachy.exceptions"
        static let defaultTriggerKey = ":"
        static let defaultAppExceptions = [
            "com.apple.dt.Xcode": "Xcode"
        ]
    }
}
