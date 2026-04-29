import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: DesktopAppModel

    var body: some View {
        NavigationSplitView {
            List(model.presets, selection: Binding(
                get: { model.selectedPreset },
                set: { preset in
                    if let preset {
                        model.select(preset)
                    }
                }
            )) { preset in
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.headline)
                    Text("@\(preset.creator)")
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Faces")
        } detail: {
            VStack(spacing: 24) {
                RenderPreview(preset: model.selectedPreset, tracker: model.tracker)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(model.selectedPreset.name)
                            .font(.title2.bold())
                        Text(model.statusMessage)
                            .foregroundStyle(.secondary)
                        Text("\(model.publishedFrameCount) processed frames published to the camera pipeline.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Last composed frame: \(model.lastPublishedResolution)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(model.extensionInstaller.status)
                            .font(.caption)
                            .foregroundStyle(model.extensionInstaller.needsUserApproval ? .yellow : .secondary)
                    }

                    Spacer()

                    Button("Stop") {
                        model.stopVirtualCamera()
                    }
                    .buttonStyle(.bordered)

                    Button("Start Virtual Camera") {
                        model.startVirtualCamera()
                    }
                    .buttonStyle(.borderedProminent)

                    Menu("Camera Extension") {
                        Button("Install Extension") {
                            model.installCameraExtension()
                        }
                        Button("Remove Extension") {
                            model.uninstallCameraExtension()
                        }
                    }
                    .menuStyle(.button)
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }
            .padding(24)
            .background(
                RadialGradient(colors: [.purple.opacity(0.24), .black], center: .topLeading, startRadius: 20, endRadius: 900)
            )
        }
    }
}

struct RenderPreview: View {
    let preset: FacePreset
    @ObservedObject var tracker: CameraFaceTracker

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                CameraPreview(session: tracker.session)
                    .clipShape(RoundedRectangle(cornerRadius: 32))

                Color.black.opacity(0.22)
                    .clipShape(RoundedRectangle(cornerRadius: 32))

                if let faceFrame = tracker.faceFrame {
                    TrackedMaskOverlay(preset: preset, faceFrame: faceFrame, canvasSize: geometry.size)
                } else {
                    CenteredMaskOverlay(preset: preset)
                }

                VStack {
                    HStack {
                        Text(tracker.cameraStatus)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.black.opacity(0.52))
                            .clipShape(Capsule())
                        Spacer()
                    }
                    Spacer()
                    Text("The overlay is driven by Vision face detection. DeepAR mesh deformation can replace this renderer later.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.52))
                        .clipShape(Capsule())
                }
                .padding(18)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(.white.opacity(0.14), lineWidth: 1)
            )
            .task {
                tracker.start()
            }
            .onDisappear {
                tracker.stop()
            }
        }
    }
}

struct TrackedMaskOverlay: View {
    let preset: FacePreset
    let faceFrame: CGRect
    let canvasSize: CGSize

    var body: some View {
        let faceWidth = max(faceFrame.width * canvasSize.width, 120)
        let faceHeight = max(faceFrame.height * canvasSize.height, 150)
        let centerX = faceFrame.midX * canvasSize.width
        let centerY = faceFrame.midY * canvasSize.height

        MaskShape(preset: preset)
            .frame(width: faceWidth * 1.38, height: faceHeight * 1.72)
            .position(x: centerX, y: centerY + faceHeight * 0.04)
            .animation(.interactiveSpring(response: 0.18, dampingFraction: 0.78), value: faceFrame)
    }
}

struct CenteredMaskOverlay: View {
    let preset: FacePreset

    var body: some View {
        VStack(spacing: 18) {
            MaskShape(preset: preset)
                .frame(width: 260, height: 320)

            Text("Move into frame to attach the mask to your face.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct MaskShape: View {
    let preset: FacePreset

    var body: some View {
        RoundedRectangle(cornerRadius: 70)
            .fill(preset.accent.gradient)
            .shadow(color: preset.accent.opacity(0.55), radius: 40)
            .overlay {
                VStack(spacing: 54) {
                    HStack(spacing: 44) {
                        Capsule().fill(.white.opacity(0.78)).frame(width: 70, height: 24)
                        Capsule().fill(.white.opacity(0.78)).frame(width: 70, height: 24)
                    }
                    Capsule().stroke(.white.opacity(0.72), lineWidth: 5).frame(width: 120, height: 38)
                }
                .scaleEffect(0.78)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 70)
                    .stroke(.white.opacity(0.72), lineWidth: 3)
            )
    }
}

struct StaticRenderPreview: View {
    let preset: FacePreset

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32)
                .fill(.black.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(.white.opacity(0.14), lineWidth: 1)
                )

            VStack(spacing: 18) {
                RoundedRectangle(cornerRadius: 70)
                    .fill(preset.accent.gradient)
                    .frame(width: 260, height: 320)
                    .shadow(color: preset.accent.opacity(0.55), radius: 40)
                    .overlay {
                        VStack(spacing: 54) {
                            HStack(spacing: 44) {
                                Capsule().fill(.white.opacity(0.78)).frame(width: 70, height: 24)
                                Capsule().fill(.white.opacity(0.78)).frame(width: 70, height: 24)
                            }
                            Capsule().stroke(.white.opacity(0.72), lineWidth: 5).frame(width: 120, height: 38)
                        }
                    }

                Text("Renderer placeholder for \(preset.assetPath)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
