# Build Automation — Makefile + Scripts Parity Plan

Mirror the beigeApp build automation (Makefile + `scripts/build_*.sh`) into biegeCPapp, but bake `--dart-define-from-file=env/<flavor>.json` into every `flutter` invocation per this repo's `CLAUDE.md` command reference.

Non-goals: Firebase App Distribution / TestFlight upload scripts. Beige has `scripts/distribute_*.sh` — flag as follow-up only if CP needs it.

---

## Source references

- beige `Makefile` — flavor-scoped targets, delegates `build-dev` / `build-prod` to shell scripts, direct `flutter build ipa|apk` for individual platform targets.
- beige `scripts/build_dev.sh` / `build_prod.sh` — `set -euo pipefail`, `flutter clean` + `flutter pub get`, iOS `build ipa` guarded by `uname != Darwin`, then Android `build apk`.
- CP `CLAUDE.md` "Commands" section — canonical flag list including `--flavor`, `--dart-define-from-file=env/<f>.json`, `-t lib/main_<f>.dart`. Lists both `build apk` and `build appbundle` per flavor.

---

## 1. `Makefile` at repo root

Same target names as beige plus a few additions.

```make
.PHONY: build-dev build-dev-ios build-dev-android build-dev-aab \
        build-prod build-prod-ios build-prod-android build-prod-aab \
        run-dev run-prod clean pub analyze test

DEV_ENV  := env/dev.json
PROD_ENV := env/prod.json

run-dev:
	flutter run --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart

run-prod:
	flutter run --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart

build-dev:
	./scripts/build_dev.sh

build-dev-ios:
	flutter clean && flutter pub get && \
	  flutter build ipa --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart --release

build-dev-android:
	flutter clean && flutter pub get && \
	  flutter build apk --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart --release

build-dev-aab:
	flutter clean && flutter pub get && \
	  flutter build appbundle --flavor dev --dart-define-from-file=$(DEV_ENV) -t lib/main_dev.dart --release

build-prod:
	./scripts/build_prod.sh

build-prod-ios:
	flutter clean && flutter pub get && \
	  flutter build ipa --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart --release

build-prod-android:
	flutter clean && flutter pub get && \
	  flutter build apk --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart --release

build-prod-aab:
	flutter clean && flutter pub get && \
	  flutter build appbundle --flavor prod --dart-define-from-file=$(PROD_ENV) -t lib/main_prod.dart --release

clean:
	flutter clean

pub:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test
```

Additions over beige:

- `run-dev` / `run-prod` — dev-loop convenience.
- `build-dev-aab` / `build-prod-aab` — appbundle target (Play Store upload artifact). CP `CLAUDE.md` lists it; beige `Makefile` does not.
- `analyze` / `test` — shortcut targets, keep parity with `CLAUDE.md` "Commands" list.

`build ipa` vs `build ios`: beige uses `build ipa`, CP `CLAUDE.md` writes `build ios`. Use `build ipa` — it produces the signed archive needed for App Store / TestFlight distribution. `build ios` builds only the Xcode `.app` bundle. Same source, different packaging. Update `CLAUDE.md` command list to match after Makefile lands.

---

## 2. `scripts/build_dev.sh`

Beige structure + env-file preflight + AAB step. Marks executable via `chmod +x`.

```bash
#!/usr/bin/env bash
# Build dev-flavor release: iOS IPA + Android APK + AAB.
# Usage: ./scripts/build_dev.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ENV_FILE="env/dev.json"

log() { printf "\n\033[1;34m==> %s\033[0m\n" "$*"; }
err() { printf "\n\033[1;31m!! %s\033[0m\n" "$*" >&2; }

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
fi

log "Build Android APK (dev, release)"
flutter build apk --flavor dev \
  --dart-define-from-file="$ENV_FILE" \
  -t lib/main_dev.dart --release

log "Build Android AAB (dev, release)"
flutter build appbundle --flavor dev \
  --dart-define-from-file="$ENV_FILE" \
  -t lib/main_dev.dart --release

log "Done"
echo "IPA: build/ios/ipa/*.ipa"
echo "APK: build/app/outputs/flutter-apk/app-dev-release.apk"
echo "AAB: build/app/outputs/bundle/devRelease/app-dev-release.aab"
```

## 3. `scripts/build_prod.sh`

Same shape as dev script with swaps:

- `ENV_FILE="env/prod.json"`
- `--flavor prod`
- `-t lib/main_prod.dart`
- output paths `app-prod-release.apk` / `bundle/prodRelease/app-prod-release.aab`
- preflight error message references `env/prod.json`

---

## 4. Permissions + gitignore audit

- `chmod +x scripts/build_dev.sh scripts/build_prod.sh` after creating.
- Verify `.gitignore` excludes `env/dev.json` and `env/prod.json` (only `.example.json` variants should be committed). Add entries if missing.
- Sanity: `env/*.example.json` files already exist in repo — copy pattern is established.

---

## 5. Verification order

1. `make pub` — smoke, confirms Makefile parses.
2. `make analyze` — expect clean (current baseline: 2 pre-existing info hints, no errors/warnings).
3. `make run-dev` on a connected device / simulator — confirms `--dart-define-from-file` values resolve through `Env` bootstrap in `lib/main.dart`.
4. `make build-dev-android` — fastest full-build sanity (~2–4 min).
5. `make build-dev` — full dev fanout (IPA + APK + AAB, ~10–20 min).
6. `make build-prod` — CI-grade rehearsal.

Fail early on any step; don't chain from 5→6 without a clean 4.

---

## 6. Files touched

Create:

- `Makefile`
- `scripts/build_dev.sh`
- `scripts/build_prod.sh`

Modify only if needed:

- `.gitignore` — add `env/dev.json` / `env/prod.json` if not already excluded.
- `CLAUDE.md` — swap `flutter build ios` → `flutter build ipa` in the Commands section for consistency with the Makefile.

---

## 7. Follow-ups (out of scope)

- `scripts/distribute_ios.sh` / `distribute_android.sh` — port from beige only when CP wires Firebase App Distribution / TestFlight upload flow.
- `scripts/asset_cleanup.sh` — beige-specific asset audit; port if / when a CP asset cleanup phase starts.
- CI wiring (GitHub Actions / Codemagic) referencing `make build-dev-android` etc. — separate task.

## 8. Rollout order

1. Create `Makefile` + smoke `make pub` + `make analyze`.
2. Add `scripts/build_dev.sh`, `chmod +x`, smoke `make build-dev-android`.
3. Add `scripts/build_prod.sh`, `chmod +x`, smoke `make build-prod-android` on a scratch tag.
4. Update `CLAUDE.md` `flutter build ios` → `flutter build ipa`.
5. Announce Makefile targets in team channel; deprecate ad-hoc build commands.
