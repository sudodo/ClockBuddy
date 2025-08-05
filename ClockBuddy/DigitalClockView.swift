import SwiftUI

struct DigitalClockView: View {
    let date: Date
    @Environment(AppSettings.self) private var settings
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = settings.showSecondsDigital ? "HH:mm:ss" : "HH:mm"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter
    }
    
    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "EEEE"
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 6) {
            Text(timeFormatter.string(from: date))
                .font(.system(size: settings.timeFontSize * settings.windowScale, weight: .thin, design: .monospaced))
                .monospacedDigit()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            Text(dateFormatter.string(from: date))
                .font(.system(size: settings.dateFontSize * settings.windowScale, weight: .regular))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
            Text(weekdayFormatter.string(from: date))
                .font(.system(size: settings.dateFontSize * 0.9 * settings.windowScale, weight: .regular))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .padding(.horizontal, 20 * settings.windowScale)
        .padding(.vertical, 15 * settings.windowScale)
    }
}