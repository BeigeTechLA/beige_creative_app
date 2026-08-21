# Design Tokens — Batch Execution Plan

> **Status:** **Superseded as of 2026-05-26** by `DESIGN_TOKENS_COMPLETION_PLAN.md`.
> Batches 11 and 12 were claimed Done here but the gate (with block-comment
> awareness) showed `home_screen.dart` and several other files still had
> active inline literals. The completion plan ran Phases A–E to finish the
> migration. Treat this file as a historical record of the batch ordering.
>
> **Created:** 2026-05-25
> **Companion:** `DESIGN_TOKENS_MIGRATION_PLAN.md`, `DESIGN_TOKENS_MIGRATION.md`, `DESIGN_TOKENS_RULES.md`, `DESIGN_TOKENS_COMPLETION_PLAN.md`
> **Goal (historical):** Finish design-token migration in traceable feature-wise batches with strict visual fidelity.

---

## Current Pending Scope

| Workstream | Remaining | Target |
|---|---:|---|
| Raw asset strings outside `lib/app/assets.dart` | 0 | 0 |
| Inline `TextStyle(` outside `lib/app/text_styles.dart` | 524 | 0 |
| Raw `EdgeInsets.*(N)` outside `lib/app/spacing.dart` | 308 | 0 |
| `Radius.circular(N)` in `BorderRadius.only/vertical` | 50 | Future/out of scope unless explicitly added |

Already done:

- `Color(0x...)` outside `lib/app/`: 0 matches.
- `Colors.X` outside `lib/app/`: 0 matches.
- `ColorCode.*` references in `lib/`: 0 matches.
- `main.dart` is wired to `AppTheme.dark()`.
- `BorderRadius.circular(N)` outside `lib/app/`: 0 matches.
- Inline `BoxShadow(` outside `lib/app/shadows.dart`: 0 matches.

---

## Execution Principles

1. Preserve visuals by using exact-match tokens. Do not round font sizes, weights, spacing, or dimensions during this migration.
2. Prefer existing `AppTextStyles`, `AppSpacing`, and `AppAssets` before adding new tokens.
3. Add new tokens only when an exact value or style does not already exist.
4. Keep each batch independently reviewable and reversible.
5. Run grep gates per batch before moving to the next batch.
6. Run `flutter analyze` after each batch. Do not run `flutter test` for this migration unless requested separately.

---

## Batch Overview

| Batch | Area | Main Work | Impact | Risk |
|---|---|---|---|---|
| 0 | Token readiness | Audit missing typography/spacing tokens before widget edits | Reduces repeated edits and token churn | Done |
| 1 | Asset cleanup | Replace active raw asset paths with `AppAssets`; remove dead commented asset paths | Finishes PR1 cleanup and removes asset registry drift | Done |
| 2 | Shared widgets | Migrate `lib/widgets/` TextStyle + EdgeInsets | Improves consistency across forms/dropdowns/calendar used by many screens | Done |
| 3 | Auth core | Migrate login, forgot password, reset password, OTP flows | Stabilizes high-traffic auth UI tokens | Done |
| 4 | Signup flow | Migrate signup step screens and auth view details | Large reduction in token debt; signup screens are dense | High |
| 5 | Profile account | Migrate profile OTP, password, delete account, preferences | Consolidates account-management UI | Medium |
| 6 | Profile details | Migrate `lib/Profile/profiledetils/` | Standardizes profile form spacing and text | Medium |
| 7 | Profile portfolio | Migrate my profile, featured work, certificates, resume | Biggest profile impact; removes many repeated styles | Done |
| 8 | File manager | Migrate file manager screens | Standardizes file cards, tabs, and detail sheets | Done |
| 9 | Shoots | Migrate shoots list/cancel/accepted screens | Standardizes shoot cards and status UI | Done |
| 10 | Availability | Migrate availability and calendar screens | Aligns scheduling UI tokens | Done |
| 11 | Home + shell | Migrate home dashboard and `main_screen.dart` | Large user-facing impact; keep isolated | Done |
| 12 | Remaining feature folders | Migrate shoot details, onboarding, messages | Clears remaining feature-level debt | Done |
| 13 | Final sweep | Repo-wide grep, import cleanup, doc updates | Confirms migration completion | Low |

---

## Batch 0 — Token Readiness

**Status:** Done.

**Files:**

- `lib/app/text_styles.dart`
- `lib/app/spacing.dart`
- `lib/app/assets.dart`

**Tasks:**

- Review existing `AppTextStyles` coverage for current font family, size, and weight combinations.
- Review existing `AppSpacing` coverage for all raw spacing values currently used.
- Decide naming convention for exact outlier tokens, for example `s7`, `s13`, or purpose-specific names when usage is repeated.
- Confirm `AppAssets` has constants for active raw asset paths.

**Impact:**

- Prevents each feature batch from inventing one-off names.
- Makes later widget edits mechanical and easier to review.

**Exit gate:**

- Token naming rules are clear before feature edits begin.

---

## Batch 1 — Raw Asset Cleanup

**Status:** Done.

**Files likely involved:**

- `lib/widgets/custom_dropdown_field.dart`
- `lib/file_manager/post_production_screen.dart`
- `lib/file_manager/pre_production_screen.dart`
- `lib/Profile/profile_otp_screen.dart`
- `lib/onboding/onboding_screen.dart`
- `lib/auth/sign_up/signup1_screen.dart`
- Additional files with commented raw asset strings

**Tasks:**

- Replace active `"assets/..."` and `'assets/...'` usages with `AppAssets` constants.
- Add missing constants to `lib/app/assets.dart` only for active assets.
- Remove commented-out raw asset strings where they are dead code.
- Keep behavioral asset loading unchanged.

**Impact:**

- Completes the remaining PR1 cleanup.
- Gives the app one canonical asset registry.

**Exit gate:**

```bash
rg -n "['\"]assets/" lib -g "*.dart" -g "!lib/app/assets.dart"
```

Expected result: 0 matches.

---

## Batch 2 — Shared Widgets

**Status:** Done.

**Files:**

- `lib/widgets/custom_text_field.dart`
- `lib/widgets/custom_dropdown_field.dart`
- `lib/widgets/custom_dropdown.dart`
- `lib/widgets/custom_multi_selectfield.dart`
- `lib/widgets/new_Textfield.dart`
- `lib/widgets/Topmessgae.dart`
- `lib/widgets/common_calendar.dart`

**Tasks:**

- Replace inline `TextStyle(` with `AppTextStyles`.
- Replace raw `EdgeInsets.*(...)` with `AppSpacing` tokens or insets.
- Add imports for `text_styles.dart` and `spacing.dart`.
- Remove unused imports after migration.

**Impact:**

- Shared form and calendar widgets stop creating new local styling patterns.
- Later feature batches become smaller because shared widgets already consume tokens.

**Exit gate:**

- No `TextStyle(` or raw numeric `EdgeInsets.*` matches remain in `lib/widgets/`.

---

## Batch 3 — Auth Core

**Status:** Done.

**Files:**

- `lib/auth/login/login.dart`
- `lib/auth/forgotpassword/forgot_password_screen.dart`
- `lib/auth/forgotpassword/forgot_password_otp_screen.dart`
- `lib/auth/resetpassword/reset_password_screen.dart`

**Tasks:**

- Migrate headings, helper text, CTA labels, field labels, and error text to `AppTextStyles`.
- Migrate auth card padding/margins to `AppSpacing` convenience insets where exact.
- Add exact tokens for auth-only spacing outliers.

**Impact:**

- Cleans the entry and recovery flows without touching the larger signup screens.
- Reduces duplicate auth typography.

**Exit gate:**

- Auth core files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 4 — Signup Flow

**Files:**

- `lib/auth/sign_up/signup1_screen.dart`
- `lib/auth/sign_up/signup2_screen.dart`
- `lib/auth/sign_up/signup3_screen.dart`
- `lib/auth/view_details_screen .dart`

**Tasks:**

- Migrate all inline text styles by exact font family, size, and weight.
- Migrate large signup card padding and repeated chip/tag spacing.
- Add exact text/spacing tokens only where the signup flow has repeated unmatched values.
- Watch for commented blocks and avoid spending time tokenizing dead code unless it is being retained.

**Impact:**

- Removes one of the largest remaining sources of typography and spacing debt.
- Makes signup screens easier to maintain in later UX work.

**Risk:**

- High. Signup files are large and include many repeated or commented patterns.

**Exit gate:**

- Signup/auth view detail files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 5 — Profile Account

**Files:**

- `lib/Profile/profile_otp_screen.dart`
- `lib/Profile/change_password_screen.dart`
- `lib/Profile/profile_new_passwrod_screen.dart`
- `lib/Profile/deleteaccount/delete_account.dart`
- `lib/Profile/deleteaccount/delete_account_otp_screen.dart`
- `lib/Profile/deleteaccount/delete_account_lottieScreen.dart`
- `lib/Profile/app_preferences.dart`

**Tasks:**

- Migrate account titles, descriptions, button labels, and dialogs to `AppTextStyles`.
- Migrate repeated page and card padding to `AppSpacing`.
- Keep delete-account and OTP screens visually unchanged.

**Impact:**

- Consolidates account-management styling.
- Reduces repeated profile/account UI patterns.

**Exit gate:**

- Profile account files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 6 — Profile Details

**Files:**

- `lib/Profile/profiledetils/enter_profile_details_screen.dart`
- `lib/Profile/profiledetils/edit_personal_details_screen.dart`
- `lib/Profile/profiledetils/profile_detils_1screen.dart`

**Tasks:**

- Migrate profile form labels, hints, section titles, and buttons.
- Replace form and sheet padding with exact `AppSpacing` tokens.
- Add form-specific text tokens only when they repeat across the three screens.

**Impact:**

- Gives profile forms a consistent token layer.
- Prepares these screens for future form component reuse.

**Exit gate:**

- Profile detail files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 7 — Profile Portfolio

**Status:** Done.

**Files:**

- `lib/Profile/myprofile.dart`
- `lib/Profile/featured_work_list.dart`
- `lib/Profile/featuredwork_details_screen.dart`
- `lib/Profile/certificates.dart`
- `lib/Profile/resume_screen.dart`
- `lib/Profile/myprofile_youre_all_set_screen.dart`

**Tasks:**

- Split this batch into two commits if needed: `myprofile` first, then portfolio/certificates/resume.
- Migrate profile cards, portfolio sections, sheet titles, and action labels to `AppTextStyles`.
- Migrate repeated card, sheet, and chip padding to `AppSpacing`.
- Avoid refactoring layout structure while replacing tokens.

**Impact:**

- Removes a large amount of repeated text and spacing code.
- Improves consistency across profile and portfolio surfaces.

**Risk:**

- High. `myprofile.dart` and `featured_work_list.dart` are large and user-facing.

**Exit gate:**

- Profile portfolio files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 8 — File Manager

**Status:** Done.

**Files:**

- `lib/file_manager/file_manager_screen.dart`
- `lib/file_manager/pre_production_screen.dart`
- `lib/file_manager/post_production_screen.dart`
- `lib/file_manager/view_details_screen.dart`

**Tasks:**

- Migrate file card titles, metadata, empty states, and detail labels.
- Replace list/card/sheet padding with `AppSpacing`.
- Confirm active asset references were already handled by Batch 1.

**Impact:**

- Standardizes repeated file-manager cards and detail screens.

**Exit gate:**

- File manager files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 9 — Shoots

**Status:** Done.

**Files:**

- `lib/shoots/shoots_screen.dart`
- `lib/shoots/shoot_cancelled_screen.dart`
- `lib/shoots/shoot_cancelled_lotties_screen.dart`
- `lib/shoots/shoot_request_accepted.dart`

**Tasks:**

- Migrate list titles, status text, filters, dialogs, and CTAs.
- Replace repeated card and filter padding with `AppSpacing`.
- Keep status colors untouched because color migration is already complete.

**Impact:**

- Makes shoot-list and status UI consistent with central text/spacing tokens.

**Exit gate:**

- Shoots files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 10 — Availability

**Status:** Done.

**Files:**

- `lib/manageavailability/add_availability_screen.dart`
- `lib/manageavailability/manage_availability_screen.dart`

**Tasks:**

- Migrate calendar labels, availability cards, legends, and actions.
- Replace calendar/card/form padding with exact spacing tokens.
- Keep calendar layout behavior unchanged.

**Impact:**

- Consolidates scheduling UI styles and makes future calendar work less fragile.

**Exit gate:**

- Availability files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 11 — Home And App Shell

**Files:**

- `lib/home/home_screen.dart`
- `lib/main_screen.dart`

**Tasks:**

- Migrate dashboard titles, stats, drawer/nav labels, filter text, and card text.
- Replace dashboard/card/nav padding with `AppSpacing`.
- Keep this batch isolated because these screens affect the most visible surfaces.

**Impact:**

- Removes major dashboard token debt.
- Improves consistency in the first screen after login and app navigation.

**Risk:**

- High. These files are large and central to daily app use.

**Exit gate:**

- Home and shell files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 12 — Remaining Feature Folders

**Status:** Done.

**Files:**

- `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart`
- `lib/onboding/onboding_screen.dart`
- `lib/messages/messages_screen.dart`

**Tasks:**

- Migrate remaining details, onboarding, and message text styles.
- Replace remaining spacing literals.
- Remove or migrate any leftover commented raw asset strings if Batch 1 did not cover them.

**Impact:**

- Clears the remaining feature-level token debt.

**Exit gate:**

- Remaining feature files have 0 inline `TextStyle(` and 0 raw numeric `EdgeInsets.*` matches.

---

## Batch 13 — Final Sweep

**Tasks:**

- Run repo-wide grep gates.
- Remove unused imports introduced during migration.
- Check for duplicated or unused new tokens.
- Update `DESIGN_TOKENS_MIGRATION_PLAN.md` status to complete only when all target gates pass.
- Add a short completion note to `DESIGN_TOKENS_MIGRATION.md` if useful.

**Impact:**

- Converts the migration from "feature-complete" to verifiably done.
- Leaves the docs aligned with the code.

**Exit gates:**

```bash
rg -n "TextStyle\(" lib -g "*.dart" -g "!lib/app/text_styles.dart"
rg -n "EdgeInsets\.(all|symmetric|only|fromLTRB)\([^)]*[0-9]" lib -g "*.dart" -g "!lib/app/spacing.dart"
rg -n "['\"]assets/" lib -g "*.dart" -g "!lib/app/assets.dart"
flutter analyze
```

Expected result:

- First three grep commands return 0 matches.
- `flutter analyze` has no new migration-caused warnings.

---

## Future Optional Batch — Radius.only / Radius.vertical

**Scope:**

- `Radius.circular(N)` inside `BorderRadius.only(...)`
- `Radius.circular(N)` inside `BorderRadius.vertical(...)`

**Current remaining:** 50 matches.

**Impact:**

- Completes radius migration beyond the original PR1 grep target.
- Makes partial-corner radii use `AppRadii` consistently.

**Reason to keep separate:**

- It was explicitly out of scope in the active migration plan.
- It may require adding more named `BorderRadius` helpers for top, bottom, and mixed-corner variants.

---

## Recommended Commit Order

1. `docs(tokens): add batch execution plan`
2. `chore(tokens): clean raw asset references`
3. `chore(tokens): migrate shared widgets to text and spacing tokens`
4. `chore(tokens): migrate auth core to text and spacing tokens`
5. `chore(tokens): migrate signup flow to text and spacing tokens`
6. `chore(tokens): migrate profile account screens to text and spacing tokens`
7. `chore(tokens): migrate profile details to text and spacing tokens`
8. `chore(tokens): migrate profile portfolio screens to text and spacing tokens`
9. `chore(tokens): migrate file manager to text and spacing tokens`
10. `chore(tokens): migrate shoots to text and spacing tokens`
11. `chore(tokens): migrate availability screens to text and spacing tokens`
12. `chore(tokens): migrate home and app shell to text and spacing tokens`
13. `chore(tokens): migrate remaining feature screens`
14. `docs(tokens): mark design token migration complete`
