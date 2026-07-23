import AVFoundation

final class VoicePlayer: NSObject {
    private var minutePlayers: [Int: AVAudioPlayer] = [:]
    private var completePlayer: AVAudioPlayer?
    private var overtimePlayer: AVAudioPlayer?

    private let synthesizer = AVSpeechSynthesizer()

    override init() {
        super.init()
        synthesizer.delegate = self

        for m in [30, 15, 10, 5] {
            guard let url = Bundle.main.url(forResource: "\(m)min", withExtension: "wav"),
                  let player = try? AVAudioPlayer(contentsOf: url) else {
                print("VoicePlayer: failed to load \(m)min.wav")
                continue
            }
            player.prepareToPlay()
            minutePlayers[m] = player
        }

        if let url = Bundle.main.url(forResource: "complete", withExtension: "wav"),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.prepareToPlay()
            completePlayer = player
        } else {
            print("VoicePlayer: failed to load complete.wav")
        }

        if let url = Bundle.main.url(forResource: "超過", withExtension: "wav"),
           let player = try? AVAudioPlayer(contentsOf: url) {
            player.prepareToPlay()
            overtimePlayer = player
        } else {
            print("VoicePlayer: failed to load 超過.wav")
        }
    }

    func play(minutes: Int) {
        guard let player = minutePlayers[minutes] else { return }
        player.stop()
        player.currentTime = 0
        player.play()
    }

    func playComplete() {
        guard let player = completePlayer else { return }
        player.stop()
        player.currentTime = 0
        player.play()
    }

    /// Speaks "N minutes" in English then plays 超過.wav, producing "N minutes 超過".
    func playOvertimeAnnouncement(minutes: Int) {
        let utterance = AVSpeechUtterance(string: "\(minutes) minutes")
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
}

extension VoicePlayer: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard let player = overtimePlayer else { return }
        player.stop()
        player.currentTime = 0
        player.play()
    }
}
