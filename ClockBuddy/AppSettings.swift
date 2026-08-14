import SwiftUI
import Observation

@Observable
final class AppSettings {
    static let windowScaleRange: ClosedRange<CGFloat> = 0.2...2.0
    static let analogWindowBaseSize: CGFloat = 190
    static let timerSetupMinimumSize = CGSize(width: 220, height: 120)

    private let defaults: UserDefaults
    
    var isAnalog: Bool {
        didSet { defaults.set(isAnalog, forKey: "isAnalog") }
    }
    
    var showSecondsHand: Bool {
        didSet { defaults.set(showSecondsHand, forKey: "showSecondsHand") }
    }
    
    var showSecondsDigital: Bool {
        didSet { defaults.set(showSecondsDigital, forKey: "showSecondsDigital") }
    }
    
    var blinkColon: Bool {
        didSet { defaults.set(blinkColon, forKey: "blinkColon") }
    }
    
    var windowOpacity: Double {
        didSet { defaults.set(windowOpacity, forKey: "windowOpacity") }
    }
    
    var windowScale: CGFloat {
        didSet { defaults.set(windowScale, forKey: "windowScale") }
    }
    
    var timeFontSize: CGFloat {
        didSet { defaults.set(timeFontSize, forKey: "timeFontSize") }
    }

    var timeFontSizeDuringTimer: CGFloat {
        didSet { defaults.set(timeFontSizeDuringTimer, forKey: "timeFontSizeDuringTimer") }
    }
    
    var dateFontSize: CGFloat {
        didSet { defaults.set(dateFontSize, forKey: "dateFontSize") }
    }
    
    var urgentEventThreshold: Int {
        didSet { defaults.set(urgentEventThreshold, forKey: "urgentEventThreshold") }
    }
    
    var showYear: Bool {
        didSet { defaults.set(showYear, forKey: "showYear") }
    }
    
    var eventNameLength: Int {
        didSet { defaults.set(eventNameLength, forKey: "eventNameLength") }
    }
    
    var eventFontSize: CGFloat {
        didSet { defaults.set(eventFontSize, forKey: "eventFontSize") }
    }
    
    var showNoEventMessage: Bool {
        didSet { defaults.set(showNoEventMessage, forKey: "showNoEventMessage") }
    }
    
    var blinkBeforeEvent: Bool {
        didSet { defaults.set(blinkBeforeEvent, forKey: "blinkBeforeEvent") }
    }

    var isTimerEnabled: Bool {
        didSet { defaults.set(isTimerEnabled, forKey: "isTimerEnabled") }
    }

    var timerDefaultMinutes: Int {
        didSet { defaults.set(timerDefaultMinutes, forKey: "timerDefaultMinutes") }
    }

    var timerFontSize: CGFloat {
        didSet { defaults.set(timerFontSize, forKey: "timerFontSize") }
    }

    var overtimeAnnouncementMinutes: Int {
        didSet { defaults.set(overtimeAnnouncementMinutes, forKey: "overtimeAnnouncementMinutes") }
    }

    // ntfy push notification (iPhone) — MVP fires only at remaining 10 min and on completion.
    // ntfyMarkerMinutes / ntfyNotifyOnComplete are stored but currently not exposed in the UI;
    // a future settings panel can let the user pick any subset of timer markers + completion.
    var ntfyEnabled: Bool {
        didSet { defaults.set(ntfyEnabled, forKey: "ntfyEnabled") }
    }

    var ntfyTopic: String {
        didSet { defaults.set(ntfyTopic, forKey: "ntfyTopic") }
    }

    var ntfyServerURL: String {
        didSet { defaults.set(ntfyServerURL, forKey: "ntfyServerURL") }
    }

    var ntfyMarkerMinutes: [Int] {
        didSet { defaults.set(ntfyMarkerMinutes, forKey: "ntfyMarkerMinutes") }
    }

    var ntfyNotifyOnComplete: Bool {
        didSet { defaults.set(ntfyNotifyOnComplete, forKey: "ntfyNotifyOnComplete") }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        // Load saved settings or use defaults
        self.isAnalog = defaults.object(forKey: "isAnalog") as? Bool ?? false // Digital by default
        self.showSecondsHand = defaults.object(forKey: "showSecondsHand") as? Bool ?? true
        self.showSecondsDigital = defaults.object(forKey: "showSecondsDigital") as? Bool ?? false // No seconds by default
        self.blinkColon = defaults.object(forKey: "blinkColon") as? Bool ?? false
        self.windowOpacity = defaults.object(forKey: "windowOpacity") as? Double ?? 0.9
        self.windowScale = defaults.object(forKey: "windowScale") as? CGFloat ?? 1.0
        self.timeFontSize = defaults.object(forKey: "timeFontSize") as? CGFloat ?? 48
        self.timeFontSizeDuringTimer = defaults.object(forKey: "timeFontSizeDuringTimer") as? CGFloat ?? 32
        self.dateFontSize = defaults.object(forKey: "dateFontSize") as? CGFloat ?? 18
        self.urgentEventThreshold = defaults.object(forKey: "urgentEventThreshold") as? Int ?? 3 // Default 3 hours
        self.showYear = defaults.object(forKey: "showYear") as? Bool ?? true
        self.eventNameLength = defaults.object(forKey: "eventNameLength") as? Int ?? 10
        self.eventFontSize = defaults.object(forKey: "eventFontSize") as? CGFloat ?? 14
        self.showNoEventMessage = defaults.object(forKey: "showNoEventMessage") as? Bool ?? true
        self.blinkBeforeEvent = defaults.object(forKey: "blinkBeforeEvent") as? Bool ?? false
        self.isTimerEnabled = defaults.object(forKey: "isTimerEnabled") as? Bool ?? true
        self.timerDefaultMinutes = defaults.object(forKey: "timerDefaultMinutes") as? Int ?? 60
        self.timerFontSize = defaults.object(forKey: "timerFontSize") as? CGFloat ?? 20
        self.overtimeAnnouncementMinutes = defaults.object(forKey: "overtimeAnnouncementMinutes") as? Int ?? 15
        self.ntfyEnabled = defaults.object(forKey: "ntfyEnabled") as? Bool ?? false
        self.ntfyTopic = defaults.object(forKey: "ntfyTopic") as? String ?? ""
        self.ntfyServerURL = defaults.object(forKey: "ntfyServerURL") as? String ?? "https://ntfy.sh"
        self.ntfyMarkerMinutes = defaults.object(forKey: "ntfyMarkerMinutes") as? [Int] ?? [10]
        self.ntfyNotifyOnComplete = defaults.object(forKey: "ntfyNotifyOnComplete") as? Bool ?? true
    }
    
    var analogWindowSize: CGFloat {
        Self.analogWindowBaseSize * windowScale
    }
}
