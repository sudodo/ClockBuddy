import SwiftUI

enum AnalogClockHandAngles {
    static func hour(for date: Date, calendar: Calendar = .current) -> Double {
        let hours = calendar.component(.hour, from: date) % 12
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return Double(hours) * 30 + Double(minutes) * 0.5 + Double(seconds) / 120
    }

    static func minute(for date: Date, calendar: Calendar = .current) -> Double {
        let minutes = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        return Double(minutes) * 6 + Double(seconds) * 0.1
    }

    static func second(for date: Date, calendar: Calendar = .current) -> Double {
        Double(calendar.component(.second, from: date)) * 6
    }
}

enum AnalogClockPresentation {
    static func dateText(for date: Date, calendar: Calendar = .current) -> String {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: date)
    }

    static func scheduleText(
        nextEventTime: Date?,
        nextEventTitle: String?,
        showNoEventMessage: Bool,
        maxTitleLength: Int,
        calendar: Calendar = .current
    ) -> String? {
        guard let nextEventTime, let nextEventTitle else {
            return showNoEventMessage ? "今日は予定なし" : nil
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.timeZone = calendar.timeZone
        formatter.dateFormat = "HH:mm"

        let title: String
        if nextEventTitle.count > maxTitleLength {
            title = String(nextEventTitle.prefix(maxTitleLength)) + "..."
        } else {
            title = nextEventTitle
        }
        return "予定 \(formatter.string(from: nextEventTime)) \(title)"
    }
}

struct AnalogClockView: View {
    let date: Date
    var showSecondsHand: Bool = true

    @Environment(AppSettings.self) private var settings
    @Environment(ClockModel.self) private var model

    private var hourAngle: Angle {
        Angle(degrees: AnalogClockHandAngles.hour(for: date))
    }

    private var minuteAngle: Angle {
        Angle(degrees: AnalogClockHandAngles.minute(for: date))
    }

    private var secondAngle: Angle {
        Angle(degrees: AnalogClockHandAngles.second(for: date))
    }

    private var scheduleText: String? {
        AnalogClockPresentation.scheduleText(
            nextEventTime: model.nextEventTime,
            nextEventTitle: model.nextEventTitle,
            showNoEventMessage: settings.showNoEventMessage,
            maxTitleLength: settings.eventNameLength
        )
    }

    var body: some View {
        ZStack {
            // Clock face
            Circle()
                .stroke(lineWidth: 3)
                .frame(width: 180, height: 180)
            
            // Hour markers
            ForEach(0..<12) { hour in
                VStack {
                    Rectangle()
                        .fill()
                        .frame(width: 2, height: hour % 3 == 0 ? 11 : 7)
                    Spacer()
                }
                .frame(height: 90)
                .rotationEffect(Angle(degrees: Double(hour) * 30))
            }
            
            // Hour hand
            Rectangle()
                .fill()
                .frame(width: 5, height: 56)
                .offset(y: -28)
                .rotationEffect(hourAngle)
            
            // Minute hand
            Rectangle()
                .fill()
                .frame(width: 3, height: 78)
                .offset(y: -39)
                .rotationEffect(minuteAngle)
            
            // Second hand (only if enabled)
            if showSecondsHand {
                Rectangle()
                    .fill(.red)
                    .frame(width: 2, height: 84)
                    .offset(y: -42)
                    .rotationEffect(secondAngle)
            }
            
            // Center dot
            Circle()
                .fill()
                .frame(width: 9, height: 9)
            
            // Date, weekday, and today's schedule
            VStack {
                Spacer()

                VStack(spacing: 2) {
                    Text(AnalogClockPresentation.dateText(for: date))
                        .font(.system(size: settings.dateFontSize, weight: .medium))

                    if let scheduleText {
                        Text(scheduleText)
                            .font(.system(size: settings.eventFontSize, weight: .regular))
                            .opacity(0.85)
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .frame(maxWidth: 160)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.black.opacity(0.65))
                )
            }
            .padding(.bottom, 8)
        }
        .frame(
            width: AppSettings.analogWindowBaseSize,
            height: AppSettings.analogWindowBaseSize
        )
    }
}
