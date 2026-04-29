import CoreGraphics
import CoreImage
import CoreVideo
import Foundation

public struct MaskRenderStyle: Hashable {
    public let red: CGFloat
    public let green: CGFloat
    public let blue: CGFloat
    public let alpha: CGFloat
    public let presetIdentifier: String

    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat = 0.86, presetIdentifier: String) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.presetIdentifier = presetIdentifier
    }
}

public enum VirtualCameraState: Equatable {
    case unavailable
    case stopped
    case starting
    case running(deviceName: String)
    case failed(message: String)
}

public struct RenderedFrame {
    public let timestamp: Date
    public let width: Int
    public let height: Int
    public let bytesPerRow: Int
    public let presetIdentifier: String
    public let normalizedFaceFrame: CGRect?
    public let pixelBufferIdentifier: String
    public let pixelBuffer: CVPixelBuffer?

    public init(
        timestamp: Date,
        width: Int,
        height: Int,
        bytesPerRow: Int,
        presetIdentifier: String,
        normalizedFaceFrame: CGRect?,
        pixelBufferIdentifier: String,
        pixelBuffer: CVPixelBuffer?
    ) {
        self.timestamp = timestamp
        self.width = width
        self.height = height
        self.bytesPerRow = bytesPerRow
        self.presetIdentifier = presetIdentifier
        self.normalizedFaceFrame = normalizedFaceFrame
        self.pixelBufferIdentifier = pixelBufferIdentifier
        self.pixelBuffer = pixelBuffer
    }
}

public protocol VirtualCameraPublishing {
    var state: VirtualCameraState { get }
    func start() async throws
    func publish(frame: RenderedFrame) async throws
    func stop() async
}

public final class MacCameraExtensionPublisher: VirtualCameraPublishing {
    public private(set) var state: VirtualCameraState = .stopped
    public private(set) var lastPublishedFrame: RenderedFrame?

    public init() {}

    public func start() async throws {
        state = .starting
        // TODO: Replace with a Camera Extension system extension publisher.
        state = .running(deviceName: "Deep Faced Camera")
    }

    public func publish(frame: RenderedFrame) async throws {
        guard case .running = state else {
            throw VirtualCameraError.notRunning
        }

        lastPublishedFrame = frame
    }

    public func stop() async {
        state = .stopped
    }
}

public enum VirtualCameraError: Error {
    case notRunning
    case cannotCreatePixelBuffer
    case cannotCreateGraphicsContext
}

public final class CompositedFrameRenderer {
    private let ciContext = CIContext()

    public init() {}

    public func render(
        sourcePixelBuffer: CVPixelBuffer,
        normalizedFaceFrame: CGRect?,
        style: MaskRenderStyle
    ) throws -> CVPixelBuffer {
        let width = CVPixelBufferGetWidth(sourcePixelBuffer)
        let height = CVPixelBufferGetHeight(sourcePixelBuffer)
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

        ciContext.render(CIImage(cvPixelBuffer: sourcePixelBuffer), to: outputBuffer)
        try drawMask(on: outputBuffer, normalizedFaceFrame: normalizedFaceFrame, style: style)
        return outputBuffer
    }

    private func drawMask(
        on pixelBuffer: CVPixelBuffer,
        normalizedFaceFrame: CGRect?,
        style: MaskRenderStyle
    ) throws {
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

        guard
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer),
            let context = CGContext(
                data: baseAddress,
                width: CVPixelBufferGetWidth(pixelBuffer),
                height: CVPixelBufferGetHeight(pixelBuffer),
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
            )
        else {
            throw VirtualCameraError.cannotCreateGraphicsContext
        }

        let width = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let height = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let faceRect = normalizedFaceFrame.map { frame in
            CGRect(
                x: frame.midX * width - frame.width * width * 0.72,
                y: frame.midY * height - frame.height * height * 0.9,
                width: frame.width * width * 1.44,
                height: frame.height * height * 1.8
            )
        } ?? CGRect(x: width * 0.39, y: height * 0.22, width: width * 0.22, height: height * 0.42)

        context.setFillColor(CGColor(red: style.red, green: style.green, blue: style.blue, alpha: style.alpha))
        context.setShadow(offset: .zero, blur: 34, color: CGColor(red: style.red, green: style.green, blue: style.blue, alpha: 0.48))
        context.fillEllipse(in: faceRect)
        context.setShadow(offset: .zero, blur: 0)
        context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.76))
        context.setLineWidth(max(4, width * 0.006))
        context.strokeEllipse(in: faceRect)

        let eyeWidth = faceRect.width * 0.22
        let eyeHeight = faceRect.height * 0.08
        let eyeY = faceRect.midY - faceRect.height * 0.16
        context.setFillColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.86))
        context.fillEllipse(in: CGRect(x: faceRect.midX - faceRect.width * 0.27, y: eyeY, width: eyeWidth, height: eyeHeight))
        context.fillEllipse(in: CGRect(x: faceRect.midX + faceRect.width * 0.05, y: eyeY, width: eyeWidth, height: eyeHeight))

        context.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 0.72))
        context.setLineWidth(max(3, width * 0.004))
        let mouth = CGRect(x: faceRect.midX - faceRect.width * 0.18, y: faceRect.midY + faceRect.height * 0.18, width: faceRect.width * 0.36, height: faceRect.height * 0.1)
        context.strokeEllipse(in: mouth)
    }
}
