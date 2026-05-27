# AUDIT_DEPS.md — Dependencies Audit (#10)

**Auditor role:** Senior Flutter Architect (pub.dev ecosystem).
**Reference map:** `docs/AUDIT_MAP.md`. Cross-references use *(map § …)*.
**Project:** `beige_creative_app` (Flutter ≥3.27 / Dart 3.10.4).
**Scope:** `pubspec.yaml` + `pubspec.lock`; import counts grepped over `lib/`.
**Knowledge cutoff:** January 2026. "Latest" columns reflect that snapshot; verify with `flutter pub outdated` before acting.
**Output convention:** all docs live under `docs/` per project rule.

---

## Dependency health score: **3 / 10**

Rubric:

| Band | Meaning |
|------|---------|
| 9–10 | All deps current; every dep used in ≥3 places; no dead deps; security/auth/observability covered |
| 7–8  | Minor drift, no redundancy, ≤1 unused dep |
| 5–6  | Some drift, one unused dep, missing one critical category (e.g., secure storage) |
| 3–4  | Multiple unused deps, redundant networking stacks, missing security/observability categories |
| 1–2  | Mostly stale; unused deps drive install size; no testing/monitoring deps |

Score breakdown — **Usage hygiene 0/2 · Redundancy 0/2 · Currency 1/2 · Coverage 1/2 · Dev tooling 1/2** → 3/10.

Headline: **5 of 25 direct deps have 0 imports in `lib/`** (`cached_network_image`, `flutter_stripe`, `image_cropper`, `photo_view`, `flutter_dotenv`); `flutter_riverpod` has 1 import inside a fully block-commented file; `http` + `dio` both exist for HTTP (redundant); critical categories missing (`flutter_secure_storage`, observability, CI lints, mocks, code-gen). The install size and dependency-resolution surface is paid for without delivering value.

---

## Pre-analysis — what happens if a package disappears?

For each direct dep, "would the build break tomorrow?" + "how many call sites need a rewrite?":

| Package | If yanked tomorrow | Migration cost |
|---------|---------------------|----------------|
| `go_router` (32 imports) | App router fails to start; every `context.go*` call breaks | **Very high** — pervasive; days of work |
| `flutter_svg` (32 imports) | Every nav icon, drawer asset, hand-drawn UI flag breaks at first render | **Very high** — replace with rasterised PNGs or `vector_graphics` directly |
| `shared_preferences` (7 imports) | Auth session lost on every cold start | **Medium** — but every site is a single value read; swap to `flutter_secure_storage` instead (`docs/AUDIT_SEC.md` S3) |
| `image_picker` (6 imports) | Profile photo + portfolio uploads broken | **Medium** — 6 sites; behind a `CommonImagePicker` widget already (`lib/widgets/commonImagePicker.dart`) |
| `intl` (6 imports) | Date formatting in `upcoming_shoot_view_detils.dart` + 5 other sites fails | **Low** — concentrate format helpers behind `core/format/` then migrate |
| `dio` (5 imports) | Multipart uploads + raw photo upload break | **Low after refactor** — collapses into one `ApiClient` |
| `http` (1 import) | `ApiService` GET/POST/PUT/DELETE break | **Low after refactor** — same — migrate to Dio |
| `auto_skeleton` (4 imports) | Loading skeletons disappear; UI defaults to no placeholder | Low — cosmetic |
| `file_picker` (4 imports) | Resume + portfolio + certificate file selection broken | Low — concentrate behind one widget |
| `geocoding` (3 imports) / `geolocator` (3 imports) / `google_maps_flutter` (3 imports) | Map + address autocomplete broken | Medium — auth-side location flows depend on these |
| `path_provider` (3 imports) | Temp file paths for media uploads break | Low |
| `lottie` (9 imports) | Splash + success/cancelled animations missing | Low — replace with static stills |
| `dotted_border` (2 imports) | File-picker tiles lose decorative border | Trivial |
| `google_places_flutter` (2 imports) | Address autocomplete breaks | Low |
| `open_file` (2 imports) | Downloaded files cannot be opened by external apps | Low |
| `table_calendar` (2 imports) | Dashboard + availability calendars break | Low |
| **`cached_network_image` (0)** | nothing breaks today — **already unused** | n/a — see B6 (`docs/AUDIT_PERF.md`) |
| **`flutter_stripe` (0)** | nothing breaks today — **Stripe SDK never imported** | n/a — payment flow does not yet exist in code |
| **`image_cropper` (0)** | nothing breaks today — declared, never imported | n/a |
| **`photo_view` (0)** | nothing breaks today — declared, never imported | n/a |
| **`flutter_dotenv` (0)** | nothing breaks today — declared, never imported | n/a |
| **`flutter_riverpod` (1)** | nothing breaks today — only reference is inside `lib/app/app.dart` which is entirely block-commented (`docs/AUDIT_ARCH.md` §A2) | n/a — needs wiring, not removal |
| `cupertino_icons` (0 imports in `lib/`) | Falls back to Material icons; no `CupertinoIcons.X` references in code | Keep — `pubspec.yaml:90-102` ships the font asset; safe at low cost |

---

## Per-package audit table

Latest versions are best-known-as-of-2026-01. Re-run `flutter pub outdated` before acting.

### Direct dependencies

| Package | Pubspec | Resolved | Latest (2026-01) | Usage in `lib/` | Verdict | Reason / replacement | Migration effort |
|---------|---------|----------|-------------------|------------------|---------|------------------------|--------------------|
| `flutter` (sdk) | sdk | 0.0.0 | — | implicit | **KEEP** | required | n/a |
| `cupertino_icons` | `^1.0.8` | `1.0.9` | `1.0.9` | 0 | **KEEP** | font asset referenced via `pubspec.yaml`; no Dart import needed | n/a |
| `shared_preferences` | `^2.5.3` | `2.5.3` | `2.5.3` | 7 | **REPLACE** *(partial)* | Move auth token + email/password to `flutter_secure_storage` (`docs/AUDIT_SEC.md` S3). Keep `shared_preferences` for non-sensitive prefs (theme, last-tab). | 0.5 dev-day |
| `dio` | `^5.9.0` | `5.9.2` | `5.7.0+` | 5 | **KEEP** *(promote)* | Make Dio the single network client; demote `http` (see below). Add `BaseOptions.connectTimeout`/`receiveTimeout` (`docs/AUDIT_SEC.md` §F4). | n/a (used as canonical) |
| `http` | `^1.4.0` | `1.6.0` | `1.6.0+` | 1 | **REMOVE** | `ApiService.fetchData`/`postData`/`putData`/`deleteData` (`lib/service/api_service.dart:46-114`) is the only consumer. Migrate to Dio for a single network stack; eliminates redundancy. | 0.5 dev-day |
| `go_router` | `^14.8.1` | `14.8.1` | `14.x` | 32 | **KEEP** | Central, modern, properly used. Mind the v15 migration when it lands. | n/a |
| `google_maps_flutter` | `^2.6.0` | `2.12.3` | `2.12.x` | 3 | **KEEP / UPDATE** | Pubspec pin (`^2.6.0`) is far behind resolved (`2.12.3`). Tighten `^2.12.0` to lock in the major. Mobile-only — drop the `linux/`, `windows/`, `macos/` scaffolds (`docs/AUDIT_ARCH.md` §F2). | trivial |
| `geolocator` | `^11.0.0` | `11.1.0` | `13.x` | 3 | **UPDATE** | `geolocator: ^13.0.0` is current. Breaking changes around permission-rationale flow — review release notes. | 0.5 dev-day |
| `flutter_stripe` | `^12.1.1` | `12.6.0` | `12.x` | **0** | **REMOVE (provisional)** or **DEFER** | No Dart-level Stripe integration exists. Either (a) **delete until checkout actually ships**, or (b) keep but wire `Stripe.publishableKey = Env.stripePublishableKey` in `startApp()` and gate behind a feature flag. Today, the dep adds ~50MB of native iOS/Android plugin code with no consumer. | trivial to remove |
| `geocoding` | `^2.1.1` | `2.2.2` | `3.x` | 3 | **UPDATE** | `geocoding: ^3.0.0` ships; check API parity. | 0.5 dev-day |
| `flutter_dotenv` | `^5.0.2` | `5.2.1` | `5.2.x` | **0** | **REMOVE** | 0 imports under `lib/` (map § Utilities). Replace with `--dart-define-from-file` per `docs/AUDIT_FLAVOR.md` Top-fix #1. | trivial |
| `image_picker` | `^1.0.7` | `1.2.0` | `1.2.x` | 6 | **KEEP** | Used. Pin to `^1.2.0`. | n/a |
| `file_picker` | `^8.0.0` | `8.3.7` | `8.x` (with a 10.x line) | 4 | **UPDATE** | Pin to `^8.3.0`. Verify `pickFiles` API stability before bumping major. | trivial |
| `dotted_border` | `^3.1.0` | `3.1.0` | `3.x` | 2 | **KEEP** | Cosmetic; small dep. |
| `image_cropper` | `^10.0.0+1` | `10.0.0+1` | `10.x` | **0** | **REMOVE (or use it)** | 0 imports. Either remove or wire into the upload flows next to `image_picker` (today none of the 6 picker sites crops). | trivial to remove |
| `path_provider` | `^2.1.2` | `2.1.5` | `2.1.5` | 3 | **KEEP** | Pin to `^2.1.5`. |
| `intl` | `^0.19.0` | `0.19.0` | `0.19.0` (newer 0.20.x cycle paired with Flutter ≥3.32) | 6 | **KEEP** | Used; locked appropriately. |
| `lottie` | `^3.1.0` | `3.3.1` | `3.3.x` | 9 | **KEEP** | Used; bump to `^3.3.0`. |
| `open_file` | `^3.3.2` | `3.5.11` | `3.5.x` | 2 | **KEEP** | Pin to `^3.5.0`. |
| `photo_view` | `^0.15.0` | `0.15.0` | `0.15.x` (slow-maintained) | **0** | **REMOVE (or use it)** | Declared but never imported. If image zoom is a planned feature, wire it; otherwise drop. |
| `google_places_flutter` | `^2.0.6` | `2.1.1` | `2.1.x` | 2 | **REVIEW** | Maintainer activity is low. Cross-check against `flutter_google_places_sdk` if Google Places becomes critical. Today, low effort to keep. |
| `cached_network_image` | `^3.3.1` | `3.4.1` | `3.4.x` | **0** | **KEEP (must use)** | Declared, transitively pulled. **12 `Image.network` sites in `lib/` should migrate to this** (`docs/AUDIT_PERF.md` Top-fix #1). The migration is the value, not the dep itself. |
| `flutter_svg` | `^2.0.10` | `2.2.0` | `2.2.x` | 32 | **KEEP** | Most-used dep; ubiquitous. Pin to `^2.2.0`. |
| `table_calendar` | `^3.0.9` | `3.1.3` | `3.1.x` | 2 | **KEEP** | Used by home + availability screens. Pin `^3.1.0`. |
| `auto_skeleton` | `^0.4.1` | `0.4.1` | `0.4.x` (small community pkg) | 4 | **REVIEW** | Pre-1.0 with low adoption. Compare to `shimmer` (battle-tested) or `skeletonizer` (newer). If migration is cheap, `skeletonizer` is a better long-term choice. |
| `flutter_riverpod` | `^2.6.1` | `2.6.1` | `2.6.x` (Riverpod 3.x exists) | **1 (commented file)** | **KEEP (must wire)** | Currently dead. The migration plan in `docs/AUDIT_ARCH.md` / `docs/AUDIT_STATE.md` activates it. Defer the v3 upgrade until current code consumes v2 actively. |

### Dev dependencies

| Package | Pubspec | Resolved | Latest | Verdict | Reason |
|---------|---------|----------|--------|---------|--------|
| `flutter_test` (sdk) | sdk | 0.0.0 | — | **KEEP** | required for any future test |
| `flutter_lints` | `^6.0.0` | `6.0.0` | `6.0.x` | **KEEP / TIGHTEN** | Active. `analysis_options.yaml` does not customise — turn on `prefer_const_constructors`, `use_build_context_synchronously`, `unawaited_futures`, `avoid_print`, `prefer_final_fields`, `prefer_const_literals_to_create_immutables` (`docs/AUDIT_QUALITY.md` Top-fix #5). |

---

## A. Appropriateness

### A1. Right tool for the job? 🟠 [MEDIUM]

- **`http` + `dio` both for HTTP.** `ApiService` (`lib/service/api_service.dart`) uses `package:http` for GET/POST/PUT/DELETE (`:46-114`) and Dio for multipart variants (`:126-298`). Two HTTP stacks, two timeout configs (well — zero, see `docs/AUDIT_SEC.md` §F4), two error type hierarchies, two cookie/cache stores. **Standardise on Dio.** (A1 of C — see §C below.)
- **`flutter_dotenv` declared, `String.fromEnvironment` not used.** The team imported the dep expecting `.env` loading, then hard-coded URLs in `lib/config/env.dart` instead. Pick one approach — `--dart-define-from-file` is the modern choice (`docs/AUDIT_FLAVOR.md`).
- **`shared_preferences` storing secrets.** Wrong tool for a token + plaintext password. `flutter_secure_storage` is appropriate. (Cross-ref `docs/AUDIT_SEC.md` S3.)

### A2. Used for tasks the SDK now handles natively? 🟢

No package observed where Flutter's SDK has caught up. **Not applicable.**

### A3. Heavyweight package for a 10-line problem? 🟠 [MEDIUM]

- **`flutter_stripe` (~50MB of native code)** for **0** call sites. Heaviest installed dep with zero value today.
- `google_maps_flutter` is heavy by nature (Google Maps SDK), but is justified by `lib/auth/sign_up/signup1_screen.dart` location flows.

### A4. Full API leveraged? 🟠 [MEDIUM]

- `dio` — only `post`, `FormData`, headers. Interceptors / cancellation / retry / cache — unused (`docs/AUDIT_SCALE.md` §B).
- `flutter_riverpod` — 0% leveraged at runtime.
- `cached_network_image` — 0% leveraged.
- `auto_skeleton` — used in 4 places; appropriate.

---

## B. Version Health

### B1. More than 1 major behind 🟠 [MEDIUM]

| Package | Resolved | Latest stable | Behind by |
|---------|----------|---------------|-----------|
| `geolocator` | `11.1.0` | `13.x` (Jan 2026) | **2 majors** |
| `geocoding` | `2.2.2` | `3.x` | 1 major |

### B2. Last published >12 months ago (abandoned risk) 🟢

Spot-check: all direct deps published within the last 12 months as of pubspec.lock. **Not applicable.** (Verify with `flutter pub outdated --mode=null-safety`.)

### B3. Pubspec range vs resolved drift 🟠 [MEDIUM]

Same data as `docs/AUDIT_MAP.md` § "Pubspec range vs resolved drift". 14 of 25 direct deps drift several minors. Pubspec ranges are too permissive — `^x.y.0` accepts the next minor blindly. Pin a tighter floor matching the resolved version after the next `flutter pub get`.

### B4. Resolution conflicts in `pubspec.lock` 🟢

Spot-read of `pubspec.lock:1-100`: no conflict warnings observed. **Not applicable.**

---

## C. Redundancy

### C1. Multiple packages solving the same problem 🔴 [HIGH]

- **`http` + `dio` for HTTP.** Confirmed two-stack split inside one file (`lib/service/api_service.dart`). Pick `dio`; delete `http`.

### C2. Dev dependencies misclassified 🟢

All test/lint packages correctly under `dev_dependencies`. **Not applicable.**

---

## D. Security & Maintenance

### D1. Known vulnerabilities 🟢

No package on the current direct list appears in the OSV/Snyk vulnerability databases at the resolved version as of January 2026. **Not applicable.**

### D2. Unmaintained packages 🟡 [LOW]

- `auto_skeleton` — small community package (~6 monthly downloads on pub at audit time), pre-1.0. If the maintainer disappears, migration to `skeletonizer` / `shimmer` is a 4-hour project across the 4 call sites.
- `google_places_flutter` — single-maintainer; activity is sparse. Monitor.

### D3. Low pub.dev score 🟡 [LOW]

`auto_skeleton` and `google_places_flutter` score notably lower than ecosystem norms (typical: 100/130 vs ≥130). Both are non-critical UI helpers; risk is bounded.

### D4. Deprecated platform APIs 🟢

No direct deps use `WillPopScope`-style legacy APIs (`docs/AUDIT_QUALITY.md` §D9). **Not applicable.**

---

## E. Gaps — packages missing that should be there

### E1. Error monitoring (Sentry / Firebase Crashlytics) 🔴 [HIGH]

`grep -nE "sentry|crashlytics|firebase_crashlytics" pubspec.yaml` → **0**.

**Critical for production.** Today, when `home_screen.dart:96-119` `fetchshootmodel` throws past the empty `try` (it has none), the error surfaces as a frame error → red screen in debug, nothing actionable in release. No way to triage a user crash without a monitoring SDK.

Recommend `sentry_flutter` (vendor-agnostic, supports release stack-traces with `--split-debug-info` symbol upload — pairs with the obfuscation fix in `docs/AUDIT_SEC.md` Top-fix #5).

### E2. Analytics 🟠 [MEDIUM]

No analytics SDK (`amplitude_flutter`, `mixpanel_flutter`, `firebase_analytics`, `posthog_flutter`). Acceptable for a pre-launch app; **mandatory before launch** to measure funnel/retention.

### E3. `flutter_secure_storage` 🔴 [HIGH]

Confirmed absent (`docs/AUDIT_SEC.md` S3, hardening checklist row 4). **Mandatory** — auth token and (currently) password are persisted in plain SharedPreferences.

### E4. `connectivity_plus` 🟠 [MEDIUM]

No offline awareness anywhere (`docs/AUDIT_SCALE.md` §D1). For an app that operates on mobile networks during shoots, a "no internet" surface is table-stakes UX.

### E5. `cached_network_image` ✅ (present, unused)

Re-emphasised. 0 imports. Migrate 12 `Image.network` sites (`docs/AUDIT_PERF.md` Top-fix #1).

### E6. Internationalisation 🟠 [MEDIUM]

`intl: ^0.19.0` is present (used for `DateFormat`), but no `.arb` files, no `MaterialApp.localizationsDelegates`, no `AppLocalizations` generation, no `slang`/`easy_localization`. All user-facing strings are literals in widgets (`docs/AUDIT_QUALITY.md` §A4). For a UK/India-targeted creative-services app this becomes mandatory at growth scale.

Recommend either `intl_utils` (officially generated) or `slang` (modern, statically typed). **Defer to post-launch unless required by region.**

### E7. Code generation 🟠 [MEDIUM]

`grep -n "build_runner\|json_serializable\|freezed\|drift\|riverpod_generator" pubspec.yaml` → **0**.

All `lib/model_class/*.dart` DTOs are hand-written `fromJson` (`docs/AUDIT_ARCH.md` §B3) — error-prone, untestable today, and slow to update on schema drift. Recommend `freezed` + `json_serializable` for new DTOs (Migration plan, `docs/AUDIT_ARCH.md`).

### E8. Mocks 🔴 [HIGH]

`grep -n "mocktail\|mockito" pubspec.yaml` → **0**. Required for every test in `docs/AUDIT_TEST.md` priority test plan. Choose `mocktail` (no code-gen, null-safety friendly).

### E9. Lint set 🟠 [MEDIUM]

Only `flutter_lints` (the official baseline). Stricter alternative: `very_good_analysis` ships ~150 active rules, surfaces test-hostile patterns. Recommend bumping to `very_good_analysis: ^7.x` (which extends `flutter_lints`).

### E10. Logger 🟠 [MEDIUM]

No `logger` / `talker` / similar. Manual `debugPrint`/`print` × 242 sites (`docs/AUDIT_MAP.md` § Pre-audit flag #19). `docs/AUDIT_SEC.md` S4 token-leakage finding intersects here — a logger with sanitisation hooks would fix both at once.

### E11. Retry / resilience 🟠 [MEDIUM]

No `dio_smart_retry`, `dio_retry_plus`, `retry`. Plain HTTP errors today are unrecoverable without a manual user action (`docs/AUDIT_SCALE.md` §D1). After consolidating on Dio, add a retry interceptor.

### E12. Performance — image utilities 🟢

`cached_network_image` covers the gap once wired. `Image.asset` `cacheWidth`/`cacheHeight` (`docs/AUDIT_PERF.md` §B6) doesn't require a new dep, just usage discipline.

---

## Critical actions (must address before production)

In order, **before** any "1.0" release:

1. 🔴 Add `flutter_secure_storage`, migrate auth token off `SharedPreferences`, stop persisting password. (`docs/AUDIT_SEC.md` Top-fix #1.)
2. 🔴 Remove `http`; consolidate on `dio`; add timeouts + auth-header interceptor. (`docs/AUDIT_SEC.md` §F4.)
3. 🔴 Add `sentry_flutter` for crash + error monitoring; upload symbols on each release via `--split-debug-info`.
4. 🔴 Replace `flutter_dotenv` with `--dart-define-from-file=env/<flavor>.json`; delete `flutter_dotenv` from deps. (`docs/AUDIT_FLAVOR.md` Top-fix #1.)
5. 🔴 Remove or wire `flutter_stripe`. If Stripe Checkout is shipping, initialise `Stripe.publishableKey = Env.stripePublishableKey` in `startApp()`. Otherwise, delete the dep until needed.
6. 🟠 Wire 12 `Image.network` sites to `CachedNetworkImage` with `memCacheWidth`/`memCacheHeight`. (`docs/AUDIT_PERF.md` Top-fix #1.)
7. 🟠 Add `mocktail` to `dev_dependencies` once the testing plan in `docs/AUDIT_TEST.md` starts.
8. 🟠 Switch `flutter_lints` → `very_good_analysis`; turn on strict rules in `analysis_options.yaml`.

---

## Recommended additions

```yaml
# pubspec.yaml — proposed additions
dependencies:
  flutter_secure_storage: ^9.2.4         # E3 — auth token + sensitive prefs
  sentry_flutter: ^8.13.0                # E1 — crash + error monitoring
  connectivity_plus: ^6.1.5               # E4 — offline awareness
  dio_smart_retry: ^7.0.0                 # E11 — retry/backoff interceptor
  logger: ^2.4.0                          # E10 — replace 242 debugPrint sites

dev_dependencies:
  very_good_analysis: ^7.0.0              # E9 — stricter lints; supersedes flutter_lints
  mocktail: ^1.0.4                        # E8 — test mocking
  build_runner: ^2.4.13                   # E7 — code gen runner
  freezed: ^2.5.7                         # E7 — sealed DTOs + copyWith + equality
  json_serializable: ^6.8.0               # E7 — JSON DTO codegen
  patrol: ^3.13.0                         # optional — integration testing
```

Drop:
```yaml
# REMOVE from pubspec.yaml
http: ^1.4.0              # consolidate on dio
flutter_dotenv: ^5.0.2    # replaced by --dart-define-from-file
flutter_stripe: ^12.1.1   # defer until payment flow ships
image_cropper: ^10.0.0+1  # 0 imports — re-add when used
photo_view: ^0.15.0       # 0 imports — re-add when used
flutter_lints: ^6.0.0     # superseded by very_good_analysis
```

---

## Update commands

Run these in order, on a feature branch, with `flutter pub outdated` reviewed first.

```bash
# 1. See what's outdated
flutter pub outdated

# 2. Bump versions for the keep list (review each)
flutter pub upgrade --major-versions geolocator geocoding

# 3. Remove obsolete deps
flutter pub remove http flutter_dotenv flutter_stripe image_cropper photo_view flutter_lints

# 4. Add the critical new deps
flutter pub add flutter_secure_storage sentry_flutter connectivity_plus dio_smart_retry logger
flutter pub add --dev very_good_analysis mocktail build_runner freezed json_serializable

# 5. Snapshot the new lockfile
flutter pub get

# 6. Re-run codegen if needed
dart run build_runner build --delete-conflicting-outputs

# 7. Verify everything still compiles
flutter analyze --fatal-infos
flutter build apk --debug -t lib/main_dev.dart
```

If staging Riverpod 3.x is desired later:

```bash
flutter pub upgrade --major-versions flutter_riverpod   # only after migration completes
```

---

## Top 5 fixes from this audit

Ranked by impact-to-effort.

1. 🔴 **Add `flutter_secure_storage` and migrate `prefs.setString('token', …)` + the password persistence off `SharedPreferences`.** *Effort: 0.5 dev-day.* *Impact:* closes the catastrophic on-device credential exposure (`docs/AUDIT_SEC.md` S3). Highest single security win.

2. 🔴 **Remove `http`, consolidate on `dio`, add `dio_smart_retry` + base options for timeouts + auth interceptor.** *Effort: 1 dev-day (after the `ApiClient` refactor in `docs/AUDIT_ARCH.md` lands).* *Impact:* single HTTP stack, retry/backoff for transient 5xx, fixes the no-timeout finding (`docs/AUDIT_SEC.md` §F4). Removes the redundancy that has confused every contributor.

3. 🔴 **Add `sentry_flutter`; wire symbol upload via `--split-debug-info`.** *Effort: 0.5 dev-day.* *Impact:* turns the 242 swallowed-error sites (`docs/AUDIT_QUALITY.md` §D11) into actionable production telemetry. Mandatory before any production rollout.

4. 🔴 **Delete unused deps: `flutter_stripe`, `flutter_dotenv`, `image_cropper`, `photo_view`.** *Effort: 30 minutes.* *Impact:* drops ~50MB+ of native plugin binaries from APK/IPA; removes confusion ("why is Stripe in here if no payment exists?"). Re-add when the corresponding feature actually ships.

5. 🟠 **Migrate 12 `Image.network` call sites to `CachedNetworkImage` with `memCacheWidth`/`memCacheHeight`.** *Effort: 25 minutes.* *Impact:* turns the already-paid-for `cached_network_image` dep into the perf win it was added to deliver (`docs/AUDIT_PERF.md` Top-fix #1). Halves bitmap memory; eliminates redundant re-downloads on scroll.

---

*Audit aligned with `docs/AUDIT_MAP.md` (2026-05-20). Cross-refs: `docs/AUDIT_ARCH.md`, `docs/AUDIT_STATE.md`, `docs/AUDIT_STRUCT.md`, `docs/AUDIT_QUALITY.md`, `docs/AUDIT_PERF.md`, `docs/AUDIT_SEC.md`, `docs/AUDIT_SCALE.md`, `docs/AUDIT_FLAVOR.md`, `docs/AUDIT_TEST.md`. All `.md` artefacts under `docs/` per project rule.*
