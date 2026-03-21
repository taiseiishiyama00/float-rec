import SwiftUI

struct FloatingPanelView: View {
    @ObservedObject var state: RecordingState
    @ObservedObject var settings: RecordingSettings
    @State private var isHovering = false
    @State private var isPulsing = false
    @State private var showSettings = false

    var body: some View {
        HStack(spacing: 10) {
            // Record / Stop button
            Button(action: toggle) {
                Image(systemName: state.isRecording ? "stop.fill" : "record.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(state.isRecording ? .white : .red)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.plain)

            if state.isRecording {
                Text(state.formattedTime)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(.white)

                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                    .shadow(color: .red, radius: 4)
                    .opacity(isPulsing ? 0.3 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                        value: isPulsing
                    )
                    .onAppear { isPulsing = true }
                    .onDisappear { isPulsing = false }
            }

            if !state.isRecording {
                // Settings button
                Button(action: { showSettings.toggle() }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .popover(isPresented: $showSettings, arrowEdge: .bottom) {
                    SettingsPopoverView(settings: settings)
                }

                // Close button
                Button(action: { NSApp.terminate(nil) }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    state.isRecording
                        ? Color.red.opacity(0.85)
                        : Color(.windowBackgroundColor).opacity(0.9)
                )
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
        }
        .scaleEffect(isHovering ? 1.03 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovering)
        .onHover { isHovering = $0 }
    }

    private func toggle() {
        Task {
            do {
                if state.isRecording {
                    try await state.stopRecording()
                } else {
                    try await state.startRecording()
                }
            } catch {
                print("Recording error: \(error.localizedDescription)")
            }
        }
    }
}
