#!/usr/bin/env bash
set -euo pipefail

APP_PATH="${1:?Missing app bundle path}"
ENTITLEMENTS_PATH="${2:?Missing entitlements path}"
IDENTITY="${APPLE_DEVELOPER_ID_APPLICATION_IDENTITY:?Missing APPLE_DEVELOPER_ID_APPLICATION_IDENTITY}"
PROFILE_BASE64="${APPLE_DEVELOPER_ID_PROVISIONING_PROFILE_BASE64:?Missing APPLE_DEVELOPER_ID_PROVISIONING_PROFILE_BASE64}"
TEAM_ID="${APPLE_TEAM_ID:-}"
SIGNING_ENTITLEMENTS_PATH="${RUNNER_TEMP:-/tmp}/nmail-developer-id.entitlements"
PROFILE_PATH="${RUNNER_TEMP:-/tmp}/nmail-developer-id.provisionprofile"
PROFILE_PLIST_PATH="${RUNNER_TEMP:-/tmp}/nmail-developer-id-profile.plist"

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

echo "$PROFILE_BASE64" | base64 --decode > "$PROFILE_PATH"
security cms -D -i "$PROFILE_PATH" > "$PROFILE_PLIST_PATH"

PROFILE_TEAM_ID=$(/usr/libexec/PlistBuddy -c "Print :TeamIdentifier:0" "$PROFILE_PLIST_PATH")
PROFILE_APP_IDENTIFIER=$(/usr/libexec/PlistBuddy -c "Print :Entitlements:com.apple.application-identifier" "$PROFILE_PLIST_PATH")
PROFILE_ENTITLEMENT_TEAM_ID=$(/usr/libexec/PlistBuddy -c "Print :Entitlements:com.apple.developer.team-identifier" "$PROFILE_PLIST_PATH")

if [ "$PROFILE_TEAM_ID" != "$TEAM_ID" ] || [ "$PROFILE_ENTITLEMENT_TEAM_ID" != "$TEAM_ID" ]; then
  echo "Developer ID provisioning profile team does not match APPLE_TEAM_ID"
  exit 1
fi

if [ "$PROFILE_APP_IDENTIFIER" != "$APP_IDENTIFIER" ]; then
  echo "Developer ID provisioning profile app identifier mismatch: expected $APP_IDENTIFIER, got $PROFILE_APP_IDENTIFIER"
  exit 1
fi

if ! /usr/libexec/PlistBuddy -c "Print :Entitlements:keychain-access-groups:0" "$PROFILE_PLIST_PATH" >/dev/null; then
  echo "Developer ID provisioning profile is missing the keychain-access-groups entitlement"
  exit 1
fi

cp "$PROFILE_PATH" "$APP_PATH/Contents/embedded.provisionprofile"

cp "$ENTITLEMENTS_PATH" "$SIGNING_ENTITLEMENTS_PATH"

set_string_entitlement() {
  local key="$1"
  local value="$2"
  /usr/libexec/PlistBuddy -c "Set :$key $value" "$SIGNING_ENTITLEMENTS_PATH" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Add :$key string $value" "$SIGNING_ENTITLEMENTS_PATH"
}

set_string_entitlement "com.apple.application-identifier" "$PROFILE_APP_IDENTIFIER"
set_string_entitlement "com.apple.developer.team-identifier" "$PROFILE_ENTITLEMENT_TEAM_ID"

/usr/libexec/PlistBuddy -c "Delete :keychain-access-groups" "$SIGNING_ENTITLEMENTS_PATH" 2>/dev/null || true
/usr/libexec/PlistBuddy -c "Add :keychain-access-groups array" "$SIGNING_ENTITLEMENTS_PATH"
KEYCHAIN_GROUP_INDEX=0
while KEYCHAIN_GROUP=$(/usr/libexec/PlistBuddy -c "Print :Entitlements:keychain-access-groups:$KEYCHAIN_GROUP_INDEX" "$PROFILE_PLIST_PATH" 2>/dev/null); do
  /usr/libexec/PlistBuddy -c "Add :keychain-access-groups:$KEYCHAIN_GROUP_INDEX string $KEYCHAIN_GROUP" "$SIGNING_ENTITLEMENTS_PATH"
  KEYCHAIN_GROUP_INDEX=$((KEYCHAIN_GROUP_INDEX + 1))
done

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
if [ ! -s "$APP_PATH/Contents/embedded.provisionprofile" ]; then
  echo "Signed app is missing embedded.provisionprofile"
  exit 1
fi

LIPO_INFO=$(lipo -info "$APP_PATH/Contents/MacOS/Nmail")
echo "$LIPO_INFO"
if [[ "$LIPO_INFO" != *"x86_64"* || "$LIPO_INFO" != *"arm64"* ]]; then
  echo "Expected a universal macOS binary containing x86_64 and arm64"
  exit 1
fi
