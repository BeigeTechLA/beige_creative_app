# Design Tokens — PR Checklist & Rules

> **Status:** Phase 1 (token bridge active, widget migration in Phase 2)
> **Companion:** `DESIGN_IMPROVE_PHASE1.md` · `guides/FLUTTER_DESIGN_SYSTEM.md`

---

## Non-negotiable rules for new code

### Colors

- ❌ **Do NOT add new `Color(0xFF…)` literals** in widget code.
- ❌ **Do NOT add new `Colors.<name>`** references (Material defaults).
- ✅ Use `AppColors.<name>` from `lib/app/colors.dart`.
- If a colour you need does not exist in `AppColors`, **add it to `lib/app/colors.dart` first**, then reference it.

### Text styles

- ❌ **Do NOT use inline `TextStyle(…)`** in widgets.
- ❌ **Do NOT hard-code `fontFamily: 'Unbounded'`** or `'Outfit'` strings.
- ✅ Use `AppTextStyles.<name>` from `lib/app/text_styles.dart`.
- If you need a one-off variant, prefer `AppTextStyles.bodyMedium.copyWith(color: …)` over a fresh `TextStyle`.

### Spacing & padding

- ❌ **Do NOT use raw numeric padding/margin** (`EdgeInsets.all(16)`, `EdgeInsets.symmetric(horizontal: 20)`, etc.).
- ✅ Use `AppSpacing.<token>` from `lib/app/spacing.dart`.
- Compose with `EdgeInsets.all(AppSpacing.base)` or use the prebuilt convenience insets (`AppSpacing.screenPadding`, `AppSpacing.cardInsets`, etc.).

### Border radius

- ❌ **Do NOT use raw `BorderRadius.circular(12)`** or `Radius.circular(N)` with literal numbers.
- ✅ Use `AppRadii.<token>` from `lib/app/radii.dart` (e.g. `AppRadii.lgAll`, `AppRadii.fullAll`).

### Shadows

- ❌ **Do NOT write inline `BoxShadow(…)`** blocks.
- ✅ Use `AppShadows.sm | md | lg | xl` from `lib/app/shadows.dart`.

### Assets

- ❌ **Do NOT hard-code asset paths** like `'assets/images/foo.png'`.
- ✅ Use `AppAssets.<name>` from `lib/app/assets.dart`.

---

## PR review checklist

Before merging any PR touching `lib/`, the reviewer must confirm:

- [ ] No new `Color(0xFF…)` in widget files (allowed only in `lib/app/colors.dart`).
- [ ] No new `Colors.<name>` references outside the token files.
- [ ] No new inline `TextStyle(…)` constructors outside `lib/app/text_styles.dart`.
- [ ] No new raw `EdgeInsets.*(N)` with literal numbers.
- [ ] No new `BorderRadius.circular(N)` with literal numbers.
- [ ] No new `BoxShadow(…)` inline.
- [ ] No new `'assets/…'` string literals.

If a violation is necessary (legacy API, third-party widget integration, etc.), add a single-line comment explaining why and link to the PR / issue.

---

## Quick check — `./tool/check_design_tokens.sh`

The grep gates below are encapsulated in `tool/check_design_tokens.sh`. Run it locally before pushing — exits non-zero if any **locked** gate has a violation.

```bash
./tool/check_design_tokens.sh           # locked gates only (current default)
./tool/check_design_tokens.sh --strict  # also enforces pending gates (TextStyle, EdgeInsets, etc.)
```

Wire it into CI (`flutter analyze && ./tool/check_design_tokens.sh`) to block PR merges on regressions.

### Locked gates (must stay at 0)

| Gate | Pattern |
|---|---|
| `no-raw-color-literal` | `Color(0xFF…)` outside `lib/app/` |
| `no-material-colors` | `Colors.<name>` outside `lib/app/` |
| `no-colorcode` | `ColorCode.*` anywhere |
| `no-inline-box-shadow` | `BoxShadow(…)` outside `lib/app/shadows.dart` |
| `no-raw-asset-string` | `'assets/…'` outside `lib/app/assets.dart` |
| `no-raw-border-radius` | `BorderRadius.circular(N)` outside `lib/app/radii.dart` |
| `no-with-opacity` | `withOpacity(…)` anywhere (deprecated; use `withValues(alpha:)`) |

### Pending gates (enforced after Phases B + C land — `--strict`)

| Gate | Pattern |
|---|---|
| `no-inline-text-style` | `TextStyle(…)` outside `lib/app/text_styles.dart` |
| `no-raw-edge-insets` | `EdgeInsets.*(N)` outside `lib/app/spacing.dart` |
| `no-raw-font-family` | `fontFamily: "…"` outside `lib/app/` |
| `no-raw-radius-only` | `Radius.circular(N)` outside `lib/app/` |
| `no-raw-sized-box-literal` | `SizedBox(width/height: N)` outside `lib/app/` |
| `no-raw-duration` | `Duration(milliseconds/seconds: N)` outside `lib/app/durations.dart` |

---

## Why these rules exist

| Problem | Cost |
|---------|------|
| Inline `Color(0xFF…)` scattered across files | Theme changes require touching N files. Dark/light mode impossible. |
| Inline `TextStyle()` | Font family swaps mean 343+ edits. Inconsistent line heights. |
| Magic padding numbers | Rhythm breaks. New designers reinvent the scale. |
| Magic radius | Card corners drift; cards look subtly different. |
| Inline `BoxShadow` | Elevation inconsistency. |
| `withOpacity(…)` | Deprecated in Flutter 3.27+. Triggers analyzer warning; rounds alpha differently from `withValues(alpha:)`. |

Stopping new violations from landing is the cheap part — `./tool/check_design_tokens.sh` is the contract.

---

## Automated enforcement

| Rule | Tooling status |
|------|----------------|
| All locked gates | **Active** — `./tool/check_design_tokens.sh` (CI-ready, non-zero exit on violation) |
| Pending gates | **Reporting only** — same script with `--strict` enforces; will be promoted to locked after Phases B + C complete |
| `custom_lint` Dart plugin | Backlog — script is sufficient for now |

---

## Changelog

| Version | Date | Notes |
|---------|------|-------|
| 1.0 | 2026-05-23 | Initial rules + checklist |
| 1.1 | 2026-05-26 | Phase A: removed ColorCode rule (class deleted); added `no-with-opacity` locked gate; wired `tool/check_design_tokens.sh` for automated enforcement. |
| 1.2 | 2026-05-26 | Phases B + D + E closed. Four additional gates passing under `--strict`: `no-inline-text-style`, `no-raw-edge-insets`, `no-raw-font-family`, `no-raw-radius-only`. `no-raw-sized-box-literal` (377) and `no-raw-duration` (28) remain — Phase C deferred. |
