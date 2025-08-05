import SwiftUI
import AppKit

@main
struct ClockBuddyApp: App {
    @State private var model = ClockModel()
    @State private var appSettings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(model)
                .environment(appSettings)
                .task {
                    await model.requestCalendarAccess()
                }
                .background(WindowAccessor())
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appSettings) {
                SettingsLink {
                    Text("Settings...")
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
        
        // Settings window
        Settings {
            SettingsView()
                .environment(appSettings)
        }
    }
}

// Helper to access NSWindow
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        
        DispatchQueue.main.async {
            if let window = view.window {
                // Make window always on top
                window.level = .floating
                
                // Keep window visible across all spaces
                window.collectionBehavior = [.canJoinAllSpaces, .stationary]
                
                // Make the window borderless and transparent
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.remove(.titled)
                
                // Remove window shadow for cleaner look
                window.hasShadow = false
                
                // Make background transparent
                window.backgroundColor = .clear
                
                // Disable full screen button
                window.collectionBehavior.insert(.fullScreenNone)
                
                // Enable window dragging by background
                window.isMovableByWindowBackground = true
            }
        }
        
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}