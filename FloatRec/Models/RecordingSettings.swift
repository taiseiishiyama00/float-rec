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

    func getLastSaveDirectory() -> URL? {
        if let urlString = UserDefaults.standard.string(forKey: "lastSaveDirectory"),
           let url = URL(string: urlString) {
            return url
        }
        return nil
    }

    func setLastSaveDirectory(_ url: URL) {
        UserDefaults.standard.set(url.absoluteString, forKey: "lastSaveDirectory")
    }
}
