import AppKit

class FloatingPanel: NSPanel {

    init(contentView: NSView) {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 52),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )

        self.contentView = contentView
        level = .floating
        isFloatingPanel = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        animationBehavior = .utilityWindow
    }

    override var canBecomeKey: Bool { true }

    override func close() {
        super.close()
        NSApp.terminate(nil)
    }
}
