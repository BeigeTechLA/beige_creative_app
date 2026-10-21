# Flutter Dependency Upgrade & iOS 27 Readiness

Standalone upgrade plan. **Not part of the migration phases** — tracked on its
own, separate from `docs/phase6/` and the `MIGRATION_PLAN.md` phase sequence.

**Overall status:** 🟡 In Progress · 10 / 12 tasks done · U-12 paused by user (local suite green; native integration/device checks pending)
**Created:** 2026-10-19 · **Updated:** 2026-10-21 (local regression verified; paused at user request)

> **Scope change 2026-10-21 (user):** iOS 27 / Xcode 27 compatibility is **not**
> being done. **U-11 is skipped.** Plugin upgrades (U-07→U-10) and the U-12
> regression still proceed. The privacy manifest (U-03) stays — it is a general
> App Store requirement, not iOS-27-specific.

| Field | Value |
|---|---|
| Goal | Upgrade every outdated plugin to its latest resolvable version (including the breaking majors), add the iOS app privacy manifest, then cut the build over to Xcode 27 / iOS 27 SDK with a passing App Store validation. |
| Flutter | Pin `3.47.0` (stable) for machine + CI. |
| Branch | `upgrade/<task-slug>` per task |
| Strategy | Strict **low-impact → high-impact** ordering, iOS 27 cutover last. Low (infra/safe bumps) → Med (isolated iOS manifest, Dart-only majors, native plugin bumps) → High (deep Dart migrations, then the native Firebase major) → iOS 27 cutover → full regression. Two forced dependencies override pure blast-radius: riverpod before go_router (`routerProvider` sits on riverpod), and socket_io leads the High tier (contained to messages). Firebase lands last among the majors — biggest native change + iOS-27 gate — but builds on Xcode 16+, so it does not require the Xcode 27 toolchain and stays before the cutover. |

**Legend:** 🔴 Not Started · 🟡 In Progress · 🟢 Completed · ⏭️ Skipped

Every task: own PR, gated by `flutter analyze --fatal-infos` + full `flutter test` + a local iOS build. No task merges red.

---

## Task list

Ordered low-impact → high-impact; iOS 27 cutover last. Tier banding in the Risk column.

| # | Task | Status | Risk | Est. |
|---|---|---|---|---|
| U-01 | Pin Flutter 3.47.0 — FVM + CI workflows | 🟢 | Low | 0.25d |
| U-02 | Tier A safe bumps (`pub upgrade`, in-constraint) | 🟢 | Low | 0.5d |
| U-03 | iOS `PrivacyInfo.xcprivacy` app manifest (isolated, zero Dart) | 🟢 | Med | 0.5d |
| U-04 | Dart-only majors batch: share_plus 13, package_info 10, cached_network_image 4, open_file 4, flutter_secure_storage 11 | 🟢 | Med | 1.5d |
| U-05 | file_picker 11→13 (drops DKImagePickerController pod) | 🟢 | Med | 1d |
| U-06 | google_maps_flutter 2.19 + geolocator/geocoding apple bumps (geocoding 4→5) | 🟢 | Med | 0.75d |
| U-07 | socket_io_client 2→3 migration (contained: messages only) | 🟢 | High | 1d |
| U-08 | flutter_riverpod 2→3 migration (foundation — before go_router) | 🟢 | High | 2.5d |
| U-09 | go_router 14→18 migration (on riverpod 3 base) | 🟢 | High | 1.5d |
| U-10 | Firebase group major: core 3→5, analytics 11→13, crashlytics 4→6 (native FB 12.x, iOS-27 gate) | 🟢 | High | 1d |
| U-11 | iOS 27 / Xcode 27 cutover + TestFlight validation | ⏭️ | High | 1d |
| U-12 | Full regression: analyze, unit, widget, golden, integration, device smoke | 🟡 | Med | 1d |

**Total est.:** ~12.5 effort-days.

**Ordering rationale:** U-01→U-02 are infra/no-code. U-03→U-06 are Med: U-03 is iOS-config-only (float-anywhere, landed early so it is not forgotten), then Dart-only API churn, then the two native-touching plugin bumps (file_picker darwin, maps/location). U-07→U-10 are High: socket_io first (smallest blast radius), then riverpod (foundation for the router), then go_router (depends on riverpod 3), then Firebase (biggest native change + iOS-27 gate, builds on Xcode 16+ so it lands before the cutover). U-11 cutover last; U-12 regression closes.

---

## Phase structure

The 12 tasks group into 6 phases by risk tier. A phase closes only when all its
tasks are 🟢 and the phase Done Criteria holds. Phases run in order; within a
phase, tasks are order-free **except** where noted.

| Phase | Goal | Tasks | Files Touched | Done Criteria | Status |
|---|---|---|---|---|---|
| 1 — Foundation (Low) | Pin SDK + land every in-constraint bump | U-01, U-02 | `.fvmrc`, `.github/workflows/*.yml`, `pubspec.lock` | CI resolves 3.47.0; `pub upgrade` resolved; analyze+test+iOS build green | Completed |
| 2 — Isolated + Dart-only majors (Med) | iOS privacy manifest + Dart-only major API migrations | U-03, U-04 | `ios/Runner/PrivacyInfo.xcprivacy`; share_plus / package_info / cached_network_image / open_file / secure_storage call sites | Manifest present; 5 majors migrated; gates green | Completed |
| 3 — Native plugin bumps (Med) | file_picker darwin + maps/location native | U-05, U-06 | `pubspec.yaml`, `ios/Podfile.lock`, picker/map/geocode call sites | `pod install` clean (DKImagePicker gone); pick+map+geocode work on iOS; gates green | Completed |
| 4 — Deep Dart migrations (High) | socket_io → riverpod → go_router majors | U-07, U-08, U-09 | messages socket source; all `presentation/providers/*`; `lib/app/router.dart` + route files | Realtime works; provider state intact; all routes navigate + guards fail closed; gates green | Completed (lib; riverpod test migration → U-12) |
| 5 — Firebase native major (High) | FB group → native iOS 12.x | U-10 | `pubspec.yaml`, `ios/Podfile.lock`, firebase init/analytics/crashlytics sites | FB 12.x pods resolve; forced crash + event verified on device; gates green | Completed (device crash/event verify → U-12) |
| 6 — Regression (High) | Full regression (iOS 27 cutover U-11 descoped) | ~~U-11~~, U-12 | `test/**`, goldens | All suites + device smoke green | In Progress (U-11 skipped) |

**Fixed intra-phase order:** Phase 4 runs U-07 → U-08 → U-09 (go_router needs the
riverpod 3 base). All other within-phase tasks are order-free.

---

## Dependency audit snapshot (2026-10-19)

Captured from `flutter pub outdated` + `ios/Podfile.lock` on Flutter 3.47.0 / Dart 3.13.0.

### iOS 27 native risk (build / App Store validation gate)

| Native pod (current) | Via plugin | Risk | Note |
|---|---|---|---|
| Firebase 11.15.0 | firebase_* (core 3.15, analytics 11.6, crashlytics 4.3) | 🔴 High | Xcode 27 SDK wants Firebase iOS 12.x; needs major Flutter bump → U-10 |
| DKImagePickerController 4.3.9 | file_picker 11 | 🟠 Med | Ancient ObjC pod; file_picker 13 drops it → U-05 |
| GoogleMaps 9.4.0 | google_maps_flutter 2.17 | 🟡 Low-Med | plugin 2.19 bumps pod → U-06 |
| geolocator_apple 1.2.0 | geolocator 14.0 | 🟢 Low | 2.4.1 available → U-06 |
| image_picker_ios 0.8.13+6 | image_picker 1.2.2 | 🟢 Low | patch bumps → U-02 |
| SDWebImage 5.21.7 | cached_network_image | 🟢 Low | recent |

App-level `PrivacyInfo.xcprivacy` **missing** — hard App Store gate, independent of plugins → U-03.
Native pods already ship their own privacy manifests (GoogleUtilities/Privacy present).

### Tier A — safe, within constraint (`pub upgrade`, no code change) → U-02

connectivity_plus 7.1→7.3 · dio 5.9→5.11 · google_maps_flutter 2.17→2.19 · image_picker 1.2.2→1.2.4 · intl 0.20.2→.3 · lottie 3.3→3.6 · path_provider 2.1.5→.6 · shared_preferences 2.5.5→.6 · url_launcher 6.3.2→.3 · table_calendar 3.2→3.3 · flutter_secure_storage 10.3.1→.4 · file_picker 11.0.2→.3 · geolocator platform bump

### Tier B — breaking majors (pubspec edit + code migration)

| Pkg | Jump | Breaking | Task |
|---|---|---|---|
| firebase_core | 3→5 | FB group, native 12.x | U-10 |
| firebase_analytics | 11→13 | event API | U-10 |
| firebase_crashlytics | 4→6 | init API | U-10 |
| file_picker | 11→13 | new darwin impl, API | U-05 |
| flutter_riverpod | 2→3 | Notifier/provider API | U-08 |
| go_router | 14→18 | redirect/route API | U-09 |
| socket_io_client | 2→3 | connect/event API | U-07 |
| share_plus | 10→13 | `SharePlus.instance.share(ShareParams)` | U-04 |
| package_info_plus | 8→10 | minor API | U-04 |
| cached_network_image | 3→4 | minor | U-04 |
| open_file | 3→4 | result API | U-04 |
| flutter_secure_storage | 10→11 | options API | U-04 |
| geocoding | 4→5 | minor (geocoding_darwin native) | U-06 |

`js` transitive pkg discontinued — resolves away when firebase_*_web updates in U-10.

---

## Per-task plan tables

### U-01 Pin Flutter 3.47.0

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Pin SDK for team + CI | `.fvmrc`, `.github/workflows/ci.yml`, `.github/workflows/integration.yml` | CI resolves `flutter-version: 3.47.0`; `fvm use 3.47.0` succeeds | Completed |

### U-03 iOS privacy manifest

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | App-level `PrivacyInfo.xcprivacy` + wire into Runner target | `ios/Runner/PrivacyInfo.xcprivacy`, `ios/Runner.xcodeproj/project.pbxproj` | plist lints OK; bundled at `Runner.app/PrivacyInfo.xcprivacy`; iOS build green | Completed |

**Declared Required Reason APIs:** UserDefaults `CA92.1`, FileTimestamp `C617.1`,
SystemBootTime `35F9.1`, DiskSpace `E174.1`. `NSPrivacyTracking` = false, no
tracking domains. Plugin pods keep their own manifests (not re-declared).

**⚠️ U-11 follow-up (PM/legal):** `NSPrivacyCollectedDataTypes` left empty. Before
TestFlight submission, confirm and finalize the data-collection disclosure (email,
name, phone, precise location, photos, product interaction/analytics, crash data)
in App Store Connect — and mirror into the manifest if the aggregate privacy
report is desired.

### U-04 + U-05 Dart-only majors batch + file_picker 13

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Bump 6 majors + migrate call sites | `pubspec.yaml`, `pubspec.lock`, share_plus/file_picker call sites | analyze clean; iOS build green; DKImagePicker gone | Completed |

**Ordering override (user-approved):** U-04's share_plus 13, package_info 10, and
secure_storage 11 all require `win32 ^6`, which `file_picker 11` forbids
(`win32 ^5.9`). Only `file_picker 13` lifts the cap, so **U-05 was pulled forward**
and landed together with U-04 as one atomic resolve. Final: file_picker 13.1.0,
share_plus 13.3.1, package_info_plus 10.2.2, cached_network_image 4.0.4,
open_file 4.0.0, flutter_secure_storage 11.2.0, win32 6.4.0.

**API migrations:**
- share_plus: `Share.shareUri(uri)` → `SharePlus.instance.share(ShareParams(uri:))`.
- file_picker 13: `pickFiles()` now returns `List<PlatformFile>` (empty on cancel),
  `pickFile()` returns `PlatformFile?`; dropped `allowMultiple`/`withData`;
  `PlatformFile.size` → `await length()`. Migrated `common_uploader.dart`,
  `signup3_screen.dart` (→ `pickFile`), `fm_upload_sheet.dart` (→ `pickFiles` list).
- package_info_plus / cached_network_image / open_file / secure_storage: no code change.

**⚠️ SPM recovery (important for all later iOS builds):** Flutter's Swift Package
Manager was enabled globally. After a `flutter clean` + `rm -rf ios/Pods`, Flutter
silently **auto-migrated the Runner project to SPM** (rewrote `project.pbxproj`,
dropped the 65-pod CocoaPods set to 4, broke the committed
`${PODS_ROOT}/FirebaseCrashlytics/run` build phase). The committed project is
deliberately **CocoaPods**. Recovery: `flutter config --no-enable-swift-package-manager`,
`git checkout ios/Runner.xcodeproj/project.pbxproj`, re-apply the privacy-manifest
pbxproj entries, then clean → `pub get` → `pod install` (restores 36 pods +
Crashlytics `run`). **Do not re-enable SPM during this upgrade** — U-11 cutover
can decide SPM adoption separately.

### U-10 Firebase group major

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Bump pubspec, resolve native 12.x | `pubspec.yaml`, `pubspec.lock`, `ios/Podfile.lock` | `pod install` pulls Firebase 12.x; app compiles | Completed (FB 12.19.0; `pod update` on dev pods needed to break the old 11.15 lock pin) |
| 2 | Migrate init/analytics/crashlytics call sites | firebase init + analytics + crashlytics usages | analyze green; events log; forced crash reports | Completed (no code changes — Dart API stable 3→5/11→13/4→6; device event/crash → U-12) |

### U-08 flutter_riverpod 2→3

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Migrate Notifier/provider APIs | all `presentation/providers/*`, `lib/app/*` | analyze green on riverpod 3 | Completed |
| 2 | Fix tests + overrides | `test/**`, `pump_app` helper | full `flutter test` green | Deferred to U-12 (user: tests at end) |

### U-09 go_router 14→18

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Migrate router + redirects | `lib/app/router.dart`, route call sites | analyze green; all routes navigate | Completed (no code changes needed — 14.8 APIs forward-compatible with 18) |

### U-11 iOS 27 cutover

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Xcode 27 toolchain | CI macos image, local Xcode 27 | `flutter build ipa --flavor prod` green | Not Started |
| 2 | TestFlight validate | — | Upload accepted; privacy manifest passes | Not Started |

---

## Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | After each task: `flutter analyze --fatal-infos` + `flutter test` | All green | Golden SDK pixel drift — regen only on deliberate token change |
| 2 | Build iOS after every native-touching task (U-02–U-06, U-11) | `flutter build ipa --flavor dev` succeeds | Pod cache stale → `pod deintegrate && pod install` |
| 3 | Firebase (U-04): trigger forced crash + log event on device | Crash in Crashlytics console; event in Analytics DebugView | Offline queue, release vs debug symbol upload |
| 4 | file_picker (U-05): pick + upload file/image on iOS and Android | File picked, multipart upload succeeds | Large file, permission denied, iOS Files provider |
| 5 | Maps/location (U-06): open map, autofill address on signup | Map renders, geocode resolves | Permission prompt, no-GPS, iOS 27 sim |
| 6 | Riverpod (U-07): login → home → logout, provider state intact | No lost state, no provider errors | Hot restart, auto-dispose timing |
| 7 | go_router (U-08): deep routes, guarded redirects (pending/rejected) | Status guards still fail closed | `state.extra` map args, back-stack |
| 8 | socket.io (U-09): messages live connect, send, receive | Realtime delivery, reconnect works | Token refresh, 401 self-heal logout path |
| 9 | iOS 27 (U-11): run on iOS 27 device/sim, submit to TestFlight | App launches, all perms work, upload accepted | Privacy manifest reasons complete |
| 10 | Full regression (U-12): integration tests login/logout + signup | Both integration suites pass | Device CI binding swap if required |

### U-12 parallel CI review — Codex (2026-10-21)

Claude owns test generation/migration and related regression fixes. Codex's
parallel pass covered CI/native configuration; no test or production Dart files
were edited in this pass.

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Review CI/native upgrade configuration | Read only | Identify configuration gaps | Completed |
| 2 | Preserve CocoaPods in iOS CI | `.github/workflows/integration.yml` | Disable SPM before dependency installation, iOS matrix only | Completed |
| 3 | Verify and record handoff | Upgrade plan, handoff, migration log | Analysis, YAML, plist, whitespace checks pass | Completed |

- [x] iOS CI explicitly runs `flutter config --no-enable-swift-package-manager`;
  the local global setting does not carry over to GitHub runners.
- [x] `flutter analyze --no-pub --fatal-infos lib/`: no issues.
- [x] Workflow YAML parses; CocoaPods step precedes dependency installation.
- [x] `plutil -lint`: privacy manifest, Runner project, AppFrameworkInfo pass.
- [x] `git diff --check`: passes.
- [x] Test/golden regression completed by Codex after Claude stopped: 749/749 pass.
- [x] Integration entry points promoted to the device test binding.
- [ ] Complete native integration execution; see paused takeover report below.
- [ ] Run remote CI and real-device smoke; neither was executed in this pass.

U-12 remains in progress; U-11 remains skipped. No clean, dependency resolution,
golden regeneration, native build, or full-suite run was performed by Codex while
Claude's parallel test work was active.


## U-12 takeover report — paused 2026-10-21

**User requested a safe stop; resume tomorrow.** Changes are preserved in the
working tree; no commit, push, deployment, or release was performed. Earlier
parallel ownership notes are historical: Claude stopped and Codex took over.

| Phase | Goal | Files Touched | Done Criteria | Status |
|-------|------|---------------|---------------|--------|
| 1 | Establish failures after Claude stopped | Test logs | Fresh suite triaged | Completed |
| 2 | Finish regression fixes | `test/app/*`, login screen test, shared widget/layout tests | Focused tests and full suite pass | Completed |
| 3 | Verify native journeys and finalize regression | `integration_test/*`, macOS pods/config, status docs | Native journeys, device smoke and remote CI verified | In Progress |

### Verified

- Flutter 3.47.0 / Dart 3.13.0; SPM disabled locally and explicitly in iOS CI.
- `flutter test --no-pub --coverage --reporter expanded`: **749/749 pass**,
  including Claude's regenerated goldens. No remaining failures in this suite.
- Full-project `flutter analyze --no-pub --fatal-infos`: **0 issues**, including
  the updated integration bindings.
- Coverage: **11209 / 21804 = 51.41%**. The existing **70% gate is unchanged**;
  CI will still fail that gate until Phase 6 coverage work raises the result.
- Unsigned dev iOS build passes using `lib/main_dev.dart` and
  `env/dev.example.json`; output `build/ios/iphoneos/Runner.app`.
- Native macOS app builds after updating Firebase pods to 12.19.0 and Flutter's
  automatic minimum deployment target migration from 10.15 to 12.0.
- `git diff --check` passes.

### Fixes completed

- Connectivity tests now supply approved account flags. Rejected-route tests
  match the established Home status-overlay behavior, confirmed in source and
  migration log. Signup-success analytics opt-out is covered.
- Login widget test no longer globally suppresses Flutter errors or depends on
  a particular debug email; its router is disposed after each test.
- Loader test supplies its required Stack parent; button test checks the current
  circular spinner; drawer test checks that unavailable Payouts stays hidden.
- Preserved Claude's Riverpod migration, image-preview retry fix and golden work.
- Both integration entry points now initialize
  `IntegrationTestWidgetsFlutterBinding`. macOS Firebase lockfile was stale at
  11.15.0 and was updated using the three Firebase plugin pod names.

### Exact resume point / pending

1. **Native integration execution is NOT verified.** The macOS app compiled and
   the login/logout journey began, but Flutter reported
   `Failed to foreground app; open returned 1`. No passing journey result was
   emitted before the user's stop request. Codex interrupted the runner safely;
   stream/sink shutdown errors occurred during cancellation, not a completed
   test verdict. Signup's native run has not been verified either.
   Resume with:
   `flutter test --no-pub integration_test/login_logout_test.dart integration_test/signup_flow_test.dart -d macos --reporter expanded`.
   Check foreground/window and live-binding behavior if it stalls again. Latest
   diagnostic log: `/tmp/beige-upgrade-integration-final.log` (temporary).
2. Run Android/iOS integration CI and verify the device bindings there. No
   remote workflow was triggered in this session.
3. Real iOS smoke: login/status guards/logout, file pick/upload, maps/geocode,
   realtime send/receive/reconnect, Firebase Analytics event and Crashlytics
   report. Golden visual review on device remains part of smoke testing.
4. Raise coverage from 51.41% to the existing 70% gate (Phase 6.14 / 6.13).
5. Before distribution, confirm privacy data-collection disclosures. U-11
   iOS 27/Xcode 27/TestFlight cutover remains **skipped**, not completed.

### Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | Resume native login/logout and signup journeys | Both tests finish green | macOS foreground failure; live-binding timing |
| 2 | Run Android/iOS integration workflow | Both platform jobs green | Simulator availability, native plugin behavior |
| 3 | Perform iOS smoke checklist above | Existing app flows work | Denied permissions, cancelled picker, reconnect, pending/rejected accounts |

Full-suite log: `/tmp/beige-upgrade-final-tests.log`; final analysis log:
`/tmp/beige-upgrade-analyze-final.log`; iOS build log:
`/tmp/beige-upgrade-ios-build.log`. These are temporary diagnostics; the results
above are the durable handoff. U-12 remains open and is paused at user request.
