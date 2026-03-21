import Foundation

@MainActor
class RecordingSettings: ObservableObject {
    @Published var resolutionScale: Int {
        didSet { UserDefaults.standard.set(resolutionScale, forKey: "resolutionScale") }
    }
    @Published var fps: Int {
        didSet { UserDefaults.standard.set(fps, forKey: "fps") }
    }

    init() {
        let d = UserDefaults.standard
        d.register(defaults: [
            "resolutionScale": 2,
            "fps": 60,
        ])
        self.resolutionScale = d.integer(forKey: "resolutionScale")
        self.fps = d.integer(forKey: "fps")
    }
}
