import SwiftUI

@main
struct DeepFacedMacApp: App {
    @StateObject private var model = DesktopAppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .frame(minWidth: 1080, minHeight: 720)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
