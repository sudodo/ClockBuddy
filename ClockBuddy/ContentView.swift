import SwiftUI

struct ContentView: View {
    @State private var isAnalog = true
    @State private var currentDate = Date()
    @State private var isHovering = false
    @State private var windowOpacity: Double = 0.9
    @State private var showSecondsHand = true
    @State private var windowScale: CGFloat = 1.0
    @Environment(ClockModel.self) private var model
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var clockColor: Color {
        model.hasUpcomingEvents ? .pink : .cyan
    }
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(.black.opacity(windowOpacity))
            
            // Clock display
            Group {
                if isAnalog {
                    AnalogClockView(date: currentDate, showSecondsHand: showSecondsHand)
                        .scaleEffect(windowScale)
                } else {
                    DigitalClockView(date: currentDate)
                        .scaleEffect(windowScale)
                }
            }
            .foregroundStyle(clockColor)
            .animation(.easeInOut(duration: 0.3), value: clockColor)
            .animation(.easeInOut(duration: 0.5), value: isAnalog)
            
            // Control buttons (shows on hover)
            if isHovering {
                VStack {
                    HStack {
                        // Transparency slider
                        VStack {
                            Image(systemName: "sun.max.fill")
                                .font(.caption)
                            Slider(value: $windowOpacity, in: 0.3...1.0)
                                .frame(width: 100)
                                .tint(.white)
                            Image(systemName: "sun.min.fill")
                                .font(.caption)
                        }
                        .padding()
                        
                        Spacer()
                        
                        VStack(spacing: 10) {
                            // Toggle clock mode
                            Button(action: { isAnalog.toggle() }) {
                                Image(systemName: isAnalog ? "clock.badge.checkmark.fill" : "clock.fill")
                                    .font(.title2)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .padding(8)
                                    .background(Circle().fill(.black.opacity(0.5)))
                            }
                            .buttonStyle(.plain)
                            .help(isAnalog ? "Switch to Digital" : "Switch to Analog")
                            
                            // Toggle seconds hand (only in analog mode)
                            if isAnalog {
                                Button(action: { showSecondsHand.toggle() }) {
                                    Image(systemName: showSecondsHand ? "timer.circle.fill" : "timer.circle")
                                        .font(.title2)
                                        .foregroundStyle(.white.opacity(0.7))
                                        .padding(8)
                                        .background(Circle().fill(.black.opacity(0.5)))
                                }
                                .buttonStyle(.plain)
                                .help(showSecondsHand ? "Hide Seconds" : "Show Seconds")
                            }
                            
                            // Size controls
                            HStack(spacing: 5) {
                                Button(action: { windowScale = max(0.5, windowScale - 0.1) }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                                .buttonStyle(.plain)
                                
                                Button(action: { windowScale = min(2.0, windowScale + 0.1) }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(5)
                            .background(Capsule().fill(.black.opacity(0.5)))
                        }
                        .padding()
                    }
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .frame(width: (isAnalog ? 350 : 400) * windowScale, 
               height: (isAnalog ? 350 : 250) * windowScale)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .onReceive(timer) { _ in
            currentDate = Date()
            
            // Refresh calendar events every 30 seconds
            if Calendar.current.component(.second, from: currentDate) % 30 == 0 {
                Task {
                    await model.refreshEvents()
                }
            }
        }
    }
}