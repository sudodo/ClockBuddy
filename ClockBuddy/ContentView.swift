import SwiftUI

struct ContentView: View {
    @State private var currentDate = Date()
    @State private var previousAnalog: Bool?
    @Environment(ClockModel.self) private var model
    @Environment(AppSettings.self) private var settings
    @Environment(TimerModel.self) private var timerModel

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var contentWidth: CGFloat? {
        if timerModel.setupSheetVisible {
            return AppSettings.timerSetupMinimumSize.width
        }
        return settings.isAnalog ? settings.analogWindowSize : nil
    }

    private var contentHeight: CGFloat? {
        if timerModel.setupSheetVisible {
            return AppSettings.timerSetupMinimumSize.height
        }
        return settings.isAnalog ? settings.analogWindowSize : nil
    }

    var clockColor: Color {
        if timerModel.isRunning && (timerModel.isOvertime || timerModel.remainingSeconds <= 600) {
            return .red
        }
        if model.hasUrgentEvents {
            return .red
        } else if model.hasUpcomingEvents {
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        } else {
            return .cyan
        }
    }

    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20 * settings.windowScale)
                .fill(.black.opacity(settings.windowOpacity))

            if timerModel.setupSheetVisible {
                TimerSetupView()
            } else {
                // Clock display
                Group {
                    if settings.isAnalog {
                        AnalogClockView(date: currentDate, showSecondsHand: settings.showSecondsHand)
                            .scaleEffect(settings.windowScale)
                    } else {
                        DigitalClockView(date: currentDate)
                            .fixedSize()
                    }
                }
                .foregroundStyle(clockColor)
                .animation(.easeInOut(duration: 0.3), value: clockColor)
                .animation(.easeInOut(duration: 0.5), value: settings.isAnalog)
            }
        }
        .frame(
            width: contentWidth,
            height: contentHeight
        )
        .fixedSize()
        .contentShape(Rectangle())
        .gesture(
            ExclusiveGesture(
                TapGesture(count: 2).onEnded {
                    guard !timerModel.setupSheetVisible else { return }
                    timerModel.openSetup()
                },
                TapGesture(count: 1).onEnded {
                    guard !timerModel.setupSheetVisible else { return }
                    timerModel.handleSingleTap(defaultMinutes: settings.timerDefaultMinutes)
                }
            )
        )
        .onChange(of: timerModel.isRunning) { _, running in
            if running && settings.isAnalog {
                previousAnalog = true
                settings.isAnalog = false
            } else if !running, let prev = previousAnalog {
                settings.isAnalog = prev
                previousAnalog = nil
            }
        }
        .onReceive(timer) { _ in
            currentDate = Date()

            // Refresh calendar events every 10 seconds
            if Calendar.current.component(.second, from: currentDate) % 10 == 0 {
                Task {
                    await model.refreshEvents(urgentThreshold: settings.urgentEventThreshold)
                }
            }
        }
        .task {
            // Initial refresh when view appears
            await model.refreshEvents(urgentThreshold: settings.urgentEventThreshold)
        }
    }
}
