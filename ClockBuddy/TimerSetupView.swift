import SwiftUI

struct TimerSetupView: View {
    @Environment(AppSettings.self) private var settings
    @Environment(TimerModel.self) private var timerModel
    @State private var minutes: Int = 60

    private let step = 5
    private let minMinutes = 1
    private let maxMinutes = 240

    var body: some View {
        @Bindable var settings = settings
        VStack(spacing: 10) {
            Text("タイマー")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 14) {
                Button {
                    let prevStep = ((minutes - 1) / step) * step
                    minutes = max(minMinutes, prevStep)
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                .buttonStyle(.plain)
                .font(.title2)

                Text("\(minutes) 分")
                    .font(.system(size: 26, weight: .medium, design: .monospaced))
                    .monospacedDigit()
                    .frame(minWidth: 96)

                Button {
                    let nextStep = (minutes / step + 1) * step
                    minutes = min(maxMinutes, nextStep)
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.plain)
                .font(.title2)
            }

            HStack(spacing: 8) {
                Button("キャンセル") {
                    timerModel.setupSheetVisible = false
                }
                .buttonStyle(.bordered)

                if timerModel.isRunning {
                    Button("リセット") {
                        timerModel.stop()
                        timerModel.setupSheetVisible = false
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }

                Button("保存") {
                    settings.timerDefaultMinutes = minutes
                    timerModel.setupSheetVisible = false
                }
                .buttonStyle(.borderedProminent)
            }
            .font(.caption)
            .controlSize(.small)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .foregroundStyle(.white)
        .onAppear {
            minutes = settings.timerDefaultMinutes
        }
    }
}
