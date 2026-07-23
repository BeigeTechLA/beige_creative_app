#!/usr/bin/env bash
# Upload a release APK to Firebase App Distribution.
# Usage: ./scripts/upload_firebase_android.sh <dev|prod> <path/to/app.apk>
#
# Auth: assumes `firebase login` has already been run interactively on this
# machine. Run it once if `firebase projects:list` fails below.
#
# Optional env vars:
#   TESTER_GROUP          Firebase App Distribution tester group alias to
#                          notify (must already exist in the Firebase console).
#   FIREBASE_RELEASE_NOTES Release notes string attached to the distribution.
set -euo pipefail

FLAVOR="${1:?Usage: upload_firebase_android.sh <dev|prod> <path/to/app.apk>}"
APK_PATH="${2:?Usage: upload_firebase_android.sh <dev|prod> <path/to/app.apk>}"

case "$FLAVOR" in
  dev)
    FIREBASE_APP_ID="1:558330423342:android:71af15af5ebf9d65b797bf"
    ;;
  prod)
    FIREBASE_APP_ID="1:800392507019:android:7eca1e3ad93c85f9b3ae8e"
    ;;
  *)
    echo "✘ Unknown flavor '$FLAVOR' (expected dev or prod)" >&2
    exit 1
    ;;
esac

if [[ ! -f "$APK_PATH" ]]; then
  echo "✘ APK not found: $APK_PATH" >&2
  exit 1
fi

if ! command -v firebase >/dev/null 2>&1; then
  echo "✘ firebase CLI not found. Install: npm install -g firebase-tools" >&2
  exit 1
fi

if ! firebase projects:list >/dev/null 2>&1; then
  echo "✘ Not logged in to firebase CLI. Run: firebase login" >&2
  exit 1
fi

group_args=()
if [[ -n "${TESTER_GROUP:-}" ]]; then
  group_args=(--groups "$TESTER_GROUP")
fi

notes_args=()
if [[ -n "${FIREBASE_RELEASE_NOTES:-}" ]]; then
  notes_args=(--release-notes "$FIREBASE_RELEASE_NOTES")
fi

echo "◆ Uploading $APK_PATH to Firebase App Distribution ($FLAVOR, app $FIREBASE_APP_ID)"
firebase appdistribution:distribute "$APK_PATH" \
  --app "$FIREBASE_APP_ID" \
  "${group_args[@]}" \
  "${notes_args[@]}"
