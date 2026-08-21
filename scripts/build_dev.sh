#!/usr/bin/env bash
# Build dev-flavor release: iOS IPA + Android APK + AAB.
# Usage: ./scripts/build_dev.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE="env/dev.json"

log() { printf "\n\033[1;36m◆ %s\033[0m\n" "$*"; }
err() { printf "\n\033[1;31m✘ %s\033[0m\n" "$*" >&2; }

if [[ ! -f "$ENV_FILE" ]]; then
  err "Missing $ENV_FILE — copy $ENV_FILE.example and fill values."
  exit 1
fi

log "flutter clean"
flutter clean

log "flutter pub get"
flutter pub get

log "Build iOS IPA (dev, release)"
if [[ "$(uname)" != "Darwin" ]]; then
  err "iOS build requires macOS. Skipping."
else
  flutter build ipa --flavor dev \
    --dart-define-from-file="$ENV_FILE" \
    -t lib/main_dev.dart --release

  log "Upload IPA to TestFlight (dev)"
  IPA_PATH="$(find build/ios/ipa -name '*.ipa' | head -n1)"
  ./scripts/upload_testflight.sh "$IPA_PATH"
fi

log "Build Android APK (dev, release)"
flutter build apk --flavor dev \
  --dart-define-from-file="$ENV_FILE" \
  -t lib/main_dev.dart --release

log "Upload APK to Firebase App Distribution (dev)"
./scripts/upload_firebase_android.sh dev build/app/outputs/flutter-apk/app-dev-release.apk

log "Build Android AAB (dev, release)"
flutter build appbundle --flavor dev \
  --dart-define-from-file="$ENV_FILE" \
  -t lib/main_dev.dart --release

log "Done"
echo "IPA: build/ios/ipa/*.ipa"
echo "APK: build/app/outputs/flutter-apk/app-dev-release.apk"
echo "AAB: build/app/outputs/bundle/devRelease/app-dev-release.aab"
