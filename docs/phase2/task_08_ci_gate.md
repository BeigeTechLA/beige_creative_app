# Task 2.08 — CI gate

**Phase:** 2 · **Status:** 🔴 Not Started · **Est:** 3h

| Field | Value |
|---|---|
| Owner | — |
| Started | — |
| Completed | — |
| PR | — |
| Branch | `migration/phase2/ci` |

## Goal
Land a minimal CI workflow that fails any PR which breaks the build or analyzer. Make `test/widget_test.dart` compile so `flutter test` exits 0. Foundation for all later phases — Phase 5 will tighten with `--fatal-infos`.

## References
- [`../../MIGRATION_PLAN.md`](../../MIGRATION_PLAN.md) §2 Foundations row 24, 29; §5 Hard Blocker #4
- [`../audit/AUDIT_TEST.md`](../audit/AUDIT_TEST.md)
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §1.3, §9.2

## Files in scope (max 10)
- `test/widget_test.dart` — replace counter template with smoke test
- `.github/workflows/ci.yml` — new

## Steps
- [ ] Rewrite `widget_test.dart`: `await tester.pumpWidget(const MyApp(isLoggedIn: null)); expect(find.byType(MaterialApp), findsOneWidget);`
- [ ] Create `.github/workflows/ci.yml`:
  - trigger: pull_request, push to main
  - jobs on `ubuntu-latest`: `flutter pub get` → `flutter analyze` → `flutter test` → `flutter build apk --flavor dev -t lib/main_dev.dart --debug --dart-define-from-file=env/dev.example.json`
- [ ] Push branch + open PR → confirm green
- [ ] Document branch protection requirement (manual repo settings — out of repo scope)

## Acceptance
- [ ] `flutter test` returns 0 locally
- [ ] CI run completes green on a no-op PR
- [ ] CI fails if `flutter analyze` reports errors
- [ ] CI fails if `flutter test` fails

## Notes
Use `env/dev.example.json` (committed) so CI doesn't need real secrets. Real keys remain in `env/dev.json` locally only. `--fatal-infos` is deferred to Phase 5 — too noisy today (~190 info-level lints).
