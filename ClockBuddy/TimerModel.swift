import SwiftUI
import AppKit
import Observation

@Observable
final class TimerModel {
    private(set) var isRunning = false
    private(set) var isPaused = false
    private(set) var remainingSeconds: Int = 0
    private(set) var totalSeconds: Int = 0
    var setupSheetVisible = false

    @ObservationIgnored private let voicePlayer = VoicePlayer()
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var endDate: Date?
    @ObservationIgnored private var pausedRemaining: Int = 0
    @ObservationIgnored private var playedMarkers: Set<Int> = []
    @ObservationIgnored private var finishClearTask: Task<Void, Never>?

    private static let markerMinutes = [30, 15, 10, 5]

    func handleSingleTap(defaultMinutes: Int) {
        if !isRunning {
            start(minutes: defaultMinutes)
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
        finishClearTask?.cancel()
        finishClearTask = nil
        totalSeconds = max(1, minutes) * 60
        remainingSeconds = totalSeconds
        endDate = Date().addingTimeInterval(TimeInterval(totalSeconds))
        playedMarkers = Set(Self.markerMinutes.filter { $0 * 60 >= totalSeconds })
        isRunning = true
        isPaused = false
        scheduleTimer()
    }

    func pause() {
        guard isRunning, !isPaused, let endDate else { return }
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
        finishClearTask?.cancel()
        finishClearTask = nil
        isRunning = false
        isPaused = false
        remainingSeconds = 0
        totalSeconds = 0
        endDate = nil
        pausedRemaining = 0
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
        guard isRunning, !isPaused, let endDate else { return }
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
        timer?.invalidate()
        timer = nil
        isPaused = false
        voicePlayer.playComplete()
        NSSound(named: "Glass")?.play()

        finishClearTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            stop()
        }
    }
}
