import CoreMedia
import CoreMediaIO
import CoreVideo
import DeepFacedVirtualCamera
import Foundation

private let providerSource = DeepFacedProviderSource()
private let provider = CMIOExtensionProvider(source: providerSource, clientQueue: nil)

do {
    try provider.addDevice(providerSource.device)
    CMIOExtensionProvider.startService(provider: provider)
    RunLoop.main.run()
} catch {
    NSLog("Deep Faced Camera Extension failed to start: \(error.localizedDescription)")
    exit(1)
}

final class DeepFacedProviderSource: NSObject, CMIOExtensionProviderSource {
    let deviceSource = DeepFacedDeviceSource()
    let device: CMIOExtensionDevice

    override init() {
        device = CMIOExtensionDevice(
            localizedName: "Deep Faced Camera",
            deviceID: UUID(uuidString: "7CF3E5A2-4697-4B20-B955-497486F9E0E1")!,
            legacyDeviceID: "app.deepfaced.camera",
            source: deviceSource
        )
        super.init()
        do {
            try device.addStream(deviceSource.stream)
        } catch {
            NSLog("Unable to add Deep Faced stream: \(error.localizedDescription)")
        }
    }

    var availableProperties: Set<CMIOExtensionProperty> {
        [.providerName, .providerManufacturer]
    }

    func connect(to client: CMIOExtensionClient) throws {}

    func disconnect(from client: CMIOExtensionClient) {}

    func providerProperties(forProperties properties: Set<CMIOExtensionProperty>) throws -> CMIOExtensionProviderProperties {
        let providerProperties = CMIOExtensionProviderProperties(dictionary: [:])
        providerProperties.name = "Deep Faced"
        providerProperties.manufacturer = "Deep Faced"
        return providerProperties
    }

    func setProviderProperties(_ providerProperties: CMIOExtensionProviderProperties) throws {}
}

final class DeepFacedDeviceSource: NSObject, CMIOExtensionDeviceSource {
    let streamSource = DeepFacedStreamSource()
    let stream: CMIOExtensionStream

    override init() {
        stream = CMIOExtensionStream(
            localizedName: "Deep Faced Output",
            streamID: UUID(uuidString: "94A3BBA7-92C8-41E3-B5F8-7F67C65D150C")!,
            direction: .source,
            clockType: .hostTime,
            source: streamSource
        )
        super.init()
        streamSource.stream = stream
    }

    var availableProperties: Set<CMIOExtensionProperty> {
        [.deviceModel, .deviceTransportType]
    }

    func deviceProperties(forProperties properties: Set<CMIOExtensionProperty>) throws -> CMIOExtensionDeviceProperties {
        let deviceProperties = CMIOExtensionDeviceProperties(dictionary: [:])
        deviceProperties.model = "Deep Faced Virtual Camera"
        deviceProperties.transportType = 0
        return deviceProperties
    }

    func setDeviceProperties(_ deviceProperties: CMIOExtensionDeviceProperties) throws {}
}

final class DeepFacedStreamSource: NSObject, CMIOExtensionStreamSource {
    weak var stream: CMIOExtensionStream?

    private let width = 1280
    private let height = 720
    private let frameDuration = CMTime(value: 1, timescale: 30)
    private let renderer = CompositedFrameRenderer()
    private var timer: DispatchSourceTimer?
    private var sequenceNumber: Int64 = 0

    lazy var formats: [CMIOExtensionStreamFormat] = {
        var description: CMFormatDescription?
        CMVideoFormatDescriptionCreate(
            allocator: kCFAllocatorDefault,
            codecType: kCVPixelFormatType_32BGRA,
            width: Int32(width),
            height: Int32(height),
            extensions: nil,
            formatDescriptionOut: &description
        )

        guard let description else {
            return []
        }

        return [
            CMIOExtensionStreamFormat(
                formatDescription: description,
                maxFrameDuration: frameDuration,
                minFrameDuration: frameDuration,
                validFrameDurations: nil
            )
        ]
    }()

    var availableProperties: Set<CMIOExtensionProperty> {
        [.streamActiveFormatIndex, .streamFrameDuration]
    }

    func streamProperties(forProperties properties: Set<CMIOExtensionProperty>) throws -> CMIOExtensionStreamProperties {
        let streamProperties = CMIOExtensionStreamProperties(dictionary: [:])
        streamProperties.activeFormatIndex = 0
        streamProperties.frameDuration = frameDuration
        return streamProperties
    }

    func setStreamProperties(_ streamProperties: CMIOExtensionStreamProperties) throws {}

    func authorizedToStartStream(for client: CMIOExtensionClient) -> Bool {
        true
    }

    func startStream() throws {
        guard timer == nil else {
            return
        }

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue(label: "app.deepfaced.camera-extension.frames"))
        timer.schedule(deadline: .now(), repeating: .milliseconds(33), leeway: .milliseconds(4))
        timer.setEventHandler { [weak self] in
            self?.sendNextFrame()
        }
        self.timer = timer
        timer.resume()
    }

    func stopStream() throws {
        timer?.cancel()
        timer = nil
    }

    private func sendNextFrame() {
        guard let stream, let sampleBuffer = makeSampleBuffer() else {
            return
        }

        let hostTime = CMClockGetTime(CMClockGetHostTimeClock())
        let hostTimeNanoseconds = UInt64(Double(hostTime.value) / Double(hostTime.timescale) * 1_000_000_000)
        stream.send(sampleBuffer, discontinuity: [], hostTimeInNanoseconds: hostTimeNanoseconds)
    }

    private func makeSampleBuffer() -> CMSampleBuffer? {
        do {
            let source = try makeBasePixelBuffer()
            let normalizedFace = animatedFaceFrame()
            let composed = try renderer.render(
                sourcePixelBuffer: source,
                normalizedFaceFrame: normalizedFace,
                style: MaskRenderStyle(red: 0.13, green: 0.83, blue: 0.93, presetIdentifier: "camera-extension")
            )

            var formatDescription: CMVideoFormatDescription?
            CMVideoFormatDescriptionCreateForImageBuffer(
                allocator: kCFAllocatorDefault,
                imageBuffer: composed,
                formatDescriptionOut: &formatDescription
            )

            guard let formatDescription else {
                return nil
            }

            var timing = CMSampleTimingInfo(
                duration: frameDuration,
                presentationTimeStamp: CMTime(value: sequenceNumber, timescale: 30),
                decodeTimeStamp: .invalid
            )
            var sampleBuffer: CMSampleBuffer?
            CMSampleBufferCreateReadyWithImageBuffer(
                allocator: kCFAllocatorDefault,
                imageBuffer: composed,
                formatDescription: formatDescription,
                sampleTiming: &timing,
                sampleBufferOut: &sampleBuffer
            )
            sequenceNumber += 1
            return sampleBuffer
        } catch {
            NSLog("Unable to create Deep Faced camera frame: \(error.localizedDescription)")
            return nil
        }
    }

    private func makeBasePixelBuffer() throws -> CVPixelBuffer {
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true,
            kCVPixelBufferIOSurfacePropertiesKey: [:],
        ]
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            width,
            height,
            kCVPixelFormatType_32BGRA,
            attributes as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let pixelBuffer else {
            throw VirtualCameraError.cannotCreatePixelBuffer
        }

        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, []) }

        guard
            let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer),
            let context = CGContext(
                data: baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
            )
        else {
            throw VirtualCameraError.cannotCreateGraphicsContext
        }

        let phase = CGFloat(sequenceNumber % 120) / 120
        context.setFillColor(CGColor(red: 0.02, green: 0.03 + phase * 0.05, blue: 0.09, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        context.setFillColor(CGColor(red: 0.12, green: 0.08, blue: 0.24, alpha: 0.86))
        context.fillEllipse(in: CGRect(x: 420, y: 170, width: 440, height: 500))
        return pixelBuffer
    }

    private func animatedFaceFrame() -> CGRect {
        let phase = CGFloat(sequenceNumber % 180) / 180
        return CGRect(x: 0.38 + sin(phase * .pi * 2) * 0.04, y: 0.22, width: 0.24, height: 0.46)
    }
}
