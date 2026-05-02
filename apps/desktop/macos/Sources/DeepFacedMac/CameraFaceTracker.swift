import AVFoundation
import AppKit
import CoreImage
import DeepFacedVirtualCamera
import SwiftUI
import Vision

final class CameraFaceTracker: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var faceFrame: CGRect?
    @Published var cameraStatus = "Camera not started."
    @Published var renderedPreviewImage: CGImage?
    @Published var isShowingRenderedOutput = false

    let session = AVCaptureSession()
    var activePresetIdentifier = "cyber-visor"
    var activeEffectPackagePath = "/effects/cyber-visor.deepar"
    var activeMaskStyle = MaskRenderStyle(red: 0.13, green: 0.83, blue: 0.93, presetIdentifier: "cyber-visor")
    var renderedFrameHandler: ((RenderedFrame) -> Void)?

    private let prototypeRenderer = PrototypeOverlayEffectRenderer()
    private let deepARRenderer = NativeDeepAREffectRenderer(licenseKey: DeepARLicense.current())
    private let videoOutput = AVCaptureVideoDataOutput()
    private let imageContext = CIContext()
    private let captureQueue = DispatchQueue(label: "app.deepfaced.camera.capture")
    private let visionQueue = DispatchQueue(label: "app.deepfaced.camera.vision")
    private var isProcessingFrame = false

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStartSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.configureAndStartSession()
                    } else {
                        self?.cameraStatus = "Camera permission was denied."
                    }
                }
            }
        case .denied, .restricted:
            cameraStatus = "Camera permission is required to track your face."
        @unknown default:
            cameraStatus = "Unknown camera permission state."
        }
    }

    func stop() {
        captureQueue.async { [weak self] in
            self?.session.stopRunning()
        }
    }

    func switchEffect(identifier: String, packagePath: String, style: MaskRenderStyle) {
        activePresetIdentifier = identifier
        activeEffectPackagePath = packagePath
        activeMaskStyle = style
        renderedPreviewImage = nil
        isShowingRenderedOutput = false
        cameraStatus = "Loading effect..."
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard !isProcessingFrame, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        isProcessingFrame = true
        let request = VNDetectFaceRectanglesRequest { [weak self] request, _ in
            guard let self else {
                return
            }

            let face = (request.results as? [VNFaceObservation])?.first
            let nextFrame = face.map { observation in
                Self.previewFrame(from: observation.boundingBox)
            }

            do {
                let renderer: EffectFrameRendering
                if let deepARRenderer = self.deepARRenderer {
                    renderer = deepARRenderer
                } else {
                    renderer = self.prototypeRenderer
                }
                let composedBuffer = try renderer.render(
                    sourcePixelBuffer: pixelBuffer,
                    normalizedFaceFrame: nextFrame,
                    style: self.activeMaskStyle,
                    effectPackagePath: self.activeEffectPackagePath
                )
                let renderedFrame = RenderedFrame(
                    timestamp: Date(),
                    width: CVPixelBufferGetWidth(composedBuffer),
                    height: CVPixelBufferGetHeight(composedBuffer),
                    bytesPerRow: CVPixelBufferGetBytesPerRow(composedBuffer),
                    presetIdentifier: self.activePresetIdentifier,
                    normalizedFaceFrame: nextFrame,
                    pixelBufferIdentifier: "\(self.activePresetIdentifier)-\(CMSampleBufferGetPresentationTimeStamp(sampleBuffer).seconds)",
                    pixelBuffer: composedBuffer
                )
                let didReceiveDeepARFrame = renderer.mode != .deepAR || composedBuffer !== pixelBuffer
                let previewFrame = self.makePreviewFrame(
                    from: composedBuffer,
                    renderedBy: didReceiveDeepARFrame ? renderer.mode : .prototypeOverlay
                )

                DispatchQueue.main.async {
                    self.faceFrame = nextFrame
                    self.renderedPreviewImage = previewFrame.image
                    self.isShowingRenderedOutput = previewFrame.image != nil
                    let rendererLabel = renderer.mode == .deepAR ? "DeepAR" : "prototype"
                    let outputLabel = !didReceiveDeepARFrame && renderer.mode == .deepAR
                        ? "Waiting for DeepAR effect frames, showing live camera."
                        : previewFrame.image == nil && renderer.mode == .deepAR
                        ? "DeepAR returned a blank frame, showing live camera."
                        : "Showing \(rendererLabel) output."
                    self.cameraStatus = nextFrame == nil
                        ? "Looking for a face. \(outputLabel)"
                        : "Face locked. \(outputLabel)"
                    self.renderedFrameHandler?(renderedFrame)
                    self.isProcessingFrame = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.cameraStatus = "Frame composition failed: \(error.localizedDescription)"
                    self.isProcessingFrame = false
                }
            }
        }

        visionQueue.async {
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .upMirrored)
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.cameraStatus = "Face tracking failed: \(error.localizedDescription)"
                    self.isProcessingFrame = false
                }
            }
        }
    }

    private func makePreviewFrame(from pixelBuffer: CVPixelBuffer, renderedBy mode: EffectRendererMode) -> (image: CGImage?, isBlank: Bool) {
        let isBlank = mode == .deepAR && Self.isMostlyBlank(pixelBuffer)
        guard !isBlank else {
            return (nil, true)
        }

        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let rect = CGRect(
            x: 0,
            y: 0,
            width: CVPixelBufferGetWidth(pixelBuffer),
            height: CVPixelBufferGetHeight(pixelBuffer)
        )
        return (imageContext.createCGImage(image, from: rect), false)
    }

    private static func isMostlyBlank(_ pixelBuffer: CVPixelBuffer) -> Bool {
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly)
        }

        guard
            CVPixelBufferGetPixelFormatType(pixelBuffer) == kCVPixelFormatType_32BGRA,
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        else {
            return false
        }

        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let pixels = baseAddress.assumingMemoryBound(to: UInt8.self)
        let sampleStepX = max(width / 16, 1)
        let sampleStepY = max(height / 16, 1)
        var sampleCount = 0
        var brightSampleCount = 0

        for y in stride(from: 0, to: height, by: sampleStepY) {
            for x in stride(from: 0, to: width, by: sampleStepX) {
                let offset = y * bytesPerRow + x * 4
                let blue = Int(pixels[offset])
                let green = Int(pixels[offset + 1])
                let red = Int(pixels[offset + 2])
                sampleCount += 1

                if red + green + blue > 36 {
                    brightSampleCount += 1
                }
            }
        }

        return sampleCount > 0 && Double(brightSampleCount) / Double(sampleCount) < 0.02
    }

    private func configureAndStartSession() {
        guard !session.isRunning else {
            return
        }

        captureQueue.async { [weak self] in
            guard let self else {
                return
            }

            self.session.beginConfiguration()
            self.session.sessionPreset = .high

            do {
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .unspecified)

                guard let device else {
                    DispatchQueue.main.async {
                        self.cameraStatus = "No camera device was found."
                    }
                    self.session.commitConfiguration()
                    return
                }

                let input = try AVCaptureDeviceInput(device: device)
                if self.session.canAddInput(input) {
                    self.session.addInput(input)
                }

                self.videoOutput.alwaysDiscardsLateVideoFrames = true
                self.videoOutput.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                self.videoOutput.setSampleBufferDelegate(self, queue: self.captureQueue)

                if self.session.canAddOutput(self.videoOutput) {
                    self.session.addOutput(self.videoOutput)
                }

                self.videoOutput.connection(with: .video)?.isVideoMirrored = true
                self.session.commitConfiguration()
                self.session.startRunning()

                DispatchQueue.main.async {
                    self.cameraStatus = "Camera running. Looking for a face..."
                }
            } catch {
                self.session.commitConfiguration()
                DispatchQueue.main.async {
                    self.cameraStatus = "Unable to start camera: \(error.localizedDescription)"
                }
            }
        }
    }

    private static func previewFrame(from visionBoundingBox: CGRect) -> CGRect {
        CGRect(
            x: visionBoundingBox.minX,
            y: 1 - visionBoundingBox.maxY,
            width: visionBoundingBox.width,
            height: visionBoundingBox.height
        )
    }
}

struct CameraPreview: NSViewRepresentable {
    let session: AVCaptureSession

    func makeNSView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateNSView(_ nsView: PreviewView, context: Context) {
        nsView.previewLayer.session = session
    }
}

final class PreviewView: NSView {
    let previewLayer = AVCaptureVideoPreviewLayer()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer = previewLayer
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layer = previewLayer
    }
}
