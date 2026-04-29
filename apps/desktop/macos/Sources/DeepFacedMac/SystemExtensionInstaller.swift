import Foundation
import SystemExtensions

@MainActor
final class SystemExtensionInstaller: NSObject, ObservableObject {
    @Published var status = "Camera Extension is not installed."
    @Published var needsUserApproval = false

    private let extensionIdentifier = "app.deepfaced.mac.camera-extension"

    func install() {
        needsUserApproval = false
        status = "Requesting Camera Extension activation..."

        let request = OSSystemExtensionRequest.activationRequest(
            forExtensionWithIdentifier: extensionIdentifier,
            queue: .main
        )
        request.delegate = self
        OSSystemExtensionManager.shared.submitRequest(request)
    }

    func uninstall() {
        needsUserApproval = false
        status = "Requesting Camera Extension removal..."

        let request = OSSystemExtensionRequest.deactivationRequest(
            forExtensionWithIdentifier: extensionIdentifier,
            queue: .main
        )
        request.delegate = self
        OSSystemExtensionManager.shared.submitRequest(request)
    }
}

extension SystemExtensionInstaller: OSSystemExtensionRequestDelegate {
    nonisolated func requestNeedsUserApproval(_ request: OSSystemExtensionRequest) {
        Task { @MainActor in
            needsUserApproval = true
            status = "Approve Deep Faced Camera in System Settings to finish installation."
        }
    }

    nonisolated func request(
        _ request: OSSystemExtensionRequest,
        actionForReplacingExtension existing: OSSystemExtensionProperties,
        withExtension extension: OSSystemExtensionProperties
    ) -> OSSystemExtensionRequest.ReplacementAction {
        .replace
    }

    nonisolated func request(
        _ request: OSSystemExtensionRequest,
        didFinishWithResult result: OSSystemExtensionRequest.Result
    ) {
        Task { @MainActor in
            needsUserApproval = false
            switch result {
            case .completed:
                status = "Deep Faced Camera Extension is installed."
            case .willCompleteAfterReboot:
                status = "Deep Faced Camera Extension will finish after reboot."
            @unknown default:
                status = "Camera Extension request finished with an unknown result."
            }
        }
    }

    nonisolated func request(_ request: OSSystemExtensionRequest, didFailWithError error: Error) {
        Task { @MainActor in
            needsUserApproval = false
            status = "Camera Extension request failed: \(error.localizedDescription)"
        }
    }
}
