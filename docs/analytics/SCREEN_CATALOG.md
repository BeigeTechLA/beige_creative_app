# Screen Catalog — Firebase Analytics

Auto-generated from `lib/app/routes.dart` `Routes.all` (Phase F, 2026-06-01).
Source of truth for analytics-team dashboards. Refresh whenever a route is
added, renamed, or its `trackScreenView` flag changes.

## How screens are logged

- `PageRoute` pushes / replaces / pops are picked up by
  `AppAnalyticsObserver` → `FirebaseAnalyticsObserver`. `screen_name` = the
  value in the **Name** column below.
- Routes with `Track` = ⛔ skip `screen_view` (Crashlytics breadcrumb still
  records).
- Shell-branch switches (Home ↔ Shoots ↔ Files ↔ Messages ↔ Manage
  Availability) are logged explicitly by `AppShell._goBranch` because the
  root Navigator doesn't see them.
- Dialogs / bottom sheets (`showDialog` / `showModalBottomSheet`) are **not**
  observed. Call `AnalyticsService.logScreenView` manually if a modal
  matters for funnels.

## Catalog (38 routes)

| # | Name (`screen_name`) | Path | Public | Track |
|---|---|---|---|---|
| 1 | `splash` | `/splash` | ✅ | ⛔ |
| 2 | `onboarding` | `/onboarding` | ✅ | ✅ |
| 3 | `login` | `/login` | ✅ | ✅ |
| 4 | `signup_step_1` | `/signup-step-1` | ✅ | ✅ |
| 5 | `signup_step_2` | `/signup-step-2` | ✅ | ✅ |
| 6 | `signup_step_3` | `/signup-step-3` | ✅ | ✅ |
| 7 | `forgot_password` | `/forgot-password` | ✅ | ✅ |
| 8 | `forgot_otp` | `/forgot-otp` | ✅ | ✅ |
| 9 | `reset_password` | `/reset-password` | ✅ | ✅ |
| 10 | `view_details` | `/view-details` | ✅ | ✅ |
| 11 | `home` | `/home` | — | ✅ |
| 12 | `shoots` | `/shoots` | — | ✅ |
| 13 | `files` | `/files` | — | ✅ |
| 14 | `messages` | `/messages` | — | ✅ |
| 15 | `manage_availability` | `/manage-availability` | — | ✅ |
| 16 | `my_profile` | `/my-profile` | — | ✅ |
| 17 | `edit_personal_details` | `/edit-personal-details` | — | ✅ |
| 18 | `enter_professional_details` | `/enter-professional-details` | — | ✅ |
| 19 | `profile_details` | `/profile-details` | — | ✅ |
| 20 | `featured_works` | `/featured-works` | — | ✅ |
| 21 | `featured_work_details` | `/featured-work-details` | — | ✅ |
| 22 | `certificates` | `/certificates` | — | ✅ |
| 23 | `resume` | `/resume` | — | ✅ |
| 24 | `app_preferences` | `/app-preferences` | — | ✅ |
| 25 | `change_password` | `/change-password` | — | ✅ |
| 26 | `profile_otp` | `/profile-otp` | — | ✅ |
| 27 | `new_password` | `/new-password` | — | ✅ |
| 28 | `profile_password_success` | `/profile-password-success` | — | ⛔ |
| 29 | `delete_account` | `/delete-account` | — | ✅ |
| 30 | `delete_account_otp` | `/delete-account-otp` | — | ✅ |
| 31 | `delete_account_success` | `/delete-account-success` | — | ⛔ |
| 32 | `upcoming_shoot_details` | `/upcoming-shoot-details` | — | ✅ |
| 33 | `cancel_shoot` | `/cancel-shoot` | — | ✅ |
| 34 | `shoot_cancelotties` | `/shoot-cancelotties` | — | ⛔ |
| 35 | `add_availability` | `/add-availability` | — | ✅ |
| 36 | `post_production` | `/post-production` | — | ✅ |
| 37 | `pre_production` | `/pre-production` | — | ✅ |
| 38 | `file_viewer` | `/file-viewer` | — | ✅ |

### Opt-outs (`trackScreenView: false`)

| Route | Reason |
|---|---|
| `splash` | Transient — every cold start hits it, dwarfs all other surfaces. |
| `profile_password_success` | Momentary success screen, 3 s before delayed `goNamed(login)`. Skews change-password funnel. |
| `delete_account_success` | Same pattern — lottie + delayed redirect. |
| `shoot_cancelotties` | Cancel-shoot lottie + delayed redirect. Same logic. |

### Migration from kebab → snake

Pre-Phase-A names were kebab-case (`signup-step-1`). Phase A (commit
`98b2196`) renamed all names to snake_case so Firebase Analytics
dashboards can group across the BIEGE crew + client apps consistently.
Paths stay kebab (URL-safe, dashboard-stable).

If any existing dashboard / funnel is keyed on `screen_name == "signup-step-1"`
(kebab), it will stop receiving data when this catalog ships. Coordinate
with analytics owner before merge — options:

1. Rename dashboard widgets to use the new snake names (preferred).
2. Add a BigQuery view that aliases old → new for legacy reports.
