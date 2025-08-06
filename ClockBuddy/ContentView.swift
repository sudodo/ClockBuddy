import SwiftUI

struct ContentView: View {
    @State private var currentDate = Date()
    @Environment(ClockModel.self) private var model
    @Environment(AppSettings.self) private var settings
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var clockColor: Color {
        if model.hasUrgentEvents {
            return .red // 緊急：n時間以内に予定
        } else if model.hasUpcomingEvents {
            return Color(red: 1.0, green: 0.84, blue: 0.0) // ゴールド：今日予定あり
        } else {
            return .cyan // 青：予定なし
        }
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(.black.opacity(settings.windowOpacity))
            
            // Clock display
            Group {
                if settings.isAnalog {
                    AnalogClockView(date: currentDate, showSecondsHand: settings.showSecondsHand)
                        .scaleEffect(settings.windowScale)
                } else {
                    DigitalClockView(date: currentDate)
                }
            }
            .foregroundStyle(clockColor)
            .animation(.easeInOut(duration: 0.3), value: clockColor)
            .animation(.easeInOut(duration: 0.5), value: settings.isAnalog)
        }
        .frame(width: settings.windowWidth, height: settings.windowHeight)
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