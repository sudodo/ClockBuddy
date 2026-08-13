import SwiftUI

struct DigitalClockView: View {
    let date: Date
    @Environment(AppSettings.self) private var settings
    @Environment(ClockModel.self) private var model
    @Environment(TimerModel.self) private var timerModel
    @State private var showTimeForBlink = true
    @State private var showRemainingForBlink = true

    private var showColon: Bool {
        !settings.blinkColon || Calendar.current.component(.second, from: date) % 2 == 0
    }

    private var isTimerCritical: Bool {
        timerModel.isRunning && (timerModel.isOvertime || timerModel.remainingSeconds <= 600)
    }

    private var shouldBlinkTime: Bool {
        (settings.blinkBeforeEvent && model.isWithin30Minutes) || isTimerCritical
    }

    private var shouldBlinkRemaining: Bool {
        timerModel.isRunning && !timerModel.isPaused && isTimerCritical
    }

    private var effectiveTimeFontSize: CGFloat {
        let baseSize = timerModel.isRunning ? settings.timeFontSizeDuringTimer : settings.timeFontSize
        return baseSize * settings.windowScale
    }

    private var remainingText: String? {
        guard timerModel.isRunning else { return nil }

        if timerModel.isOvertime {
            let s = timerModel.overtimeSeconds
            return String(format: "超過%02d:%02d", s / 60, s % 60)
        }

        let seconds = timerModel.remainingSeconds

        if timerModel.isPaused {
            let minutes = max(1, Int(ceil(Double(seconds) / 60.0)))
            return "⏸️ 残り\(minutes)分"
        }

        if seconds <= 600 {
            return String(format: "残り%02d:%02d", seconds / 60, seconds % 60)
        }
        let minutes = Int(ceil(Double(seconds) / 60.0))
        return "残り\(minutes)分"
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

        // If urgent (red color), show start time instead of time until event
        if model.hasUrgentEvents {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: eventTime)
        } else {
            // Show time until event
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
        VStack(spacing: 2 * settings.windowScale) {
            // Time display with optional blinking colon
            HStack(spacing: 0) {
                Text(timeComponents.hours)
                    .font(.system(size: effectiveTimeFontSize, weight: .thin, design: .monospaced))
                    .monospacedDigit()

                Text(showColon ? ":" : " ")
                    .font(.system(size: effectiveTimeFontSize, weight: .thin, design: .monospaced))
                    .opacity(showColon ? 1.0 : 0.0)

                Text(timeComponents.minutes)
                    .font(.system(size: effectiveTimeFontSize, weight: .thin, design: .monospaced))
                    .monospacedDigit()

                if let seconds = timeComponents.seconds {
                    Text(":")
                        .font(.system(size: effectiveTimeFontSize, weight: .thin, design: .monospaced))

                    Text(seconds)
                        .font(.system(size: effectiveTimeFontSize, weight: .thin, design: .monospaced))
                        .monospacedDigit()
                }
            }
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .opacity(shouldBlinkTime ? (showTimeForBlink ? 1.0 : 0.3) : 1.0)
            .animation(shouldBlinkTime ? .easeInOut(duration: 0.5).repeatForever(autoreverses: true) : .default, value: showTimeForBlink)
            .onAppear {
                if shouldBlinkTime {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        showTimeForBlink.toggle()
                    }
                }
            }
            .onChange(of: shouldBlinkTime) { oldValue, newValue in
                if newValue && !oldValue {
                    withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                        showTimeForBlink.toggle()
                    }
                } else if !newValue && oldValue {
                    withAnimation(.default) {
                        showTimeForBlink = true
                    }
                }
            }

            // Remaining time (timer mode)
            if let remaining = remainingText {
                Text(remaining)
                    .font(.system(size: settings.timerFontSize * settings.windowScale, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .opacity(shouldBlinkRemaining ? (showRemainingForBlink ? 1.0 : 0.3) : 1.0)
                    .animation(shouldBlinkRemaining ? .easeInOut(duration: 0.6).repeatForever(autoreverses: true) : .default, value: showRemainingForBlink)
                    .onAppear {
                        if shouldBlinkRemaining {
                            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                showRemainingForBlink.toggle()
                            }
                        }
                    }
                    .onChange(of: shouldBlinkRemaining) { oldValue, newValue in
                        if newValue && !oldValue {
                            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                                showRemainingForBlink.toggle()
                            }
                        } else if !newValue && oldValue {
                            withAnimation(.default) {
                                showRemainingForBlink = true
                            }
                        }
                    }
            }

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
            } else if !model.hasUpcomingEvents && settings.showNoEventMessage {
                Text("今日は予定なし")
                    .font(.system(size: settings.eventFontSize * settings.windowScale, weight: .regular))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .opacity(0.8)
            }
        }
        .padding(2 * settings.windowScale)
    }
}
