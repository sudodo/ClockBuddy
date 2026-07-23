import SwiftUI
import AppKit
import Observation

@Observable
final class TimerModel {
    private(set) var isRunning = false
    private(set) var isPaused = false
    private(set) var isOvertime = false
    private(set) var remainingSeconds: Int = 0
    private(set) var totalSeconds: Int = 0
    private(set) var overtimeSeconds: Int = 0
    var setupSheetVisible = false

    @ObservationIgnored private let voicePlayer = VoicePlayer()
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var endDate: Date?
    @ObservationIgnored private var pausedRemaining: Int = 0
    @ObservationIgnored private var playedMarkers: Set<Int> = []
    @ObservationIgnored private var overtimeStartDate: Date?

    private static let markerMinutes = [30, 15, 10, 5]

    func handleSingleTap(defaultMinutes: Int) {
        if !isRunning {
            start(minutes: defaultMinutes)
        } else if isOvertime {
            stop()
        } else if isPaused {
            resume()
        } else {
            pause()
        }
    }

    func openSetup() {
        setupSheetVisible = true
    }

    func start(minutes: Int) {
        totalSeconds = max(1, minutes) * 60
        remainingSeconds = totalSeconds
        endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        playedMarkers = Set(Self.markerMinutes.filter { $0 * 60 >= totalSeconds })
        isRunning = true
        isPaused = false
        isOvertime = false
        overtimeSeconds = 0
        overtimeStartDate = nil
        scheduleTimer()
    }

    func pause() {
        guard isRunning, !isPaused, !isOvertime, let endDate else { return }
        pausedRemaining = max(0, Int(endDate.timeIntervalSinceNow.rounded()))
        timer?.invalidate()
        timer = nil
        isPaused = true
    }

    func resume() {
        guard isRunning, isPaused else { return }
        endDate = Date().addingTimeInterval(TimeInterval(pausedRemaining))
        remainingSeconds = pausedRemaining
        isPaused = false
        scheduleTimer()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        isOvertime = false
        remainingSeconds = 0
        totalSeconds = 0
        overtimeSeconds = 0
        endDate = nil
        pausedRemaining = 0
        overtimeStartDate = nil
        playedMarkers.removeAll()
    }

    private func scheduleTimer() {
        timer?.invalidate()
        let t = Timer(timeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        guard isRunning, !isPaused else { return }

        if isOvertime, let start = overtimeStartDate {
            overtimeSeconds = max(0, Int(Date().timeIntervalSince(start).rounded()))
            return
        }

        guard let endDate else { return }
        let remaining = max(0, Int(endDate.timeIntervalSinceNow.rounded()))

        for m in Self.markerMinutes where remaining <= m * 60 && !playedMarkers.contains(m) {
            playedMarkers.insert(m)
            voicePlayer.play(minutes: m)
        }

        remainingSeconds = remaining
        if remaining == 0 {
            finish()
        }
    }

    private func finish() {
        isPaused = false
        voicePlayer.playComplete()
        NSSound(named: "Glass")?.play()
        remainingSeconds = 0
        overtimeSeconds = 0
        overtimeStartDate = Date()
        isOvertime = true
    }
}
