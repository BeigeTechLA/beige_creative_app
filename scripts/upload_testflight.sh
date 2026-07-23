#!/usr/bin/env bash
# Upload a release IPA to TestFlight via App Store Connect API key auth.
# Usage: ./scripts/upload_testflight.sh <path/to/app.ipa>
#
# Required env vars:
#   APP_STORE_CONNECT_KEY_ID     API key ID (e.g. ABCD123456)
#   APP_STORE_CONNECT_ISSUER_ID  API issuer UUID
#   APP_STORE_CONNECT_KEY_PATH   Path to the downloaded AuthKey_<KEY_ID>.p8
set -euo pipefail

IPA_PATH="${1:?Usage: upload_testflight.sh <path/to/app.ipa>}"

: "${APP_STORE_CONNECT_KEY_ID:?Set APP_STORE_CONNECT_KEY_ID}"
: "${APP_STORE_CONNECT_ISSUER_ID:?Set APP_STORE_CONNECT_ISSUER_ID}"
: "${APP_STORE_CONNECT_KEY_PATH:?Set APP_STORE_CONNECT_KEY_PATH (path to AuthKey_<KEY_ID>.p8)}"

if [[ "$(uname)" != "Darwin" ]]; then
  echo "✘ TestFlight upload requires macOS (xcrun altool)." >&2
  exit 1
fi

if [[ ! -f "$IPA_PATH" ]]; then
  echo "✘ IPA not found: $IPA_PATH" >&2
  exit 1
fi

if [[ ! -f "$APP_STORE_CONNECT_KEY_PATH" ]]; then
  echo "✘ API key file not found: $APP_STORE_CONNECT_KEY_PATH" >&2
  exit 1
fi

# altool discovers API keys by filename convention: AuthKey_<KEY_ID>.p8
# under ~/.appstoreconnect/private_keys/ (created if missing).
KEY_DIR="$HOME/.appstoreconnect/private_keys"
DEST_KEY="$KEY_DIR/AuthKey_${APP_STORE_CONNECT_KEY_ID}.p8"
mkdir -p "$KEY_DIR"
if [[ ! -f "$DEST_KEY" ]]; then
  cp "$APP_STORE_CONNECT_KEY_PATH" "$DEST_KEY"
  chmod 600 "$DEST_KEY"
fi

echo "◆ Uploading $IPA_PATH to TestFlight"
xcrun altool --upload-app \
  -f "$IPA_PATH" \
  -t ios \
  --apiKey "$APP_STORE_CONNECT_KEY_ID" \
  --apiIssuer "$APP_STORE_CONNECT_ISSUER_ID"
