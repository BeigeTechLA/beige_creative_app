# Design Tokens — Status

> **Last updated:** 2026-05-26
> **Source of truth:** `lib/app/*.dart` (`colors`, `text_styles`, `spacing`,
> `radii`, `shadows`, `assets`, `durations`, `theme`).
> **Gate:** `./tool/check_design_tokens.sh` (CI-ready) or `--strict` to
> enforce pending categories too.

## Active gates (must stay at 0)

| Gate | Description |
|---|---|
| `no-raw-color-literal` | `Color(0xFF…)` outside `lib/app/` |
| `no-material-colors` | `Colors.<name>` outside `lib/app/` |
| `no-colorcode` | Legacy `ColorCode.*` (class removed) |
| `no-inline-box-shadow` | `BoxShadow(…)` outside `lib/app/shadows.dart` |
| `no-raw-asset-string` | `'assets/…'` outside `lib/app/assets.dart` |
| `no-raw-border-radius` | `BorderRadius.circular(N)` literal |
| `no-with-opacity` | Deprecated; use `withValues(alpha:)` or pre-baked alpha |
| `no-inline-text-style` | `TextStyle(…)` outside `lib/app/text_styles.dart` |
| `no-raw-edge-insets` | `EdgeInsets.*(N)` outside `lib/app/spacing.dart` |
| `no-raw-font-family` | `fontFamily: "…"` outside `lib/app/` |
| `no-raw-radius-only` | `Radius.circular(N)` outside `lib/app/` |

## Pending gates (Phase C — deferred)

| Gate | Count |
|---|---:|
| `no-raw-sized-box-literal` | 377 |
| `no-raw-duration` | 28 |

These will fail under `--strict`. The plan for closing them lives in
`DESIGN_TOKENS_COMPLETION_PLAN.md` → Phase C.

## Adding new tokens

- **Colour:** `lib/app/colors.dart` (`AppColors`)
- **Typography:** `lib/app/text_styles.dart` (`AppTextStyles`)
- **Spacing / SizedBox:** `lib/app/spacing.dart` (`AppSpacing`)
- **Radius:** `lib/app/radii.dart` (`AppRadii`)
- **Shadow:** `lib/app/shadows.dart` (`AppShadows`) — keep new entries `const`; use a pre-baked `AppColors.*` alpha constant rather than `withValues(alpha:)`
- **Duration:** `lib/app/durations.dart` (`AppDurations`)
- **Asset:** `lib/app/assets.dart` (`AppAssets`)
- **Theme defaults:** `lib/app/theme.dart` (`AppTheme.dark()` — wired into `MaterialApp.router` in `lib/main.dart`)

When introducing a new outlier value, prefer a semantic name tied to the
use site (`folderCardInset`, `editProfileBtnH`) over numeric names
(`s22`, `r15`) — see `DESIGN_TOKENS_COMPLETION_PLAN.md` Phase D.1 for the
rationale.
