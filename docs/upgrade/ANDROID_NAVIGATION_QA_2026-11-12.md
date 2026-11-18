# Android dev navigation check — 2026-11-12

Device: `emulator-5554`, Android 16 / API 36, arm64.
Command: `flutter run --no-pub --flavor dev --dart-define-from-file=env/dev.json -t lib/main_dev.dart -d emulator-5554`.
Firebase confirmed dev initialization. Current dev configuration uses
`https://mobile.beige.app/api/`. Initial installation failed for insufficient
storage; Flutter automatically uninstalled the old version and retried successfully.
App subsequently signed in with the available approved account.

## Live checks

| Flow exercised with emulator controls | Result |
|---|---|
| Dashboard, Shoots, File Manager, Messages bottom tabs | Open successfully |
| Shoots Request/Shoots tabs, filter sheet and dismissal | Open; completed list loads |
| Brand & Product #3052 → details → Android Back | Route/Back work; API fails, see finding below |
| Wedding #4596 → details, scroll → Android Back | Data loads and returns to Shoots |
| File Manager → booking_rach_#4786 → Post-Production → Edits → Revisions → Version1 → image preview | Opens successfully; Back returns through folder history |
| Messages | Empty state; no conversation for thread checks |
| Drawer → Meetings → Upcoming/Completed | Both open; completed meetings load |
| Drawer → Manage Availability → Add Availability → Back | Calendar/form open; returns without saving |
| Drawer → Affiliate | Data loads |
| Affiliate drawer → Profile → nested pages → Back | Returns to original Affiliate branch |
| Profile Details → Personal → Edit | Saved values load; location permission prompt dismissible; Back works |
| Profile Details → Professional → Edit | Saved values load; Back works |
| Featured Works → Add sheet → Back | Empty list and entry sheet open |
| Certificates → Add uploader chooser → Back | Screen/chooser open |
| Resume → Back | Opens and returns |
| App Preferences → Delete Account → OTP → success preview → Back | Dummy six-digit preview works; session remains signed in |
| Dashboard notification bell | No navigation; no tap handler in source |

## Findings

1. `GET /creator/project-details/3052` returns HTTP 400, `Invalid v4 shoot_type.`
   Screen displays “Failed to load project”, literal `null` values and default
   status/budget. Confirm backend contract/data and implement a proper error
   state. Wedding #4596 succeeds; this is not a universal routing failure.
2. Dashboard notification bell in `home_welcome_header.dart` is a
   Semantics/SizedBox/SVG with no handler. Its navigation is unimplemented.

## Verification and limits

- Targeted routing, redirects, page/analytics, shell and route-argument tests: **72 passed**.
- `flutter test --no-pub`: **756 passed**, exit 0.
- Host tests only; native integration entrypoints were not rerun.
- Login occurred during the session; logout, forgot-password/OTP, signup,
  guest/pending/rejected sessions and session expiry were not manually driven.
- No pending shoot for accept/decline/cancellation and no conversation for chat.
- External meeting joins/social links, file upload/share/download, camera/gallery,
  and live form submissions were not exercised. Payouts is hidden; password
  routes are not exposed by current Preferences.
- Deletion is intentionally UI-only. No iOS/physical-device QA claimed.

Broad navigation smoke, not certification of every route/state. App left signed
in on Dashboard with dev/debug runner attached. No app code changed.
