import Foundation
import SwiftUI
import DeepFacedVirtualCamera

struct FacePreset: Identifiable, Hashable {
    let id: String
    let name: String
    let creator: String
    let accent: Color
    let maskStyle: MaskRenderStyle
    let assetPath: String
}

@MainActor
final class DesktopAppModel: ObservableObject {
    @Published var selectedPreset: FacePreset
    @Published var presets: [FacePreset]
    @Published var cameraState: VirtualCameraState = .stopped
    @Published var statusMessage = "Select a face and start the virtual camera."
    @Published var publishedFrameCount = 0
    @Published var lastPublishedResolution = "No frames yet"

    private let fallbackPresets: [FacePreset] = [
        FacePreset(
            id: "cyber-visor",
            name: "Cyber Visor",
            creator: "lumenforge",
            accent: .cyan,
            maskStyle: MaskRenderStyle(red: 0.13, green: 0.83, blue: 0.93, presetIdentifier: "cyber-visor"),
            assetPath: "/effects/cyber-visor.deepar"
        ),
        FacePreset(
            id: "alien-oracle",
            name: "Alien Oracle",
            creator: "sablemesh",
            accent: .green,
            maskStyle: MaskRenderStyle(red: 0.24, green: 0.82, blue: 0.38, presetIdentifier: "alien-oracle"),
            assetPath: "/effects/alien-oracle.deepar"
        ),
        FacePreset(
            id: "toon-villain",
            name: "Toon Villain",
            creator: "oddmask",
            accent: .orange,
            maskStyle: MaskRenderStyle(red: 0.98, green: 0.36, blue: 0.13, presetIdentifier: "toon-villain"),
            assetPath: "/effects/toon-villain.deepar"
        )
    ]

    private let publisher = MacCameraExtensionPublisher()
    private let effectCatalog = LocalEffectCatalog()
    let tracker = CameraFaceTracker()
    let extensionInstaller = SystemExtensionInstaller()

    init() {
        let loadedPresets = effectCatalog.loadPresets()
        let initialPresets = loadedPresets.isEmpty ? fallbackPresets : loadedPresets
        presets = initialPresets
        selectedPreset = initialPresets[0]
        statusMessage = loadedPresets.isEmpty
            ? "Using starter masks. Add DeepAR effects to macos/Effects."
            : "Loaded \(loadedPresets.count) DeepAR effects. Select an effect to preview it with the DeepAR SDK."
    }

    func select(_ preset: FacePreset) {
        selectedPreset = preset
        statusMessage = "Previewing \(preset.name) with the DeepAR SDK."
    }

    func startVirtualCamera() {
        Task {
            do {
                try await publisher.start()
                cameraState = publisher.state
                tracker.start()
                statusMessage = "Deep Faced Camera is running. Choose it in Zoom, Meet, or Teams."
            } catch {
                cameraState = .failed(message: error.localizedDescription)
                statusMessage = "Unable to start virtual camera: \(error.localizedDescription)"
            }
        }
    }

    func installCameraExtension() {
        extensionInstaller.install()
    }

    func uninstallCameraExtension() {
        extensionInstaller.uninstall()
    }

    func stopVirtualCamera() {
        Task {
            await publisher.stop()
            cameraState = publisher.state
            statusMessage = "Virtual camera stopped."
        }
    }

    private func publishTrackedFrame(_ frame: RenderedFrame) async {
        guard case .running = publisher.state else {
            return
        }

        do {
            try await publisher.publish(frame: frame)
            cameraState = publisher.state
            publishedFrameCount += 1
            lastPublishedResolution = "\(frame.width)x\(frame.height)"
            statusMessage = frame.normalizedFaceFrame == nil
                ? "Publishing camera frames. Looking for a face to attach \(selectedPreset.name)."
                : "Publishing \(selectedPreset.name) with face tracking."
        } catch {
            cameraState = .failed(message: error.localizedDescription)
            statusMessage = "Unable to publish frame: \(error.localizedDescription)"
        }
    }
}
