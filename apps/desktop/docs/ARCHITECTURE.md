# Deep Faced Desktop Companion

The desktop companion exists because a browser app cannot register itself as a real camera device
for Zoom, Meet, Teams, or similar apps. The website owns discovery, creation, and preview. The
desktop companion owns OS-level virtual camera output.

## First Target

Start with macOS using a Camera Extension style backend.

Reasons:

- The current development environment is macOS.
- It gives a first real virtual camera path without designing all platform backends at once.
- The app can still share presets, effect metadata, and the DeepAR rendering boundary with the web
  app.

An iPhone companion should follow later as a separate Continuity Camera-style workflow. iOS apps do
not expose themselves as arbitrary desktop virtual camera devices in the same way OBS does on macOS;
the practical route is a paired Mac app plus iPhone camera/renderer handoff.

## Current App Shape

- Native shell: SwiftUI app scaffold in [macos](../macos).
- Renderer: placeholder SwiftUI preview until the DeepAR macOS renderer or embedded web renderer is
  selected.
- Bridge: `DeepFacedVirtualCamera` module receives processed frames.
- Backend: `MacCameraExtensionPublisher` boundary for the Camera Extension implementation.
- Pairing: local handoff from the website to desktop, carrying only preset/effect IDs and settings.

## Frame Pipeline

```mermaid
flowchart LR
  preset[PresetMetadata] --> renderer[DesktopRenderer]
  renderer --> deepar[DeepARAdapter]
  deepar --> canvas[ProcessedCanvas]
  canvas --> bridge[NativeFrameBridge]
  bridge --> macos[MacOSCameraExtension]
  macos --> callApp[ZoomMeetTeams]
```

## Privacy Boundary

Live camera frames should stay local. The desktop app should not upload raw frames unless a future
feature explicitly asks the user to export or share media.

## Prototype Milestones

1. Load a saved preset locally.
2. Render processed frames in the desktop renderer.
3. Copy frames into a native bridge.
4. Publish a macOS virtual camera device.
5. Add diagnostics for permissions, camera device state, frame rate, and dropped frames.
