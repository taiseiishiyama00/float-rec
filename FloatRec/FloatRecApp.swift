import SwiftUI
import AppKit

@main
struct FloatRecApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var panel: FloatingPanel!
    private let settings = RecordingSettings()
    private lazy var recordingState = RecordingState(settings: settings)

    func applicationDidFinishLaunching(_ notification: Notification) {
        let view = FloatingPanelView(state: recordingState, settings: settings)
        panel = FloatingPanel(contentView: NSHostingView(rootView: view))
        panel.orderFrontRegardless()
        restorePosition()

        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak panel] _ in
            guard let origin = panel?.frame.origin else { return }
            UserDefaults.standard.set(origin.x, forKey: "panelX")
            UserDefaults.standard.set(origin.y, forKey: "panelY")
        }
    }

    private func restorePosition() {
        let d = UserDefaults.standard
        guard d.object(forKey: "panelX") != nil else {
            positionDefault()
            return
        }
        let x = d.double(forKey: "panelX")
        let y = d.double(forKey: "panelY")
        let point = NSPoint(x: x, y: y)

        // Validate that the saved position is still on a connected screen
        let panelSize = panel.frame.size
        let testRect = NSRect(origin: point, size: panelSize)
        let onScreen = NSScreen.screens.contains { screen in
            screen.visibleFrame.intersects(testRect)
        }

        if onScreen {
            panel.setFrameOrigin(point)
        } else {
            positionDefault()
        }
    }

    private func positionDefault() {
        guard let screen = NSScreen.main else { return }
        let frame = screen.visibleFrame
        let x = frame.maxX - panel.frame.width - 20
        let y = frame.maxY - panel.frame.height - 20
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
