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
- Renderer: AVFoundation camera capture feeds bundled `.deepar` effects into DeepAR's native
  offscreen renderer when a license key is available. Without a key, the app falls back to the
  prototype overlay renderer so local development can still exercise the camera pipeline.
- Bridge: `DeepFacedVirtualCamera` module receives processed frame metadata from the tracker. The
  current publisher stores the latest frame and validates the runtime pipeline; a real Camera
  Extension implementation still needs to copy composed pixel buffers into the system extension.
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

1. Load a saved preset locally. Done in the SwiftUI prototype.
2. Detect the user face from the Mac camera and move the selected face overlay with the head. Done
   with AVFoundation and Vision.
3. Send selected preset IDs and normalized face frames into the virtual camera pipeline. Done in the
   prototype publisher boundary.
4. Render composed pixel buffers in the desktop renderer. Done with DeepAR offscreen rendering for
   Intel macOS builds and a prototype fallback when DeepAR is unavailable.
5. Copy composed pixel buffers into a native Camera Extension bridge.
6. Publish a macOS virtual camera device.
7. Add diagnostics for permissions, camera device state, frame rate, and dropped frames.
