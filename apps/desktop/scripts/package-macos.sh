#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_DIR="$(cd "${DESKTOP_DIR}/../.." && pwd)"
MACOS_DIR="${DESKTOP_DIR}/macos"
BUILD_DIR="${MACOS_DIR}/.build"
BUILD_ARCH="x86_64"
BUILD_TRIPLE="${BUILD_ARCH}-apple-macosx"
BUILD_PRODUCTS_DIR="${BUILD_DIR}/${BUILD_TRIPLE}/release"
RELEASE_DIR="${DESKTOP_DIR}/dist/macos"
APP_NAME="Deep Faced"
APP_BUNDLE="${RELEASE_DIR}/${APP_NAME}.app"
EXTENSION_BUNDLE="${APP_BUNDLE}/Contents/Library/SystemExtensions/app.deepfaced.mac.camera-extension.systemextension"
DMG_PATH="${REPO_DIR}/apps/web/public/downloads/deep-faced-mac-alpha.dmg"

rm -rf "${RELEASE_DIR}"
mkdir -p "${APP_BUNDLE}/Contents/MacOS" "${APP_BUNDLE}/Contents/Frameworks" "${APP_BUNDLE}/Contents/Resources" "${EXTENSION_BUNDLE}/Contents/MacOS" "$(dirname "${DMG_PATH}")"

swift build --package-path "${MACOS_DIR}" -c release --arch "${BUILD_ARCH}" --product DeepFacedMac
swift build --package-path "${MACOS_DIR}" -c release --arch "${BUILD_ARCH}" --product DeepFacedCameraExtension

cp "${BUILD_PRODUCTS_DIR}/DeepFacedMac" "${APP_BUNDLE}/Contents/MacOS/DeepFacedMac"
cp "${MACOS_DIR}/Assets/Info.plist" "${APP_BUNDLE}/Contents/Info.plist"
cp "${BUILD_PRODUCTS_DIR}/DeepFacedCameraExtension" "${EXTENSION_BUNDLE}/Contents/MacOS/DeepFacedCameraExtension"
cp "${MACOS_DIR}/Assets/CameraExtension/Info.plist" "${EXTENSION_BUNDLE}/Contents/Info.plist"

if [[ -d "${BUILD_PRODUCTS_DIR}/DeepAR.framework" ]]; then
  ditto "${BUILD_PRODUCTS_DIR}/DeepAR.framework" "${APP_BUNDLE}/Contents/Frameworks/DeepAR.framework"
  install_name_tool -add_rpath "@executable_path/../Frameworks" "${APP_BUNDLE}/Contents/MacOS/DeepFacedMac" 2>/dev/null || true
fi

if [[ -d "${MACOS_DIR}/Effects" ]]; then
  rm -rf "${APP_BUNDLE}/Contents/Resources/Effects"
  ditto "${MACOS_DIR}/Effects" "${APP_BUNDLE}/Contents/Resources/Effects"
fi

if [[ -f "${DESKTOP_DIR}/.env.local" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "${DESKTOP_DIR}/.env.local"
  set +a
fi

if [[ -n "${DEEPAR_LICENSE_KEY:-}" ]]; then
  /usr/libexec/PlistBuddy -c "Add :DeepARLicenseKey string ${DEEPAR_LICENSE_KEY}" "${APP_BUNDLE}/Contents/Info.plist" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Set :DeepARLicenseKey ${DEEPAR_LICENSE_KEY}" "${APP_BUNDLE}/Contents/Info.plist"
fi

if [[ -n "${COMMUNITY_CATALOG_URL:-}" ]]; then
  /usr/libexec/PlistBuddy -c "Set :CommunityCatalogURL ${COMMUNITY_CATALOG_URL}" "${APP_BUNDLE}/Contents/Info.plist"
fi

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

if command -v codesign >/dev/null 2>&1; then
  if [[ -d "${APP_BUNDLE}/Contents/Frameworks/DeepAR.framework" ]]; then
    codesign --force --sign - "${APP_BUNDLE}/Contents/Frameworks/DeepAR.framework"
  fi

  codesign --force --sign - \
    --entitlements "${MACOS_DIR}/Assets/CameraExtension/DeepFacedCameraExtension.entitlements" \
    "${EXTENSION_BUNDLE}"

  codesign --force --deep --sign - \
    --entitlements "${MACOS_DIR}/Assets/DeepFaced.entitlements" \
    "${APP_BUNDLE}"
fi

if command -v hdiutil >/dev/null 2>&1; then
  rm -f "${DMG_PATH}"
  hdiutil create -volname "${APP_NAME}" -srcfolder "${APP_BUNDLE}" -ov -format UDZO "${DMG_PATH}" >/dev/null
  echo "Created ${DMG_PATH}"
else
  echo "hdiutil not found; app bundle created at ${APP_BUNDLE}"
fi
