# Task 6.04 — Notifier tests: auth + profile

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1.5d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/notifier-auth-profile` |

## Goal
Unit tests for auth + profile Notifiers. State transitions on each action — happy, validation error, server error.

## References
- [`../../MIGRATION_RULES.md`](../../MIGRATION_RULES.md) §9.3 Riverpod-Specific Testing

## Files in scope (max 8)
- `test/features/auth/presentation/providers/login_notifier_test.dart`
- `test/features/auth/presentation/providers/signup_notifier_test.dart`
- `test/features/auth/presentation/providers/signup3_*_notifier_test.dart` (one per sub-screen Notifier)
- `test/features/auth/presentation/providers/forgot_password_notifier_test.dart`
- `test/features/profile/presentation/providers/my_profile_notifier_test.dart`
- `test/features/profile/presentation/providers/featured_work_notifier_test.dart`
- `test/features/profile/presentation/providers/delete_account_notifier_test.dart`

## Steps
- [ ] `ProviderContainer` per test with `mockRepoProvider` override
- [ ] Assert state transitions after `await notifier.method()`
- [ ] AAA + ≥3 cases per public method

## Acceptance
- [ ] All test files pass
- [ ] Notifier coverage ≥ 80% on auth + profile
- [ ] No real API calls

## Notes
Pattern from `MIGRATION_RULES.md` §9.3 — copy verbatim and adapt per Notifier.
