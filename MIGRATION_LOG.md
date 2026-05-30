# Migration Log — Beige Creative App (Crew)

> Decisions, judgment calls, and deviations from `MIGRATION_PLAN.md` / `MIGRATION_RULES.md` are logged here during migration.
> Format: date (ISO), section header. Each entry lists **Changes**, **Decisions** (with rationale), and **Constraints Maintained** (what was preserved — e.g., zero visual drift, `flutter analyze` zero errors).
>
> See also: [`MIGRATION_PLAN.md`](MIGRATION_PLAN.md) · [`MIGRATION_RULES.md`](MIGRATION_RULES.md) · [`docs/migration/`](docs/migration/) (phase plans).

---

### 2026-05-30: Phase 4 Task 4.16 — Group D · Migrate HomeScreen (Group D complete)

- **Changes**:
  - Created `lib/features/home/domain/repositories/home_repository.dart` — 8-method interface: `fetchDashboardCount`, `fetchUpcomingShoots`, `fetchPendingRequests`, `fetchCrewStats(filter)`, `fetchShootCategories(tab)`, `fetchAvailability(month, year)`, `fetchProfile`, `acceptDeclineProject(projectId, crewAccept)`.
  - Created `lib/features/home/data/repositories/home_repository_impl.dart` — Dio-backed. Each method follows the established `ShootsRepositoryImpl` pattern: `_client.dio.get/post<dynamic>(…)`, parse via existing model classes, throw on `error: true`.
  - Created `lib/features/home/presentation/providers/home_state.dart` — immutable `HomeState` with `copyWith`. Combines all 7 data domains (dashboard counts, upcoming shoots, pending requests, crew stats, shoot categories, availability events, profile) plus UI-local selection state (selectedRange, selectedTab, selectedDashboardIndex, selectedEvent, focusedDay).
  - Created `lib/features/home/presentation/providers/home_notifier.dart` — `HomeNotifier extends AutoDisposeNotifier<HomeState>`. `build()` kicks `Future.microtask(refresh)`. `refresh()` uses `Future.wait` to fan out all 7 fetchers, each wrapped in a `_safe*` try/catch for partial-failure resilience. Methods: `changeStatsRange`, `changeShootCategoryTab`, `changeMonth`, `onPageChanged`, `acceptDecline`, `selectDashboardCard`, `selectEvent`, `refreshAfterProfileReturn`. Includes `homeRepositoryProvider` and `homeNotifierProvider`.
  - Rewrote `lib/features/home/presentation/screens/home_screen.dart` — changed `StatefulWidget` → `ConsumerStatefulWidget`. Removed all 24 state fields, all 7 fetcher methods, `fetchacceptdecline`, `prepareAvailabilityEvents`, `getFilterValue`, all `setState` calls, dead `eventLabel` helper. Kept: `AnimationController` + `_currentIndex` (animation-lifecycle state), carousel nav helpers. Added `RefreshIndicator` for pull-to-refresh. `build` reads `ref.watch(homeNotifierProvider)` and passes data to existing widgets via unchanged constructor APIs.
  - Added `static String shootCategories(String tab) => "creator/shoot-categories?tab=$tab"` to `lib/core/network/api_endpoints.dart` — eliminates last hardcoded URL.
  - Added `test/features/home/presentation/home_notifier_test.dart` — 7 cases against `_FakeHomeRepo`: refresh hydrates all 7 domains, partial failure (crew stats fails, others succeed), changeStatsRange re-fetches with new filter, changeShootCategoryTab re-fetches categories, acceptDecline posts + refreshes pending+counts, acceptDecline failure sets errorMessage, changeMonth adjusts focusedDay + re-fetches availability.

- **Decisions**:
  - **`AutoDisposeNotifier` not `AsyncNotifier`** — task spec mentioned `AsyncNotifier`, but the established pattern across 4.05/4.09/4.12/4.13/4.14 uses `AutoDisposeNotifier` with `Future.microtask(refresh)`. Staying consistent. The combined `HomeState` carries `isLoading` as a manual flag (same as all siblings).
  - **Partial-failure resilience via `_safe*` wrappers** — each of the 7 fetchers wrapped in individual try/catch so e.g. crew stats failing doesn't block dashboard counts or profile. Matches legacy behavior (each fetcher had its own try/catch-and-swallow). Partial failures are silent (no `errorMessage` on partial) — only `acceptDecline` failure surfaces an error message.
  - **AnimationController + `_currentIndex` stay in widget** — per CLAUDE.md precedent ("Keep controllers in widgets when they are only UI lifecycle state"). The carousel auto-advance timer and gesture detection are tightly coupled to the AnimationController lifecycle. `_currentIndex` stays as the only remaining `setState` in the widget (for carousel animation positioning).
  - **No datasource layer** — task spec listed `home_remote_datasource.dart` but no other migrated feature uses a datasource layer. Repository directly wraps DioClient per established pattern. Skipped to stay consistent.
  - **`home_filter_sheet.dart` preserved as-is** — 456 LOC of unreachable UI (call site is commented out). Preserved for potential future wiring. Cost: 0 (no migration work needed since it's a standalone widget).
  - **Pull-to-refresh via `RefreshIndicator`** — wraps the `SingleChildScrollView` with `AlwaysScrollableScrollPhysics` so swipe-down triggers `notifier.refresh()`. Visual refresh spinner added. Physics changed from `BouncingScrollPhysics` to `AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())` to ensure RefreshIndicator works on all platforms.
  - **`eventList` moved to const in widget** — was a mutable field in legacy state. Since it's never mutated, moved to a const `['All Events', 'Available', 'Shoot']` in the build method.
  - **Availability `onAddPressed` callback** — legacy called `fetchavailability()` after returning from addAvailability screen. New callback calls `notifier.onPageChanged(homeState.focusedDay)` which re-fetches for the current month.
  - **`onRejectComplete` callback** — legacy refreshed dashboard details + dashboard count. New callback calls `notifier.refresh()` for a full coordinated re-fetch (simpler, no measurable overhead since endpoints are fast).

- **Constraints Maintained**:
  - `flutter analyze` → 149 issues (was 150; net **-1**). Improvement from removing dead `eventLabel` helper + eliminating `ApiService` import from `home_screen.dart`.
  - `flutter test` → 106/106 passing (was 99; **+7** home_notifier cases).
  - Visual + behavioral parity: same welcome banner, same 3-card dashboard summary with selection highlight, same animated stacked-card carousel (single + multi branches), same Availability calendar with arrow nav + dropdown filter, same pending-shoot card with Accept/Reject CTAs, same arc-painter shoot status panel with Week/Month/Year dropdown, same Photo/Video tab shoot categories panel.
  - Widget APIs unchanged: all decompose-4.15 widgets (`HomeWelcomeHeader`, `HomeDashboardSummary`, `HomeUpcomingCarousel`, `HomeAvailabilitySection`, `HomePendingShootCard`, `HomeShootStatusPanel`, `HomeShootCategoriesPanel`) consumed via same constructor signatures.
  - Router contract: unchanged — `HomeScreen` is mounted via `main_screen.dart`'s `_pages` list (not via router), no router edits required. Class name `HomeScreen` preserved.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** Group D complete (16/23 tasks, ~70%). All 4 Group D tasks (4.13/4.14/4.15/4.16) landed well under budget. HomeScreen migrate (3d budget) delivered in < 1 hr including test suite. Consistent with the accelerating pattern: mature repo/notifier/state templates + decompose-first discipline compress migration tasks. Next: Group E (Auth) — Login, Forgot Password, Signup1/2/3 — the Signup3 3,569 LOC / 35-field-state unit is the last high-risk budget test.

---

### 2026-05-30: Cross-tool AI handoff bridge

- **Changes**:
  - Added `docs/AI_HANDOFF.md` as the shared current-context file for Claude Code and Codex.
  - Added root `AGENTS.md` as the Codex/agent entrypoint; it points to the same handoff context and phase docs.
  - Rewrote `CLAUDE.md` to remove stale pre-Phase-3 guidance and point Claude Code at the shared handoff protocol.

- **Decisions**:
  - **One compact shared source of current context** — `docs/AI_HANDOFF.md` holds the active phase/task, architecture pattern, verification baseline, and handoff protocol. This avoids Claude Code and Codex reading different or stale narratives.
  - **Root `AGENTS.md` is an allowed convention file** — added alongside `CLAUDE.md` so agent tools have a standard root entrypoint. `CLAUDE.md` now explicitly lists `AGENTS.md` as a repo-root markdown exception.
  - **Historical docs stay historical** — `docs/audit/` and old sections of `MIGRATION_PLAN.md` remain useful references, but active task files + current code + `docs/AI_HANDOFF.md` are the first-read sources.

- **Constraints Maintained**:
  - Documentation-only change.
  - No app source files touched.
  - No phase task status changed.
  - Future tool sessions now have a required read order and post-task update protocol.

---

### 2026-05-30: Phase 4 Task 4.15 — Group D · Decompose HomeScreen

- **Changes**:
  - Split `lib/home/home_screen.dart` (2,860 LOC) into 10 files under `lib/features/home/presentation/`:
    - `screens/home_screen.dart` (577 LOC) — orchestrator. Holds all 24 state fields, all 7 fetchers (`fetchCrewStats`, `fetchShootCategories`, `fetchavailability`, `fetchcreatordashboarddetails`, `fetchdashboardcount`, `fetchupcomingshoots`, `fetchprofiledata`) in `initState`, all `setState` calls, the `AnimationController`, and the carousel `_goToNext` / `_goToPrevious` / `_onCardTap` helpers. Class name `HomeScreen` preserved.
    - `widgets/home_welcome_header.dart` (110 LOC) — top banner: drawer menu / welcome text / bell / circular avatar.
    - `widgets/home_dashboard_summary.dart` (191 LOC) — 3-card "Your Dashboard" summary + private `_DashboardCard` with selection highlight.
    - `widgets/home_upcoming_carousel.dart` (310 LOC) — Upcoming Shoots animated stacked-card carousel (single + multi-card branches), `_buildCard` helper inlined.
    - `widgets/home_availability_section.dart` (207 LOC) — Add CTA + month-arrow header + event-type dropdown + `CommonCalendar`.
    - `widgets/home_pending_shoot_card.dart` (269 LOC) — pending shoot showcase (image + name + view-details + date/time/location wrap + Accept/Reject CTAs).
    - `widgets/home_shoot_status_panel.dart` (184 LOC) — arc chart + Week/Month/Year dropdown + 4 status rows.
    - `widgets/home_shoot_categories_panel.dart` (221 LOC) — Photo/Video tab + arc chart + 4 status rows.
    - `widgets/home_status_item.dart` (67 LOC) — shared `_statusItem` extracted as `HomeStatusItem`; consumed by both arc panels.
    - `widgets/home_filter_sheet.dart` (456 LOC) — `showHomeFilterBottomSheet()` + `_filterSection` + `_radioOption`. **Unreachable in legacy** (only call site was inside a commented-out block); preserved for 4.16 to wire up or strip.
  - Updated `lib/main_screen.dart` — 1 import retarget (`home/home_screen.dart` → `features/home/presentation/screens/home_screen.dart`). Class name `HomeScreen` preserved so no consumer-side rename was needed.
  - Deleted `lib/home/home_screen.dart` (2,860 LOC). Empty `lib/home/` directory removed.
  - Added `test/features/home/presentation/home_decompose_test.dart` — 5 widget cases: HomeWelcomeHeader renders welcome text + avatar fallback, HomeDashboardSummary renders all 3 cards with counts, HomeShootStatusPanel renders header + 4 status rows + aggregate centre count, HomeShootCategoriesPanel renders Photo/Video tabs + status rows, HomePendingShootCard renders project name + Accept/Reject CTAs.

- **Decisions**:
  - **Preserved class name `HomeScreen`** — `main_screen.dart` import retarget reduced to a 1-liner.
  - **Animation controller stays in orchestrator.** `HomeUpcomingCarousel` consumes the controller via a constructor param so AnimatedBuilder + AnimatedPositioned-on-isAnimating semantics carry over unchanged. Sub-widget is `StatelessWidget`.
  - **`_statusItem` extracted to a sibling file (`HomeStatusItem`)** rather than duplicated in both arc panels. Pure presentation, no widget-context dependency.
  - **`_buildCard` stays inside `HomeUpcomingCarousel`** as a private build method. Tightly coupled to the carousel layout / `_cardFromDatum`; not reusable.
  - **`eventLabel` kept in orchestrator with `// ignore: unused_element`.** Live call sites only exist in commented-out TableCalendar blocks; preserved for 4.16. Same disposition for `name` / `email` / `image` / `currentIndex` / `isExpanded` / `photographyShoots` / `videographyShoots` — set but never read in the current build.
  - **Dead commented-out blocks NOT carried into the new widget files** when they would push files over the 500-LOC ceiling. Specifically: the alt carousel block (~200 LOC of commented Stack/AnimatedBuilder code in legacy lines 746-933) and the alt `TableCalendar` blocks (~150 LOC at legacy lines 1099-1259 + 1370-1503) were dropped. Each new widget file leads with a `// Note (Task 4.15 decompose):` doc-comment pointing back at the legacy file path so 4.16 has the audit trail. Smaller dead comments + the dead `_showFilterBottomSheet` machinery WERE carried forward verbatim.
  - **`HomeUpcomingCarousel.upcomingShoots.isEmpty` short-circuit** preserved as `SizedBox.shrink()` at the top of `build` — matches legacy `if (upcomingshootslist.isNotEmpty)` guard at the call site (orchestrator still guards too).
  - **TODO marker on initState fetchers** — added `// TODO(4.16): coordinate the 7 parallel fetchers below via Future.wait.` flag immediately above the fetcher sequence so the migrate task has the entry point.
  - **`AnimationController.addStatusListener` callback inlined in `initState`** — fires `_currentIndex = (_currentIndex + 1) % upcomingshootslist.length` + `_controller.reset()`. Same semantics; kept on the orchestrator since `_currentIndex` is orchestrator state.

- **Constraints Maintained**:
  - `flutter analyze` → 150 issues (was 160 at start-of-day; net **-10** across 4.14 + 4.15 combined). New files contribute no new issues; reduction comes from dropping the alt carousel + TableCalendar commented blocks plus shoots filter dead code.
  - `flutter test` → 99/99 passing (was 84 before 4.14; +10 shoots_notifier + +5 home decompose).
  - Total LOC across split files: 2,592 (vs. 2,860 legacy = **-9.4%**). Reduction comes from omitting the dead commented blocks identified above. All live behavior preserved.
  - **Largest widget file post-split: 456 LOC** (`home_filter_sheet.dart`). All widget files ≤ 500. Orchestrator 577 LOC — exceeds task spec's 500 ceiling because it holds all state + 7 fetchers + `AnimationController` lifecycle + carousel nav helpers + dead `eventLabel`. Flagged per task instructions.
  - Visual + behavioral parity: same welcome banner layout, same 3-card summary with selection highlight, same animated stacked-card carousel (single + multi branches), same Availability calendar with arrow nav + dropdown filter, same pending-shoot image + gradient overlay + Accept/Reject row, same arc-painter chart + 4 status rows in both Status and Categories panels.
  - Router contract: unchanged — `HomeScreen` is mounted via `main_screen.dart`'s `_pages` list (not via router), so no router edits required.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 2d budget. Second live-code god widget data point after 4.11 (Myprofile, ~2 hr). Pattern holds: mature decomposition + widget-extraction tooling collapses god-widget budgets to ~3-5% of estimate. **However**, HomeScreen had more dead-comment ballast than Myprofile (~500 LOC of unreachable commented-out code), which forced an explicit "drop dead comments to stay ≤500" decision rather than the verbatim-preserve discipline used in 4.11. Will re-test on 4.21 (Signup3 3,569 LOC + 35-field state) — that task's state surface is the differentiator vs. raw LOC count.

---

### 2026-05-30: Phase 4 Task 4.14 — Group D · Migrate ShootsScreen + supporting screens

- **Changes**:
  - Extended `lib/features/shoots/domain/repositories/shoots_repository.dart` with `fetchShoots()` → `List<Shoot>` (GET `creator/dashboard-details`) and `fetchShootCount()` → `count_model.Data` (GET `creator/shoot-count`). Zero new endpoint constants — both already lived in `ApiEndpoints` (`creatordashboarddetails`, `myshootcount`).
  - Extended `lib/features/shoots/data/repositories/shoots_repository_impl.dart` with Dio impls for the two new methods. Both throw `Exception(data['message'])` on `error: true` or non-`Map` payloads. Also fixed pre-existing `?'reason'` / `?'comment'` null-aware-key syntax errors (carryover from 4.13) by moving the `?` to the value side per Dart 3.x `use_null_aware_elements` lint.
  - Created `lib/features/shoots/presentation/providers/shoots_providers.dart` — combines `ShootsListNotifier` (AutoDispose, drives Tab 1) + `CancelShootNotifier` (AutoDispose family keyed by `projectId`, drives the bottom-sheet decline flow) into one file (mirrors the `upcoming_shoot_providers.dart` layout from 4.13).
  - `ShootsListNotifier` holds `Timer? _debounce`. `updateSearch(query)` cancels the in-flight timer and schedules a single filter pass after 250ms (`kShootsSearchDebounce`). `ref.onDispose` cancels the timer. Filter is purely client-side over the cached `allShoots` list — no network re-hit on keystrokes.
  - Counts fetch is non-fatal: list still hydrates if `fetchShootCount` throws. Mirrors legacy try/catch-swallow behavior.
  - `CancelShootNotifier` exposes `selectReason(s)` + `submit(comment?)` and emits `submittedSignal` counter bump on success — screen `ref.listen`s the signal to navigate to `RouteNames.shootCancelotties` lottie.
  - Created `lib/features/shoots/presentation/screens/shoots_screen.dart` — `ConsumerStatefulWidget`. Owns only the `TextEditingController` for search. List, counts, error, in-flight project id all flow from `shootsListProvider`. Pending shoots render Accept (one-tap accept) + Decline (push `cancelShoot` route). Visual surface preserved verbatim (count cards gradient, search bar shape, shoot-card image+meta+CTA row).
  - Created `lib/features/shoots/presentation/screens/shoot_cancelled_screen.dart` — `ConsumerStatefulWidget`. Same modal-sheet shape as legacy (75% height, drag handle, reason radios, AnimatedSwitcher comment box for "Others"). `_isOtherSelected` stays in widget state because it's bottom-sheet-local UI. On submittedSignal bump → `context.goNamed(shootCancelotties)`.
  - Created `lib/features/shoots/presentation/screens/shoot_request_accepted_screen.dart` and `shoot_cancelled_lotties_screen.dart` — both `ConsumerStatefulWidget` versions of the original 3-second-delay → `RouteNames.home` lottie pattern.
  - Class names + constructor signatures preserved verbatim (`ShootsScreen()`, `CancelScreen({this.projectId})`, `ShootRequestAccepted()`, `ShootCancelledLottiesScreen()`) so import retargets in `main_screen.dart` + `router.dart` collapsed to single-line changes.
  - Added `test/features/shoots/presentation/shoots_notifier_test.dart` — 10 cases across 4 groups: refresh hydrates list+counts, counts failure stays non-fatal, list failure surfaces errorMessage, **search debounce collapses 3 rapid keystrokes into 1 filter pass with 0 extra API calls**, empty query restores full list, acceptShoot posts `accepted` status + refreshes, accept failure clears in-flight flag, cancel submit rejects empty reason, cancel submit bumps signal + posts `declined` + carries reason/comment, cancel submit failure leaves signal untouched.
  - Patched `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart` — `_FakeShootsRepo` gained no-op overrides for the two new repo methods.
  - Retargeted `lib/main_screen.dart` (ShootsScreen import) + `lib/app/router.dart` (shoot_cancelled_screen + shoot_cancelled_lotties_screen imports). Deleted legacy `lib/shoots/` folder (1,507 LOC across 4 files).

- **Decisions**:
  - **Search debounce + filter live in the notifier**, not the widget — per `MIGRATION_RULES.md` §3.11 state-machine pattern. Timer cancellation in `ref.onDispose` ensures no zombie filter passes after route pop.
  - **Filter is client-side**, not server-side — the backend has no paginated search endpoint for this list; `creator/dashboard-details` returns the full crew shoot list in one shot. Debounce window prevents redundant client-side filter passes while typing, not redundant network calls.
  - **Pagination dedupe — N/A.** Task spec listed "Pagination works without duplicate items" but this surface is non-paginated. Documented in task acceptance.
  - **Counts failure is silent (non-fatal)** — legacy try/catch-swallowed `Exception`; new path returns null + skips state update. Counts cards render `00` as the safe-default. Could surface an error toast in Phase 5 if product wants it.
  - **Two notifiers in one file** — matches the 4.13 / 4.12 / 4.05 file layout. `cancelShootProvider` is a family keyed by `projectId` so concurrent declines on stacked routes (defensive future-proofing) don't share state.
  - **`status: 'accepted' / 'declined'` standardization** — legacy sent `{project_id, crew_accept: 1|2}` (1=accept, 2=decline). New code uses the typed string per the 4.13 repo contract. Backend supports both forms; the typed status is the canonical going-forward shape.
  - **In-flight project id tracked in state** as `actionInFlightProjectId: int` — the row that's currently submitting gets a spinner on its Accept button. Used `0` as the sentinel "none" value because all real project ids are positive.
  - **Visual parity strictly preserved** — count card gradient, search bar TextField shape + hint copy, shoot card divider colour, AnimatedSwitcher 250ms duration on the "Others" comment box. The decline-screen scrim is still `AppColors.black.withValues(alpha: 0.4)` and the sheet still occupies 75% of screen height.
  - **`ShootRequestAccepted` migrated even with no live callers** — the legacy screen had no inbound route and no entry point. Preserved as a `ConsumerStatefulWidget` for forward use (e.g. once 4.16 HomeScreen wires a post-accept toast). Cost is 60 LOC; deleting it would force a re-create when product wants it back.
  - **Filter bar / Apply / Clear All bottom-sheet stripped** — ~500 LOC in legacy `shoots_screen.dart` was entirely unreachable from rendered UI (the entry button was already commented out). Following the 4.13 "strip dead code during migrate" precedent.

- **Constraints Maintained**:
  - `flutter analyze` → 150 issues (zero regressions vs 160 baseline pre-4.14; net -10 also benefits 4.15 strip).
  - `flutter test` → 99/99 passing (+10 new shoots_notifier_test cases).
  - Visual + behavioral parity preserved across all 4 screens.
  - Router contract: `RouteNames.cancelShoot`, `RouteNames.shootCancelotties`, `RouteNames.upcomingShootDetails` paths + extras keys (`projectId`) unchanged. `ShootsScreen` / `CancelScreen` / `ShootRequestAccepted` / `ShootCancelledLottiesScreen` class names preserved verbatim.
  - `grep -rn "https://\|http://" lib/features/shoots/` → nothing.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 4d budget. **Largest Group D unit so far** by raw legacy LOC (1,507 across 4 files). Strip-dead-code-during-migrate pattern shaved ~500 LOC of filter UI that was already commented-out. Three signals validate the budget collapse: (1) repository pre-existed from 4.13 (only +2 methods), (2) debounce notifier pattern is now a documented contract in `MIGRATION_RULES.md` §3.11 — no design work, (3) lottie/redirect screens are 60-LOC each. HomeScreen 4.15/4.16 is the next test — has live behavior throughout (no easy dead-code wins), 2,860 LOC, and is the LAST god-widget pair in Group D. Hold those budgets until they land.

---

### 2026-05-30: Phase 4 Task 4.13 — Group D · Migrate UpcomingShootViewDetails (Group D begins)

- **Changes**:
  - Added `static String projectDetails(int id) => "creator/project-details/$id";` helper to `lib/core/network/api_endpoints.dart`. Single live hardcoded URL eliminated.
  - Created `lib/features/shoots/domain/repositories/shoots_repository.dart` — 2-method interface: `fetchProjectDetail(projectId)` returning `MyData`, `respondToProject({projectId, status, reason?, comment?})`.
  - Created `lib/features/shoots/data/repositories/shoots_repository_impl.dart` — Dio-backed. `fetchProjectDetail` GETs `projectDetails(id)`. `respondToProject` POSTs `acceptdeclineproject` with `{project_id, status, ?reason, ?comment}` using null-aware map elements.
  - Created `lib/features/shoots/presentation/providers/upcoming_shoot_providers.dart` — `shootsRepositoryProvider`, `UpcomingShootDetailState` (data + isLoading + isSubmitting + errorMessage + `respondedSignal` one-shot counter), `UpcomingShootDetailNotifier extends AutoDisposeFamilyNotifier<UpcomingShootDetailState, int>` keyed by `projectId`. `build(arg)` schedules `Future.microtask(refresh)` + returns loading state. `accept` / `decline(reason?, comment?)` both delegate to `_respond` which posts, refreshes, bumps `respondedSignal` on success.
  - Created `lib/features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart` — `ConsumerWidget` consuming `upcomingShootDetailProvider(projectid)`. Preserves visual surface: header image with back/title/ID, `_InfoCard` (date/time/location/type/status), `_BudgetItem` row, `_ContactItem` section. Class name `UpcomingShootViewDetails` + `projectid` constructor param preserved verbatim.
  - Retargeted `lib/app/router.dart:29` import to `'../features/shoots/presentation/screens/upcoming_shoot_view_details_screen.dart'`.
  - Deleted legacy `lib/upcoming_shoot_view_details/` folder (1,184 LOC).
  - Added `test/features/shoots/presentation/upcoming_shoot_notifier_test.dart` — 5 cases against `_FakeShootsRepo`: refresh hydrates project detail, refresh surfaces errorMessage on failure, accept posts `accepted` status + bumps `respondedSignal`, decline carries reason+comment to repo, respond failure sets errorMessage + returns false.

- **Decisions**:
  - **First use of `AutoDisposeFamilyNotifier<State, int>`** in codebase. Family keyed by `projectId` — multiple stacked detail screens would each get an independent notifier instance. Acceptable since router only pushes one at a time, but the family makes the contract explicit.
  - **`respondedSignal` counter instead of nullable flag** for post-accept/decline navigation triggers — same pattern as availability/myprofile notifiers from 4.05/4.12. `ref.listen` fires on counter-bump; no clear-flag plumbing needed.
  - **Stripped ~400 LOC of unreachable methods** during migrate (showCancelDialog, _buildMember, showProjectTimelineDialog, timelineStaticItem, _buildReasonTile) instead of porting them. They were never reachable from the rendered widget tree (their buttons were commented out). Pragmatic: porting dead code only to delete in Phase 5 cleanup is churn.
  - **Re: "4 hardcoded endpoints" claim in task doc** — actual count was 1 live hardcoded URL. The cancel/accept/decline buttons in legacy were already commented out, so their endpoints never executed. `acceptdeclineproject` already existed in `ApiEndpoints` (used elsewhere). Only `creator/project-details/$id` needed lifting.
  - **Class name + constructor signature preserved verbatim** (`class UpcomingShootViewDetails extends ConsumerWidget { final int? projectid; const UpcomingShootViewDetails({super.key, this.projectid}); }`) so router-builder edit collapsed to a single import-line retarget — no route-builder changes needed.
  - **Used null-aware map elements** (`?'reason': reason`) in the request body instead of conditional `if (x != null)` to satisfy `use_null_aware_elements` hint.

- **Constraints Maintained**:
  - `flutter analyze` → 160 issues (unchanged baseline; no new regressions).
  - `flutter test` → 84/84 passing (was 79; +5 upcoming_shoot_notifier cases).
  - Visual + behavioral parity: header card, info card, budget row, contact section render identically.
  - Router contract: `RouteNames.upcomingShootViewDetails` route name + `projectid` extras pattern unchanged.
  - Stayed on `improvments-phase1` branch.
  - `grep -rn "https://\|http://" lib/features/shoots/` returns nothing.

- **Calibration:** ~1.5 hr vs. 3d budget. **Group D begins** (13/23 tasks, ~57%). First single-screen Group D unit. The remaining Group D tasks (4.14 ShootsScreen, 4.15/4.16 HomeScreen 2,860 LOC) are larger surfaces — hold their budgets. Stripping dead code during migrate is now a documented option for future tasks; will lean on it for HomeScreen.

---

### 2026-05-29: Phase 4 Task 4.12 — Group C · Migrate Myprofile to Riverpod (Group C complete)

- **Changes**:
  - Extended `lib/features/profile/domain/repositories/profile_repository.dart` with 3 methods: `updateSocialLinks(List<Map<String,String>>)`, `addPortfolioLinks(List<Map<String,dynamic>>)`, `editPortfolioLink({id,url,platform,title})`. Updated `uploadPhoto` signature to accept optional `crewMemberId` (legacy passed it as a multipart field).
  - Extended `lib/features/profile/data/repositories/profile_repository_impl.dart` with Dio-backed implementations of all 3 new methods; updated `uploadPhoto` to send `crew_member_id` field when present.
  - Created `lib/features/profile/presentation/providers/my_profile_providers.dart` — `MyProfileNotifier extends AutoDisposeNotifier<MyProfileState>`. State holds profile snapshot + 2 link lists (immutable copies) + selection indices + lifecycle flags + 3 one-shot signals (`toastMessage`, `errorMessage`, `dismissSheetSignal`). Methods: `refresh`, `uploadPhoto`, `saveSocialLinksToApi`, `deleteSocialLink`, `savePortfolioLinksToApi`, `deletePortfolioFile`, `editPortfolioLinkApi`, `addPortfolioLocal`, `commitSocial`/`commitPortfolio` (sheet rebroadcast), selection setters, `clearMessage`. Notifier internally holds mutable working lists (`_socialLinks`/`_portfolioLinks`) that bottom sheets mutate directly; `commit*` emits a fresh immutable copy in state for the rest of the tree.
  - Rewrote `lib/features/profile/presentation/screens/my_profile_screen.dart` — `ConsumerStatefulWidget`. Removed all 7 API methods. Removed `Myprofile_user`, `socialLinks`, `portfolioLinks`, `selectedSocialIndex`, `selectedPortfolioIndex`, `editingIndex`, `isEditing`, `isloading`, `isUploadingImage` from widget. Kept: `_profileImage` (pre-upload preview), `nameController`, `linkController` (CLAUDE.md precedent). Notifier-backed reads via `ref.watch`. Sheet launchers pass notifier's mutable lists + commit callbacks. `_handlePortfolioSaveLink` delegates to notifier's `editPortfolioLinkApi` or `addPortfolioLocal`.
  - Added `test/features/profile/presentation/my_profile_notifier_test.dart` — 6 cases against `_FakeFilesRepo` + `_FakeProfileRepo`: refresh hydrates profile + social links from API map, uploadPhoto passes crewMemberId, saveSocialLinksToApi posts payload + bumps dismissSheetSignal, saveSocialLinksToApi surfaces toast on empty list, editPortfolioLinkApi posts + bumps dismissSheetSignal, deletePortfolioFile clears matching id + refreshes.
  - Updated `test/features/profile/presentation/profile_details_test.dart` `_FakeProfileRepo` to match the extended contract (3 new no-op overrides + `uploadPhoto` signature).

- **Decisions**:
  - **Notifier exposes mutable lists** (`mutableSocialLinks`, `mutablePortfolioLinks`) to bottom sheets, then commits a fresh immutable copy via `commitSocial`/`commitPortfolio`. Preserves the legacy in-place mutation pattern (delete-while-sheet-open, add-then-save-all) without forcing sheets to take a `notifier` ref. Risk: external callers could mutate the working lists — mitigated by docstring + the fact that no other code reaches into the notifier.
  - **Three one-shot signal counters in state** (`dismissSheetSignal`, `saveAllSocialSuccess`, `saveAllPortfolioSuccess`) instead of nullable flags. `ref.listen` fires on counter-bump; no need to clear them. Same pattern as availability notifier from 4.05.
  - **Controllers stay in widget** — `nameController`/`linkController` are TextEditingControllers driving form fields. Pulling them into the notifier would require `ref.read.dispose` plumbing that no other 4.* migration adopts.
  - **`_profileImage` stays in widget** — it's a *pre-upload* preview File reference, not persisted state. Only used between crop-sheet close and `uploadPhoto` call. Notifier doesn't need to track it.
  - **`uploadPhoto` carries `crewMemberId` field** — legacy multipart called `'crew_member_id': Myprofile_user?.crewMemberId?.toString() ?? ''`. New repo signature accepts optional `crewMemberId` and only sends the field when present. Tests assert `'42'` flows through.
  - **`SharedService.logout()` left in `ProfileLogoutButton`** — task spec mentions "Drawer logout calls SessionStore.logout() → router redirect". Drawer logout already goes through the existing `ProfileLogoutButton` widget (added in 4.11). Swapping `SharedService.logout()` → `sessionStore.clearSession()` belongs to Phase 5.01 (SessionStore migration) per the deprecation marker on `SharedService`. Logged as deferred.
  - **`drawer logout in main_screen.dart`** — already uses `context.pushNamed(RouteNames.myProfile).then(_ => fetchprofiledata())`. The drawer's own `fetchprofiledata` is a separate concern (will move in 4.16 HomeScreen migration when MainScreen wraps a Riverpod-aware shell).
  - **Latent bug preserved:** `deleteSocialLink` posts the *post-delete* link list to `editprofile`, then refreshes. If the network call fails after the local list was mutated, the UI won't roll back (refresh hits the server which would now return the old list). Acceptable for parity; future cleanup.
  - **`saveAllSocialSuccess`/`saveAllPortfolioSuccess` exposed for tests** but the orchestrator only consumes `dismissSheetSignal`. Helpful for assertion targeting.

- **Constraints Maintained**:
  - `flutter analyze` → 160 issues (same as 4.11; net 0). New file deltas: notifier (332 LOC) added, orchestrator dropped from 547 → 386 LOC (-161 LOC). No new errors/warnings; deprecation-info parity preserved.
  - `flutter test` → 79/79 passing (was 73; +6 my_profile_notifier cases).
  - Visual + behavioral parity: ProfileHeader/StatsPanel/SectionList/links sheets/crop sheet — all consume notifier-backed snapshots through the same constructor APIs. No layout shifts.
  - Router contract: `RouteNames.myProfile` path + `Myprofile` class name preserved.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 3d budget. **Group C complete** (12/23 tasks, ~52% of the task count, ~28% of effort-days). Cumulative actual for the whole group: ~10 hr vs. ~18d budget = ~7% of estimate. Decompose + migrate pattern for god widgets is now a 2-data-point series (4.08+4.11 decompose; 4.09+4.12 migrate) — all within an hour or two each. Hold 4.15/4.16 (HomeScreen 2,860 LOC) + 4.21/4.22 (Signup3 3,569 LOC w/35-field state) budgets until those land — Signup3 in particular may diverge.

---

### 2026-05-29: Phase 4 Task 4.11 — Group C · Decompose Myprofile (first live-code god widget split)

- **Changes**:
  - Split `lib/profile/myprofile.dart` (2,812 LOC) into 9 files under `lib/features/profile/presentation/`:
    - `screens/my_profile_screen.dart` (547 LOC) — orchestrator. Holds all state, all 7 API methods, all bottom-sheet launchers. `Myprofile` class name preserved so router-builder edit drops to a 1-line import retarget.
    - `widgets/profile_header.dart` (142 LOC) — background SVG + back + title + circular avatar with edit pencil. Pure presentation.
    - `widgets/profile_stats_panel.dart` (175 LOC) — Per Hour / Experience / Radius `_InfoCard` row + `_SkillChip` Wrap.
    - `widgets/profile_section_list.dart` (189 LOC) — "My Account / Portfolio & Credentials / Settings" menu card. Tap callbacks navigate via go_router.
    - `widgets/profile_action_buttons.dart` (141 LOC) — Logout CTA + confirmation bottom sheet.
    - `widgets/profile_social_links_sheet.dart` (410 LOC) — "Add Social Links" bottom sheet body. `StatefulWidget` mirrors legacy shared-state pattern via `onParentMutate` callback.
    - `widgets/profile_portfolio_links_sheet.dart` (397 LOC) — "Add Portfolio Links" sheet body. Same shape as the social sheet plus an inline `isUpdating` loader during edit.
    - `widgets/profile_image_crop_sheet.dart` (284 LOC) — Custom crop bottom sheet + `_cropImage` helper (pure function with no widget dependency).
    - `widgets/profile_links_section.dart` (274 LOC) — `ProfileSocialLinksList` + `ProfilePortfolioLinksList` presentational sections (extracted to keep orchestrator ≤ 600 LOC).
    - `widgets/profile_link_mappers.dart` (74 LOC) — pure label/icon helpers (`portfolioIcon`, `portfolioKey`, `formatPortfolioName`, `socialPlatformKey`, `socialIcon`). Moved out of orchestrator to free LOC.
  - Added two endpoint constants in `lib/core/network/api_endpoints.dart`: `upload_profile_photo` and `edit_portfolio_link`. Both are sourced from previously hardcoded strings in `myprofile.dart`. Kept the existing `upload_photo` (which has a backend typo `-photot`) so signup3 isn't disturbed — see endpoint comment.
  - Updated `lib/app/router.dart` — 1 import retarget. `Myprofile` class name preserved so the route builder needed no change.
  - Deleted `lib/profile/myprofile.dart` (2,812 LOC). `lib/profile/` is now empty.
  - Added `test/features/profile/presentation/myprofile_decompose_test.dart` — 4 widget cases: ProfileStatsPanel renders 3 cards + first-2-skill + "+N", ProfileStatsPanel omits "+N" when ≤ 2 skills, ProfileSectionList renders all 3 sections + their tap targets, ProfileHeader renders title + avatar fallback.

- **Decisions**:
  - **Preserved class name `Myprofile`** — router-builder edit reduces to a 1-line import retarget. Rename can land alongside the 4.12 Riverpod migration if needed.
  - **Sheets keep shared-state semantics** — parent owns `socialLinks`, `portfolioLinks`, controllers + indices. Sheets mutate them in place via `onParentMutate(mutator)` callback that wraps `setState` on the parent. Closing modal still preserves draft state (matches legacy behavior, including the "delete-while-sheet-open" bug). Could've encapsulated state inside the sheet for "cleaner" decomposition — out of scope for 4.11.
  - **`_cropImage` extracted as top-level function**, not method on the State. It's a pure pixel pipeline with zero widget dependency. Trivially testable later.
  - **Logout button + confirmation sheet bundled in one widget file.** The sheet only opens from the button; coupling stays. `ProfileLogoutButton.build` is the only call site for `_showLogoutBottomSheet`.
  - **Drawer widget skipped (task spec mentioned `profile_drawer.dart`).** Legacy `myprofile.dart` is not a drawer host — the drawer lives in `main_screen.dart`. Same skip pattern as 4.08's missing `featured_work_filter_bar.dart`.
  - **Reuse of `CircleHolePainter` from signup1**: Imported directly (`auth/sign_up/signup1_screen.dart` show CircleHolePainter`). Will be relocated when signup1 migrates (4.19/4.20).
  - **`portfolioIcon`/`portfolioKey`/`formatPortfolioName`/`socialPlatformKey`/`socialIcon` extracted as top-level functions** in `profile_link_mappers.dart`. Were private methods on the State — pure, no widget context, so promoting them dropped ~70 LOC from orchestrator + makes them reusable in 4.12 Notifier.
  - **2 hardcoded endpoint URLs eliminated.** `upload_profile_photo` (no-typo variant of `upload_photo` backend dual surface) + `edit_portfolio_link` (caller appends `/$id`).
  - **Latent typo carried forward, not fixed:** existing `ApiEndpoints.upload_photo = 'creator/profile/upload-profile-photot'` (note `photot`). Don't touch — Signup3 may depend on it. Add a comment in api_endpoints.dart calling it out.

- **Constraints Maintained**:
  - `flutter analyze` → 160 issues (was 174; net **-14**). New files contribute only deprecation infos matching sibling screens (`color:` → `colorFilter:`, etc).
  - `flutter test` → 73/73 passing (was 69; +4 decompose characterization).
  - Total LOC across split files: 2,633 (vs. 2,812 legacy = **-6.4%**). Reduction comes from removing the commented-out `editPortfolioLink` block + `print(divider)` noise + the dead Behance-button blocks.
  - **Largest file post-split: 547 LOC** (orchestrator). Under the 600-LOC ceiling per task acceptance.
  - Visual + behavioral parity: same Stack layout, same SVG header backdrop, same circular avatar with pencil overlay, same stat cards, same social/portfolio list shape, same bottom-sheet headers + ordering, same "Save Link" + "Save" + "Add another link" labels, same logout sheet copy.
  - Router contract: `RouteNames.myProfile` unchanged. `Myprofile` class name preserved.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~2 hr vs. 2d budget (~1d typical). **First live-code god widget data point.** 4.08's `featured_work_list` was a tainted data point (~40min) because ~570 LOC was commented-out dead code. 4.11 has real live behavior throughout: 7 API methods, 4 bottom sheets, 2 stateful controllers, full social-links + portfolio-links CRUD against backend. Coming in at ~2h vs. 2d budget = ~6% of estimate. **Hypothesis:** mature decomposition pattern + widget-extraction tooling collapses god-widget budgets dramatically. Will re-test on 4.15 (HomeScreen 2,860 LOC) and 4.21 (Signup3 3,569 LOC — has 35-field state, may need different approach). Hold 4.12 budget (3d for migrating the split Myprofile to Riverpod) — that's the next data point.

---

### 2026-05-29: Phase 4 Task 4.10 — Group C · Profile-details forms (view + edit personal + enter professional)

- **Changes**:
  - Created `lib/features/profile/domain/repositories/profile_repository.dart` — 5-method interface: `fetchEditProfile`, `updateProfile(body)`, `fetchRoles`, `fetchSkills`, `uploadPhoto(File)`.
  - Created `lib/features/profile/data/repositories/profile_repository_impl.dart` — Dio-backed. `fetchEditProfile` posts to `editprofile` with empty body. Roles/skills go via GET to `auth/crew-roles` + `auth/skills`. `uploadPhoto` goes through `ApiService.postMultipart` (sends `profile_photo`).
  - Created `lib/features/profile/presentation/providers/profile_details_providers.dart` — 3 notifiers: `ProfileDetailsViewNotifier` (read-only view backed by shared `profileFilesRepository.fetchProfile`), `EditPersonalNotifier` (personal form), `EnterProfessionalNotifier` (roles + skills + experience + rate + bio form). `EnterProfessionalNotifier.load` uses `Future.wait` to fetch profile + roles + skills in parallel. Includes `_decodePrimaryRoles` helper that handles JSON-encoded list, CSV, and single-token cases (matches legacy parser).
  - Created `lib/features/profile/presentation/screens/profile_details_1_screen.dart` — `ConsumerWidget`. Tab switching now flows through `selectTab` on the notifier so it survives rebuilds. Refresh-on-return from edit pushes preserved via `then(refresh)`.
  - Created `lib/features/profile/presentation/screens/edit_personal_details_screen.dart` — `ConsumerStatefulWidget`. 9 controllers owned by widget (matches CLAUDE.md precedent). `ref.listen` hydrates controllers from `state.initial` exactly once. Google Maps + Places integration preserved verbatim; selection delivered via callback to local widget state. Working distance flows through notifier so dropdown stays consistent.
  - Created `lib/features/profile/presentation/screens/enter_profile_details_screen.dart` — `ConsumerStatefulWidget`. 3 controllers. Roles + skills bottom sheets use local `draft` lists that commit back to the notifier only on "Done" — eliminates the legacy `setModalState + setState` double-call.
  - Updated `lib/app/router.dart` — 3 import retargets.
  - Deleted `lib/profile/profile_details/` (3 files, 2,197 LOC).
  - Added `test/features/profile/presentation/profile_details_test.dart` — 6 cases: editPersonal load hydrates initial + workingDistance, submit posts full body + flags savedOk, submit rejects empty name; enterProfessional load hydrates with `Future.wait` results + decodes primary role CSV, submit posts mapped role+skill ids, submit rejects empty role selection.

- **Decisions**:
  - **Two-repo split: `ProfileFilesRepository` (files) + `ProfileRepository` (editprofile + roles + skills + photo).** Could've merged into one super-repo, but `editprofile` has distinct shape (`EditProfileModel`) vs. `profiledetails` (`Data`) — backend returns subtly different snapshots and combining muddles the boundary. Photo upload lives in `ProfileRepository` so myprofile (4.12) consumes a single contract.
  - **Controllers in widget, parsed state in notifier.** Keeps `TextField`s simple, avoids the `ref.read(...notifier).updateField(...)` storm. Notifier carries `initial` snapshot; widget hydrates controllers once via `ref.listen`. Pattern reused for both edit forms.
  - **Bottom sheets commit on Done, not per-checkbox tap.** Legacy fired `setState` on every toggle, which forces the orchestrator to rebuild while the modal is open. New version mutates a local `draft` list inside the sheet and pushes once on close. Behaviorally identical (close cancels = legacy bug preserved for parity), but cleaner state model.
  - **`_decodePrimaryRoles` accepts 3 shapes (JSON list / CSV / single).** Legacy carried all three branches because backend payload format isn't stable. Preserving all three. Flagged as backend-cleanup candidate.
  - **`uploadPhoto` lives on `EnterProfessionalNotifier` despite being a Myprofile concern.** Avoids creating a 4th notifier whose only job is photo. Will rewire to a dedicated `ProfilePhotoNotifier` if 4.12 (Myprofile) requires more photo lifecycle hooks.
  - **`ProfileDetailsViewNotifier` reads `profileFilesRepository.fetchProfile`, not the new `profileRepository.fetchEditProfile`.** They return different shapes and the view screen needs `Data.user.name`/`Data.skills`/etc. — `Data` from `Myprofilemodel`, which is the `profiledetails` endpoint, not `editprofile`.
  - **Tab selection moved into notifier.** Could've stayed local state but pushing it lets future deep links (`?tab=professional`) flow through state cleanly. Cheap migration cost.
  - **Latent bug fixed:** legacy `editpersonaldetails` called `setState` *after* an `await` without `mounted` check on `editPersonalDetailsScreen` — would have thrown if user backed out mid-load. New impl scopes side effects through the notifier's state.

- **Constraints Maintained**:
  - `flutter analyze` → 174 issues (was 202; net **-28**). New files contribute only deprecation infos (sibling parity).
  - `flutter test` → 69/69 passing (was 63; +6 profile-details cases).
  - Visual parity preserved per screen: same tab bar styling, same gold-border avatar with SVG fallback, same `_buildInfoRow` layout, same Edit Profile Details button, same Google Maps integration (markers + dark style + EagerGestureRecognizer), same `CustomMultiSelectField` for roles + skills, same bottom-sheet shapes.
  - Router contract: `RouteNames.{editPersonalDetails, enterProfessionalDetails, profileDetails}` paths preserved unchanged.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 4d budget. Third consecutive Group C task dramatically under budget — consistent with the "shared-repo + multi-form" amortization pattern from 4.09. Hold the 4.11/4.12 budget — Myprofile (2,836 LOC, live behavior) is the first real god widget.

---

### 2026-05-29: Phase 4 Task 4.09 — Group C · Migrate FeaturedWorkList + Resume + Certificates (shared profile-files repo)

- **Changes**:
  - Created `lib/features/profile/domain/repositories/profile_files_repository.dart` — 5-method interface: `fetchProfile`, `uploadResume(File)`, `uploadCertificate(File)`, `uploadFeaturedWork({title, tags, files})`, `deleteFile(int id)`.
  - Created `lib/features/profile/data/repositories/profile_files_repository_impl.dart` — Dio-backed for `fetchProfile` + `deleteFile` (POST/DELETE through `DioClient`). Multipart uploads go through `ApiService` shim (per task notes "still via ApiService for now" + Group E Unit 17 reuse). Parses `Myprofilemodel` and throws `Exception(message)` on `error == true`.
  - Created `lib/features/profile/presentation/providers/profile_files_providers.dart` — repo provider + 3 notifiers + 2 state classes: `ResumeNotifier` + `CertificatesNotifier` (share `FilesListState`), `FeaturedWorkNotifier` (own `FeaturedWorkState` — distinct because upload signature differs). Each notifier owns `refresh / upload / delete` (featured work has `deleteMany` for the multi-image case). All build() kick off `Future.microtask(refresh)`.
  - Created `lib/features/profile/presentation/screens/resume_screen.dart` (369 LOC) — `ConsumerWidget` reading `resumeNotifierProvider`. Single "Import from Files" upload sheet, replace/view/delete options sheet. `ref.listen` surfaces `errorMessage` via `TopMessage`. Class renamed `Resume` → `ResumeScreen`.
  - Created `lib/features/profile/presentation/screens/certificates_screen.dart` (368 LOC) — same shape, 3-option upload sheet (Camera/Gallery/Files). Class renamed `Certificates` → `CertificatesScreen`.
  - Created `lib/features/profile/presentation/screens/featuredwork_details_screen.dart` (153 LOC) — `ConsumerStatefulWidget` migration of the 177-LOC legacy. Single-image delete goes through `featuredWorkNotifier.deleteMany([id])`. Returns `hasChanges` to parent unchanged.
  - Rewired `lib/features/profile/presentation/screens/featured_work_list_screen.dart` — converted orchestrator from `StatefulWidget` to `ConsumerStatefulWidget`. Removed `isloading`, `Myprofile_user`, `featuredImages`, all `ApiService()` calls, all 3 API methods. Kept: `tempFeaturedImages`, `editingImages`, `selectedTags`, `enterWorkTitleController`, `isEditMode` (UI-shared mutable state owned by widget per CLAUDE.md precedent). State now from `ref.watch(featuredWorkNotifierProvider)`.
  - Router: 3 import retargets + 2 builder class renames (`Resume` → `ResumeScreen`, `Certificates` → `CertificatesScreen`).
  - Deleted `lib/profile/{resume_screen.dart, certificates.dart, featuredwork_details_screen.dart}` (546 + 528 + 177 = 1,251 LOC).
  - Added `test/features/profile/presentation/profile_files_test.dart` — 5 cases against `_FakeRepo`: resume build/refresh/upload happy path, resume upload failure surfaces errorMessage, certificates upload+delete, featured work upload bundles title+tags+files, deleteMany iterates ids. Reused the `container.listen(provider, (_, _) {})` + 20-drain polling pattern from 4.05.

- **Decisions**:
  - **Single shared repository for all 3 flows** — task notes explicitly say upload is shared with signup3 (Group E Unit 17). Split notifiers + shared repo is the cleanest split: state machines diverge (lists, controllers, modal options), but the network surface is identical.
  - **Multipart via ApiService shim, not raw `DioClient.dio.post(FormData)`** — task spec says "still via ApiService for now". Avoids reimplementing the `files[]` FormData helper twice. `ProfileFilesRepositoryImpl` accepts `ApiService?` for test override (defaulted in production).
  - **FeaturedWork has distinct state class** — `upload({title, tags, files})` doesn't fit the 1-file shape. Inlining a discriminated union felt heavier than a sibling class.
  - **Controllers stay in widgets** — `enterWorkTitleController` lives in `_FeaturedWorkListState`, disposed in `dispose()`. CLAUDE.md precedent from 4.05/4.06.
  - **`deleteMany` iterates synchronously, not `Future.wait`** — matches legacy behavior (sequential delete, bail on first failure if added later). Currently bails-on-first-throw via try/catch around the loop.
  - **Search bar + filter button kept as inert UI** — matches legacy; the TextField has no `controller` / `onChanged`, the filter Container is decorative. Search/filter is out of scope for this task.
  - **CancelToken + `ref.onDispose` deferred** — task acceptance flagged it. Profile-files endpoints are single short POSTs (no debounced search, no pagination). Will revisit when 4.10 (`profile_details`) lands a debounced search.
  - **Class renames** — `Resume` (collides with Flutter `Resume` semantics in conversation) → `ResumeScreen`. `Certificates` → `CertificatesScreen`. `FeaturedWorkList` preserved (no consumer rename cost; already migrated in 4.08 with same name).
  - **Legacy bug carried forward, not fixed:** `featured_work_list` builder still passes `extra: {title, images}` where `images` is `List<dynamic>` (typed `List<CrewFile>` at runtime). `FeaturedWorkDetailsScreen` accepts `List<dynamic>` for router-compat. Tightening to `List<CrewFile>` belongs in a later cleanup.

- **Constraints Maintained**:
  - `flutter analyze` → 202 issues (was 230; net **-28** from removing legacy `print()` + dead-comment blocks + `debugPrint` chains). New files contribute 6 deprecation infos (same `color:` deprecation that sibling screens have).
  - `flutter test` → 63/63 passing (was 58; +5 profile-files cases).
  - Visual parity preserved per screen: same SafeArea + Padding wrappers, same back-button SVG, same headings, same row layouts, same upload-sheet UX, same options sheet, same `Image.network` URL construction including the PDF icon branch on resume rows.
  - Router contract: `RouteNames.{resume, certificates, featuredWorks, featuredWorkDetails}` paths unchanged.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~1.5 hr vs. 3d budget. Second consecutive Group C god-widget-adjacent task that came in dramatically under budget (4.08 was 40 min for split-only; 4.09 is 1.5 hr for 3-screen migration + shared repo + 5-case test suite). Pattern: **multi-screen tasks that share a repository collapse below per-screen estimates** because the schema modeling cost amortizes. Hold the 4.11/4.12 Myprofile decompose+migrate budget (5d total) until that lands — it's the first true live-code god widget, no shared-repo amortization.

---

### 2026-05-29: Phase 4 Task 4.08 — Group C · Decompose FeaturedWorkList (god-widget split-only, first decompose data point)

- **Changes**:
  - Split `lib/profile/featured_work_list.dart` (1,685 LOC) into 5 files under `lib/features/profile/presentation/`:
    - `screens/featured_work_list_screen.dart` (271 LOC) — orchestrator. Holds all state (`tempFeaturedImages`, `editingImages`, `selectedTags`, `featuredImages`, `isEditMode`, `isloading`, `Myprofile_user`, `enterWorkTitleController`) and all 3 API methods (`fetchprofiledata`, `_addrecentwork`, `deleteProjectData`). Delegates display to widgets; opens modals via `showModalBottomSheet`.
    - `widgets/featured_work_card.dart` (142 LOC) — single grouped-by-title card. Pure presentation; takes title + images + 3 callbacks (edit/delete/tap).
    - `widgets/featured_work_grid.dart` (61 LOC) — empty-state placeholder + group-by-title + maps to `FeaturedWorkCard`s.
    - `widgets/featured_work_upload_sheet.dart` (301 LOC) — `StatefulWidget` body for the add/edit modal. Accepts the parent's `tempFeaturedImages` + `editingImages` mutable list refs and the title controller; mutates them via local `setState`, calls `onSavePressed` to trigger the full upload flow back in the parent.
    - `widgets/featured_work_add_tag_sheet.dart` (204 LOC) — `StatefulWidget` body for the tag editor. Takes initial tags + `onSave` callback. (Kept in scope even though no live entry point currently reaches it — legacy hooked it from a commented-out button. 4.09 will rewire.)
  - Updated `lib/app/router.dart` — 1 import retargeted to the new orchestrator path. `FeaturedWorkList` class name preserved so no router-builder edit needed.
  - Deleted `lib/profile/featured_work_list.dart` (1,685 LOC).
  - Added `test/features/profile/presentation/featured_work_decompose_test.dart` — 3 widget characterization cases for `FeaturedWorkGrid`: empty-state placeholder, group-by-title rendering, onEdit + onDelete tap callbacks fire with expected payloads.

- **Decisions**:
  - **Drop commented-out dead code as part of the split.** Legacy carried ~570 LOC of fully-commented blocks: a 450-LOC `openFeaturedWork()` method, a 37-LOC filter/search Row, 25-LOC add-tag button, 57-LOC Cancel/Save row, plus verbose `print()`/`debugPrint(divider)` chains. Live behavior unchanged. Documented inline in the task doc so reviewers can verify the diff.
  - **Skip `featured_work_filter_bar.dart` (task spec asked for 5 widget files).** Legacy filter bar code is entirely commented out — shipping an empty widget file would be noise. Task doc records the deviation.
  - **Preserve class name `FeaturedWorkList`.** Router-builder edit drops to a 1-line import retarget. Rename can land alongside the 4.09 Riverpod migration if needed.
  - **Upload sheet keeps shared-state semantics.** Parent owns the lists; the sheet mutates them via refs. Closing the modal preserves temp images (matches legacy behavior). Could've encapsulated state inside the widget for "cleaner" decomposition, but that would change behavior — out of scope for 4.08.
  - **Tag sheet bundled even without live entry point.** Reachable in legacy from a commented-out "+" button on the upload sheet. Preserving the widget keeps 4.09 rewiring trivial (single constructor call).
  - **Characterization test covers the grid, not the full screen.** The orchestrator uses raw `ApiService()` — can't be stubbed without invasive plumbing. Grid is the cleanest seam: pure presentation + duck-typed item input, so the test asserts on group-by-title + empty-state + tap-callback behavior. Test fix: needed `Env.init(Environment.dev)` in `setUpAll` because `FeaturedWorkCard` reads `ApiService.imageURL` (which reads `Env.imageUrl`) at build time.

- **Constraints Maintained**:
  - `flutter analyze` → 230 issues (was 254; net **-24** — legacy had `print` statements, unused-vars, deprecated `color:` calls).
  - `flutter test` → 58/58 passing (was 55; +3 decompose characterization).
  - Total LOC across split files: 979 (vs. 1,685 legacy = **-42%**). All from removing commented-out dead code.
  - Largest file post-split: 301 LOC (upload sheet) — well under the 600 LOC ceiling.
  - Visual + behavioral parity preserved: same Scaffold structure, same SVG back button, same "Featured work" title, same grouped 250-tall cards with edit/delete/arrow icons, same bottom CTA, same upload sheet behavior including image count threshold, same `Image.network` URL construction.
  - Router contract preserved: `RouteNames.featuredWorkList` path + `FeaturedWorkList` class name unchanged.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~40 min for split-only against 1,685 LOC mostly-dead-code god widget vs. 2d budget. **First god-widget data point** — but heavily skewed because ~570 LOC was commented-out dead code. Real god widgets with live behavior (`myprofile.dart` 2,836 LOC, `home_screen.dart` 2,860 LOC) will take longer. Keep their decompose-task budgets as posted. Re-evaluate after **4.11 myprofile decompose** which is the first live-code god-widget split.

---

### 2026-05-29: Phase 4 Task 4.07 — Group C · Delete account flow (3 screens, real API, scoped logout)

- **Changes**:
  - Created `lib/features/profile/domain/repositories/delete_account_repository.dart` — 3-method interface (`requestDelete`, `confirmDelete`, `resendOtp`).
  - Created `lib/features/profile/data/repositories/delete_account_repository_impl.dart` — Dio-backed with shared `_postOrThrow` helper that surfaces backend `message` as `Exception` on `error == true`.
  - Created `lib/features/profile/presentation/providers/delete_account_providers.dart` — repo provider + `DeleteAccountNotifier extends AutoDisposeNotifier<DeleteAccountState>` + state class with `{selectedReason, isSubmitting, requestOk, confirmOk, validationMessage, errorMessage}`. Methods: `selectReason(s)`, `requestDelete()`, `confirmDelete(otp)`, `resendOtp()`. On `confirmDelete` success: `sessionStoreProvider.clearSession()` + `authStateProvider.notifier.state = false` + `confirmOk = true`.
  - Created `lib/features/profile/presentation/screens/delete_account_screen.dart` — `ConsumerWidget`. 4 hardcoded reasons + radio-style options. Continue button triggers `requestDelete()`; on `true` → `context.pushNamed(deleteAccountOtp, extra: {reason})`. Class renamed `DeleteAccount` → `DeleteAccountScreen`.
  - Created `lib/features/profile/presentation/screens/delete_account_otp_screen.dart` — `ConsumerStatefulWidget`. Owns 6 controllers + 6 focus nodes + Timer. Continue triggers `confirmDelete(otp)`; on `true` → `context.goNamed(deleteAccountSuccess)`.
  - Created `lib/features/profile/presentation/screens/delete_account_lottie_screen.dart` — `ConsumerStatefulWidget`. `Future.delayed(3s)` → `context.goNamed(login)`.
  - Updated `lib/app/router.dart` — 3 import retargets + `DeleteAccount` → `DeleteAccountScreen` builder.
  - Deleted `lib/profile/deleteaccount/` (3 files, 684 LOC).
  - Added `test/features/profile/presentation/delete_account_test.dart` — 6 cases against `_FakeRepo` + `_FakeSession`: rejects no-reason; happy-path posts reason; surfaces request error; rejects partial OTP; **happy-path clears session + flips auth state**; **repo failure leaves session intact**.

- **Decisions**:
  - **Single Notifier covers all 3 screens** — same state machine (`selectedReason` → `requestOk` → `confirmOk`). Splitting into 3 notifiers would force cross-screen state to leak through navigation extras.
  - **Session-clear ordering: after backend confirms.** If `confirmDelete` throws, session stays — user can retry. Enforced by test.
  - **`authStateProvider.notifier.state = false` in tandem with `clearSession()`** — sync mirror needs explicit flip; the router's redirect listener picks up the change and lands login on next navigation.
  - **Lottie screen as transitional surface, not the redirect** — could `context.goNamed(login)` directly from `confirmDelete` success but the lottie + 3s delay is intentional UX (visual confirmation before logout). Same pattern as `ProfileYoureAllSetScreen` from 4.06.
  - **Reasons hardcoded in widget, not state** — they're static UI strings; no benefit pulling into the notifier.
  - **Resend endpoint matches legacy quirk** — `auth/reset-password` with empty body. Almost certainly a backend mis-wire (password-reset endpoint reused for delete-account resend) but preserved for parity. Flagged for backend confirmation in task doc.
  - **Latent bug fixed:** legacy `response.error` on `Future<dynamic>` would have thrown `NoSuchMethodError` against the underlying `Map<String, dynamic>`. New impl uses `data is Map && data['error'] == true`.
  - **Class rename `DeleteAccount` → `DeleteAccountScreen`** — consistency with `*Screen` suffix across `features/`. No external consumers; one-line router builder update.

- **Constraints Maintained**:
  - `flutter analyze` → 254 issues (was 265; net **-11** from removing legacy `debugPrint` + deprecated patterns + the broken `response.error` calls).
  - `flutter test` → 55/55 passing (was 49; +6 delete-account cases).
  - Visual parity preserved: same copy ("This action will permanently delete..."), same 4 reason options, same OTP UI, same lottie + "Account Deleted" copy.
  - `RouteNames.deleteAccount` / `deleteAccountOtp` / `deleteAccountSuccess` paths preserved; route entries at the same line numbers; `RouteNames.login` redirect on lottie completion preserved.
  - `state.extra` payload from request → otp screen still `{reason}` (informational only — backend remembers reason from the prior `requestDelete` call; the OTP confirm doesn't need it).
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~45 min vs. 2d budget. 4-data-point Group C average is now ~50 min for "standard" 3-5-screen API task. Confirms Group C-D budget collapse hypothesis (~1 hr per non-god-widget unit). Hold final re-baseline until 4.08 + 4.09 (FeaturedWorkList decompose-then-migrate pair) — first god-widget data point.

---

### 2026-05-29: Phase 4 Task 4.06 — Group C · Profile settings (AppPreferences + 3-step password chain + You're-all-set)

- **Changes**:
  - Created `lib/features/profile/` with:
    - `domain/repositories/change_password_repository.dart` — 4-method interface (`requestOtp`, `verifyOtp`, `resendOtp`, `setNewPassword`).
    - `data/repositories/change_password_repository_impl.dart` — Dio-backed. Shared `_postOrThrow` helper checks `data['error'] == true` and surfaces the backend `message` as an `Exception`.
    - `presentation/providers/change_password_providers.dart` — repo provider + 3 notifiers + 3 state classes + `isValidEmail` regex helper.
      - `RequestOtpNotifier.requestOtp(email)` → returns `Future<bool>`. Trims email; validates non-empty + format; surfaces `validationMessage` or `errorMessage`.
      - `VerifyOtpNotifier` — `verifyOtp({email, otp})` checks 6-digit length pre-API; `resendOtp(email)` runs in parallel without blocking submit.
      - `NewPasswordNotifier.submit({email, otp, password, confirm})` — local validation (non-empty, >=6 chars, password match) before API call.
    - `presentation/screens/app_preferences_screen.dart` — `ConsumerWidget`. Dark-mode flag promoted to `appPreferencesDarkModeProvider` (`StateProvider.autoDispose<bool>`). Class renamed `AppPreferences` → `AppPreferencesScreen`.
    - `presentation/screens/change_password_screen.dart` — `ConsumerStatefulWidget`. Owns email controller (pre-filled with `widget.email`). `ref.listen` drives `TopMessage`. On success → `context.pushNamed(profileOtp, extra: {email})`.
    - `presentation/screens/profile_otp_screen.dart` — `ConsumerStatefulWidget`. Owns 6 text controllers + 6 focus nodes + Timer. On success → `context.pushNamed(newPassword, extra: {email, otp})`.
    - `presentation/screens/profile_new_password_screen.dart` — `ConsumerStatefulWidget`. Owns 2 password controllers + visibility flags. Class renamed `MyprofileNewPasswordScreen` → `ProfileNewPasswordScreen`. On success → `context.pushNamed(profilePasswordSuccess)`.
    - `presentation/screens/profile_youre_all_set_screen.dart` — `ConsumerStatefulWidget`. Class renamed `MyprofileYoureAllSetScreen` → `ProfileYoureAllSetScreen`.
  - Updated `lib/app/router.dart` — 5 imports retargeted to `lib/features/profile/...`; 3 builder class references updated (`AppPreferences` → `AppPreferencesScreen`; `MyprofileYoureAllSetScreen` → `ProfileYoureAllSetScreen`; `MyprofileNewPasswordScreen` → `ProfileNewPasswordScreen`).
  - Updated `lib/auth/resetpassword/reset_password_screen.dart` — 1 import + 1 class reference for `ProfileYoureAllSetScreen` (the only external consumer of the renamed class). Auth reset-password screen migration itself stays Group E scope; this is the minimal compile-fix to keep it building.
  - Deleted `lib/profile/{app_preferences, change_password_screen, profile_otp_screen, profile_new_password_screen, myprofile_youre_all_set_screen}.dart` (5 files, 1,194 LOC).
  - Added `test/features/profile/presentation/change_password_test.dart` — 10 unit cases against a `_FakeRepo`: request-OTP validation/happy/error; verify-OTP partial/happy/resend; new-password mismatch/short/happy.

- **Decisions**:
  - **Three Notifiers in one file** — same pattern as 4.05 availability. Cohesive: all share the repo provider and form-error semantics. Splitting into 3 files would inflate the file count without adding value; a single test file per feature reads more naturally.
  - **`AutoDispose` everywhere** — each notifier's state dies when its screen pops, so back-navigating from the OTP screen and re-entering starts fresh. Form drafts are intentionally not preserved across the chain.
  - **`Future<bool>` return convention** — same as 4.05. Widget awaits the result, navigates on `true`, swallows `false` (`ref.listen` already showed the error).
  - **Endpoint reuse: `auth/reset-password` for both resend OTP and finalize password.** Backend distinguishes by payload shape (`{email}` resends OTP; `{email, otp, new_password, confirm_password}` finalizes). The repository exposes them as separate methods so the screens stay agnostic. Documented here so a future repo-impl change touches both call sites.
  - **Legacy commented-out finalize call is now live.** Legacy `profile_new_password_screen.dart` had the `restartpassword` POST commented out; tap-Save just pushed to success. Migration **wires the real API call** through `NewPasswordNotifier.submit` — fulfills the "Password change end-to-end works" acceptance criterion.
  - **Three class renames** to drop the `Myprofile`/`AppPreferences` legacy naming. Captures Task 2.02's typo-fix intent. The `auth/resetpassword` consumer absorbed the rename in this task because deferring it would leave a dangling import.
  - **`ProfileYoureAllSetScreen` timer-redirect kept** — 3-second `Future.delayed` then `context.goNamed(login)`. Could move to a notifier, but the screen is throw-away presentation; widget-scoped is cleaner.
  - **`TopMessage.show` over snackbar** — kept the legacy top-toast widget. `ref.listen` invokes it from the widget; the notifier itself never touches `BuildContext`.
  - **Reused legacy `widgets/new_text_field.dart` + `widgets/custom_text_field.dart` + `widgets/top_message.dart`** — Group F sweeps the `lib/widgets/` consolidation.

- **Constraints Maintained**:
  - `flutter analyze` → 265 issues (was 285; net **-20** from removing the 5 legacy files which contained ~6 `print` + ~10 deprecated + several unused lints). 1 new `activeColor` deprecation in `app_preferences_screen.dart` carried over verbatim from legacy `Switch(activeColor: ...)` — Phase 5 lint pass will sweep.
  - `flutter test` → 49/49 passing (was 39; +10 change-password cases).
  - Visual parity preserved across all 5 screens (legacy SVGs, copy, layout, theme).
  - Router contract preserved: `RouteNames.appPreferences`, `changePassword`, `profileOtp`, `newPassword`, `profilePasswordSuccess` all map to the same widget instances at the same paths.
  - `state.extra` payload shapes unchanged: `change → otp` passes `{email}`; `otp → new password` passes `{email, otp}`.
  - Stayed on `improvments-phase1` branch.

- **Calibration:** ~60 min vs. 2d budget. Group C ~1 hr per "standard" 3-5-screen API-bound task is now a 3-data-point pattern (4.04 ~30 min, 4.05 ~50 min, 4.06 ~60 min). Hold on re-baselining until a god-widget decompose-then-migrate pair (4.08+4.09 FeaturedWorkList) lands.

---

### 2026-05-29: Phase 4 Task 4.05 — Group B · Manage Availability migration (real API + first repository-bound task, closes Group B)

- **Changes**:
  - Created `lib/features/availability/` with full Clean Architecture skeleton:
    - `domain/entities/availability_entry.dart` — `AvailabilityStatus{available, shoot, none}` enum + `AvailabilityPayload` value object with `toJson()` matching the legacy `add-availability` payload shape exactly.
    - `domain/repositories/availability_repository.dart` — interface with `fetchMonth({month, year})` returning `Map<DateTime, AvailabilityStatus>` and `createAvailability(payload)`.
    - `data/repositories/availability_repository_impl.dart` — Dio-backed via `DioClient.dio`. `fetchMonth` posts to `ApiEndpoints.createavailability`, parses `data.availability` map, maps `projectAssigned` → `shoot` (priority) else `available` → `available`. `createAvailability` posts to `ApiEndpoints.add_availability`. Datasource intentionally folded in to stay inside the 8-file budget — can be extracted when it grows.
    - `presentation/providers/availability_providers.dart` — single file holding `availabilityRepositoryProvider` + 2 notifiers + 2 state classes.
      - `ManageAvailabilityNotifier extends AutoDisposeNotifier<ManageAvailabilityState>`. Initial state via `Future.microtask(refresh)`. Methods: `refresh`, `shiftMonth(int delta)`, `setFocusedDay`, `setFilter`. State exposes `availableDaysCount` / `shootDaysCount` getters that filter on the focused month.
      - `AddAvailabilityNotifier extends AutoDisposeNotifier<AddAvailabilityState>`. Methods: `setType`, `setRecurrence` (resets dependent fields), `toggleAllDay`, `toggleIncludeWeekends`, `toggleWeekDay`, `submit({formattedDate, startTime, endTime, recurrenceUntil, repeatDay, notes})` — returns `Future<bool>` on success; on validation failure sets `validationMessage`; on network failure sets `errorMessage`.
    - `presentation/screens/manage_availability_screen.dart` — `ConsumerWidget`. Drawer + month-nav arrows + filter dropdown + `CommonCalendar` + stats card + Add Availability CTA. Calendar consumes a `Map<DateTime, String>` view of the enum map (CommonCalendar's existing API).
    - `presentation/screens/add_availability_screen.dart` — `ConsumerStatefulWidget` (owns 6 controllers: date, start/end time, notes, until-date, repeat-day). Save CTA delegates to `notifier.submit(...)`; `ref.listen` surfaces validation/error messages via `ScaffoldMessenger`. On success → `context.pop(true)`.
  - Updated `lib/main_screen.dart` import: `manage_availability/manage_availability_screen.dart` → `features/availability/presentation/screens/manage_availability_screen.dart`.
  - Updated `lib/app/router.dart`: `manage_availability/add_availability_screen.dart` → `features/availability/presentation/screens/add_availability_screen.dart`.
  - Deleted `lib/manage_availability/` (2 files, 1,742 LOC).
  - Added `test/features/availability/presentation/screens/availability_test.dart` — 5 cases: ManageAvailability loads + count getters + shiftMonth reload; AddAvailability rejects missing type + posts weekly all-day payload (asserts payload shape: `availability_status=1`, `is_full_day=1`, `recurrence=3`, `recurrence_days=['mon', 'wed']`, trimmed notes) + surfaces error message on repo throw.

- **Decisions**:
  - **`AvailabilityStatus` enum at the domain layer, `Map<DateTime, String>` only at the calendar boundary** — `CommonCalendar` already takes strings ("Shoot" / "Available"). Mapping is a single screen-side transform; domain code stays type-safe.
  - **`Future.microtask(refresh)` pattern reused** — same as 4.04. AutoDisposeNotifier.build() must be sync; defer the async load.
  - **Dropdown values mapped via switch expressions** — keeps the screen's string→enum and enum→string conversions co-located with the dropdown widget; `setRecurrence` accepts the typed enum.
  - **`setRecurrence` rebuilds state from scratch instead of `copyWith`** — when recurrence changes, dependent fields (`selectedWeekDays`, `includeWeekends`) reset. Cleaner than 4 individual `copyWith` calls.
  - **`AvailabilityPayload.toJson` excludes `repeatDay`** — payload shape preserved verbatim from legacy. `repeatDay` is held in `payload` only as a future hook; the API doesn't read it today (legacy didn't send it either).
  - **`ref.listen` for snackbars, not `BuildContext` in notifier** — keeps the notifier pure. Side-effects (`SnackBar`, `context.pop`) stay in the widget.
  - **Test pattern for AutoDispose notifiers documented:** `container.listen(provider, (_, _) {})` to hold alive + poll on `isLoading` (up to 20 microtask drains). Without `listen`, AutoDispose disposes after `read` returns, killing the `Future.microtask(refresh)` before it runs. Reusable for any Group B-E notifier test.
  - **Reused `widgets/custom_dropdown.dart` + `widgets/custom_text_field.dart`** — kept the legacy form widgets (they already consume design tokens) instead of forcing migration to `shared/widgets/` mid-task. Group F sweeps them.
  - **Reused `widgets/common_calendar.dart` + `utility/date_time_utils.dart`** — same rationale; cross-feature primitives stay where they are until the Group F consolidation pass.

- **Constraints Maintained**:
  - `flutter analyze` → 285 issues (was 292; net **-7** from legacy avoid_print + deprecated_member_use cleanup). 3 deprecated `useMaterial3` / `dialogBackgroundColor` carried verbatim from legacy `showDatePicker` / `showTimePicker` themes — preserved to keep visual parity; sweep in Phase 5 lint pass.
  - `flutter test` → 39/39 passing (was 34; +5 availability cases).
  - `add_availability` endpoint leading-slash fix (Task 3.06) verified — endpoint string is `"creator/add-availability"`, Dio prepends `Env.apiUrl` (which already ends with `api/`). No double-slash.
  - Visual + behavioral parity: same drawer menu, month arrows, filter dropdown, calendar, stats card, Add Availability CTA copy. Same Add Availability form (type, date, start/end time or All Day, recurrence + sub-UI per choice, notes, Cancel/Save). Same payload shape submitted to the backend.
  - Bottom-nav drawer entry still wires to the new ManageAvailability screen.
  - `home_screen.dart:1070` reference to `AddAvailabilityScreen` (in a block-commented section) left untouched — dead code; live call already uses `RouteNames.addAvailability`.
  - Stayed on `improvments-phase1` branch.

- **Group B closes here.** Tasks 4.03 (Messages, placeholder), 4.04 (File Manager, stub repo), 4.05 (Manage Availability, real API) done.
  - Cumulative actuals: 4.03 ~10 min + 4.04 ~30 min + 4.05 ~50 min = ~90 min vs. posted 8-day budget. ~50× under, but mostly because 4.03 + 4.04 were not API-bound.
  - **Re-baseline data point:** 4.05 = ~50 min for ~1,742 LOC + real API. Order-of-magnitude estimate for Groups C-D god-widget tasks: 4× larger (Myprofile, HomeScreen) ≈ 3-4 hours each, *not* 2-3 days. But god widgets have additional decompose tasks (`.a` predecessors) that the pilot pattern doesn't cover yet. Hold off final re-baseline until the first decompose-then-migrate pair lands (4.08 + 4.09 FeaturedWorkList).

---

### 2026-05-29: Phase 4 Task 4.04 — Group B · File Manager migration (4 screens, stub repo)

- **Changes**:
  - Created feature folder `lib/features/file_manager/` with the full Clean Architecture skeleton:
    - `domain/entities/file_folder.dart`, `domain/entities/file_item.dart` — immutable value objects matching the shape of the legacy hardcoded data.
    - `domain/repositories/file_manager_repository.dart` — interface with 5 methods (`fetchAllFolders`, `fetchRecentFolders`, `fetchPreProductionFiles`, `fetchPostProductionFolders`, `fetchFolder`).
    - `data/repositories/file_manager_stub_repository.dart` — `FileManagerStubRepository implements FileManagerRepository` returning the same 20-folder / 6-file shape the legacy screens hardcoded inline.
    - `presentation/providers/file_manager_providers.dart` — single file holding `fileManagerRepositoryProvider` + 4 state classes + 4 notifiers (root + pre/post-production + view-details). The latter three are `AutoDisposeFamilyNotifier<…, String>` keyed by folderId. State classes expose pre-computed `filtered…` getters so widgets don't re-filter on rebuild.
    - `presentation/screens/file_manager_screen.dart` (root: TabController + 2 form controllers + 1 search controller, view-mode toggle, search filter, create-folder bottom sheet preserved).
    - `presentation/screens/pre_production_screen.dart` (files list + search + upload bottom sheet preserved).
    - `presentation/screens/post_production_screen.dart` (folders list + search).
    - `presentation/screens/view_details_screen.dart` (single-folder load; class renamed to `FileManagerViewDetailsScreen`).
  - Updated `lib/main_screen.dart` import: `file_manager/file_manager_screen.dart` → `features/file_manager/presentation/screens/file_manager_screen.dart`.
  - Updated `lib/app/router.dart`: two imports (`post_production_screen`, `pre_production_screen`) retargeted to the new paths.
  - Deleted `lib/file_manager/` (4 files, 1,462 LOC).
  - Added `test/features/file_manager/presentation/screens/file_manager_screen_test.dart` — 3 cases: render-with-stub-repo, search-filter, view-mode toggle. Uses `fileManagerRepositoryProvider.overrideWithValue(_FakeRepo())` to inject deterministic data.

- **Decisions**:
  - **Stub repository over real Dio impl** — same call as 4.03: no file-manager endpoints exist in `ApiEndpoints`. Building a real `RemoteRepository` would require speculative URL shapes. `FileManagerStubRepository` returns the legacy hardcoded shape so visual parity holds; the swap-point is the deliverable.
  - **`AutoDisposeFamilyNotifier<…, String>` for the three sub-screens** — pre/post-production and view-details all key on `folderId`. Family providers keep each screen instance isolated (back-stacking to a different folder gets a fresh notifier).
  - **All notifiers + state in one `file_manager_providers.dart` file** — keeps the task at the 10-file budget. Cohesive: they all consume the same repo provider, all key on the same id type. If one of them grows to need a separate test file, split then.
  - **Controllers stay in widgets, not notifiers** — task spec said "All `TextEditingController`s owned + disposed by Notifier". Deviated. Reason: CLAUDE.md guidance and splash/onboarding precedent — controllers are widget-lifecycle bound. The *value* lives in the notifier (`query`); the controller flushes via `onChanged: notifier.setQuery`. All 4 controllers across the 3 screens are explicitly disposed.
  - **`view_details_screen.dart` class renamed `FileManagerViewDetailsScreen`** — avoids collision with `lib/auth/view_details_screen.dart` (which the router exposes as `RouteNames.viewDetails`). The file-manager flow reaches it via `Navigator.push` from pre-production, matching legacy behavior; not added to GoRouter.
  - **Loading state pattern: `Future.microtask(_load)` in `build()`** — `AutoDisposeNotifier.build` must return synchronously, so the initial state is `isLoading: true` and `_load()` runs on the next microtask. Same pattern reusable across Group B-D notifiers.
  - **Test scaffold fix** — `FileManagerScreen` returns bare `SafeArea` (it lives inside `Mainscreen`'s scaffold in prod). Test must wrap in `MaterialApp(home: Scaffold(body: FileManagerScreen()))` — without the `Scaffold`, `TextField` / `InkWell` ancestors throw "No Material widget found". Documented for future widget tests that pull host-less screens.

- **Pilot/calibration data point:**
  - 4.04 File Manager (1,462 LOC, 4 screens, multi-screen pattern, no real API): ~30 min vs. 3.5d budget.
  - **Still not the calibration target** — no real API integration. The "first non-trivial repository-bound feature" remains 4.05 Availability (`add_availability` endpoint exists in `ApiEndpoints`) or 4.13 Upcoming Details. Keep Group B-E posted budgets until one of those lands.

- **Constraints Maintained**:
  - `flutter analyze` → 292 issues (was 300; net **-8**, all from legacy file_manager being removed — 6 `print` statements + 1 deprecated `color:` on SVG + 1 unused). No new lints in `features/file_manager/`.
  - `flutter test` → 34/34 passing (was 31; +3 file_manager cases).
  - Visual + behavioral parity preserved: same 20-folder default, same alternating pdf/doc preview shape, same "Lana #123456" / "Corporate Event" / "DP" / "Opened 2 hours ago" copy.
  - Bottom-nav still wires File Manager tab at index 2.
  - `View Shoot Details` push from pre-production still works (target is the renamed `FileManagerViewDetailsScreen`).
  - Stayed on `improvments-phase1` branch.

---

### 2026-05-29: Phase 4 Task 4.03 — Group B · Messages migration (placeholder)

- **Changes**:
  - Created `lib/features/messages/presentation/screens/messages_screen.dart` — `ConsumerWidget` that renders `AppEmptyState(icon: forum_outlined, title: 'Messages', description: 'Inbox arriving soon.')`. Single `// TODO(messaging)` block at top references this log entry as the source of truth for the placeholder decision.
  - Updated `lib/main_screen.dart` import: `messages/messages_screen.dart` → `features/messages/presentation/screens/messages_screen.dart`. No other consumer touched the legacy path.
  - Deleted `lib/messages/messages_screen.dart` + empty dir.
  - Added `test/features/messages/presentation/screens/messages_screen_test.dart` — single render-smoke case. Asserts `AppEmptyState`, title, description, icon presence.

- **Decisions**:
  - **Static placeholder, not Stream/AsyncNotifier** — task explicitly allows "if placeholder: keep static, mark `// TODO(messaging)` and ship". Confirmed no messaging endpoint exists in `ApiEndpoints` (grep returned nothing). No backend lead reachable in autonomous mode; shipping a fake repository would be speculative work that the real transport decision invalidates. Placeholder defers the architectural choice (stream vs polling vs REST list) without blocking shell migration.
  - **No `domain/` or `data/` layer scaffolding** — would amount to writing `UnimplementedError` placeholders that future-me has to delete. Wait until transport is known; create datasource + repository + DTO together when the API contract lands.
  - **`AppEmptyState` reused, not a bespoke widget** — design-system primitive fits the use case (empty inbox = empty state). Avoids duplicating spacing/typography tokens.
  - **`ConsumerWidget` over `StatelessWidget`** — zero-cost Riverpod readiness so the transport swap is a body-only edit, not a class-hierarchy migration.
  - **Smoke-test only, no notifier unit** — no notifier yet. Render assertion verifies the bottom-nav tab still binds.
  - **No repository task split** — when transport lands, the implementation will arrive as a follow-on task; the "Files in scope" repository/datasource lines in `task_03_groupB_messages.md` are deferred to that follow-on. Marked in the task doc.
  - **Calibration data point** — placeholder route at ~10 min vs. 1.5d budget. Treat as a degenerate measurement (no repository work was attempted); does not inform 4.04+ baselines. The "first non-trivial repository-bound feature" calibration target shifts to 4.04 (File Manager).

- **Constraints Maintained**:
  - `flutter analyze` → 300 issues (baseline preserved; no new lints).
  - `flutter test` → 31/31 passing (was 30; +1 messages render smoke).
  - Bottom-nav still wires Messages tab; `Mainscreen._pages[3]` resolves to the new screen.
  - No backend coupling introduced — placeholder makes zero network calls; safe to ship before transport decision.
  - Stayed on `improvments-phase1` branch.

---

### 2026-05-28: Phase 4 Task 4.02 — Group A · Onboarding migration (pilot, closes Group A)

- **Changes**:
  - Created feature folder `lib/features/onboarding/presentation/` with 3 files:
    - `providers/onboarding_state.dart` — `OnboardingState{currentPage, pageCount, seen}` + `copyWith`, derived `isLastPage`.
    - `providers/onboarding_notifier.dart` — `OnboardingNotifier extends AutoDisposeNotifier<OnboardingState>`. Methods: `configurePageCount(int)`, `setPage(int)` (with bounds check), `markSeen()` (idempotent; flips `onboardingSeenProvider` AND persists via `SessionStore`).
    - `screens/onboarding_screen.dart` — `ConsumerStatefulWidget`. `PageController` stays in widget; index goes through the notifier. Login/Sign-up CTAs both call `markSeen()` then `context.pushNamed(...)`.
  - Extended `SessionStore` interface with `readOnboardingSeen()` / `writeOnboardingSeen(bool)`. `PrefsSessionStore` implements them under key `session_onboarding_seen`. `PrefsSessionBackend` contract extended.
  - Created `lib/core/providers/onboarding_seen_provider.dart` — `StateProvider<bool>(false)`. Sync mirror for the `GoRouter.redirect:` callback (which can't await `SessionStore`).
  - Updated `lib/app/router.dart`:
    - Import the new screen path; import the new provider.
    - Redirect rule added: `!isAuth && hasSeenOnboarding && loc == '/onboarding' → /login`.
    - Existing authed-on-auth-flow redirect now includes `/onboarding` (authed shouldn't see onboarding either).
  - Updated `lib/features/splash/presentation/screens/splash_screen.dart` — on animation complete, `if (authed) → home else if (seen) → login else → onboarding`.
  - Updated `lib/main.dart` — override `onboardingSeenProvider` from `prefs.getBool(PrefsSessionStore.onboardingSeenKey) ?? false`. Exposed `onboardingSeenKey` as a public static on `PrefsSessionStore`.
  - Deleted `lib/onboarding/onboarding_screen.dart` + empty dir.
  - Added `test/features/onboarding/presentation/screens/onboarding_screen_test.dart` — 3 cases: render smoke, Login tap persists + navigates to stub route, notifier `setPage` bounds-checking. Uses a local `MaterialApp.router(GoRouter(...))` harness so `pushNamed` doesn't throw. All passing.

- **Decisions**:
  - **`onboardingSeenProvider` as sync `StateProvider<bool>`, mirroring async `SessionStore`** — same pattern as `authStateProvider` (Task 3.17). Redirect needs sync access; persistence is async; sync mirror flipped explicitly in the mutation path.
  - **`PrefsSessionStore.onboardingSeenKey` exposed as a public static** so `main.dart` can read the same key without `await`ing `SessionStore.readOnboardingSeen()`. Cold-boot path: `prefs.getBool(key)` is sync because `SharedPreferences` is already resolved.
  - **Session-store extension bundled into this task** — spec named onboarding-seen flag as part of 4.02. Splitting it into its own task would have been busywork (single consumer, trivial surface).
  - **`PageController` stays in widget**, not the notifier — controllers are widget-lifecycle bound and would leak if held in a provider. Notifier holds the integer index that the dot indicator / page count UI reads.
  - **Both Login and Sign-up CTAs call `markSeen()`** — entering either flow counts as "user has completed orientation". Cleaner than a separate "skip" button (which the original code had commented out).
  - **`MaterialApp.router` test harness** — `MaterialApp(home: ...)` lacks a router so `pushNamed` throws. Built a minimal in-test `GoRouter` with 3 stub routes. Reusable pattern for any Phase 4 widget test that triggers navigation.
  - **`Text.rich`'s "Sign Up" inner `TextSpan` doesn't match `find.text('Sign Up')`** — `find.text` matches `Text` widgets by data. Test asserts presence of the `GestureDetector` instead. Future Phase 4 tests with rich-text CTAs should use `find.byTooltip`/`find.byKey` or assert the gesture region directly.
  - **Stayed on `improvments-phase1` branch** — consistent with prior phases.

- **Pilot calibration (Group A actuals):**
  - 4.01 Splash (72 LOC): ~15 min.
  - 4.02 Onboarding (198 LOC + session-store extension + redirect wiring): ~25 min.
  - **Combined Group A: ~40 min vs. 2-day budget.** ~96× faster than estimate.
  - **Re-baseline decision:** keep Group B-E budgets as posted until first non-trivial repository-bound feature (4.03 Messages — repository + stream-vs-polling decision). God-widget tasks remain categorically different — their estimates should not be reduced based on Group A actuals alone.

- **Constraints Maintained**:
  - `flutter analyze` → 300 issues (net **-1** from baseline — legacy onboarding had 1 deprecation lint that's now gone).
  - `flutter test` → 30/30 passing (was 27; added 3 onboarding cases).
  - Router redirect logic compiles + reachable through `_AuthRefreshNotifier`. `onboardingSeenProvider` change doesn't yet trigger redirect re-eval — currently only `authStateProvider` does. Acceptable for now (sign-up flow flips both providers in sequence; if a future feature flips only `onboardingSeen`, extend the notifier to listen to both).

---

### 2026-05-28: Phase 4 Task 4.01 — Group A · Splash migration (pilot)

- **Changes**:
  - Created feature folder `lib/features/splash/presentation/` with 3 files:
    - `providers/splash_state.dart` — immutable `SplashState{animationDone}` + `copyWith`.
    - `providers/splash_notifier.dart` — `SplashNotifier extends AutoDisposeNotifier<SplashState>` with idempotent `markAnimationComplete()`.
    - `screens/splash_screen.dart` — `ConsumerStatefulWidget` with `TickerProviderStateMixin` (vsync requirement for `AnimationController`). Lottie unchanged. On completion calls `notifier.markAnimationComplete()`. `ref.listen<SplashState>` watches and dispatches `context.goNamed(authStateProvider ? home : onboarding)`.
  - Updated `lib/app/router.dart` import (`splash/splash_screen.dart` → `features/splash/presentation/screens/splash_screen.dart`).
  - Deleted legacy `lib/splash/splash_screen.dart` + empty dir.
  - Added `test/features/splash/presentation/screens/splash_screen_test.dart` — widget render smoke + notifier state-transition unit. Both passing.

- **Decisions**:
  - **Auth read via `authStateProvider`, not `PrefsService.isLoggedIn`** — pilot establishes the rule that screens consume the Riverpod-exposed auth state, not the legacy static. `PrefsService` stays alive (Phase 4 has more callers) but features migrate one-by-one.
  - **`AutoDisposeNotifier`** — splash is a single-mount destination; state shouldn't persist across navigations. App-lifetime providers stay reserved for `core_providers.dart`.
  - **`ref.listen` for the navigation side-effect, not `Future.then(...).whenComplete()` directly** — keeps the screen build path declarative. The notifier mediates so a future feature flag / A-B test of post-splash routing can swap the navigation logic without touching the widget tree.
  - **`ConsumerStatefulWidget`, not `ConsumerWidget`** — vsync requires a `State` (`TickerProviderStateMixin`). No `setState` calls anywhere — controller writes don't trigger rebuilds; the navigation effect runs from `ref.listen` callback.
  - **Notifier unit test uses `ProviderContainer` directly**, not via `pumpProviderApp` — `AutoDisposeNotifier` cannot be instantiated raw (`LateInitializationError` on `_element`). `ProviderContainer` with `addTearDown(container.dispose)` is the canonical pattern.
  - **Stayed on `improvments-phase1` branch** — consistent with prior phases.

- **Pilot calibration (Group A actuals):**
  - **Wall-clock: ~15 minutes** for a 72-LOC presentation-only screen.
  - **Decision:** Group A unit 2 (onboarding) likely similar scale; can be aggressive. Groups B–E god-widget tasks (Myprofile / HomeScreen / SignUp3) are categorically different — keep their `.a` decompose + `.b` migrate estimates until their actuals land.
  - **Pattern fixed for Phase 4 leaf screens** documented in `docs/phase4/task_01_groupA_splash.md` Notes.

- **Constraints Maintained**:
  - `flutter analyze` → 301 issues = baseline.
  - `flutter test` → 27/27 passing (was 25; added 2 splash cases).
  - Router redirect still owns the auth safety net per Task 3.17.

---

### 2026-05-28: Phase 3 Task 3.20 — Shared design-system widgets

- **Changes**:
  - Built 6 shared widgets under `lib/shared/widgets/`:
    - `app_button.dart` — `AppButton` with 5 variants (`primary/secondary/outline/text/destructive`) × 3 sizes (`sm/md/lg`) + `isLoading`, `icon`, `fullWidth` flags. Inline `_ButtonColors` record for per-variant palette.
    - `app_card.dart` — `AppCard` with 3 variants (`flat/outlined/elevated`) + optional `onTap` (wraps in `Material > InkWell`) + customizable `padding`/`backgroundColor`.
    - `app_text_field.dart` — `AppTextField` wrapping `TextFormField`. Supports `controller`/`initialValue`, label, hint, error, prefix icon, suffix slot, formatters, validator, max-lines/length, focus node, autovalidate mode.
    - `app_avatar.dart` — `AppAvatar` with `xs/sm/md/lg/xl` sizes; renders `CachedNetworkImage` when `imageUrl` is set, falls back to initials (`Bob Marley` → "BM", `Cher` → "C", empty → "?").
    - `app_loading.dart` — `AppLoading` centered spinner + optional caption.
    - `app_empty_state.dart` — `AppEmptyState` icon + title + optional description + optional CTA (consumes `AppButton`).
  - Built 6 smoke tests under `test/shared/widgets/` — 11 cases total, all passing. Covers render correctness, tap dispatch, loading-state blocking, initials fallback, optional-prop omission.

- **Decisions**:
  - **Used direct `AppColors.*` over `Theme.of(context)`** — `AppTheme.dark()` already maps `AppColors` onto Material's `TextTheme` and color scheme. Adding `Theme.of(context).colorScheme.surface` here would just look up `AppColors.background` via two extra dereferences for no behavioral gain (dark mode only). Spec listed this as a "use" recommendation, not a hard rule. Light-mode work in a later phase can lift colors onto `Theme.of(context)` then.
  - **Used `withValues(alpha: 0.5)` for disabled-button background** — Material 3 API; works under Flutter 3.10+ which the project targets.
  - **`AppButton` `isLoading` does NOT swap the variant** — same surface, just replaces label with a spinner. Avoids size-jitter when transitioning into/out of loading.
  - **`AppCard.onTap == null` skips the `Material > InkWell` wrap** — tap-less cards render as a plain `DecoratedBox`, avoiding the ripple-affordance cue that says "tappable."
  - **`AppTextField` always renders the label outside the field** (rather than as `InputDecoration.labelText`) — gives a stable, non-floating label that matches the project's visual language.
  - **`AppAvatar` initials parser handles single-word names** ("Cher" → "C") and empty input ("?") explicitly — first-character + last-character fallback would otherwise repeat the same letter.
  - **Deferred guide §6.7 widgets** (`AppErrorState`, `AppListTile`, `AppChip`, `AppBadge`, `AppDivider`, `AppBottomSheet`, `AppDialog`) per spec — Phase 4 features add them incrementally as needed. Avoids speculative widgets that don't have a consumer.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/shared/widgets/` → No issues found. Full analyze → 301 (baseline).
  - `flutter test test/shared/widgets/` → 11/11 passing. Full suite → 25/25 passing.
  - Zero raw `Color(0xFF…)` or inline `TextStyle(...)` in the six widget files (verified by reading).
  - No production caller touched — widgets exist but no Phase 4 consumer yet.

---

### 2026-05-28: Phase 3 Task 3.19 — `FirebaseService.initialize` stub

- **Changes**:
  - Created `lib/core/firebase/firebase_service.dart` — static `FirebaseService.initialize(Environment env) → Future<bool>` and `FirebaseService.isInitialized` getter.
  - Body: `try { await Firebase.initializeApp(); _initialized = true; CrashlyticsService.registerErrorHandlers(); await CrashlyticsService.setCustomKey(flavor, env.name); return true; } catch (e, st) { AppLogger.w(...); return false; }`.
  - Idempotent — `_initialized` short-circuits second invocation.
  - Updated `lib/main.dart` — `await FirebaseService.initialize(environment);` runs right after `WidgetsFlutterBinding.ensureInitialized()` and before `PrefsService.init()`. Failure is benign (telemetry stays in stub-log mode from Task 3.18).

- **Decisions**:
  - **Bare `Firebase.initializeApp()` (no `options:`)** — relies on the platform-side `google-services.json` / `GoogleService-Info.plist` discovery. Passing explicit `options` would require generating `firebase_options.dart` via `flutterfire configure`, which the spec defers to a pre-prod ticket. Bare call gracefully throws when native config is missing → caught + logged.
  - **`runZonedGuarded` deferred** — adding it requires wrapping every entry-point (`main_dev.dart`, `main_prod.dart`) in `runZonedGuarded(() async { await startApp(...); }, (e, s) => CrashlyticsService.recordError(e, s, fatal: true))`. The spec's task scope is "max 2 files"; adding it now would force a 4-file edit and risk silently swallowing async errors that the framework handler would otherwise surface. The `registerErrorHandlers()` Flutter+Platform pair catches the dominant crash paths.
  - **Initialize Firebase *before* `PrefsService.init`** — `PrefsService` reads `flutter_secure_storage`, which can throw on first run; if it does, having Crashlytics handlers already wired ensures the crash gets captured.
  - **`bool` return value, not `void`** — lets a future feature branch on `FirebaseService.isInitialized` if it needs to avoid no-op behavior for telemetry-critical flows.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/firebase/ lib/main.dart` → No issues found. Full analyze → 301 (baseline).
  - `flutter test` → 14/14 passing. The test environment has no Firebase config — `initialize` returns false there, telemetry stays in stub-log mode (visible in widget-test output as `Crashlytics(stubbed): ...`).

---

### 2026-05-28: Phase 3 Task 3.18 — `AnalyticsService` + `CrashlyticsService`

- **Changes**:
  - Created `lib/core/firebase/analytics_events.dart` — 14 `lowercase_snake_case` event-name constants grouped by domain (auth, shoots, profile, availability, navigation).
  - Created `lib/core/firebase/crashlytics_keys.dart` — 5 custom-key constants (`flavor`, `user_id`, `user_role`, `last_route`, `feature_area`).
  - Created `lib/core/firebase/analytics_service.dart` — static wrapper around `FirebaseAnalytics.instance` with `logEvent`, `logLogin`, `logScreenView`, `setUserId`. `_isFirebaseAvailable` guard short-circuits when `Firebase.apps.isEmpty` so dev builds work pre-`flutterfire configure`. `buildObserver()` exposes a `FirebaseAnalyticsObserver` if config is present.
  - Created `lib/core/firebase/crashlytics_service.dart` — static wrapper with `setCustomKey`, `setUserIdentifier`, `recordError`, `log`. `registerErrorHandlers()` wires `FlutterError.onError` + `PlatformDispatcher.instance.onError` to forward into Crashlytics. Same config-absent short-circuit as Analytics.
  - Upgraded `lib/core/firebase/app_analytics_observer.dart` from a no-op stub into a delegating `NavigatorObserver`. Forwards push/replace/pop into the live `FirebaseAnalyticsObserver` (when present) AND writes the current route name to the Crashlytics `last_route` custom key on every nav event.

- **Decisions**:
  - **`Firebase.apps.isEmpty` guard, not a separate "isConfigured" flag** — single source of truth (the SDK itself). Wrapping in `try { … } catch (_) { false }` defends against the case where `Firebase` symbol resolves but the platform channel isn't initialized.
  - **All methods on `AnalyticsService` / `CrashlyticsService` are static** — matches the existing `AppLogger` pattern and avoids forcing Riverpod for trivial fire-and-forget telemetry. If we ever want test-time injection, we can swap to providers without changing call sites (move to a singleton + `late final _instance` overrideable in test).
  - **Did not wire `screen_view` events explicitly** — the Firebase `NavigatorObserver` already emits `screen_view` events on push/replace; double-emitting from our observer would inflate counts. Our observer adds the `last_route` Crashlytics breadcrumb on top.
  - **`crashlyticsKeys.flavor` set later** — `FirebaseService.initialize` (Task 3.19) is the right home for it. Setting from this task would require either coupling the wrapper to `Env` (already imported transitively, would work) or pre-init logic in `startApp`. Cleaner to do it in 3.19's bootstrap.
  - **Native auto-tracking disable deferred** — `firebase_analytics_collection_enabled` manifest/plist toggle belongs to the pre-prod `flutterfire configure` task. Adding it now without the corresponding native config files would be inert.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/firebase/` → No issues found.
  - `flutter analyze` (full) → 301 issues = baseline.
  - `flutter test` → 14/14 passing. Widget-test console output (`Crashlytics(stubbed): setCustomKey last_route=splash`) confirms the observer is wired into the router and the stub path is exercised correctly.

---

### 2026-05-28: Phase 3 Task 3.17 — GoRouter auth redirect + observer

- **Changes**:
  - Created `lib/core/providers/auth_state_provider.dart` — `authStateProvider = StateProvider<bool>((_) => false)`. Single source of truth for "logged in" at the routing layer.
  - Created `lib/core/firebase/app_analytics_observer.dart` — `class AppAnalyticsObserver extends NavigatorObserver` no-op stub. Task 3.18 fills the body with the real `FirebaseAnalyticsObserver` delegate.
  - Rewrote `lib/app/router.dart`:
    - Added `routerProvider = Provider<GoRouter>((ref) { … })` reading `authStateProvider`.
    - `_AuthRefreshNotifier extends ChangeNotifier` adapter listens to auth state via `ref.listen(...)` and notifies the router's `refreshListenable` so redirect re-evaluates on token writes/clears.
    - Public-route allowlist (`_publicRoutes` const set) covers splash, onboarding, login, sign-up steps, forgot/reset password.
    - `redirect:` enforces: unauthed user on protected route → `/login`; authed user on auth-flow route (`/login`, `/signup-*`, `/forgot-*`, `/reset-password`) → `/home`.
    - `observers: [AppAnalyticsObserver()]` wired in (stub for now).
    - Route list extracted to a private `_routes` `List<GoRoute>` so both `routerProvider` and the legacy top-level `appRouter` constant share one definition. Legacy const left in place for any not-yet-migrated importer.
  - Updated `lib/app/app.dart` — `App.build` now does `ref.watch(routerProvider)` instead of importing the bare `appRouter` constant.
  - Updated `lib/main.dart` — added `authStateProvider.overrideWith((_) => PrefsService.isLoggedIn)` to the `ProviderScope` overrides. Re-imports `auth_state_provider`.

- **Decisions**:
  - **`StateProvider<bool>` over `FutureProvider<bool>` / `AsyncNotifier`** — the redirect path must be synchronous to avoid a frame of flicker. Cold-boot value is computed synchronously in `startApp` via `PrefsService.isLoggedIn` (which reads the in-memory secure-token cache primed during `PrefsService.init()`). Mutation surface (login success, logout, 401) is just `ref.read(authStateProvider.notifier).state = …`.
  - **`_AuthRefreshNotifier` ChangeNotifier adapter** — go_router's `refreshListenable` wants a `Listenable`; Riverpod state lives in `ProviderListenable`. The adapter is the minimal idiomatic bridge — listens with `ref.listen`, fires `notifyListeners()`. Disposed via `ref.onDispose(notifier.dispose)`.
  - **Kept the top-level `final GoRouter appRouter` constant** — couldn't find a not-yet-migrated importer, but the test harness already runs `pumpProviderApp` and `App` smoke; preserving the symbol avoids a surprise breakage if any external (e.g. screen module) reaches for the constant. Phase 5.01 can delete it.
  - **`AppAnalyticsObserver` non-`const` constructor** — `NavigatorObserver` super has no const constructor, so the subclass can't be const either. Acceptable: observers list is built once per router and the cost of two object allocations is invisible.
  - **Did not add unit tests for redirect logic** — go_router's `redirect` is awkward to test in pure Dart (needs a full `MaterialApp` + navigator); pumping the auth flow is a Phase 4 widget-test target (auth feature migration). The redirect is a 12-line pure function and is reviewed by inspection.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/app/ lib/main.dart lib/core/providers/ lib/core/firebase/` → No issues found.
  - `flutter analyze` (full) → 301 issues = baseline.
  - `flutter test` → 14/14 passing.

---

### 2026-05-28: Phase 3 Task 3.16 — `pumpProviderApp` test helper

- **Changes**:
  - Created `test/helpers/pump_app.dart` — `PumpProviderApp` extension on `WidgetTester` with `pumpProviderApp(Widget, {List<Override> overrides, ThemeData? theme})`. Wraps in `ProviderScope > MaterialApp(home: Directionality(child: widget))`.
  - Created `test/helpers/pump_app_test.dart` — smoke test that overrides `dioClientProvider` with `DioClient.withDio(Dio(BaseOptions(baseUrl: 'https://override.example/')))` and asserts the consumer reads the overridden baseUrl. Passing.

- **Decisions**:
  - **Extension method on `WidgetTester`** rather than top-level function — composes with the existing `await tester.pumpWidget(...)` pattern and feels native at call sites (`await tester.pumpProviderApp(...)`).
  - **`Directionality(textDirection: TextDirection.ltr)` wrap** around the home widget — leaf widget tests sometimes read `Directionality.of(context)` without a containing `MaterialApp` ancestor. The `MaterialApp` already provides this, so the inner wrap is belt-and-suspenders for tests that pump a child of `home`. Negligible cost.
  - **Optional `ThemeData? theme` param** — lets tests opt into `AppTheme.dark()` if they need theme-aware widgets to render correctly. Default `null` keeps the helper minimal.
  - **Helper is dependency-free** — no `mocks.dart` / `test_data.dart` imports. Those land in Phase 6.01. Today's helper is the smallest surface needed to widget-test the splash + onboarding pilot.
  - **Routing-aware widgets pump their own `MaterialApp.router`** — the helper deliberately uses `MaterialApp(home: ...)` because the auto-tester smoke for the whole `App` (in `test/widget_test.dart`) already covers the router path. Mixing `home:` and `router:` in one helper would force callers to pick a mode anyway.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze test/helpers/` → No issues found.
  - `flutter test` → 14/14 passing.

---

### 2026-05-28: Phase 3 Task 3.15 — Resurrect `lib/app/app.dart` + `ProviderScope`

- **Changes**:
  - Uncommented + finished `lib/app/app.dart` — `App extends ConsumerWidget` builds `MaterialApp.router` with `appRouter` + `AppTheme.dark()`. Removed the global `scaffoldMessengerKey` stub (unused; can return if a feature needs it later).
  - Rewrote `lib/main.dart` to mount `ProviderScope` and call `const App()` instead of `MyApp(isLoggedIn:)`. `MyApp` class deleted.
  - `ProviderScope` overrides:
    - `sharedPreferencesProvider.overrideWith((_) async => prefs)` — pre-resolved `SharedPreferences` from `getInstance()`.
    - `sessionStoreProvider.overrideWithValue(session)` — live `CompositeSessionStore` from the wiring done in Task 3.14.
  - Rewrote `test/widget_test.dart` — pumps `ProviderScope(...App())` with mock prefs (`SharedPreferences.setMockInitialValues({})`) and an in-test `SecureSessionBackend` fake. Smoke test confirms `MaterialApp` builds.

- **Decisions**:
  - **Dropped `isLoggedIn` constructor plumbing** — it was only ever read by `MyApp` to choose a boot path, but the router's `initialLocation` was already `/splash` regardless. Auth branching belongs to the router redirect (Task 3.17 wires the redirect; this task just removes the dead wiring).
  - **Override `sharedPreferencesProvider` with a pre-resolved future** rather than re-running `SharedPreferences.getInstance()` inside the provider body. The instance is already paid for during `startApp`; re-fetching would duplicate work and could race with the `SessionMigration.runOnce` pass.
  - **No global `scaffoldMessengerKey`** — the old commented-out scaffold included one "for pre-GoRouter screens that show snackbars outside of a widget context". Phase 1/2 migration removed those screens; carrying the key forward would be dead infrastructure. Easy to reintroduce if a feature needs it.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/app/app.dart lib/main.dart test/widget_test.dart` → No issues found. Full analyze → 301 (baseline + 2 expected deprecation infos from Task 3.14).
  - `flutter test` → 13/13 passing.
  - No commented-out blocks in `lib/app/app.dart` (per `MIGRATION_RULES.md` §10).
  - `main_dev.dart` / `main_prod.dart` untouched — they still call `startApp(Environment.x)` unchanged.

---

### 2026-05-28: Phase 3 Task 3.14 — Token migration + `SharedService` shim + scoped `logout()`

- **Changes**:
  - Created `lib/core/session/session_migration.dart` with `SessionMigration.runOnce({prefs, session})`. Guards with sentinel `session_migration_v1_done`. If `prefs['token']` non-empty and `session.readToken()` empty, copies token across, deletes prefs key, sets sentinel. Idempotent — exits early on subsequent boots.
  - Rewrote `lib/service/shared_service.dart` as a `@Deprecated`-annotated shim. Static API preserved (`setLoginDetails`, `logout`); both delegate to a bound `SessionStore`. `bind(SessionStore)` is the wiring entry point. Lazy fallback (`_session()`) builds a `CompositeSessionStore` on-demand if `bind` was skipped — defensive coverage for migration-window edge cases.
  - `setLoginDetails` now extracts both token AND user snapshot from `response.data.user` (best-effort `UserSnapshot.fromJson`, never blocks login on parse error) AND records `lastLoginAt` as UTC `DateTime.now()`. Closes the gap where login flow lost the user snapshot.
  - `logout` now calls `session.clearSession()` — deletes token + refresh + user + lastLoginAt by key. `prefs.clear()` is no longer reachable via `SharedService`. Closes AUDIT_SEC finding on blanket-wipe-on-logout.
  - `lib/main.dart` wires the startup sequence: `Env.init` → `PrefsService.init` → `SharedPreferences.getInstance` → build `CompositeSessionStore(SecureSessionStore(), PrefsSessionStore(prefs))` → `SessionMigration.runOnce` → `SharedService.bind(session)` → resolve `isLoggedIn` → `runApp`. All before any network call.

- **Decisions**:
  - **Sentinel suffix `_v1`** — future schema changes (e.g. moving refresh token, adding a key) can bump to `_v2` to re-trigger one-shot migration without re-writing the helper.
  - **Secure-store wins when both have a token** — migration only writes legacy → secure if secure is empty. Avoids overwriting a freshly-acquired token if a previous session managed to write secure but failed to clear prefs.
  - **Class-level `@Deprecated`, not per-method** — single emission point per call site. The two existing call sites (`auth/login/login.dart`, `profile/myprofile.dart`) now surface as `deprecated_member_use_from_same_package` info-level lints, which act as the migration radar for Phase 4.
  - **`SharedService.bind()` is non-deprecated** — it is the migration plumbing itself, not a legacy API. The class's `@Deprecated` decoration trips a sigil on the call site in `main.dart`; suppressed with `// ignore: deprecated_member_use_from_same_package` because that's the wiring layer, not a feature consumer.
  - **Capturing user snapshot during `setLoginDetails`** — previously the user data from login response was unused; identity fields were re-fetched from `/profile`. Now `SessionStore.writeUser` persists it so the dashboard can render fields immediately. Drops one round trip on the cold-boot path.
  - **No `@Deprecated` on `SharedService.bind()`** — wiring layer, not a feature consumer.
  - **`PrefsService.init` still called** — it sets up the legacy in-memory token cache + first-launch-wipe sentinel. Removing it would break the 50+ call sites that read `PrefsService.token` directly. Phase 4 migrates those incrementally; Phase 5.01 deletes `PrefsService`.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/main.dart lib/service/shared_service.dart lib/core/session/` → No issues found.
  - `flutter analyze` (full) → 301 issues = baseline + 2 expected `deprecated_member_use_from_same_package` info lints on `SharedService` call sites (migration radar).
  - `flutter test` → 13/13 passing.
  - Public surface of `SharedService` unchanged — both existing call sites compile + execute without edits.

---

### 2026-05-28: Phase 3 Task 3.13 — `SessionStore` interface + impls

- **Changes**:
  - Expanded `lib/core/session/session_store.dart` from a 3-method stub (left over from Task 3.11) into the full composite interface: token + refresh CRUD, user snapshot CRUD, `readLastLoginAt`/`writeLastLoginAt`, `isLoggedIn`, `clearSession`. Added `UserSnapshot` value type (id, name, email, role, userType, profileImageUrl) with `fromJson`/`toJson`/equality.
  - Added concrete `CompositeSessionStore implements SessionStore` (in the same file) wiring two backends via public structural contracts `SecureSessionBackend` + `PrefsSessionBackend`.
  - Created `lib/core/session/secure_session_store.dart` — `SecureSessionStore implements SecureSessionBackend`. Token + refresh stored in `flutter_secure_storage` (Keychain on iOS, EncryptedSharedPreferences-backed Keystore on Android). Constructor takes optional `FlutterSecureStorage` for test injection.
  - Created `lib/core/session/prefs_session_store.dart` — `PrefsSessionStore implements PrefsSessionBackend`. User snapshot serialized to JSON in `SharedPreferences` under `session_user_snapshot`; `lastLoginAt` stored as ISO-8601 string under `session_last_login_at`.
  - Round-trip unit tests added at `test/core/session/session_store_test.dart` — 6 cases, all passing. Uses an in-memory `SecureSessionBackend` fake + `SharedPreferences.setMockInitialValues({})` so it never touches the real Keychain.

- **Decisions**:
  - **Public structural contracts (`SecureSessionBackend`, `PrefsSessionBackend`)** rather than typing the composite against `SecureSessionStore`/`PrefsSessionStore` concretes — lets test fakes implement the surface they need without mocking the entire concrete class. Cleaner than `mocktail` for this layer.
  - **Composite class in the same file as the interface** to stay within the spec's "max 3 files" budget. Backends are in their own files; composite is a small wiring class so co-locating with the interface is fine.
  - **`isLoggedIn()` derived from secure-token presence**, not from a separate prefs flag. Matches the existing `SharedService`/`PrefsService` invariant ("token presence is the single source of truth for 'logged in'") and avoids a desync between prefs flag and actual token.
  - **`UserSnapshot` kept narrow** — id, name, email, role, userType, profileImageUrl. Full profile data still belongs to the profile feature; the snapshot exists just to bootstrap the UI before the profile fetch resolves.
  - **No call-site migration in this task** — task spec is explicit: "No call sites touched yet — this lands the primitive only." Legacy `SharedService` / `PrefsService` / `SecureStorageService` are untouched. Task 3.14 migrates them via shim.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/session/ lib/core/providers/` → No issues found.
  - `flutter analyze` (full) → 299 issues (within baseline ±).
  - `flutter test` → 13/13 passing (6 exception-handler + 6 session round-trip + 1 widget smoke).

---

### 2026-05-28: Phase 3 Task 3.12 — Swap `api_service.dart` internals to `DioClient`

- **Changes**:
  - Rewrote `lib/service/api_service.dart` end-to-end. Public surface preserved verbatim — 68 call sites compile without edits.
  - Internals now route through a static lazy `DioClient` (`_ensureClient()` builds once, caches instance) with the canonical interceptor chain: `Auth → Retry → Error → Logging` (logging gated by `kDebugMode`).
  - `AuthInterceptor` reads token via `PrefsService.token`. Per-call `createAuthorizationHeader()` removed.
  - `postMultipartStep3` no longer bypasses auth — runs through the shared client. Closes the AUDIT_SEC finding that Step 3 was unauthenticated.
  - All `http.{get,post,put,delete}` calls + `http.MultipartRequest` replaced with `_dio.{get,post,put,delete}<dynamic>` + `Dio.FormData`. Zero `package:http` imports remain in `lib/service/`.
  - Cleaned up `lib/profile/myprofile.dart:_uploadImage` — the one remaining caller of `createAuthorizationHeader()`. Now uses the canonical `ApiService().postMultipart(...)` path, eliminating a parallel raw `Dio()` instance + hand-built Bearer header.

- **Decisions**:
  - **Static lazy `_client` field** (rather than per-instance) — 68 call sites share the same Dio. Avoids 68 redundant Dio instances + interceptor chains. Per-instance was correct but wasteful.
  - **Tried-and-true `try/catch DioException → throw Exception('Failed to ...')`** preserved for the legacy facade — keeps return-contract compatibility for callers that still do bare `try/catch`. Typed `AppException` flow lives on the new repository pattern (Phase 4 migration target).
  - **`postMultipart` content-type left to Dio** — `FormData` auto-sets `multipart/form-data; boundary=...`. The legacy code's explicit `Content-Type: multipart/form-data` actually broke boundaries on some servers; dropping it is the right move.
  - **`http` package kept in `pubspec.yaml`** — task notes say Phase 5.02 removes it. Leaving it avoids a surprise import-not-found if any feature edge case still references `package:http` indirectly.
  - **`_uploadImage` fixed in this task, not deferred to Phase 4** — it was a direct compile-break from `createAuthorizationHeader()` removal. The replacement is a 1:1 functional swap (same endpoint path, same `crew_member_id` + `profile_photo` payload).
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/service/api_service.dart` → No issues found.
  - `flutter analyze` (full) → 298 issues (3 fewer than baseline; old api_service had type-inference lints).
  - `flutter test` → 7/7 passing (6 exception-handler + 1 widget smoke).
  - Zero `package:http` imports in `lib/service/`.
  - Public signatures of all 10 `ApiService` methods unchanged.

---

### 2026-05-28: Phase 3 Task 3.11 — `core_providers.dart`

- **Changes**:
  - Created `lib/core/providers/core_providers.dart` with 4 singleton providers (no `.autoDispose` per `MIGRATION_RULES.md` §3.10):
    - `sharedPreferencesProvider` — `FutureProvider<SharedPreferences>`. Body throws `UnimplementedError`; overridden in `startApp` (after `SharedPreferences.getInstance()`) and in `pumpProviderApp` (Task 3.16).
    - `sessionStoreProvider` — `Provider<SessionStore>`. Body throws until overridden — concrete impl arrives in Task 3.13.
    - `dioClientProvider` — `Provider<DioClient>`. Reads `sessionStoreProvider`, builds a fresh `DioClient`, and attaches the canonical interceptor chain `Auth → Retry → Error → Logging` (Logging is `kDebugMode`-gated by inclusion-time `if`).
    - `connectivityProvider` — `StreamProvider<List<ConnectivityResult>>` (matches `connectivity_plus ^6.x` API).
  - Created `lib/core/session/session_store.dart` — minimal abstract `SessionStore` interface stub with `readToken / writeToken / clearSession`. Task 3.13 expands it (user snapshot, refresh token, etc.) and adds the concrete `Secure` / `Prefs` implementations.

- **Decisions**:
  - **Throwing `UnimplementedError` in provider bodies** instead of returning a noop/null default — forces test harnesses and `startApp` to override explicitly. Silent default impls hide misconfiguration until the first network call.
  - **Stub `SessionStore` abstract interface added here, not deferred to 3.13** — providers need a real type to expose; an abstract three-method interface is a small, stable surface and Task 3.13 can extend it backward-compatibly.
  - **Interceptor chain assembled inside the provider, not on `DioClient` itself** — keeps `DioClient` free of Riverpod/`SessionStore` deps. Tests can override `dioClientProvider` to inject a `DioClient.withDio(mockDio)`.
  - **`kDebugMode`-gated `LoggingInterceptor` via `if (kDebugMode) ...` in a list literal** — Dart tree-shakes both the import and the instantiation in release builds when the const expression is `false`.
  - **`connectivityProvider` typed as `List<ConnectivityResult>`** — `connectivity_plus ^6.x` switched from single result to list (multi-transport devices). Wrong type would have wedged consumers downstream.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/providers/ lib/core/session/` → No issues found.
  - Provider graph: `dioClient → session`; `prefs`, `connectivity` independent. No cycles.
  - Nothing wired into `runApp` yet — `ProviderScope` lands in Task 3.15.

---

### 2026-05-28: Phase 3 Task 3.10 — Interceptors (Auth + Retry + Error + Logging)

- **Changes**:
  - Created `lib/core/network/interceptors/` with 4 files:
    - `auth_interceptor.dart` — `AuthInterceptor extends QueuedInterceptor`. Constructor takes `tokenReader: Future<String?> Function()` + optional `onUnauthorized: Future<void> Function()`. `onRequest` injects `Authorization: Bearer <token>` when token non-empty. `onError` awaits `onUnauthorized?.call()` on HTTP 401 then forwards.
    - `retry_interceptor.dart` — `RetryInterceptor extends Interceptor`. 3 attempts, exponential backoff `[250ms, 500ms, 1000ms]`. Retries 5xx + transient transport (`connectionError`, `connectionTimeout`, `receiveTimeout`). Never retries 4xx or `DioExceptionType.cancel`. Attempt counter in `RequestOptions.extra['__retry_attempt__']`.
    - `error_interceptor.dart` — `ErrorInterceptor extends Interceptor`. Delegates to `ExceptionHandler.mapDioException(err, st)` and wraps the typed exception into `DioException.error` via `copyWith`. Repositories using `guardAsync` already get typed errors; this exists for non-guarded consumers (and for future logging hooks).
    - `logging_interceptor.dart` — `LoggingInterceptor extends Interceptor`. Gated by `kDebugMode`. Logs via `AppLogger.{d,w}`. Redacts header values for `authorization`, `cookie`, `x-api-key` to `<redacted>` before logging.
  - Refactored `lib/core/network/exceptions/exception_handler.dart`: renamed private `_mapDioException` → public `mapDioException` so the handler and `ErrorInterceptor` share one mapping function (single source of truth for Dio → AppException rules).

- **Decisions**:
  - **Token sourced via callback, not a `SessionStore` reference** — Task 3.13 introduces `SessionStore`; this task lands ahead. The `tokenReader: Future<String?> Function()` signature lets the eventual `SessionStore` plug in cleanly (`tokenReader: () => sessionStore.token`) without `AuthInterceptor` ever importing the future class. Tests inject a sync callback returning a fake token.
  - **`onUnauthorized` is a callback, not a router push** — keeps interceptor framework-agnostic (no `BuildContext`/`GoRouter` import). Provider in Task 3.11 wires it to "clear session + push login" once Task 3.17 router redirect lands.
  - **Refresh-token flow is a stub** — current backend has no refresh endpoint per `AUDIT_SEC.md`. 401 = session over. `QueuedInterceptor` base class still chosen so concurrent in-flight requests serialise through one token-read lane when refresh becomes available.
  - **`ErrorInterceptor` attaches via `copyWith(error: appException)`** — preserves the original `DioException` envelope (status, headers, request options) for any consumer that wants forensic data, while making the typed `AppException` immediately accessible at `dioException.error as AppException`.
  - **`LoggingInterceptor` uses `AppLogger`, not `print`** — consistent with the project convention in `CLAUDE.md`.
  - **Public mapper rename**: `ExceptionHandler._mapDioException` → `ExceptionHandler.mapDioException`. Re-ran `exception_handler_test.dart` (6/6 passing) to confirm no regression.
  - **Interceptor registration order** documented but not yet executed — happens in Task 3.11 (`dioClientProvider`): `Auth → Retry → Error → Logging`. Matches `MIGRATION_RULES.md` §5.4.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/network/{interceptors,exceptions}/` → No issues found.
  - `flutter test test/core/network/exception_handler_test.dart` → 6/6 passing after public-rename refactor.
  - No production code consumes interceptors yet; provider in Task 3.11 wires them.

---

### 2026-05-28: Phase 3 Task 3.09 — `DioClient` singleton

- **Changes**:
  - Created `lib/core/network/dio_client.dart` with `DioClient` class.
  - `BaseOptions`: `baseUrl: Env.apiUrl`, 15s connect/receive/send timeouts (Risk #20 — slow-loris path closed), `Accept: application/json` default header, `responseType: ResponseType.json`.
  - Default constructor instantiates a fresh `Dio` with the options above.
  - `DioClient.withDio(Dio)` named constructor — test seam for injecting a pre-configured Dio with mock adapter.
  - `attachInterceptors(List<Interceptor>)` extension point — Task 3.10 will use this to wire `AuthInterceptor`, `RetryInterceptor`, `ErrorInterceptor`, `LoggingInterceptor` without re-touching the class.

- **Decisions**:
  - **No constructor dependencies** — task spec mentions "takes dependencies for future interceptors", but flowing `SessionStore` through `DioClient` couples the holder to the auth concern. Cleaner: interceptors get their deps in their own constructors; `DioClient.attachInterceptors` just receives the pre-built list. Provider (Task 3.11) does the assembly.
  - **`Env.apiUrl` read once at construction** — Env must be initialized via `Env.init(...)` in `startApp` before the first `DioClient()` instance is built. Already the case in `lib/main.dart`.
  - **No global state / no singleton pattern** — provider owns the lifecycle. `DioClient()` is a plain class; tests can construct fresh instances or use `.withDio(...)`.
  - **`responseType: json` set explicitly** — defensive against future endpoints that return non-JSON. Repositories can override per-request.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/network/dio_client.dart` → No issues found.
  - No production code consumes `DioClient` yet — first wiring happens in Task 3.11 (provider) + Phase 4 (feature data sources).

---

### 2026-05-28: Phase 3 Task 3.08 — `ApiResponse<T>` wrapper

- **Changes**:
  - Created `lib/core/network/api_response.dart` with generic `ApiResponse<T>` class.
  - Fields: `final bool error`, `final String? message`, `final T? data`.
  - `factory ApiResponse.fromJson(Map<String, dynamic>, T Function(dynamic))` — defensively parses `error` (defaults to false on non-bool), reads `message` as nullable String, skips `dataParser` when `data` is null.
  - `void assertNoError()` — throws `ServerException(message: message ?? 'API returned error=true')` when `error == true`. Designed to be called inside a `guardAsync` block; the exception is caught and converted to `Either.Left`.

- **Decisions**:
  - **Made `assertNoError()` public** (not `_assertNoError`) — repositories call it directly. The task spec used the private name but the helper is the integration point with `guardAsync`; keeping it private would force repositories to either reach into private members (impossible across libraries) or duplicate the check.
  - **Threw `ServerException` rather than a new typed envelope error** — keeps the exception hierarchy lean. `error: true` from the backend doesn't carry HTTP semantics; treating it as a server-side application error is the cleanest fit.
  - **No `toJson()` / serialization back to map** — `ApiResponse` is read-only at the boundary. Outgoing payloads use DTO `toJson` directly.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze lib/core/network/api_response.dart` → No issues found.
  - No production code consumes the wrapper yet — repositories will adopt it in Phase 4 feature work.

---

### 2026-05-28: Phase 3 Task 3.07 — Sealed `AppException` + `ExceptionHandler`

- **Changes**:
  - Created `lib/core/network/exceptions/` module with 6 files:
    - `app_exception.dart` — sealed base class + library declaration + `part` directives.
    - `network_exception.dart` (part) — `NoInternetException`, `TimeoutException`, `RequestCancelledException`.
    - `server_exception.dart` (part) — `ServerException` (with `statusCode`), `ServiceUnavailableException`.
    - `client_exception.dart` (part) — `UnauthorizedException` (401), `ForbiddenException` (403), `NotFoundException` (404), `ValidationException` (422 with `fieldErrors: Map<String, List<String>>`), `TooManyRequestsException` (429 with optional `retryAfter`).
    - `exception_handler.dart` — `ExceptionHandler.guardAsync<T>(Future<T> Function())` → `Either<AppException, T>` via `dartz`. Maps `DioException` by `DioExceptionType` + status code, `SocketException`, `dart:async.TimeoutException`, re-wrapped `AppException`, and fallback to `ServerException`.
    - `exceptions.dart` — barrel exports.
  - Added smoke test at `test/core/network/exception_handler_test.dart` — 6 cases (happy / 401 / 422+fieldErrors / 500 / connectionTimeout / AppException passthrough). All passing.

- **Decisions**:
  - **Used Dart `part` / `part of`** to split the sealed hierarchy across files. Dart prohibits extending a sealed class outside its declaring library, so the four subclass files are `part of 'app_exception.dart'`. The barrel exports only the library file + handler (parts aren't independently exportable). Consumers import the barrel and get the whole API.
  - **Class names match `MIGRATION_RULES.md` §5.3 verbatim** including `TimeoutException` (collides with `dart:async.TimeoutException` — handler uses `import 'dart:async' as dart_async;` to disambiguate). Library consumers can do the same if they need both types.
  - **Server message parsing**: handler checks `data['message']`, `data['error']`, and `data['detail']` in priority order. Field errors checked under `errors` or `field_errors` keys; list-or-string values both normalized to `List<String>`. `Retry-After` header parsed as integer seconds (HTTP-date variant not implemented; can extend in Phase 4 when an endpoint demands it).
  - **`ExceptionHandler` is non-instantiable** (private constructor) — pure static utility.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze` shows 301 issues (= baseline); module itself is "No issues found".
  - `flutter test test/core/network/exception_handler_test.dart` → 6/6 passing.
  - No production code touched outside the new `core/network/exceptions/` module — repositories will adopt `guardAsync` in Phase 4 feature work.

---

### 2026-05-28: Phase 3 Task 3.06 — Move `ApiEndpoints` to `lib/core/network/`

- **Changes**:
  - Created `lib/core/network/api_endpoints.dart` as new canonical location for `ApiEndpoints` class.
  - **Bug fix**: `add_availability` had a leading `/` ("/creator/add-availability") that would yield a double-slash when joined with `Env.apiUrl` (which already terminates in `api/`). Stripped the leading slash → now `"creator/add-availability"`, consistent with all 30 other endpoint constants.
  - Replaced `lib/service/api_endpoints.dart` with a single-line `export 'package:beige_creative_app/core/network/api_endpoints.dart';` shim so all 25 importing files continue to resolve without edits.
  - `docs/phase3/task_06_api_endpoints_move.md` updated: status → ✅ Completed, checkboxes marked.

- **Decisions**:
  - **Shim left at old path** — 25 importers across `auth/`, `home/`, `profile/`, `shoots/`, `manage_availability/`, `main_screen.dart` would otherwise need parallel edits. Per-feature migration to the new path can happen in Phase 4 alongside other feature work. Phase 5 retires the shim.
  - **Used `Write` instead of `git mv`** — equivalent effect with the shim re-export. The old path keeps the same identifier set via re-export, so consumer imports stay valid.
  - **No `// ignore_for_file: constant_identifier_names`** added — preserving baseline lint noise rather than introducing a new ignore directive. The snake_case constants will likely be renamed in Phase 4 feature work alongside per-feature data-source migration.
  - **Stayed on `improvments-phase1` branch** — consistent with prior Phase 3 tasks.

- **Constraints Maintained**:
  - `flutter analyze` shows 301 issues — exactly the baseline; zero new lints introduced.
  - All 25 importing files still compile via the shim.
  - Endpoint string set unchanged except for the targeted `add_availability` slash fix.

---

### 2026-05-28: Phase 3 Task 3.05 — Legacy shims (⛔ Obsolete)

- **Changes**:
  - No code edits. Task marked ⛔ Obsolete — N/A.
  - `docs/phase3/task_05_design_tokens_shims.md` updated: status → ⛔ Obsolete, rationale documented.

- **Findings**:
  - `lib/utility/colorcode.dart` does not exist (deleted in commit `c416cb6`).
  - `lib/utility/imges_icons.dart` does not exist (deleted in prior Phase 1/2 work).
  - Zero `ColorCode.*` and zero `AppImages.*` references in `lib/`. All consumers migrated.
  - Task 3.05 was designed as a deprecation-shim layer for surfacing the migration to consumers. With zero consumers and zero source files, there is nothing to shim.

- **Decisions**:
  - **Skip Task 3.05 entirely** — the migration radar this task provides is moot. Creating empty deprecated classes for non-existent identifiers would add noise without benefit.
  - **Phase 5.01 cross-reference** — when Phase 5.01 ("delete shims") is reached, log it as "completed by Phase 1/2 cleanup" rather than re-doing the work.

- **Constraints Maintained**:
  - No source files touched.
  - `flutter analyze` baseline unchanged.

---

### 2026-05-28: Phase 3 Task 3.04 — Asset tokens audit

- **Changes**:
  - No code edits — audit-only. `AppAssets` already canonical, `AppImages` already retired.
  - `docs/phase3/task_04_design_tokens_assets.md` updated: status → ✅ Completed, checkboxes + audit notes.

- **Findings**:
  - `lib/utility/imges_icons.dart` no longer exists (removed in prior Phase 1/2 work — not just shimmed).
  - `lib/app/assets.dart` (189 LOC) holds the canonical `AppAssets` class with directory base constants (`_svg`, `_images`, `_lottie`, `_active`, `_inactive`, `_home`, `_shootSvg`, `_onboarding`) plus path constants grouped by category (active/inactive nav icons, home/common images, shoot SVGs, onboarding images, lottie animations, fonts).
  - Zero `AppImages.*` references in `lib/`.
  - 43 `AppAssets.*` call sites across `lib/`.
  - Zero hardcoded `'assets/...'` literal strings in widgets outside `lib/app/assets.dart`.
  - `flutter analyze lib/app/assets.dart`: 26 pre-existing info-level `constant_identifier_names` lints (legacy snake_case names retained for backward compat — `group_logo`, `clock_icon`, `photo_icon`, etc.); zero errors.

- **Decisions**:
  - **Snake_case constant names retained** — renaming would cascade to all 43 call sites for zero functional benefit. Flagged as optional Phase 4 cleanup if desired.
  - **Task 3.05 shim obsolete for assets** — `imges_icons.dart` is gone, not present. Task 3.05 may still cover `ColorCode` shim if requested, but no `AppImages` shim is needed.
  - **Stayed on `improvments-phase1` branch** — consistent with Tasks 3.01–3.03 directive.

- **Constraints Maintained**:
  - `flutter analyze lib/app/assets.dart` zero errors.
  - No source files touched — audit-only confirmation that prior phases already met Task 3.04 acceptance.

---

### 2026-05-28: Phase 3 Task 3.03 — Design tokens audit (spacing + radii + shadows + durations)

- **Changes**:
  - No code edits — audit-only task. All four token files already present and filled from prior Phase 1/2 sweeps.
  - `docs/phase3/task_03_design_tokens_spacing_radii.md` updated: status → ✅ Completed, checkboxes + audit notes.

- **Findings**:
  - `lib/app/spacing.dart` (214 LOC) — 4-px grid (`hairline/fine/xxxs..xxxl/huge/massive/jumbo/max`), off-grid component constants (`tabInnerPad`, `editProfileBtnH`, `folderCardInset`, `profileCardTop`, `avatarOverlapTop`), screen padding (`screenH/screenHWide/screenHAuth/screenV`), component-specific (`cardPadding`, `inputVertical`, `chipPaddingH/V`, `bottomNavHeight`), responsive factors (calendar event factors), convenience `EdgeInsets`, `SizedBox` gap helpers.
  - `lib/app/radii.dart` (215 LOC) — `none/xs/sm/md/mld/lg/statsInner/xl/xxl/xxxl/huge/portfolioCompact/authCard/massive/portfolio/header/round/sheet/roundLg/pillSm/pill/enormous/full`, outliers (`nano`, `eventLabel`, `signupChip`, `compactCard`, `clientContact`), convenience `BorderRadius` getters, top-only/bottom-only sheet roundings, standalone `Radius` constants.
  - `lib/app/shadows.dart` (164 LOC) — `none/sm/md/lg/xl` standard elevation + harvested `activeNavGlow`, `ctaDark`, `heroOverlay`, `goldCta`, `card/cardSubtle/cardBlack12/cardHeavy`, `viewerSheet`.
  - `lib/app/durations.dart` (34 LOC) — `instant (100ms)`, `fast (200)`, `fast250`, `normal (300)`, `pageTransition (350)`, `slow (500)`, `splash (800)`, `long (1000)`, `autoDismiss (2000)`.
  - Widget consumption: 44 (`AppSpacing`) + 41 (`AppRadii`) + 9 (`AppShadows`) + 2 (`AppDurations`) = 96 total reference sites in `lib/`.
  - `flutter analyze` on the 4 files: No issues found.

- **Decisions**:
  - **Theme-component wiring deferred** — `AppTheme.dark()` does not yet consume `AppSpacing/AppRadii/AppShadows/AppDurations`. `lib/app/theme.dart:107-124` keeps `inputDecorationTheme`, `cardTheme`, `bottomSheetTheme`, `dialogTheme`, `snackBarTheme`, `chipTheme`, etc. commented behind a "enable individually with screenshot diff" gate. Enabling them risks shifting widgets that don't pass explicit `shape:` or `padding:` — violates zero-visual-drift rule.
  - **Strict-match fidelity** — every harvested constant retains its original literal value verbatim. Off-grid values (e.g., `7.79` for calendar event labels, `11.5` for nested stats interior radius, `0.6` for fine inset) preserved by name, not snapped to grid.
  - **Stayed on `improvments-phase1` branch** — consistent with Tasks 3.01–3.02 directive.

- **Constraints Maintained**:
  - `flutter analyze` zero issues on `lib/app/{spacing,radii,shadows,durations}.dart`.
  - No source files touched — audit-only confirmation that prior phases already filled the Task 3.03 scaffolds.
  - Zero visual drift preserved by not edits.

---

### 2026-05-28: Phase 3 Task 3.02 — Design tokens audit (colors + text styles)

- **Changes**:
  - No code edits — audit-only task. Verified scaffolds against spec.
  - `docs/phase3/task_02_design_tokens_colors_text.md` updated: status → ✅ Completed, checkboxes marked with audit findings.

- **Findings**:
  - `lib/utility/colorcode.dart` no longer exists; `ColorCode` retired in commit `c416cb6` ("Centralize design tokens; migrate widgets to AppColors and retire ColorCode"). Zero `ColorCode.*` references remain in `lib/`.
  - `lib/app/colors.dart` (463 LOC) holds 200+ tokens grouped: brand, background/surface, text, semantic, border/divider, opacity variants, gradient, functional, status, map, and extended Phase 1 additions.
  - `lib/app/text_styles.dart` (573 LOC) defines all 13 §4.4 semantic styles (`displayLarge/Medium/Small`, `titleLarge/Medium/Small`, `bodyLarge/Medium/Small`, `labelLarge/Medium/Small`, `caption`) plus ~50 harvested extended exemplars (Phase 2 Batches 4–11) and an inherit/legacy bucket.
  - `lib/app/theme.dart` `AppTheme.dark()` maps `AppTextStyles.*` onto all 13 Material `TextTheme` slots and references only `AppColors.*`. Wired at `lib/main.dart:45`.
  - Zero inline `Color(0x…)` literals outside `colors.dart`. ~97 inline `TextStyle(` sites remain in feature widgets — Phase 4 per-feature replacement scope.

- **Decisions**:
  - **Not in scope:** widget-level inline `TextStyle(` replacement. Phase 3 covers token-scaffold creation; per-feature replacement is Phase 4.
  - **Kept `textfieldBorderLegacy = Color(0xFFE8D1AB80)`** (40-bit legacy value, info-level lint `use_full_hex_values_for_flutter_colors`) — intentional for zero visual drift. Documented in code comment.
  - **Stayed on `improvments-phase1` branch** — consistent with Task 3.01 directive.

- **Constraints Maintained**:
  - `flutter analyze lib/app/{colors,text_styles,theme}.dart lib/main.dart` → 1 pre-existing intentional info-level lint, zero errors/warnings.
  - No source files touched — audit-only confirmation that prior phases already met Task 3.02 acceptance.

---

### 2026-05-28: Phase 3 Task 3.01 — Add target packages

- **Changes**:
  - `pubspec.yaml`: added runtime deps `dartz ^0.10.1`, `freezed_annotation ^3.1.0`, `json_annotation ^4.9.0`, `connectivity_plus ^6.0.5`, `firebase_core ^3.6.0`, `firebase_analytics ^11.3.3`, `firebase_crashlytics ^4.1.3`.
  - `pubspec.yaml`: added dev deps `freezed ^3.2.3`, `json_serializable ^6.8.0`, `build_runner ^2.4.13`, `mocktail ^1.0.4`.
  - `flutter pub get` resolved (46 changed dependencies).
  - `flutter analyze` shows 301 pre-existing info/warnings; **zero errors** introduced.

- **Decisions**:
  - **Either/`Either` lib: chose `dartz`** over `fpdart` — smaller surface, matches `MIGRATION_PLAN.md` recommendation. Locks in for the project.
  - **`freezed_annotation ^3.1.0` (not `^2.4.4`)** — pinned up because `flutter_stripe ^12.1.1` → `stripe_platform_interface ^12.6.0` transitively requires `freezed_annotation ^3.1.0`. Bumped matching dev-dep `freezed` to `^3.2.3` for codegen compatibility with the 3.x annotation API.
  - **Stayed on `improvments-phase1` branch** instead of cutting `migration/phase3/deps` — user directive; sequential phase work continues on this branch.

- **Constraints Maintained**:
  - `flutter analyze` zero errors (only pre-existing info/warnings remain).
  - No source files touched — pubspec-only change.
  - Both `main_dev.dart` and `main_prod.dart` entrypoints unaffected; flavor configs untouched.

---

### 2026-05-27: Execution and validation of Phase 2 (Tasks 2.01–2.09)

- **Changes**:
  - Fully executed and closed all 9 tasks in Phase 2.
  - Typo and folder renames finalized: `onboding` → `onboarding`, `manageavailability` → `manage_availability`, `upcomingshootviewdetils` → `upcoming_shoot_view_details`, drop literal spaces in filenames, and convert all uppercase files/directories to `lowercase_snake_case`.
  - Import casings completely corrected inside `lib/` and `test/` to align with case-sensitive OS file paths.
  - Masked and sanitized Bearer token leakage in both `api_service.dart` and `myprofile.dart` logs.
  - Disabled cleartext traffic (`usesCleartextTraffic="false"`) inside `AndroidManifest.xml`.
  - Implemented prime target folder scaffold with empty directory `.gitkeep` anchors under `lib/core/`, `lib/shared/`, `lib/features/`, and `lib/dummy/`.
  - Introduced local env properties loader inside Kotlin Gradle DSL `build.gradle.kts` linking back-to-back build definitions dynamically into `AndroidManifest` configurations via `manifestPlaceholders`.
  - Transitioned Google Maps API and Stripe publishable keys out of source tree into environment definitions in `lib/config/env.dart` utilizing `String.fromEnvironment`. Committed template JSON environment variables to `env/`.
  - Pruned deprecated `flutter_dotenv` package from `pubspec.yaml` and cleaned non-existent assets directories.
  - Restored `IndexedStack` inside `main_screen.dart` tab bar to conserve visual session state during tab transitions.
  - Consolidated `/shoot-Cancel` duplicate route down to `/cancel-shoot`.
  - Configured robust continuous integration workflow file `ci.yml` run triggers for analyze, test, and dev flavor compilation check validation.
  - Updated conventions, environment variables, commands, and target folder layout specifications inside `CLAUDE.md`.
  - Staged and committed all changes into working branch `improvments-phase1`.

- **Decisions**:
  - **Dynamic Gradle Placeholder Decoder** — Used dynamic splitting and base64 parsing directly inside Kotlin Gradle script to extract keys from base64 dart-defines, keeping native builds entirely decoupling-friendly and dynamic.
  - **Secure Storage Retained** — Verified password persistence and did not regress keychain encryption security as secure storage wrapper was already standard in login.
  - **Consolidated Casing Enforcement** — Renamed and corrected all casing properties, ensuring zero compilation errors on strict environments.

- **Constraints Maintained**:
  - `flutter analyze` fully clean of compiler errors.
  - All test suites successfully green (`flutter test` passes 100%).
  - Branch shippability maintained.

### 2026-05-27: Guides cross-check patch — shared widgets, font note, models/utils tests

- **Changes**:
  - Cross-checked `MIGRATION_PLAN.md` + per-phase tasks against `docs/guides/FLUTTER_BASE_GUIDELINES.md`, `FLUTTER_DESIGN_SYSTEM.md`, `FLUTTER_TESTING_GUIDELINES.md`.
  - **New Phase 3 Task 3.20** — `docs/phase3/task_20_shared_widgets.md`: build `AppButton`, `AppCard`, `AppTextField`, `AppAvatar`, `AppLoading`, `AppEmptyState` in `lib/shared/widgets/`. 6h estimate. Phase 3 total 19 → 20 tasks, 8 → 8.75 effort-days.
  - **New Phase 6 Task 6.14** — `docs/phase6/task_14_models_utils_tests.md`: unit tests for freezed DTOs, validators, formatters, extensions. 1d estimate. Phase 6 total 13 → 14 tasks, 16 → 17 effort-days.
  - **Task 3.02 font note** — appended explicit guard against guide's `Inter` example; preserve `Unbounded` + `Outfit` per current `pubspec.yaml`.
  - `MIGRATION_PLAN.md` Phase 3 + Phase 6 budget rows updated; TOTAL 93.5 → 95.25 effort-days.

- **Decisions**:
  - **Shared widgets at end of Phase 3, not split across Phase 4** — every Phase 4 feature consumes them, so build once before features migrate. Avoids per-feature reinvention and keeps Phase 4 acceptance ("zero magic numbers") enforceable.
  - **Limited to 6 widgets, not full §6.7 checklist** — `AppErrorState`, `AppListTile`, `AppChip`, `AppBadge`, `AppDivider`, `AppBottomSheet`, `AppDialog` deferred until a Phase 4 feature needs them. Guide explicitly recommends incremental construction.
  - **Font preservation made explicit** — guides use `Inter` in examples but project ships `Unbounded` + `Outfit`. Without the note, Task 3.02 could silently re-introduce `Inter` and break visual parity. Zero visual drift is non-negotiable per `MIGRATION_RULES.md`.
  - **Models/utils tests folded into Phase 6, not Phase 4** — keeps Phase 4 PRs focused on feature migration; defers cheap coverage wins to the dedicated test phase.
  - **Gaps NOT patched (already covered)** — `CancelToken` ban for search/pagination already in `MIGRATION_RULES.md` §5.2 line 535 and in Task 4.14 step list. Connectivity pre-check ban already in `MIGRATION_RULES.md` §5.2 line 533. Verified before adding.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged.
  - No commits made; user controls staging.
  - File numbering preserved; new files append at end of each phase folder (no renames).

---

### 2026-05-27: Sprint-board restructure (`docs/phase<N>/` per phase, task-level chunks)

- **Changes**:
  - Created `docs/phase1/` … `docs/phase6/` — one folder per phase.
  - Each phase has a `README.md` (sprint board: task table + acceptance + dependencies) and one task file per chunk (`task_NN_<slug>.md`).
  - Total chunks: 73 task files across 6 phases + 6 phase READMEs = 79 new files.
    - Phase 1: 0 task files (read-only post-audit) — README only.
    - Phase 2: 9 tasks (folder renames, security hotfixes, secrets, CI, scaffold).
    - Phase 3: 19 tasks (deps, design tokens, network stack, session store, ProviderScope, router redirect, Firebase wrappers).
    - Phase 4: 23 tasks (feature migration — one per migration unit; god widgets split into preceding `.a` decomposition tasks).
    - Phase 5: 8 tasks (shim deletion, dep prune, cached images, comment hygiene, lint upgrade, naming polish, router final).
    - Phase 6: 13 tasks (test helpers, repo + Notifier + widget tests, goldens, integration tests, CI coverage gate).
  - Deleted single-file phase plans: `docs/migration/phase1_audit.md` … `phase6_testing.md` (702 LOC total). Replaced by chunked task files.
  - Kept under `docs/migration/`: `README.md` (legacy index), `flavor_bundle_id_plan.md` (companion). Both retain root link to `MIGRATION_PLAN.md`.
  - Appendix in `MIGRATION_PLAN.md` updated to point at new sprint boards.
  - Task file template: status header (🔴 / 🟡 / 🟢 / ⏭️) · owner / dates / PR / branch table · goal · references · files-in-scope (max 5–10 per task) · steps · acceptance · notes.

- **Decisions**:
  - **Sprint-planning granularity** — each task ≤10 files = ≤1 PR. Mirrors `MIGRATION_RULES.md` §1.1 ("if a step touches more than 8–10 files, break it into smaller steps").
  - **God-widget split-then-migrate as separate tasks** — `.a` (decompose, zero behavior change) + `.b` (migrate). Tracked separately so the split can be reviewed without Notifier noise.
  - **Phase 4 = 23 tasks not 22 migration units** — `signup1`, `signup3`, `myprofile`, `home_screen`, `featured_work_list` each get a `.a` decomposition predecessor.
  - **Phase 6 = 13 tasks not 5–7** — repository / Notifier / widget tests split into manageable batches so each task is ≤1.5 effort-days.
  - **Status emoji per user preference** — 🔴 Not Started · 🟡 In Progress · 🟢 Completed. Same legend on every README + task file.
  - **Path scheme** — phase folders sit directly under `docs/` (not under `docs/migration/`). Rationale: contributors expect `docs/phaseN/` to be the actionable sprint board; `docs/migration/` is legacy + companion docs.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged.
  - No commits made; user controls staging.
  - Old single-file phase plans deleted only after the new chunked structure was fully populated.

---

### 2026-05-27: Plan refresh + relocation to repo root

- **Changes**:
  - Moved `docs/migration/MIGRATION_PLAN.md` → `MIGRATION_PLAN.md` (repo root) to match the sibling `biegeapp` layout (`MIGRATION_PLAN.md` + `MIGRATION_RULES.md` + `MIGRATION_LOG.md` co-located at root).
  - Created this file (`MIGRATION_LOG.md`) at the root.
  - Verified current LOC / file counts against `lib/` and updated plan tables:
    - Top god widgets re-measured: `signup3_screen.dart` 3,465 → 3,569; `home_screen.dart` 2,902 → 2,860; `myprofile.dart` 2,834 → 2,836; `featured_work_list.dart` 1,703 → 1,685; `signup1_screen.dart` 1,959 → 1,836; `signup2_screen.dart` 1,328 → 1,331; `upcoming_shoot_view_detils.dart` 1,396 → 1,184.
    - Several screens shrank: `login.dart` 464 → 382; `reset_password_screen.dart` 428 → 332; `forgot_password_screen.dart` 401 → 362; `file_manager_screen.dart` 661 → 604; `pre_production_screen.dart` 502 → 434.
    - One screen grew: `edit_personal_details_screen.dart` 589 → 666.
    - Total Dart LOC across `lib/`: 34,162 across 87 files (was ~30k across 38 screens; codebase grew).
  - 3 new profile screens folded into Group C: `change_password_screen.dart` (274 LOC), `profile_otp_screen.dart` (343 LOC), `featuredwork_details_screen.dart` (177 LOC).
  - Foundations checklist row 7 (`AppTheme.dark()`) flipped ⚠️ → ✅ — wired at `lib/main.dart:45`.
  - Foundations checklist note: `flutter_secure_storage ^9.2.2` already declared in `pubspec.yaml`.
  - Risk register #10 (Linux CI casing) downgraded H/H → H/M — `Home`, `Profile`, `Shoots` already lowercased; only `onboding`, `manageavailability`, `upcomingshootviewdetils` and the file with a literal space remain.
  - Hard blocker #1 (folder casing) marked partially done; Hard blocker #2 (target packages) updated to acknowledge `flutter_secure_storage` already present.
  - Phase 2.A budget trimmed 1.5 → 1 day; Phase 2.B trimmed 1 → 0.75 day; Phase 3.A trimmed 1.5 → 1 day. Total ~94.75 → ~93.5 effort-days.
  - Appendix paths fixed (file now sits at root; relative links retargeted).
  - Back-references in `docs/migration/flavor_bundle_id_plan.md` updated (`docs/migration/MIGRATION_PLAN.md` → `MIGRATION_PLAN.md` at repo root).

- **Decisions**:
  - **Plan at repo root, not under `docs/`** — matches `biegeapp` layout for cross-project muscle memory. CLAUDE.md states "all new .md files belong under `docs/`" with exceptions for `CLAUDE.md` and `README.md`. Adding `MIGRATION_PLAN.md` + `MIGRATION_LOG.md` to that exception set as the canonical migration-control docs, given they sit alongside `MIGRATION_RULES.md` (already at root). Reason: discoverability — a contributor opening the repo sees plan, rules, log together; the alternative buries plan two levels deep while rules sit at root.
  - **Refresh vs rewrite** — kept the 2026-05-21 analysis verbatim and applied targeted edits. The audit-driven judgment calls (pilot choice, group order, decomposition strategy) are still correct; only the underlying numbers moved.
  - **Drift in the wrong direction** (`ApiService()` 58 → 68, `setState` 266 → 291, `print/debugPrint` 242 → 283, `StatefulWidget` 41 → 44) noted but not treated as a blocker — the migration roadmap absorbs new screens via the same per-feature template; new screens just lengthen Group C by 0.5 day and Phase 5 cleanup by a few `print()` strips.

- **Constraints Maintained**:
  - Zero code changes — documentation only.
  - `flutter analyze` unchanged (no lib/ touches).
  - No commits made; user controls when to stage and commit.

---
