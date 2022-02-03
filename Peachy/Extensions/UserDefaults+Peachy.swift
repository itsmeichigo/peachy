import Foundation

extension UserDefaults {
    static let peachyDefaults = UserDefaults(suiteName: .userDefaultsSuiteName)!
    
    @objc dynamic var currentAppStateValue: Int {
        get {
            integer(forKey: .appStateKey)
        }
        
        set {
            set(newValue, forKey: .appStateKey)
        }
    }

    @objc dynamic var triggerKey: String? {
        get {
            string(forKey: .triggerKeyPreferencesKey)
        }

        set {
            set(newValue, forKey: .triggerKeyPreferencesKey)
        }
    }

    @objc dynamic var appExceptions: AppExceptions? {
        get {
            dictionary(forKey: .appExceptionsPreferencesKey) as? AppExceptions
        }

        set {
            set(newValue, forKey: .appExceptionsPreferencesKey)
        }
    }

    @objc dynamic var appExceptionIDs: [String]? {
        get {
            stringArray(forKey: .appIDsPreferencesKey)
        }

        set {
            set(newValue, forKey: .appIDsPreferencesKey)
        }
    }
}

private extension String {
    static let userDefaultsSuiteName = "com.ichigo.peachy.UserDefaults"
    static let appStateKey = "com.ichigo.peachy.current-app-state"
    static let triggerKeyPreferencesKey = "com.ichigo.peachy.trigger-key"
    static let appIDsPreferencesKey = "com.ichigo.peachy.exception-ids"
    static let appExceptionsPreferencesKey = "com.ichigo.peachy.exceptions"
}
