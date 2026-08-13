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
    @ObservationIgnored private let ntfyClient = NtfyClient()
    @ObservationIgnored private let settings: AppSettings
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var endDate: Date?
    @ObservationIgnored private var pausedRemaining: Int = 0
    @ObservationIgnored private var playedMarkers: Set<Int> = []
    @ObservationIgnored private var overtimeStartDate: Date?
    @ObservationIgnored private var nextOvertimeAnnouncementSeconds: Int = 0

    static let markerMinutes = [30, 15, 10, 5]

    init(settings: AppSettings) {
        self.settings = settings
    }

    func setTimerEnabled(_ enabled: Bool) {
        settings.isTimerEnabled = enabled

        if !enabled {
            setupSheetVisible = false
            stop()
        }
    }

    func handleSingleTap(defaultMinutes: Int) {
        guard settings.isTimerEnabled else { return }

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
        guard settings.isTimerEnabled else { return }
        setupSheetVisible = true
    }

    func start(minutes: Int) {
        guard settings.isTimerEnabled else { return }
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
        nextOvertimeAnnouncementSeconds = 0
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
            checkOvertimeAnnouncement()
            return
        }

        guard let endDate else { return }
        let remaining = max(0, Int(endDate.timeIntervalSinceNow.rounded()))

        for m in Self.markerMinutes where remaining <= m * 60 && !playedMarkers.contains(m) {
            playedMarkers.insert(m)
            voicePlayer.play(minutes: m)
            sendNtfyForMarker(minutes: m)
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
        sendNtfyForCompletion()
        remainingSeconds = 0
        overtimeSeconds = 0
        overtimeStartDate = Date()
        nextOvertimeAnnouncementSeconds = max(1, settings.overtimeAnnouncementMinutes) * 60
        isOvertime = true
    }

    private func checkOvertimeAnnouncement() {
        let interval = max(1, settings.overtimeAnnouncementMinutes) * 60
        while overtimeSeconds >= nextOvertimeAnnouncementSeconds {
            let minutes = nextOvertimeAnnouncementSeconds / 60
            voicePlayer.playOvertimeAnnouncement(minutes: minutes)
            nextOvertimeAnnouncementSeconds += interval
        }
    }

    private func sendNtfyForMarker(minutes: Int) {
        guard settings.ntfyEnabled,
              settings.ntfyMarkerMinutes.contains(minutes) else { return }
        ntfyClient.send(
            serverURL: settings.ntfyServerURL,
            topic: settings.ntfyTopic,
            message: "ClockBuddy: 残り\(minutes)分"
        )
    }

    private func sendNtfyForCompletion() {
        guard settings.ntfyEnabled, settings.ntfyNotifyOnComplete else { return }
        ntfyClient.send(
            serverURL: settings.ntfyServerURL,
            topic: settings.ntfyTopic,
            message: "ClockBuddy: 作業完了"
        )
    }
}
