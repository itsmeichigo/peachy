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

    @objc dynamic var recentKaomojis: [String]? {
        get {
            stringArray(forKey: .recentKaomojisPreferencesKey)
        }

        set {
            set(newValue, forKey: .recentKaomojisPreferencesKey)
        }
    }

    @objc dynamic var optOutCrashReports: Bool {
        get {
            bool(forKey: .optOutCrashReportsPreferencesKey)
        }
        set {
            set(newValue, forKey: .optOutCrashReportsPreferencesKey)
        }
    }

    @objc dynamic var usesDoubleTriggerKey: Bool {
        get {
            bool(forKey: .usesDoubleKeyTriggerPreferencesKey)
        }
        set {
            set(newValue, forKey: .usesDoubleKeyTriggerPreferencesKey)
        }
    }
}

private extension String {
    static let userDefaultsSuiteName = "com.ichigo.peachy.UserDefaults"
    static let appStateKey = "com.ichigo.peachy.current-app-state"
    static let triggerKeyPreferencesKey = "com.ichigo.peachy.trigger-key"
    static let appIDsPreferencesKey = "com.ichigo.peachy.exception-ids"
    static let appExceptionsPreferencesKey = "com.ichigo.peachy.exceptions"
    static let recentKaomojisPreferencesKey = "com.ichigo.peachy.recent-kaomojis"
    static let optOutCrashReportsPreferencesKey = "com.ichigo.peachy.crash-reports-enabled"
    static let usesDoubleKeyTriggerPreferencesKey = "com.ichigo.peachy.uses-double-key-trigger"
}
