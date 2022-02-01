import Foundation

typealias AppExceptions = [String: String]

final class AppPreferences {
    private let userDefaults: UserDefaults

    var triggerKey: String {
        get {
            userDefaults.string(forKey: Constants.triggerKeyPreferencesKey) ?? Constants.defaultTriggerKey
        }
    }

    var appExceptions: AppExceptions {
        get {
            userDefaults.dictionary(forKey: Constants.appExceptionsPreferencesKey) as? AppExceptions ?? Constants.defaultAppExceptions
            
        }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func updateTriggerKey(_ key: String) {
        userDefaults.set(key, forKey: Constants.triggerKeyPreferencesKey)
    }

    func updateAppExceptions(_ exceptions: AppExceptions) {
        userDefaults.set(exceptions, forKey: Constants.triggerKeyPreferencesKey)
    }
}

extension AppPreferences {
    private enum Constants {
        static let triggerKeyPreferencesKey = "com.ichigo.peachy.trigger-key"
        static let appExceptionsPreferencesKey = "com.ichigo.peachy.exceptions"
        static let defaultTriggerKey = ":"
        static let defaultAppExceptions = [
            "com.apple.dt.Xcode": "Xcode"
        ]
    }
}
