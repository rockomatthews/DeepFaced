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

## Installing The Camera Extension

The Mac app includes install/remove controls under the `Camera Extension` menu. At runtime the app
submits an `OSSystemExtensionRequest` for:

```text
app.deepfaced.mac.camera-extension
```

macOS may require user approval in System Settings before the camera appears in Zoom, Meet, Teams,
or other camera clients.

## Signing And Notarization

After packaging, sign and notarize with:

```bash
export DEEPFACED_DEVELOPER_ID_APP="Developer ID Application: Your Name (TEAMID)"
export DEEPFACED_NOTARY_APPLE_ID="you@example.com"
export DEEPFACED_NOTARY_TEAM_ID="TEAMID"
export DEEPFACED_NOTARY_PASSWORD="app-specific-password"

npm run mac:sign -w apps/desktop
```

This script signs the nested system extension first, signs the app bundle, creates a signed DMG,
submits it to Apple notarization, staples the result, and copies it back to:

```text
apps/web/public/downloads/deep-faced-mac-alpha.dmg
```

For production, move these values into a secure CI secret store and never commit signing credentials.
