#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:?Missing app bundle path}"
ENTITLEMENTS_PATH="${2:?Missing entitlements path}"
IDENTITY="${APPLE_DEVELOPER_ID_APPLICATION_IDENTITY:?Missing APPLE_DEVELOPER_ID_APPLICATION_IDENTITY}"
TEAM_ID="${APPLE_TEAM_ID:-}"
SIGNING_ENTITLEMENTS_PATH="${RUNNER_TEMP:-/tmp}/nmail-developer-id.entitlements"

if [ ! -d "$APP_PATH" ]; then
  echo "App bundle not found: $APP_PATH"
  exit 1
fi

if [ -z "$TEAM_ID" ]; then
  if [[ "$IDENTITY" =~ \(([A-Z0-9]{10})\)$ ]]; then
    TEAM_ID="${BASH_REMATCH[1]}"
  else
    echo "Missing APPLE_TEAM_ID and unable to infer it from signing identity"
    exit 1
  fi
fi

BUNDLE_ID=$(/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" "$APP_PATH/Contents/Info.plist")
APP_IDENTIFIER="$TEAM_ID.$BUNDLE_ID"

cp "$ENTITLEMENTS_PATH" "$SIGNING_ENTITLEMENTS_PATH"

set_string_entitlement() {
  local key="$1"
  local value="$2"
  /usr/libexec/PlistBuddy -c "Set :$key $value" "$SIGNING_ENTITLEMENTS_PATH" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Add :$key string $value" "$SIGNING_ENTITLEMENTS_PATH"
}

set_string_entitlement "com.apple.application-identifier" "$APP_IDENTIFIER"
set_string_entitlement "com.apple.developer.team-identifier" "$TEAM_ID"

/usr/libexec/PlistBuddy -c "Delete :keychain-access-groups" "$SIGNING_ENTITLEMENTS_PATH" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :keychain-access-groups array" "$SIGNING_ENTITLEMENTS_PATH"
/usr/libexec/PlistBuddy -c "Add :keychain-access-groups:0 string $APP_IDENTIFIER" "$SIGNING_ENTITLEMENTS_PATH"

echo "Signing with Developer ID entitlements:"
plutil -p "$SIGNING_ENTITLEMENTS_PATH"

codesign \
  --force \
  --deep \
  --options runtime \
  --timestamp \
  --entitlements "$SIGNING_ENTITLEMENTS_PATH" \
  --sign "$IDENTITY" \
  "$APP_PATH"

codesign --verify --deep --strict --verbose=2 "$APP_PATH"

SIGNATURE_DETAILS=$(codesign -dv --verbose=4 "$APP_PATH" 2>&1)
echo "$SIGNATURE_DETAILS"
if [[ "$SIGNATURE_DETAILS" != *"Authority=Developer ID Application:"* && "$SIGNATURE_DETAILS" != *"Authority=Mac Developer ID Application:"* ]]; then
  echo "Expected a Developer ID Application signature"
  exit 1
fi
SIGNED_ENTITLEMENTS=$(codesign -d --entitlements - "$APP_PATH" 2>/dev/null)
echo "$SIGNED_ENTITLEMENTS"
if [[ "$SIGNED_ENTITLEMENTS" == *"AppIdentifierPrefix"* || "$SIGNED_ENTITLEMENTS" == *'$('* ]]; then
  echo "Developer ID signature must not include unresolved entitlement placeholders"
  exit 1
fi
if [[ "$SIGNED_ENTITLEMENTS" != *"keychain-access-groups"* || "$SIGNED_ENTITLEMENTS" != *"$APP_IDENTIFIER"* ]]; then
  echo "Developer ID signature is missing the resolved keychain access group"
  exit 1
fi

LIPO_INFO=$(lipo -info "$APP_PATH/Contents/MacOS/Nmail")
echo "$LIPO_INFO"
if [[ "$LIPO_INFO" != *"x86_64"* || "$LIPO_INFO" != *"arm64"* ]]; then
  echo "Expected a universal macOS binary containing x86_64 and arm64"
  exit 1
fi
