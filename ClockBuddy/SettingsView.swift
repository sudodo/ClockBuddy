import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var settings = settings
        
        VStack(spacing: 0) {
            // Title
            Text("Clock Settings")
                .font(.title2)
                .fontWeight(.semibold)
                .padding()
            
            Divider()
            
            // Settings content
            Form {
                // Clock Type Section
                Section("Clock Type") {
                    Picker("Display Mode", selection: $settings.isAnalog) {
                        Text("Digital").tag(false)
                        Text("Analog").tag(true)
                    }
                    .pickerStyle(.segmented)
                    
                    if settings.isAnalog {
                        Toggle("Show Seconds Hand", isOn: $settings.showSecondsHand)
                    } else {
                        Toggle("Show Seconds", isOn: $settings.showSecondsDigital)
                        Toggle("Blink Colon", isOn: $settings.blinkColon)
                    }
                }
                
                // Appearance Section
                Section("Appearance") {
                    HStack {
                        Text("Transparency")
                        Slider(value: $settings.windowOpacity, in: 0.3...1.0) {
                            Text("Transparency")
                        } minimumValueLabel: {
                            Image(systemName: "sun.min.fill")
                                .foregroundStyle(.secondary)
                        } maximumValueLabel: {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(.secondary)
                        }
                        Text("\(Int(settings.windowOpacity * 100))%")
                            .monospacedDigit()
                            .frame(width: 45, alignment: .trailing)
                    }
                    
                    HStack {
                        Text("Window Size")
                        Slider(value: $settings.windowScale, in: 0.5...2.0, step: 0.1) {
                            Text("Window Size")
                        } minimumValueLabel: {
                            Text("50%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } maximumValueLabel: {
                            Text("200%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(Int(settings.windowScale * 100))%")
                            .monospacedDigit()
                            .frame(width: 45, alignment: .trailing)
                    }
                }
                
                // Font Size Section
                Section("Font Sizes") {
                    HStack {
                        Text("Time Font Size")
                        Slider(value: $settings.timeFontSize, in: 24...96, step: 4) {
                            Text("Time Font Size")
                        }
                        Text("\(Int(settings.timeFontSize))pt")
                            .monospacedDigit()
                            .frame(width: 45, alignment: .trailing)
                    }
                    
                    HStack {
                        Text("Date Font Size")
                        Slider(value: $settings.dateFontSize, in: 12...36, step: 2) {
                            Text("Date Font Size")
                        }
                        Text("\(Int(settings.dateFontSize))pt")
                            .monospacedDigit()
                            .frame(width: 45, alignment: .trailing)
                    }
                    
                    HStack {
                        Text("Event Font Size")
                        Slider(value: $settings.eventFontSize, in: 10...24, step: 1) {
                            Text("Event Font Size")
                        }
                        Text("\(Int(settings.eventFontSize))pt")
                            .monospacedDigit()
                            .frame(width: 45, alignment: .trailing)
                    }
                }
                
                // Calendar Section
                Section("Calendar Colors") {
                    HStack {
                        Text("Urgent Event Threshold")
                        Slider(value: Binding(
                            get: { Double(settings.urgentEventThreshold) },
                            set: { settings.urgentEventThreshold = Int($0) }
                        ), in: 1...24, step: 1) {
                            Text("Hours")
                        }
                        Text("\(settings.urgentEventThreshold)h")
                            .monospacedDigit()
                            .frame(width: 35, alignment: .trailing)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Label("No events", systemImage: "circle.fill")
                            .foregroundStyle(.cyan)
                        Label("Events today", systemImage: "circle.fill")
                            .foregroundStyle(Color(red: 1.0, green: 0.84, blue: 0.0))
                        Label("Events within \(settings.urgentEventThreshold)h", systemImage: "circle.fill")
                            .foregroundStyle(.red)
                    }
                    .font(.caption)
                }
                
                // Event Display Section
                Section("Event Display") {
                    Toggle("Show Year in Date", isOn: $settings.showYear)
                    Toggle("Show \"今日は予定なし\"", isOn: $settings.showNoEventMessage)
                    Toggle("Blink Time Before Event (30 min)", isOn: $settings.blinkBeforeEvent)
                    
                    HStack {
                        Text("Event Name Length")
                        Slider(value: Binding(
                            get: { Double(settings.eventNameLength) },
                            set: { settings.eventNameLength = Int($0) }
                        ), in: 5...30, step: 1) {
                            Text("Characters")
                        }
                        Text("\(settings.eventNameLength)文字")
                            .monospacedDigit()
                            .frame(width: 50, alignment: .trailing)
                    }
                }
                
                // Quick Actions Section
                Section("Quick Actions") {
                    HStack {
                        Button("Reset to Defaults") {
                            withAnimation {
                                settings.isAnalog = false // Digital by default
                                settings.showSecondsHand = true
                                settings.showSecondsDigital = false // No seconds by default
                                settings.blinkColon = false
                                settings.windowOpacity = 0.9
                                settings.windowScale = 1.0
                                settings.timeFontSize = 48
                                settings.dateFontSize = 18
                                settings.urgentEventThreshold = 3
                                settings.showYear = true
                                settings.eventNameLength = 10
                                settings.eventFontSize = 14
                                settings.showNoEventMessage = true
                                settings.blinkBeforeEvent = false
                            }
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.blue)
                        
                        Spacer()
                    }
                }
            }
            .formStyle(.grouped)
        }
        .frame(width: 450, height: 500)
        .background(Color(NSColor.windowBackgroundColor))
    }
}