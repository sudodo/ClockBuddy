import SwiftUI
import Observation

@Observable
final class AppSettings {
    private let defaults = UserDefaults.standard
    
    var isAnalog: Bool {
        didSet { defaults.set(isAnalog, forKey: "isAnalog") }
    }
    
    var showSecondsHand: Bool {
        didSet { defaults.set(showSecondsHand, forKey: "showSecondsHand") }
    }
    
    var showSecondsDigital: Bool {
        didSet { defaults.set(showSecondsDigital, forKey: "showSecondsDigital") }
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
    
    var dateFontSize: CGFloat {
        didSet { defaults.set(dateFontSize, forKey: "dateFontSize") }
    }
    
    init() {
        // Load saved settings or use defaults
        self.isAnalog = defaults.object(forKey: "isAnalog") as? Bool ?? false // Digital by default
        self.showSecondsHand = defaults.object(forKey: "showSecondsHand") as? Bool ?? true
        self.showSecondsDigital = defaults.object(forKey: "showSecondsDigital") as? Bool ?? false // No seconds by default
        self.windowOpacity = defaults.object(forKey: "windowOpacity") as? Double ?? 0.9
        self.windowScale = defaults.object(forKey: "windowScale") as? CGFloat ?? 1.0
        self.timeFontSize = defaults.object(forKey: "timeFontSize") as? CGFloat ?? 48
        self.dateFontSize = defaults.object(forKey: "dateFontSize") as? CGFloat ?? 18
    }
    
    // Computed property for window size
    var windowWidth: CGFloat {
        (isAnalog ? 350 : 260) * windowScale
    }
    
    var windowHeight: CGFloat {
        (isAnalog ? 350 : 170) * windowScale
    }
}