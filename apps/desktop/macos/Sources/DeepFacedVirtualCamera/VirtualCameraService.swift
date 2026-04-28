import Foundation

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
    public let pixelBufferIdentifier: String

    public init(timestamp: Date, width: Int, height: Int, bytesPerRow: Int, pixelBufferIdentifier: String) {
        self.timestamp = timestamp
        self.width = width
        self.height = height
        self.bytesPerRow = bytesPerRow
        self.pixelBufferIdentifier = pixelBufferIdentifier
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

        _ = frame
    }

    public func stop() async {
        state = .stopped
    }
}

public enum VirtualCameraError: Error {
    case notRunning
}
