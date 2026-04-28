import Foundation
import SwiftUI
import DeepFacedVirtualCamera

struct FacePreset: Identifiable, Hashable {
    let id: String
    let name: String
    let creator: String
    let accent: Color
    let assetPath: String
}

@MainActor
final class DesktopAppModel: ObservableObject {
    @Published var selectedPreset: FacePreset
    @Published var cameraState: VirtualCameraState = .stopped
    @Published var statusMessage = "Select a face and start the virtual camera."

    let presets: [FacePreset] = [
        FacePreset(id: "cyber-visor", name: "Cyber Visor", creator: "lumenforge", accent: .cyan, assetPath: "/effects/cyber-visor.deepar"),
        FacePreset(id: "alien-oracle", name: "Alien Oracle", creator: "sablemesh", accent: .green, assetPath: "/effects/alien-oracle.deepar"),
        FacePreset(id: "toon-villain", name: "Toon Villain", creator: "oddmask", accent: .orange, assetPath: "/effects/toon-villain.deepar")
    ]

    private let publisher = MacCameraExtensionPublisher()

    init() {
        selectedPreset = presets[0]
    }

    func select(_ preset: FacePreset) {
        selectedPreset = preset
        statusMessage = "Loaded \(preset.name)."
    }

    func startVirtualCamera() {
        Task {
            do {
                try await publisher.start()
                cameraState = publisher.state
                statusMessage = "Deep Faced Camera is running. Choose it in Zoom, Meet, or Teams."
            } catch {
                cameraState = .failed(message: error.localizedDescription)
                statusMessage = "Unable to start virtual camera: \(error.localizedDescription)"
            }
        }
    }

    func stopVirtualCamera() {
        Task {
            await publisher.stop()
            cameraState = publisher.state
            statusMessage = "Virtual camera stopped."
        }
    }
}
