import AppKit
import Foundation

final class AyabarAppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var statusView: CatStatusView!
    private var brain: CatBrain!
    private var beatTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: 220)
        statusView = CatStatusView(frame: NSRect(x: 0, y: 0, width: 220, height: 24))

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

        brain = CatBrain { [weak self] frame in
            self?.statusView.set(frame: frame)
        }

        setupEventMonitors()
        scheduleBeat()
    }

    func applicationWillTerminate(_ notification: Notification) {
        beatTimer?.invalidate()
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
        beatTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            self?.brain.tick()
        }
    }
}

final class CatStatusView: NSView {
    private let label: NSTextField = {
        let text = NSTextField(labelWithString: "")
        text.alignment = .center
        text.font = NSFont.monospacedSystemFont(ofSize: 9, weight: .regular)
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
    private enum LookDirection {
        case left
        case center
        case right
    }

    private enum PawPose: CaseIterable {
        case rest
        case leftStep
        case rightStep

        var paws: String {
            switch self {
            case .rest: " /|_|\\ "
            case .leftStep: " _/|_|\\"
            case .rightStep: " /|_|\\_"
            }
        }
    }

    private let render: (String) -> Void

    private var lookDirection: LookDirection = .center
    private var typingTicks = 0
    private var stompIndex = 0

    private var blinkTicks = 0
    private var tongueTicks = 0
    private var blinkCooldown = Int.random(in: 18...45)
    private var tongueCooldown = Int.random(in: 25...80)

    private var tailIndex = 0
    private let tailFrames = ["~", "≈", "~", "﹏"]

    init(render: @escaping (String) -> Void) {
        self.render = render
        render(renderCurrentFrame())
    }

    func tick() {
        tailIndex = (tailIndex + 1) % tailFrames.count

        if typingTicks > 0 {
            typingTicks -= 1
            blinkTicks = max(blinkTicks, 1)
            stompIndex = (stompIndex + 1) % 2
        }

        updateBlinkState()
        updateTongueState()
        render(renderCurrentFrame())
    }

    func reactToKeyPress() {
        typingTicks = max(typingTicks, 12)
    }

    func followCursor(_ point: NSPoint) {
        guard !point.x.isNaN else { return }
        let screenFrame = NSScreen.main?.frame ?? .zero
        let leftThreshold = screenFrame.minX + screenFrame.width * 0.42
        let rightThreshold = screenFrame.minX + screenFrame.width * 0.58

        if point.x < leftThreshold {
            lookDirection = .left
        } else if point.x > rightThreshold {
            lookDirection = .right
        } else {
            lookDirection = .center
        }
    }

    private func updateBlinkState() {
        if blinkTicks > 0 {
            blinkTicks -= 1
            return
        }

        blinkCooldown -= 1
        if blinkCooldown <= 0 {
            blinkTicks = Int.random(in: 2...3)
            blinkCooldown = Int.random(in: 22...58)
        }
    }

    private func updateTongueState() {
        if tongueTicks > 0 {
            tongueTicks -= 1
            return
        }

        tongueCooldown -= 1
        if tongueCooldown <= 0 {
            tongueTicks = Int.random(in: 3...5)
            tongueCooldown = Int.random(in: 45...95)
        }
    }

    private func renderCurrentFrame() -> String {
        let eyes = currentEyes()
        let mouth = tongueTicks > 0 ? "ᴗ⌣" : "ᴗ◡"

        let pawPose: PawPose
        if typingTicks > 0 {
            pawPose = stompIndex.isMultiple(of: 2) ? .leftStep : .rightStep
        } else {
            pawPose = .rest
        }

        return " /\\_/\\ (\(eyes))<\(mouth)>\(pawPose.paws)\(tailFrames[tailIndex])"
    }

    private func currentEyes() -> String {
        if blinkTicks > 0 {
            return "- -"
        }

        switch lookDirection {
        case .left:
            return "◉ ·"
        case .right:
            return "· ◉"
        case .center:
            return "• •"
        }
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
