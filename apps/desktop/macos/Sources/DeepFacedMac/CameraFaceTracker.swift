import AVFoundation
import AppKit
import DeepFacedVirtualCamera
import SwiftUI
import Vision

final class CameraFaceTracker: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var faceFrame: CGRect?
    @Published var cameraStatus = "Camera not started."

    let session = AVCaptureSession()
    var activePresetIdentifier = "cyber-visor"
    var activeMaskStyle = MaskRenderStyle(red: 0.13, green: 0.83, blue: 0.93, presetIdentifier: "cyber-visor")
    var renderedFrameHandler: ((RenderedFrame) -> Void)?

    private let renderer = CompositedFrameRenderer()
    private let videoOutput = AVCaptureVideoDataOutput()
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
                let composedBuffer = try self.renderer.render(
                    sourcePixelBuffer: pixelBuffer,
                    normalizedFaceFrame: nextFrame,
                    style: self.activeMaskStyle
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

                DispatchQueue.main.async {
                    self.faceFrame = nextFrame
                    self.cameraStatus = nextFrame == nil ? "Looking for a face..." : "Face locked. Mask follows your head."
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
    override var wantsUpdateLayer: Bool {
        true
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }

    override func makeBackingLayer() -> CALayer {
        AVCaptureVideoPreviewLayer()
    }
}
