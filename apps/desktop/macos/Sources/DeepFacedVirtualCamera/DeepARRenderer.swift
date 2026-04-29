import CoreGraphics
import CoreVideo
import Foundation

public enum EffectRendererMode: String, Hashable {
    case prototypeOverlay
    case deepAR
}

public enum EffectRendererError: LocalizedError {
    case deepARSDKUnavailable
    case missingEffectPackage(String)

    public var errorDescription: String? {
        switch self {
        case .deepARSDKUnavailable:
            return "DeepAR rendering is not available because the native DeepAR SDK and license are not bundled."
        case .missingEffectPackage(let path):
            return "The DeepAR effect package could not be found: \(path)"
        }
    }
}

public protocol EffectFrameRendering {
    var mode: EffectRendererMode { get }

    func render(
        sourcePixelBuffer: CVPixelBuffer,
        normalizedFaceFrame: CGRect?,
        style: MaskRenderStyle,
        effectPackagePath: String
    ) throws -> CVPixelBuffer
}

public final class PrototypeOverlayEffectRenderer: EffectFrameRendering {
    public let mode: EffectRendererMode = .prototypeOverlay
    private let renderer = CompositedFrameRenderer()

    public init() {}

    public func render(
        sourcePixelBuffer: CVPixelBuffer,
        normalizedFaceFrame: CGRect?,
        style: MaskRenderStyle,
        effectPackagePath: String
    ) throws -> CVPixelBuffer {
        try renderer.render(
            sourcePixelBuffer: sourcePixelBuffer,
            normalizedFaceFrame: normalizedFaceFrame,
            style: style
        )
    }
}

public final class DeepAREffectRenderer: EffectFrameRendering {
    public let mode: EffectRendererMode = .deepAR

    public init() {}

    public func render(
        sourcePixelBuffer: CVPixelBuffer,
        normalizedFaceFrame: CGRect?,
        style: MaskRenderStyle,
        effectPackagePath: String
    ) throws -> CVPixelBuffer {
        guard FileManager.default.fileExists(atPath: effectPackagePath) else {
            throw EffectRendererError.missingEffectPackage(effectPackagePath)
        }

        // Integration point for DeepAR's native renderer once the SDK and license are available.
        // The renderer should load effectPackagePath and return a composed CVPixelBuffer.
        throw EffectRendererError.deepARSDKUnavailable
    }
}
