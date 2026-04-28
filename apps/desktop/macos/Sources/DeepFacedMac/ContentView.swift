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
                RenderPreview(preset: model.selectedPreset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(model.selectedPreset.name)
                            .font(.title2.bold())
                        Text(model.statusMessage)
                            .foregroundStyle(.secondary)
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
