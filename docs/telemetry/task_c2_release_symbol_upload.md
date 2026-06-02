# Task C2 — Release symbol upload (iOS dSYM + Android mapping)

**Phase:** C · **Status:** 🟢 Completed (2026-06-02) · **Est:** 0.5d

| Field | Value |
|---|---|
| Owner | TBD |
| Branch | `telemetry/c2-symbol-upload` |

## Goal
Verify and (if missing) wire the release-build symbol upload for both platforms across both flavors. Without this, every release-build crash stack trace is unsymbolicated — a useless report. Recent commit `c34924f` introduced per-flavor Firebase wiring; this task closes the verification loop.

## References
- `android/app/build.gradle` (or `.kts`)
- `ios/Runner.xcodeproj/project.pbxproj` — Build Phases
- `ios/Podfile`
- `c34924f` — per-flavor Firebase wiring commit

## Files in scope (2, audit-only if already correct)
- `android/app/build.gradle(.kts)` — confirm `com.google.firebase.crashlytics` Gradle plugin applied; `firebaseCrashlytics { mappingFileUploadEnabled true }` on release buildType; `nativeSymbolUploadEnabled true` if NDK ships any native code (audit; this repo is pure Flutter so likely no).
- `ios/Runner.xcodeproj/project.pbxproj` — confirm per-scheme Build Phase runs `${PODS_ROOT}/FirebaseCrashlytics/run` with input files `${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}` and `$(SRCROOT)/$(BUILT_PRODUCTS_DIR)/$(INFOPLIST_PATH)`, for both `Runner-dev` and `Runner-prod` (or however flavors are named).

## Steps
- [ ] Android: open `android/app/build.gradle`; verify `apply plugin: 'com.google.firebase.crashlytics'` + the `firebaseCrashlytics` block. If missing, add per Firebase docs.
- [ ] Android: ensure `release` buildType keeps `minifyEnabled true` + `shrinkResources true` and that mapping upload is enabled. If R8 is off in `prod`, turn it on (separate consideration — confirm with team before flipping).
- [ ] iOS: open Xcode project, for each scheme's Runner target, confirm Build Phases include the `[CP] Embed Pods Frameworks` AND a "Upload Symbols to Crashlytics" run script identical to what FlutterFire `firebase_crashlytics` README mandates.
- [ ] iOS: confirm `DEBUG_INFORMATION_FORMAT = dwarf-with-dsym` for Release config across both flavors.
- [ ] CI: if `.github/workflows/` or equivalent has a release build job, it should already be producing mapping.txt / dSYM artifacts; verify they're uploaded.
- [ ] Manual: do a release-flavor build, install on device, trigger a deliberate crash. Confirm Crashlytics dashboard shows a symbolicated stack within 10 minutes.

## Acceptance
- [ ] Both flavors (`dev`, `prod`) upload symbols on release builds.
- [ ] One deliberate test crash on each platform comes back symbolicated.
- [ ] `MIGRATION_LOG.md` entry records the verification + any config delta.

## Notes
- This task is mostly audit. If the recent per-flavor wiring commit already did everything correctly, the deliverable is a verification entry in `MIGRATION_LOG.md` and the test-crash screenshots.
- iOS dSYM upload silently no-ops if Firebase plist isn't found at build time — the per-flavor `GoogleService-Info.plist` selection from `c34924f` is load-bearing here.
- Do NOT enable bitcode (Apple deprecated it). Crashlytics dSYM upload assumes no bitcode.
