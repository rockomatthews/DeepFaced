import CoreGraphics
import CoreVideo
import DeepAR
import DeepFacedVirtualCamera
import Foundation

final class NativeDeepAREffectRenderer: EffectFrameRendering {
    let mode: EffectRendererMode = .deepAR

    private let deepAR = DeepAR()
    private let licenseKey: String
    private var isInitialized = false
    private var currentEffectPackagePath: String?
    private var renderSize: CGSize = .zero

    init?(licenseKey: String?) {
        guard let licenseKey, !licenseKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        self.licenseKey = licenseKey
        deepAR.setLicenseKey(licenseKey)
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
        try initializeIfNeeded(width: width, height: height)
        switchEffectIfNeeded(effectPackagePath)

        let outputBuffer = try makeOutputBuffer(width: width, height: height)
        deepAR.processFrameAndReturn(sourcePixelBuffer, outputBuffer: outputBuffer, mirror: true)
        return outputBuffer
    }

    private func initializeIfNeeded(width: Int, height: Int) throws {
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

        deepAR.switchEffect(withSlot: "effect", path: effectPackagePath)
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
}

enum DeepARLicense {
    static func current() -> String? {
        if let environmentValue = ProcessInfo.processInfo.environment["DEEPAR_LICENSE_KEY"], !environmentValue.isEmpty {
            return environmentValue
        }

        return Bundle.main.object(forInfoDictionaryKey: "DeepARLicenseKey") as? String
    }
}
