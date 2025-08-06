import SwiftUI
import EventKit
import Observation

@Observable
final class ClockModel {
    private var eventStore: EKEventStore?
    private(set) var hasUpcomingEvents = false
    private(set) var hasUrgentEvents = false
    private(set) var nextEventTime: Date?
    private(set) var nextEventTitle: String?
    
    init() {
        // Initialize event store only when needed
    }
    
    @MainActor
    func requestCalendarAccess() async {
        // Create new event store instance
        let store = EKEventStore()
        self.eventStore = store
        
        do {
            let granted = try await store.requestFullAccessToEvents()
            guard granted else { 
                print("Calendar access denied")
                return 
            }
            print("Calendar access granted")
            
            // Add a small delay to ensure proper initialization
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            await refreshEvents()
        } catch {
            print("Error requesting calendar access: \(error)")
        }
    }
    
    @MainActor
    func refreshEvents(urgentThreshold: Int = 3) async {
        guard let store = eventStore else { 
            print("Event store not initialized")
            return 
        }
        
        let now = Date()
        let endOfDay = Calendar.current.dateInterval(of: .day, for: now)?.end ?? now
        
        // Try different approach: fetch calendars first
        let calendars = store.calendars(for: .event)
        print("Available calendars: \(calendars.count)")
        for calendar in calendars {
            print("Calendar: \(calendar.title) - \(calendar.type.rawValue)")
        }
        
        // Create predicate with specific calendars
        let predicate = store.predicateForEvents(
            withStart: now,
            end: endOfDay,
            calendars: calendars.isEmpty ? nil : calendars
        )
        
        let events = store.events(matching: predicate)
        print("Found \(events.count) total events today")
        
        // Filter out all-day events and past events
        let upcomingEvents = events.filter { event in
            !event.isAllDay && event.startDate > now
        }
        
        // Find the next event time and check if it's urgent
        if let nextEvent = upcomingEvents.min(by: { $0.startDate < $1.startDate }) {
            nextEventTime = nextEvent.startDate
            nextEventTitle = nextEvent.title ?? "イベント"
            
            let hoursUntilEvent = Calendar.current.dateComponents([.hour, .minute], 
                                                                 from: now, 
                                                                 to: nextEvent.startDate).hour ?? 24
            
            hasUrgentEvents = hoursUntilEvent < urgentThreshold
            
            print("Next event: \(nextEvent.title ?? "Untitled") at \(nextEvent.startDate)")
            print("Hours until event: \(hoursUntilEvent), Urgent: \(hasUrgentEvents)")
        } else {
            nextEventTime = nil
            nextEventTitle = nil
            hasUrgentEvents = false
        }
        
        hasUpcomingEvents = !upcomingEvents.isEmpty
        print("Has upcoming events: \(hasUpcomingEvents), Has urgent events: \(hasUrgentEvents)")
    }
}