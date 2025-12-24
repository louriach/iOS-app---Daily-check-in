import Foundation

struct NotificationSettings {
    private static let notificationTimeKey = "notificationTime"
    private static let hasCompletedOnboardingKey = "hasCompletedOnboarding"
    private static let notificationIdentifierKey = "notificationIdentifier"
    
    static var notificationTime: DateComponents {
        get {
            if let data = UserDefaults.standard.data(forKey: notificationTimeKey),
               let components = try? JSONDecoder().decode(DateComponents.self, from: data) {
                return components
            }
            // Default to 9:00 PM
            return DateComponents(hour: 21, minute: 0)
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: notificationTimeKey)
            }
        }
    }
    
    static var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: hasCompletedOnboardingKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: hasCompletedOnboardingKey)
        }
    }
    
    static var notificationIdentifier: String {
        get {
            if let identifier = UserDefaults.standard.string(forKey: notificationIdentifierKey) {
                return identifier
            }
            let identifier = "dailyMoodCheckIn"
            UserDefaults.standard.set(identifier, forKey: notificationIdentifierKey)
            return identifier
        }
        set {
            UserDefaults.standard.set(newValue, forKey: notificationIdentifierKey)
        }
    }
}

extension DateComponents: Codable {
    enum CodingKeys: String, CodingKey {
        case hour, minute, second
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hour = try container.decodeIfPresent(Int.self, forKey: .hour)
        minute = try container.decodeIfPresent(Int.self, forKey: .minute)
        second = try container.decodeIfPresent(Int.self, forKey: .second)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(hour, forKey: .hour)
        try container.encodeIfPresent(minute, forKey: .minute)
        try container.encodeIfPresent(second, forKey: .second)
    }
}

