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
        formatter.dateFormat = "M月d日 E"
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

enum AnalogClockLayout {
    static let visibleMarkerHours = Array(0...4) + Array(8...11)

    // The Artifact uses a 260 pt window. ClockBuddy keeps its compact 190 pt
    // base window and scales the design metrics proportionally.
    static let artifactScale = AppSettings.analogWindowBaseSize / 260
    static let faceDiameter = 236 * artifactScale

    static func scaled(_ value: CGFloat) -> CGFloat {
        value * artifactScale
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

    private var dateFontSize: CGFloat {
        settings.dateFontSize * 15 / 18
    }

    private var eventFontSize: CGFloat {
        settings.eventFontSize * 11 / 14
    }

    private var markerOffset: CGFloat {
        -(AnalogClockLayout.faceDiameter / 2 - AnalogClockLayout.scaled(10))
    }

    private var hourHandWidth: CGFloat {
        settings.analogFaceStyle == .hairline ? 3 : 6
    }

    private var hourHandLength: CGFloat {
        AnalogClockLayout.scaled(settings.analogFaceStyle == .hairline ? 64 : 58)
    }

    private var minuteHandWidth: CGFloat {
        settings.analogFaceStyle == .hairline ? 2 : 3
    }

    private var minuteHandLength: CGFloat {
        AnalogClockLayout.scaled(settings.analogFaceStyle == .hairline ? 98 : 94)
    }

    @ViewBuilder
    private func marker(for hour: Int) -> some View {
        if settings.analogFaceStyle == .hairline {
            Rectangle()
                .fill()
                .frame(width: 1, height: AnalogClockLayout.scaled(9))
                .opacity(hour % 3 == 0 ? 0.9 : 0.35)
        } else {
            Circle()
                .fill()
                .frame(
                    width: hour % 3 == 0 ? 4 : 2,
                    height: hour % 3 == 0 ? 4 : 2
                )
                .opacity(hour % 3 == 0 ? 0.9 : 0.55)
        }
    }

    private func hand(width: CGFloat, length: CGFloat, angle: Angle) -> some View {
        Capsule()
            .fill()
            .frame(width: width, height: length)
            .offset(y: -length / 2)
            .rotationEffect(angle)
    }

    var body: some View {
        ZStack {
            if settings.analogFaceStyle == .hairline {
                Circle()
                    .stroke(lineWidth: 1)
                    .opacity(0.22)
                    .frame(
                        width: AnalogClockLayout.faceDiameter,
                        height: AnalogClockLayout.faceDiameter
                    )
            }
            
            ForEach(AnalogClockLayout.visibleMarkerHours, id: \.self) { hour in
                marker(for: hour)
                    .offset(y: markerOffset)
                .rotationEffect(Angle(degrees: Double(hour) * 30))
            }
            
            hand(width: hourHandWidth, length: hourHandLength, angle: hourAngle)
            hand(width: minuteHandWidth, length: minuteHandLength, angle: minuteAngle)
            
            if showSecondsHand {
                Rectangle()
                    .fill(.red)
                    .frame(
                        width: 1,
                        height: AnalogClockLayout.scaled(104 + 24)
                    )
                    .offset(y: -AnalogClockLayout.scaled((104 - 24) / 2))
                    .rotationEffect(secondAngle)
            }
            
            if settings.analogFaceStyle == .hairline {
                Circle()
                    .fill()
                    .frame(width: 5, height: 5)
            } else {
                Circle()
                    .stroke(lineWidth: 2)
                    .frame(width: 11, height: 11)
            }
            
            VStack(spacing: 1) {
                Text(AnalogClockPresentation.dateText(for: date))
                    .font(.system(size: dateFontSize, weight: .medium))

                if let scheduleText {
                    Text(scheduleText)
                        .font(.system(size: eventFontSize, weight: .regular))
                        .foregroundStyle(Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255))
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .frame(maxWidth: AnalogClockLayout.scaled(220))
            .offset(y: AnalogClockLayout.scaled(72))
        }
        .frame(
            width: AppSettings.analogWindowBaseSize,
            height: AppSettings.analogWindowBaseSize
        )
    }
}
