# Task 4.20 — Group E · Unit 16.b · Migrate SignUp1 + SignUp2

**Phase:** 4 · **Group:** E · **Status:** 🟢 Completed · **Est:** 3d

| Field | Value |
|---|---|
| Owner | Claude Code |
| Branch | `improvments-phase1` |

## Goal
Migrate the post-split signup1 + the 1,331-LOC signup2 to Riverpod. signup2 carries 8 keys from signup1 via `state.extra` Map.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §3 Group E Unit 16

## Files in scope (max 8)
- `lib/features/auth/presentation/providers/signup_notifier.dart` + `_state.dart` (covers 1+2)
- `lib/features/auth/presentation/screens/signup1_screen.dart`
- `lib/features/auth/presentation/screens/signup2_screen.dart`
- All widgets from 4.19

## Steps
- [x] Single `SignupNotifier` (`NotifierProvider`, not auto-dispose) accumulates form data across both steps.
- [x] `state.extra` Map carries crewMemberId + frozen step-1 snapshot → step-2 → step-3.
- [x] Validation per step lives in the notifier (`submitStep1`, `submitStep2`).
- [x] Notifier tests for happy paths + each validation branch.

## Acceptance
- [x] No `setState` on business state. UI-only `setState` remains for: password visibility toggles, text-field-change rebuilds (controllers stay widget-owned per CLAUDE.md), and inside the lookup-sheet `StatefulBuilder`.
- [x] All `TextEditingController`s disposed in widget `dispose`. None leak.
- [x] Step 2 reads `state.crewMemberId` + frozen step-1 snapshot from the shared notifier and forwards to step 3 via `state.extra`.
- [x] `flutter analyze` → 92 issues (was 103, **−11**); zero new errors.

## Notes
Shared notifier survives signup3 — Task 4.22 extends `SignupNotifier` with `submitStep3` rather than introducing a new one. Roles/Skills lookup sheets share a single generic `showSignUp2LookupSheet` helper; signup3 should reuse it where its own checklists land.

Post-migration follow-up (2026-08-13): `is_registration_complete == 0` skips Step 1 because it represents completed account registration. Backend `is_step_2_complete` selects Step 2 (`0`/missing) or Step 3 (`1`). A dedicated process-only temporary auth session calls `POST creator/get-profile-detail`; Step 2 binds its saved roles, experience, hourly rate, bio, skills, and equipment while retaining lookup IDs for submission. Approved sessions remain persistent; pending/incomplete/rejected sessions do not survive process termination.
