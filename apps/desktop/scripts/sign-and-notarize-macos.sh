#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_DIR="$(cd "${DESKTOP_DIR}/../.." && pwd)"
APP_BUNDLE="${DESKTOP_DIR}/dist/macos/Deep Faced.app"
EXTENSION_BUNDLE="${APP_BUNDLE}/Contents/Library/SystemExtensions/app.deepfaced.mac.camera-extension.systemextension"
DMG_PATH="${REPO_DIR}/apps/web/public/downloads/deep-faced-mac-alpha.dmg"
SIGNED_DMG_PATH="${REPO_DIR}/apps/web/public/downloads/deep-faced-mac-alpha-signed.dmg"

: "${DEEPFACED_DEVELOPER_ID_APP:?Set DEEPFACED_DEVELOPER_ID_APP to your Developer ID Application identity}"
: "${DEEPFACED_NOTARY_APPLE_ID:?Set DEEPFACED_NOTARY_APPLE_ID to your Apple ID}"
: "${DEEPFACED_NOTARY_TEAM_ID:?Set DEEPFACED_NOTARY_TEAM_ID to your Apple Team ID}"
: "${DEEPFACED_NOTARY_PASSWORD:?Set DEEPFACED_NOTARY_PASSWORD to an app-specific password or notarytool keychain profile password}"

if [[ ! -d "${APP_BUNDLE}" ]]; then
  echo "Missing ${APP_BUNDLE}. Run npm run mac:package -w apps/desktop first."
  exit 1
fi

codesign --force --timestamp --options runtime \
  --entitlements "${DESKTOP_DIR}/macos/Assets/CameraExtension/DeepFacedCameraExtension.entitlements" \
  --sign "${DEEPFACED_DEVELOPER_ID_APP}" \
  "${EXTENSION_BUNDLE}"

codesign --force --timestamp --options runtime \
  --entitlements "${DESKTOP_DIR}/macos/Assets/DeepFaced.entitlements" \
  --sign "${DEEPFACED_DEVELOPER_ID_APP}" \
  "${APP_BUNDLE}"

codesign --verify --deep --strict --verbose=2 "${APP_BUNDLE}"

rm -f "${SIGNED_DMG_PATH}"
hdiutil create -volname "Deep Faced" -srcfolder "${APP_BUNDLE}" -ov -format UDZO "${SIGNED_DMG_PATH}" >/dev/null

xcrun notarytool submit "${SIGNED_DMG_PATH}" \
  --apple-id "${DEEPFACED_NOTARY_APPLE_ID}" \
  --team-id "${DEEPFACED_NOTARY_TEAM_ID}" \
  --password "${DEEPFACED_NOTARY_PASSWORD}" \
  --wait

xcrun stapler staple "${SIGNED_DMG_PATH}"

cp "${SIGNED_DMG_PATH}" "${DMG_PATH}"
echo "Signed and notarized ${DMG_PATH}"
