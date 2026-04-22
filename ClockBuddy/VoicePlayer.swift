import AVFoundation

final class VoicePlayer {
    private var minutePlayers: [Int: AVAudioPlayer] = [:]
    private var completePlayer: AVAudioPlayer?

    init() {
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
}
