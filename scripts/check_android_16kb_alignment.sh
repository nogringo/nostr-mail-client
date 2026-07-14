#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -eq 0 ]; then
  echo "Usage: $0 APK_PATH [APK_PATH ...]" >&2
  exit 2
fi

sdk_root="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [ -z "$sdk_root" ]; then
  echo "ANDROID_SDK_ROOT or ANDROID_HOME must point to the Android SDK." >&2
  exit 2
fi

zipalign="${ZIPALIGN:-}"
if [ -z "$zipalign" ]; then
  zipalign="$(find "$sdk_root/build-tools" -name zipalign -type f | sort | tail -n 1)"
fi

objdump="${LLVM_OBJDUMP:-}"
if [ -z "$objdump" ]; then
  objdump="$(find "$sdk_root/ndk" -path '*/toolchains/llvm/prebuilt/*/bin/llvm-objdump' -type f | sort | tail -n 1)"
fi

if [ ! -x "$zipalign" ]; then
  echo "zipalign not found. Install Android SDK Build-Tools 35.0.0 or newer." >&2
  exit 2
fi

if [ ! -x "$objdump" ]; then
  echo "llvm-objdump not found. Install Android NDK r28 or newer." >&2
  exit 2
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "$tmp_root"' EXIT

for apk in "$@"; do
  if [ ! -f "$apk" ]; then
    echo "APK not found: $apk" >&2
    exit 2
  fi

  echo "Checking 16KB alignment: $apk"
  "$zipalign" -c -P 16 -v 4 "$apk" >/dev/null

  tmp_dir="$tmp_root/$(basename "$apk")"
  mkdir -p "$tmp_dir"

  libs="$(unzip -Z1 "$apk" | grep -E '^lib/(arm64-v8a|x86_64)/.*\.so$' || true)"
  if [ -z "$libs" ]; then
    echo "No 64-bit native libraries found."
    continue
  fi

  while IFS= read -r lib; do
    so_path="$tmp_dir/${lib//\//_}"
    unzip -p "$apk" "$lib" > "$so_path"

    while IFS= read -r load_segment; do
      alignment="$(printf '%s\n' "$load_segment" | sed -n 's/.* align 2\*\*\([0-9][0-9]*\).*/\1/p')"
      if [ -z "$alignment" ]; then
        echo "Could not parse LOAD segment alignment for $lib: $load_segment" >&2
        exit 1
      fi
      if [ "$alignment" -lt 14 ]; then
        echo "$lib has an unaligned LOAD segment: $load_segment" >&2
        exit 1
      fi
    done < <("$objdump" -p "$so_path" | grep ' LOAD ')
  done <<< "$libs"
done

echo "All checked APKs are 16KB aligned."
