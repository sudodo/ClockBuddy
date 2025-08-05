import SwiftUI

struct DigitalClockView: View {
    let date: Date
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
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
        VStack(spacing: 8) {
            Text(timeFormatter.string(from: date))
                .font(.system(size: 72, weight: .thin, design: .monospaced))
                .monospacedDigit()
            
            Text(dateFormatter.string(from: date))
                .font(.system(size: 24, weight: .regular))
            
            Text(weekdayFormatter.string(from: date))
                .font(.system(size: 20, weight: .regular))
        }
        .padding()
    }
}