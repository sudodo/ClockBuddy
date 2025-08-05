import SwiftUI
import EventKit
import Observation

@Observable
final class ClockModel {
    private let eventStore = EKEventStore()
    private(set) var hasUpcomingEvents = false
    
    @MainActor
    func requestCalendarAccess() async {
        do {
            let granted = try await eventStore.requestFullAccessToEvents()
            guard granted else { 
                print("Calendar access denied")
                return 
            }
            await refreshEvents()
        } catch {
            print("Error requesting calendar access: \(error)")
        }
    }
    
    @MainActor
    func refreshEvents() async {
        let now = Date()
        let endOfDay = Calendar.current.dateInterval(of: .day, for: now)?.end ?? now
        
        let predicate = eventStore.predicateForEvents(
            withStart: now,
            end: endOfDay,
            calendars: nil
        )
        
        let events = eventStore.events(matching: predicate)
        
        // Filter out all-day events and past events
        let upcomingEvents = events.filter { event in
            !event.isAllDay && event.startDate > now
        }
        
        hasUpcomingEvents = !upcomingEvents.isEmpty
    }
}