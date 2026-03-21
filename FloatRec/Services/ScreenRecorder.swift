import ScreenCaptureKit
import AVFoundation
import CoreMedia

class ScreenRecorder: NSObject, SCStreamOutput {
    private var stream: SCStream?
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var outputURL: URL?
    private var sessionStarted = false
    private var isActive = false
    private let outputQueue = DispatchQueue(label: "com.floatrec.output")

    func startRecording(scale: Int, fps: Int) async throws {
        let content = try await SCShareableContent.excludingDesktopWindows(
            false, onScreenWindowsOnly: true
        )
        guard let display = content.displays.first else {
            throw RecordingError.noDisplay
        }

        let filter = SCContentFilter(display: display, excludingWindows: [])

        let config = SCStreamConfiguration()
        config.width = display.width * scale
        config.height = display.height * scale
        config.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale(fps))
        config.showsCursor = true

        let fileName = "FloatRec_\(Self.timestamp()).mov"
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(fileName)
        outputURL = url

        let writer = try AVAssetWriter(outputURL: url, fileType: .mov)

        videoInput = AVAssetWriterInput(
            mediaType: .video,
            outputSettings: [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: config.width,
                AVVideoHeightKey: config.height,
            ]
        )
        videoInput!.expectsMediaDataInRealTime = true
        writer.add(videoInput!)

        assetWriter = writer
        writer.startWriting()
        sessionStarted = false
        isActive = true

        stream = SCStream(filter: filter, configuration: config, delegate: nil)
        try stream!.addStreamOutput(self, type: .screen, sampleHandlerQueue: outputQueue)
        try await stream!.startCapture()
    }

    func stopRecording() async throws -> URL? {
        isActive = false

        if let stream {
            try await stream.stopCapture()
        }
        stream = nil

        await withCheckedContinuation { (c: CheckedContinuation<Void, Never>) in
            outputQueue.async { c.resume() }
        }

        guard let writer = assetWriter, sessionStarted else {
            if let url = outputURL {
                try? FileManager.default.removeItem(at: url)
            }
            cleanup()
            return nil
        }

        videoInput?.markAsFinished()
        await writer.finishWriting()

        let url = outputURL
        cleanup()
        return url
    }

    private func cleanup() {
        assetWriter = nil
        videoInput = nil
        outputURL = nil
        sessionStarted = false
        isActive = false
    }

    // MARK: - SCStreamOutput

    func stream(
        _ stream: SCStream,
        didOutputSampleBuffer sampleBuffer: CMSampleBuffer,
        of type: SCStreamOutputType
    ) {
        guard isActive, sampleBuffer.isValid, assetWriter?.status == .writing else { return }

        if !sessionStarted {
            guard type == .screen else { return }
            guard CMSampleBufferGetImageBuffer(sampleBuffer) != nil else { return }
            assetWriter?.startSession(atSourceTime: sampleBuffer.presentationTimeStamp)
            sessionStarted = true
        }

        switch type {
        case .screen:
            guard CMSampleBufferGetImageBuffer(sampleBuffer) != nil else { return }
            if videoInput?.isReadyForMoreMediaData == true {
                videoInput?.append(sampleBuffer)
            }
        default:
            break
        }
    }

    private static func timestamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return f.string(from: Date())
    }
}

enum RecordingError: LocalizedError {
    case noDisplay

    var errorDescription: String? {
        switch self {
        case .noDisplay: return "ディスプレイが見つかりません"
        }
    }
}
