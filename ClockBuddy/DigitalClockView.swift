import SwiftUI

struct DigitalClockView: View {
    let date: Date
    @Environment(AppSettings.self) private var settings
    @Environment(ClockModel.self) private var model
    
    private var showColon: Bool {
        !settings.blinkColon || Calendar.current.component(.second, from: date) % 2 == 0
    }
    
    private var timeComponents: (hours: String, minutes: String, seconds: String?) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)
        
        let hours = String(format: "%02d", hour)
        let minutes = String(format: "%02d", minute)
        let seconds = settings.showSecondsDigital ? String(format: "%02d", second) : nil
        
        return (hours, minutes, seconds)
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = settings.showYear ? "yyyy年M月d日" : "M月d日"
        return formatter
    }
    
    private var weekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "E"
        return formatter
    }
    
    private var eventTimeText: String? {
        guard let eventTime = model.nextEventTime else { return nil }
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: date, to: eventTime)
        let hours = components.hour ?? 0
        let minutes = components.minute ?? 0
        
        if hours > 0 {
            return "\(hours)時間後"
        } else if minutes > 0 {
            return "\(minutes)分後"
        } else {
            return "まもなく"
        }
    }
    
    private var truncatedEventTitle: String? {
        guard let title = model.nextEventTitle else { return nil }
        let maxLength = settings.eventNameLength
        if title.count <= maxLength {
            return title
        } else {
            let index = title.index(title.startIndex, offsetBy: maxLength)
            return String(title[..<index]) + "..."
        }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // Time display with optional blinking colon
            HStack(spacing: 0) {
                Text(timeComponents.hours)
                    .font(.system(size: settings.timeFontSize * settings.windowScale, weight: .thin, design: .monospaced))
                    .monospacedDigit()
                
                Text(showColon ? ":" : " ")
                    .font(.system(size: settings.timeFontSize * settings.windowScale, weight: .thin, design: .monospaced))
                    .opacity(showColon ? 1.0 : 0.0)
                
                Text(timeComponents.minutes)
                    .font(.system(size: settings.timeFontSize * settings.windowScale, weight: .thin, design: .monospaced))
                    .monospacedDigit()
                
                if let seconds = timeComponents.seconds {
                    Text(":")
                        .font(.system(size: settings.timeFontSize * settings.windowScale, weight: .thin, design: .monospaced))
                    
                    Text(seconds)
                        .font(.system(size: settings.timeFontSize * settings.windowScale, weight: .thin, design: .monospaced))
                        .monospacedDigit()
                }
            }
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            
            // Date with weekday
            HStack(spacing: 0) {
                Text(dateFormatter.string(from: date))
                Text("(\(weekdayFormatter.string(from: date)))")
            }
            .font(.system(size: settings.dateFontSize * settings.windowScale, weight: .regular))
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            
            // Event information
            if let timeText = eventTimeText, let eventTitle = truncatedEventTitle {
                HStack(spacing: 4) {
                    Text(timeText)
                    Text(eventTitle)
                }
                .font(.system(size: settings.eventFontSize * settings.windowScale, weight: .regular))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .opacity(0.8)
            }
        }
        .padding(.horizontal, 20 * settings.windowScale)
        .padding(.vertical, 15 * settings.windowScale)
    }
}