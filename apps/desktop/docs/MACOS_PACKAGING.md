# macOS Packaging Notes

The package script builds a `Deep Faced.app` bundle and places a CoreMediaIO Camera Extension payload
inside:

```text
Deep Faced.app/
  Contents/
    MacOS/DeepFacedMac
    Info.plist
    Resources/AppIcon.icns
    Library/SystemExtensions/app.deepfaced.mac.camera-extension.systemextension/
      Contents/MacOS/DeepFacedCameraExtension
      Contents/Info.plist
```

Run:

```bash
npm run mac:package -w apps/desktop
```

The generated DMG is written to:

```text
apps/web/public/downloads/deep-faced-mac-alpha.dmg
```

The app target uses this camera permission string:

```xml
<key>NSCameraUsageDescription</key>
<string>Deep Faced uses your camera to track your face and render selected face masks locally.</string>
```

The Camera Extension source builds and is included in the app bundle, but a working system camera
requires Apple Developer signing, System Extension entitlements, hardened runtime settings, user
approval on install, and notarization. The checked-in entitlements are placeholders for the signing
phase and may need to be adjusted in Xcode for your Apple Team ID.
