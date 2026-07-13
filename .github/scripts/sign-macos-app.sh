#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:?Missing app bundle path}"
ENTITLEMENTS_PATH="${2:?Missing entitlements path}"
IDENTITY="${APPLE_DEVELOPER_ID_APPLICATION_IDENTITY:?Missing APPLE_DEVELOPER_ID_APPLICATION_IDENTITY}"

if [ ! -d "$APP_PATH" ]; then
  echo "App bundle not found: $APP_PATH"
  exit 1
fi

codesign \
  --force \
  --deep \
  --options runtime \
  --timestamp \
  --entitlements "$ENTITLEMENTS_PATH" \
  --sign "$IDENTITY" \
  "$APP_PATH"

codesign --verify --deep --strict --verbose=2 "$APP_PATH"

LIPO_INFO=$(lipo -info "$APP_PATH/Contents/MacOS/Nmail")
echo "$LIPO_INFO"
if [[ "$LIPO_INFO" != *"x86_64"* || "$LIPO_INFO" != *"arm64"* ]]; then
  echo "Expected a universal macOS binary containing x86_64 and arm64"
  exit 1
fi
