//
//  ClockBuddyTests.swift
//  ClockBuddyTests
//
//  Created by Akihito Sudo on 2025/08/05.
//

import Foundation
import Testing
@testable import ClockBuddy

struct ClockBuddyTests {

    private func tokyoCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "ja_JP")
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        return calendar
    }

    @Test func timerIsEnabledByDefaultAndPersistsChanges() {
        let suiteName = "ClockBuddyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let initialSettings = AppSettings(defaults: defaults)
        #expect(initialSettings.isTimerEnabled)

        initialSettings.isTimerEnabled = false

        let reloadedSettings = AppSettings(defaults: defaults)
        #expect(!reloadedSettings.isTimerEnabled)
    }

    @Test func disabledTimerRejectsClickSetupAndDirectStart() {
        let suiteName = "ClockBuddyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        let timerModel = TimerModel(settings: settings)

        timerModel.setTimerEnabled(false)
        timerModel.handleSingleTap(defaultMinutes: 25)
        timerModel.openSetup()
        timerModel.start(minutes: 25)

        #expect(!timerModel.isRunning)
        #expect(!timerModel.setupSheetVisible)
        #expect(timerModel.remainingSeconds == 0)
    }

    @Test func disablingTimerStopsAndResetsCurrentTimer() {
        let suiteName = "ClockBuddyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        let timerModel = TimerModel(settings: settings)

        timerModel.start(minutes: 25)
        timerModel.pause()
        timerModel.openSetup()

        #expect(timerModel.isRunning)
        #expect(timerModel.isPaused)
        #expect(timerModel.setupSheetVisible)

        timerModel.setTimerEnabled(false)

        #expect(!timerModel.isRunning)
        #expect(!timerModel.isPaused)
        #expect(!timerModel.isOvertime)
        #expect(!timerModel.setupSheetVisible)
        #expect(timerModel.remainingSeconds == 0)
        #expect(timerModel.totalSeconds == 0)
        #expect(timerModel.overtimeSeconds == 0)
    }

    @Test func reenabledTimerStartsFromSingleClick() {
        let suiteName = "ClockBuddyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        let timerModel = TimerModel(settings: settings)

        timerModel.setTimerEnabled(false)
        timerModel.setTimerEnabled(true)
        timerModel.handleSingleTap(defaultMinutes: 25)

        #expect(timerModel.isRunning)
        #expect(timerModel.totalSeconds == 25 * 60)
        timerModel.stop()
    }

    @Test func compactWindowScalePersistsAndUsesReducedAnalogWindowMetrics() {
        let suiteName = "ClockBuddyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        settings.windowScale = AppSettings.windowScaleRange.lowerBound

        #expect(abs(settings.windowScale - 0.2) < 0.001)
        #expect(abs(settings.analogWindowSize - 38) < 0.001)

        let reloadedSettings = AppSettings(defaults: defaults)
        #expect(abs(reloadedSettings.windowScale - 0.2) < 0.001)
        #expect(AppSettings.windowScaleRange.upperBound == 2.0)
    }

    @Test func analogFaceStyleDefaultsToHairlineAndPersistsDots() {
        let suiteName = "ClockBuddyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        #expect(settings.analogFaceStyle == .hairline)

        settings.analogFaceStyle = .dots
        #expect(AppSettings(defaults: defaults).analogFaceStyle == .dots)

        defaults.set("unsupported-style", forKey: "analogFaceStyle")
        #expect(AppSettings(defaults: defaults).analogFaceStyle == .hairline)
    }

    @Test func analogClockLeavesLowerMarkersClearForDateAndSchedule() {
        #expect(AnalogClockLayout.visibleMarkerHours == [0, 1, 2, 3, 4, 8, 9, 10, 11])
    }

    @Test func analogClockHandsMatchNineOhFive() {
        let calendar = tokyoCalendar()
        let date = calendar.date(from: DateComponents(
            year: 2026, month: 8, day: 14, hour: 9, minute: 5, second: 30
        ))!

        #expect(abs(AnalogClockHandAngles.hour(for: date, calendar: calendar) - 272.75) < 0.001)
        #expect(abs(AnalogClockHandAngles.minute(for: date, calendar: calendar) - 33) < 0.001)
        #expect(abs(AnalogClockHandAngles.second(for: date, calendar: calendar) - 180) < 0.001)
    }

    @Test func analogClockPresentsWeekdayAndTodaySchedule() {
        let calendar = tokyoCalendar()
        let date = calendar.date(from: DateComponents(
            year: 2026, month: 8, day: 14, hour: 9, minute: 5
        ))!
        let eventTime = calendar.date(from: DateComponents(
            year: 2026, month: 8, day: 14, hour: 10, minute: 30
        ))!

        #expect(AnalogClockPresentation.dateText(for: date, calendar: calendar) == "8月14日 金")
        #expect(AnalogClockPresentation.scheduleText(
            nextEventTime: eventTime,
            nextEventTitle: "打ち合わせ",
            showNoEventMessage: true,
            maxTitleLength: 4,
            calendar: calendar
        ) == "予定 10:30 打ち合わ...")
        #expect(AnalogClockPresentation.scheduleText(
            nextEventTime: nil,
            nextEventTitle: nil,
            showNoEventMessage: true,
            maxTitleLength: 10,
            calendar: calendar
        ) == "今日は予定なし")
    }

    @Test func digitalYearVisibilityIsEnabledByDefaultAndPersists() {
        let suiteName = "ClockBuddyTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName)!
        defer { defaults.removePersistentDomain(forName: suiteName) }

        let settings = AppSettings(defaults: defaults)
        #expect(settings.showYear)

        settings.showYear = false
        #expect(!AppSettings(defaults: defaults).showYear)
    }

}
