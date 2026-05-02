import CoreGraphics
import CoreMedia
import CoreVideo
import DeepAR
import DeepFacedVirtualCamera
import Dispatch
import Foundation

final class NativeDeepAREffectRenderer: NSObject, EffectFrameRendering, DeepARDelegate {
    let mode: EffectRendererMode = .deepAR

    private let deepAR = DeepAR()
    private let licenseKey: String
    private var isInitialized = false
    private var currentEffectPackagePath: String?
    private var renderSize: CGSize = .zero
    private var latestFrameBuffer: CVPixelBuffer?
    private var lastErrorMessage: String?

    init?(licenseKey: String?) {
        guard let licenseKey, !licenseKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        self.licenseKey = licenseKey
        super.init()
        deepAR.setLicenseKey(licenseKey)
        deepAR.delegate = self
        deepAR.changeLiveMode(false)
    }

    func render(
        sourcePixelBuffer: CVPixelBuffer,
        normalizedFaceFrame: CGRect?,
        style: MaskRenderStyle,
        effectPackagePath: String
    ) throws -> CVPixelBuffer {
        guard FileManager.default.fileExists(atPath: effectPackagePath) else {
            throw EffectRendererError.missingEffectPackage(effectPackagePath)
        }

        let width = CVPixelBufferGetWidth(sourcePixelBuffer)
        let height = CVPixelBufferGetHeight(sourcePixelBuffer)
        performOnMainThread {
            self.initializeIfNeeded(width: width, height: height)
            self.switchEffectIfNeeded(effectPackagePath)
            self.deepAR.processFrame(sourcePixelBuffer, mirror: true)
        }

        return latestFrameBuffer ?? sourcePixelBuffer
    }

    func frameAvailable(_ sampleBuffer: CMSampleBuffer!) {
        guard let sampleBuffer, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        latestFrameBuffer = pixelBuffer
    }

    func onError(withCode code: ARErrorType, error: String!) {
        lastErrorMessage = error
    }

    private func initializeIfNeeded(width: Int, height: Int) {
        let nextSize = CGSize(width: width, height: height)

        guard !isInitialized || renderSize != nextSize else {
            return
        }

        renderSize = nextSize
        deepAR.initializeOffscreen(withWidth: width, height: height)
        deepAR.startCapture(
            withOutputWidthAndFormat: width,
            outputHeight: height,
            subframe: CGRect(x: 0, y: 0, width: 1, height: 1),
            outputImageFormat: .BGRA
        )
        isInitialized = true
    }

    private func switchEffectIfNeeded(_ effectPackagePath: String) {
        guard currentEffectPackagePath != effectPackagePath else {
            return
        }

        deepAR.switchEffect(withSlot: "mask", path: effectPackagePath)
        currentEffectPackagePath = effectPackagePath
    }

    private func makeOutputBuffer(width: Int, height: Int) throws -> CVPixelBuffer {
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: [:],
        ]
        var outputBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &outputBuffer
        )

        guard status == kCVReturnSuccess, let outputBuffer else {
            throw VirtualCameraError.cannotCreatePixelBuffer
        }

        return outputBuffer
    }

    private func performOnMainThread(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.sync(execute: work)
        }
    }
}

enum DeepARLicense {
    static func current() -> String? {
        if let environmentValue = ProcessInfo.processInfo.environment["DEEPAR_LICENSE_KEY"], !environmentValue.isEmpty {
            return environmentValue
        }

        return Bundle.main.object(forInfoDictionaryKey: "DeepARLicenseKey") as? String
    }
}
