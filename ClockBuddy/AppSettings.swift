import SwiftUI
import Observation

@Observable
final class AppSettings {
    var isAnalog = true
    var showSecondsHand = true
    var windowOpacity: Double = 0.9
    var windowScale: CGFloat = 1.0
    
    // Computed property for window size
    var windowWidth: CGFloat {
        (isAnalog ? 350 : 400) * windowScale
    }
    
    var windowHeight: CGFloat {
        (isAnalog ? 350 : 250) * windowScale
    }
}