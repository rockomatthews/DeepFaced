import DeepFacedVirtualCamera
import Foundation
import SwiftUI

struct LocalEffectCatalog {
    func loadPresets() -> [FacePreset] {
        candidateEffectRoots()
            .lazy
            .compactMap(loadPresets(from:))
            .first { !$0.isEmpty } ?? []
    }

    private func candidateEffectRoots() -> [URL] {
        var candidates: [URL] = []

        if let bundledEffects = Bundle.main.resourceURL?.appending(path: "Effects") {
            candidates.append(bundledEffects)
        }

        let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        candidates.append(currentDirectory.appending(path: "apps/desktop/macos/Effects"))
        candidates.append(currentDirectory.appending(path: "macos/Effects"))
        candidates.append(currentDirectory.appending(path: "Effects"))

        return candidates
    }

    private func loadPresets(from root: URL) -> [FacePreset]? {
        guard
            let effectFolders = try? FileManager.default.contentsOfDirectory(
                at: root,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
            )
        else {
            return nil
        }

        let presets = effectFolders
            .filter(\.isDirectory)
            .compactMap(facePreset(from:))
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        return presets
    }

    private func facePreset(from folder: URL) -> FacePreset? {
        guard
            let files = try? FileManager.default.contentsOfDirectory(
                at: folder,
                includingPropertiesForKeys: nil,
                options: [.skipsHiddenFiles]
            ),
            let effectFile = files.first(where: { $0.pathExtension.lowercased() == "deepar" })
        else {
            return nil
        }

        let name = folder.lastPathComponent
        let style = maskStyle(for: name, id: effectFile.deletingPathExtension().lastPathComponent)

        return FacePreset(
            id: effectFile.deletingPathExtension().lastPathComponent,
            name: name,
            creator: "DeepAR",
            accent: style.color,
            maskStyle: style.mask,
            assetPath: effectFile.path
        )
    }

    private func maskStyle(for name: String, id: String) -> (color: Color, mask: MaskRenderStyle) {
        let lowercased = name.lowercased()

        if lowercased.contains("fire") || lowercased.contains("devil") || lowercased.contains("burn") {
            return (.orange, MaskRenderStyle(red: 0.98, green: 0.32, blue: 0.12, presetIdentifier: id))
        }

        if lowercased.contains("flower") || lowercased.contains("snail") || lowercased.contains("elephant") {
            return (.green, MaskRenderStyle(red: 0.24, green: 0.82, blue: 0.38, presetIdentifier: id))
        }

        if lowercased.contains("heart") || lowercased.contains("makeup") {
            return (.pink, MaskRenderStyle(red: 0.98, green: 0.45, blue: 0.62, presetIdentifier: id))
        }

        return (.cyan, MaskRenderStyle(red: 0.13, green: 0.83, blue: 0.93, presetIdentifier: id))
    }
}

private extension URL {
    var isDirectory: Bool {
        (try? resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }
}
