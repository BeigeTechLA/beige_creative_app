# Task 6.12 — Integration test: signup1 → 2 → 3 → success

**Phase:** 6 · **Status:** 🔴 Not Started · **Est:** 1d

| Field | Value |
|---|---|
| Owner | — |
| Branch | `migration/phase6/integration-signup` |

## Goal
End-to-end signup test across all 3 (or 4, post-decomp) screens. Asserts final submit body is correct + lands user on `/home`.

## Files in scope (max 2)
- `integration_test/signup_flow_test.dart`
- `integration_test/robots/signup_robot.dart`

## Steps
- [ ] Stub Dio for `auth/signup1`, `auth/signup2`, `auth/signup3-multipart` endpoints
- [ ] Robot drives each step including image picker mock + map picker mock
- [ ] Assert multipart body byte-identical to the characterization snapshot from Task 4.21

## Acceptance
- [ ] Integration test passes on emulator
- [ ] All 3 (or 4) screens traversed
- [ ] Final submit assertion green

## Notes
Largest integration test in the suite. Reuses the characterization snapshot from signup3 decomposition (Task 4.21) as the source of truth.
