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

}
