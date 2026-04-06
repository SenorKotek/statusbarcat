import AppKit
import Foundation

final class AyabarAppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var statusView: CatStatusView!
    private var brain: CatBrain!

    private var beatTimer: Timer?
    private var spinTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: 86)
        statusView = CatStatusView(frame: NSRect(x: 0, y: 0, width: 86, height: 24))

        if let button = statusItem.button {
            button.title = ""
            button.addSubview(statusView)
            statusView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                statusView.leadingAnchor.constraint(equalTo: button.leadingAnchor),
                statusView.trailingAnchor.constraint(equalTo: button.trailingAnchor),
                statusView.topAnchor.constraint(equalTo: button.topAnchor),
                statusView.bottomAnchor.constraint(equalTo: button.bottomAnchor)
            ])
        }

        brain = CatBrain {
            [weak self] frame in
            self?.statusView.set(frame: frame)
        }

        setupEventMonitors()
        scheduleBeat()
        scheduleSpin()
    }

    func applicationWillTerminate(_ notification: Notification) {
        beatTimer?.invalidate()
        spinTimer?.invalidate()
    }

    private func setupEventMonitors() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.brain.reactToKeyPress()
            return event
        }

        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] _ in
            self?.brain.reactToKeyPress()
        }

        NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.brain.followCursor(event.locationInWindow)
        }

        NSEvent.addLocalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            self?.brain.followCursor(event.locationInWindow)
            return event
        }
    }

    private func scheduleBeat() {
        beatTimer = Timer.scheduledTimer(withTimeInterval: 0.16, repeats: true) { [weak self] _ in
            self?.brain.tick()
        }
    }

    private func scheduleSpin() {
        spinTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 6...14), repeats: false) { [weak self] _ in
            self?.brain.startSpin()
            self?.scheduleSpin()
        }
    }
}

final class CatStatusView: NSView {
    private let label: NSTextField = {
        let text = NSTextField(labelWithString: "")
        text.alignment = .center
        text.font = NSFont.monospacedSystemFont(ofSize: 9, weight: .medium)
        text.textColor = .labelColor
        text.lineBreakMode = .byClipping
        return text
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(frame: String) {
        label.stringValue = frame
    }
}

final class CatBrain {
    private struct Frames {
        static let breathe: [String] = [
            "ᓚᘏᗢ~",
            "ᓚᘏᗢ~~",
            "ᓚᘏᗢ~"
        ]

        static let leftPaw = "ᓚᘏᗢ/"
        static let rightPaw = "\\ᓚᘏᗢ"

        static let spin: [String] = [
            "ᓚᘏᗢ~",
            "(ᓚᘏᗢ)",
            "~ᓚᘏᗢ",
            "(ᓚᘏᗢ)"
        ]

        static let tail: [String] = [
            "ᓚᘏᗢ~",
            "ᓚᘏᗢ≈",
            "ᓚᘏᗢ~"
        ]
    }

    private let render: (String) -> Void

    private var breathIndex = 0
    private var tailIndex = 0
    private var spinIndex = 0
    private var spinTicks = 0
    private var pawTicks = 0
    private var lookLeft = false

    init(render: @escaping (String) -> Void) {
        self.render = render
        render(Frames.breathe[0])
    }

    func tick() {
        if spinTicks > 0 {
            render(Frames.spin[spinIndex % Frames.spin.count])
            spinIndex += 1
            spinTicks -= 1
            return
        }

        if pawTicks > 0 {
            let paw = pawTicks.isMultiple(of: 2) ? Frames.leftPaw : Frames.rightPaw
            pawTicks -= 1
            render(applyLook(to: paw))
            return
        }

        breathIndex = (breathIndex + 1) % Frames.breathe.count
        tailIndex = (tailIndex + 1) % Frames.tail.count

        let frame = breathIndex.isMultiple(of: 2) ? Frames.breathe[breathIndex] : Frames.tail[tailIndex]
        render(applyLook(to: frame))
    }

    func reactToKeyPress() {
        pawTicks = 6
    }

    func followCursor(_ point: NSPoint) {
        if point.x.isNaN { return }
        lookLeft = point.x < NSScreen.main?.frame.midX ?? 0
    }

    func startSpin() {
        spinTicks = 8
        spinIndex = 0
    }

    private func applyLook(to frame: String) -> String {
        guard lookLeft else { return frame }
        return String(frame.reversed())
    }
}


@main
enum AyabarMain {
    static func main() {
        let app = NSApplication.shared
        let delegate = AyabarAppDelegate()
        app.delegate = delegate
        app.run()
    }
}
