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
                }
                
                // Quick Actions Section
                Section("Quick Actions") {
                    HStack {
                        Button("Reset to Defaults") {
                            withAnimation {
                                settings.isAnalog = false // Digital by default
                                settings.showSecondsHand = true
                                settings.showSecondsDigital = false // No seconds by default
                                settings.windowOpacity = 0.9
                                settings.windowScale = 1.0
                                settings.timeFontSize = 48
                                settings.dateFontSize = 18
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
        .frame(width: 450, height: 350)
        .background(Color(NSColor.windowBackgroundColor))
    }
}