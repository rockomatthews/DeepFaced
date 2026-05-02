import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var model: DesktopAppModel

    var body: some View {
        NavigationSplitView {
            List(model.presets) { preset in
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.headline)
                    Text("@\(preset.creator)")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 6)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(preset.id == model.selectedPreset.id ? Color.white.opacity(0.12) : Color.clear)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    model.select(preset)
                }
            }
            .navigationTitle("Faces")
        } detail: {
            VStack(spacing: 24) {
                SDKPreview(preset: model.selectedPreset)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(model.selectedPreset.name)
                            .font(.title2.bold())
                        Text(model.statusMessage)
                            .foregroundStyle(.secondary)
                        Text("Preview uses DeepAR SDK initializeView, CameraController, and switchEffect only.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
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

struct SDKPreview: View {
    let preset: FacePreset

    var body: some View {
        GeometryReader { geometry in
            DeepARLivePreview(effectPackagePath: preset.assetPath)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .clipped()
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(.white.opacity(0.14), lineWidth: 1)
            )
        }
    }
}
