import Foundation
import AppKit
import UniformTypeIdentifiers

@MainActor
class RecordingState: ObservableObject {
    @Published var isRecording = false
    @Published private(set) var elapsedTime: TimeInterval = 0

    let recorder = ScreenRecorder()
    let settings: RecordingSettings
    private var timer: Timer?
    private var startTime: Date?

    var formattedTime: String {
        let m = Int(elapsedTime) / 60
        let s = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", m, s)
    }

    init(settings: RecordingSettings) {
        self.settings = settings
    }

    func startRecording() async throws {
        try await recorder.startRecording(
            scale: settings.resolutionScale,
            fps: settings.fps
        )
        isRecording = true
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self, let start = self.startTime else { return }
                self.elapsedTime = Date().timeIntervalSince(start)
            }
        }
    }

    func stopRecording() async throws {
        timer?.invalidate()
        timer = nil

        guard let tempURL = try await recorder.stopRecording() else {
            reset()
            return
        }

        reset()
        await saveFile(from: tempURL)
    }

    private func reset() {
        isRecording = false
        elapsedTime = 0
        startTime = nil
    }

    private static var defaultDirectory: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Recordings", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func saveFile(from tempURL: URL) async {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.movie]
        panel.nameFieldStringValue = tempURL.lastPathComponent
        panel.directoryURL = Self.defaultDirectory
        panel.canCreateDirectories = true

        let response = panel.runModal()

        if response == .OK, let url = panel.url {
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                }
                try FileManager.default.moveItem(at: tempURL, to: url)
            } catch {
                print("Save error: \(error.localizedDescription)")
                try? FileManager.default.removeItem(at: tempURL)
            }
        } else {
            try? FileManager.default.removeItem(at: tempURL)
        }
    }
}
