import AppKit
import DeepAR
import SwiftUI

struct DeepARLivePreview: NSViewRepresentable {
    let effectPackagePath: String

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeNSView(context: Context) -> NSView {
        let view = DeepARContainerView()
        context.coordinator.setPendingEffect(effectPackagePath)
        view.onAttachedToWindow = { [weak coordinator = context.coordinator] containerView in
            coordinator?.startIfNeeded(in: containerView)
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.setPendingEffect(effectPackagePath)
        context.coordinator.switchEffectIfNeeded(effectPackagePath)
    }

    final class Coordinator: NSObject, DeepARDelegate {
        private let deepAR = DeepAR()
        private var cameraController: CameraController?
        private var arView: NSView?
        private var currentEffectPackagePath: String?
        private var pendingEffectPackagePath: String?
        private var isInitialized = false
        private var isStarted = false
        private var didStart = false

        func setPendingEffect(_ effectPackagePath: String) {
            pendingEffectPackagePath = effectPackagePath
        }

        func startIfNeeded(in containerView: DeepARContainerView) {
            guard !didStart else {
                if let arView {
                    containerView.install(arView)
                }
                if let pendingEffectPackagePath {
                    switchEffectIfNeeded(pendingEffectPackagePath)
                }
                return
            }

            didStart = true

            if let arView {
                containerView.install(arView)
                if let pendingEffectPackagePath {
                    switchEffectIfNeeded(pendingEffectPackagePath)
                }
                return
            }

            guard let licenseKey = DeepARLicense.current() else {
                containerView.showMessage("Missing DeepAR license key.")
                return
            }

            deepAR.setLicenseKey(licenseKey)
            deepAR.delegate = self

            guard let view = deepAR.initializeView(withFrame: NSScreen.main?.visibleFrame ?? containerView.bounds) else {
                containerView.showMessage("DeepAR could not create a preview view.")
                return
            }
            arView = view
            containerView.install(view)
            NSLog("Deep Faced DeepAR view installed. containerWindow=\(containerView.window != nil)")

            guard let controller = CameraController() else {
                containerView.showMessage("DeepAR could not create a camera controller.")
                return
            }
            controller.deepAR = deepAR
            controller.preset = .hd1280x720
            cameraController = controller
            controller.startCamera()
            isStarted = true
            deepAR.resume()
            NSLog("Deep Faced DeepAR camera started.")

            if isInitialized {
                switchEffectIfNeeded(pendingEffectPackagePath)
            }
        }

        func switchEffectIfNeeded(_ effectPackagePath: String?) {
            guard let effectPackagePath else {
                return
            }

            guard isStarted, isInitialized, currentEffectPackagePath != effectPackagePath else {
                return
            }

            guard FileManager.default.fileExists(atPath: effectPackagePath) else {
                return
            }

            deepAR.switchEffect(withSlot: "effect", path: effectPackagePath)
            currentEffectPackagePath = effectPackagePath
            NSLog("Deep Faced requested effect switch: \(effectPackagePath)")
        }

        @objc(didInitialize)
        func didInitialize() {
            isInitialized = true
            NSLog("Deep Faced DeepAR didInitialize.")
            switchEffectIfNeeded(pendingEffectPackagePath)
        }

        @objc(didSwitchEffect:)
        func didSwitchEffect(_ slot: String!) {
            NSLog("DeepAR switched effect slot: \(slot ?? "unknown")")
        }

        @objc(onErrorWithCode:error:)
        func onError(withCode code: ARErrorType, error: String!) {
            NSLog("DeepAR error \(code.rawValue): \(error ?? "unknown")")
        }

        deinit {
            deepAR.pause()
            deepAR.shutdown()
        }
    }
}

final class DeepARContainerView: NSView {
    private let messageLabel = NSTextField(labelWithString: "")
    var onAttachedToWindow: ((DeepARContainerView) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.cgColor

        messageLabel.textColor = .secondaryLabelColor
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layout() {
        super.layout()
        subviews
            .filter { $0 !== messageLabel }
            .forEach { $0.frame = bounds }
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        guard window != nil else {
            return
        }

        onAttachedToWindow?(self)
    }

    func install(_ arView: NSView) {
        messageLabel.stringValue = ""
        if arView.superview !== self {
            addSubview(arView, positioned: .below, relativeTo: messageLabel)
        }
        arView.frame = bounds
        arView.autoresizingMask = [.width, .height]
    }

    func showMessage(_ message: String) {
        messageLabel.stringValue = message
    }
}
