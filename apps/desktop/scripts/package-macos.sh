#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_DIR="$(cd "${DESKTOP_DIR}/../.." && pwd)"
MACOS_DIR="${DESKTOP_DIR}/macos"
BUILD_DIR="${MACOS_DIR}/.build"
RELEASE_DIR="${DESKTOP_DIR}/dist/macos"
APP_NAME="Deep Faced"
APP_BUNDLE="${RELEASE_DIR}/${APP_NAME}.app"
EXTENSION_BUNDLE="${APP_BUNDLE}/Contents/Library/SystemExtensions/app.deepfaced.mac.camera-extension.systemextension"
DMG_PATH="${REPO_DIR}/apps/web/public/downloads/deep-faced-mac-alpha.dmg"

rm -rf "${RELEASE_DIR}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS" "${APP_BUNDLE}/Contents/Resources" "${EXTENSION_BUNDLE}/Contents/MacOS" "$(dirname "${DMG_PATH}")"

swift build --package-path "${MACOS_DIR}" -c release --product DeepFacedMac
swift build --package-path "${MACOS_DIR}" -c release --product DeepFacedCameraExtension

cp "${BUILD_DIR}/release/DeepFacedMac" "${APP_BUNDLE}/Contents/MacOS/DeepFacedMac"
cp "${MACOS_DIR}/Assets/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"
cp "${BUILD_DIR}/release/DeepFacedCameraExtension" "${EXTENSION_BUNDLE}/Contents/MacOS/DeepFacedCameraExtension"
cp "${MACOS_DIR}/Assets/CameraExtension/Info.plist" "${EXTENSION_BUNDLE}/Contents/Info.plist"
cp "${MACOS_DIR}/Assets/CameraExtension/DeepFacedCameraExtension.entitlements" "${EXTENSION_BUNDLE}/Contents/DeepFacedCameraExtension.entitlements"

ICONSET="${RELEASE_DIR}/AppIcon.iconset"
mkdir -p "${ICONSET}"

if command -v qlmanage >/dev/null 2>&1 && command -v sips >/dev/null 2>&1 && command -v iconutil >/dev/null 2>&1; then
  PNG_BASE="${RELEASE_DIR}/AppIcon-base.png"
  qlmanage -t -s 1024 -o "${RELEASE_DIR}" "${MACOS_DIR}/Assets/AppIcon.svg" >/dev/null 2>&1 || true
  GENERATED_PNG="${RELEASE_DIR}/AppIcon.svg.png"
  if [[ -f "${GENERATED_PNG}" ]]; then
    mv "${GENERATED_PNG}" "${PNG_BASE}"
    for size in 16 32 64 128 256 512; do
      sips -z "${size}" "${size}" "${PNG_BASE}" --out "${ICONSET}/icon_${size}x${size}.png" >/dev/null
      double=$((size * 2))
      sips -z "${double}" "${double}" "${PNG_BASE}" --out "${ICONSET}/icon_${size}x${size}@2x.png" >/dev/null
    done
    iconutil -c icns "${ICONSET}" -o "${APP_BUNDLE}/Contents/Resources/AppIcon.icns"
  else
    cp "${MACOS_DIR}/Assets/AppIcon.svg" "${APP_BUNDLE}/Contents/Resources/AppIcon.svg"
  fi
else
  cp "${MACOS_DIR}/Assets/AppIcon.svg" "${APP_BUNDLE}/Contents/Resources/AppIcon.svg"
fi

if command -v hdiutil >/dev/null 2>&1; then
  rm -f "${DMG_PATH}"
  hdiutil create -volname "${APP_NAME}" -srcfolder "${APP_BUNDLE}" -ov -format UDZO "${DMG_PATH}" >/dev/null
  echo "Created ${DMG_PATH}"
else
  echo "hdiutil not found; app bundle created at ${APP_BUNDLE}"
fi
