# BEIGE Crew App — UI Design Audit

**Date:** 2026-11-05
**Reviewer:** Claude Code (mobile-app-design-mastery skill — Refactoring UI principles)
**Scope:** Overall app UI — design-token system, shared components, representative
feature screens (Home, Shoots, Login, Profile, Messages, auth flow).
**Branch:** `feature-flutter-upgrade`

This audit evaluates the *design* layer only (hierarchy, spacing, touch,
typography, color, depth, accessibility, consistency). It does not cover
business logic, networking, or state management.

---

## Executive Summary

The app has a **mature, well-documented design-token foundation** — centralized
`AppColors` / `AppTextStyles` / `AppSpacing` / `AppRadii` / `AppShadows` /
`AppDurations`, a canonical button / text-field / empty-state / loader, a
44dp touch-target helper (`AppIconTapTarget`), and a shared scaffold + toolbar.
That is well ahead of a typical Flutter codebase.

The gaps are in **consistency of adoption** and **accessibility**, not in the
system itself. The token system is bypassed in ~100+ spots, there are three
competing text-field widgets, global ripple feedback is disabled, dynamic
type / large-font scaling is unhandled, and semantic labels cover only ~16 of
45 screens. None are blockers; all are fixable incrementally.

### Priority tally

| Priority | Count | Theme |
|----------|-------|-------|
| 🔴 High | 5 | Touch feedback, touch-target gaps, dynamic type, image distortion, color sprawl diluting hierarchy |
| 🟡 Medium | 6 | Token-adoption leaks, duplicate input widgets, accessibility coverage, fixed heights, error color, brittle overlap layout |
| 🟢 Low | 6 | Spacing literals vs tokens, bottom-nav labels, divider spacing comments, SnackBar vs TopMessage, light-mode stub, debug creds in login |

---

## What's Working Well (keep doing this)

- **Token discipline is codified**, not just aspirational — each token file
  documents intent and use site. `AppColors`, `AppTextStyles`, `AppSpacing`,
  `AppRadii`, `AppShadows`, `AppDurations` all exist and are broadly used.
- **Canonical components exist**: `AppButton` (5 variants × 3 sizes),
  `AppCtaButton`, `AppEmptyState`, `AppCircularLoader`/`AppLoadingOverlay`,
  `AppMainToolbar`, `AppScaffold`, `AppSegmentedControl`, `AppCountCard`.
- **`AppIconTapTarget` enforces a 44×44 hit area + `Semantics(button:true)`** —
  the right primitive exists; it just needs wider adoption.
- **Type scale is sensible**: Unbounded for display/titles, Outfit for body —
  clear two-family system with a real scale (10 → 32).
- **Empty states are specific** ("No Shoot Available" + guidance copy), not
  generic "No data". Matches the skill's guidance.
- **Spacing is on a 4px grid** with named tokens and pre-built `SizedBox` gaps.
- **Safe-area handling is centralized** in `AppScaffold` with explicit opt-outs.

---

## 🔴 High Priority

### H1 — Global ripple/press feedback is disabled app-wide

**Where:** `lib/app/theme.dart:50-73` — `splashFactory: NoSplash.splashFactory`,
`splashColor/highlightColor/hoverColor = transparent`, plus the same override
on every button theme.

**Problem:** The skill's "Design for Touch" rule requires *visual feedback on
press* (ripple, scale, or opacity). Right now a tap produces no visual
acknowledgement anywhere. On a dark luxury theme this reads as "did my tap
register?" and hurts perceived responsiveness.

**Recommendation:** Replace the global kill-switch with a **subtle** custom
feedback — a low-opacity gold/white highlight (`AppColors.white10` /
`primary` at ~8%) via `InkWell(highlightColor:…, splashColor:…)` or a
press-scale wrapper. Keep it quiet to fit the brand, but make *something*
happen on every tappable surface.

---

### H2 — Many interactive targets are below the 44×44 minimum

**Where (examples):**
- `shoots_screen.dart:542` "View Details" is a bare `InkWell` on 12sp text.
- `shoots_screen.dart:265` chip close is `GestureDetector` → `Icon(size:16)`.
- `shoots_screen.dart:600-652` Accept/Decline buttons use `vertical: 8` padding
  → ~32dp tall, under the 44dp floor.
- ~30+ bare `GestureDetector`s wrapping small icons across `home_filter_sheet`,
  `featured_work_card`, `affiliate_code_section`, `signup3_sections`, etc.

**Problem:** iOS minimum is 44×44pt, Android 48×48dp. Sub-target controls raise
mis-tap rates, especially the destructive Decline action.

**Recommendation:** Route all icon-only / small-text actions through the
existing `AppIconTapTarget` (adoption is only 22 files today). For text buttons
and Accept/Decline, raise vertical padding so the hit box clears 44dp (visual
size can stay compact via transparent padding).

---

### H3 — Dynamic Type / large font scale is unhandled

**Where:** Only **one** `textScaler`/`textScaleFactor` reference in the entire
`lib/`. Fixed pixel heights are everywhere: button `height: 55` / `50`
(`app_cta_button.dart:51`, `login_screen.dart:249`), shoot card image `180`,
count-card strip `height: 76` (`shoots_screen.dart:148`), bottom nav `60`.

**Problem:** When a user bumps system font size, text grows but these fixed
boxes don't → clipped labels and `RenderFlex overflow`. Accessibility + App
Store review risk.

**Recommendation:** (a) Prefer min-height + intrinsic sizing over fixed
`height:` on anything containing text. (b) Clamp extreme scale app-wide via
`MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3)` at the `App` root so
layouts degrade gracefully instead of breaking. (c) Spot-check the count-card
strip and CTA buttons at 1.3× scale.

---

### H4 — Hero/header images use `BoxFit.fill` (distortion)

**Where:** `login_screen.dart:139`, plus `signup1/2/3_header.dart`,
`reset_password_screen.dart`, `forgot_password_screen.dart`,
`profile_header.dart`, `details_hero_header.dart` — 10 sites total.

**Problem:** `BoxFit.fill` stretches the source to the box aspect ratio,
visibly distorting the brand hero art across every entry-point screen (first
impression surfaces).

**Recommendation:** Switch to `BoxFit.cover` (fill the box, crop overflow, keep
aspect ratio). It's a near-mechanical find/replace on a known asset.

---

### H5 — Color palette sprawl dilutes the elevation/hierarchy system

**Where:** `lib/app/colors.dart` — 577 lines. ~15 near-identical dark surfaces
(`surface 0xFF262624`, `surfaceMid 0xFF282828`, `surfaceCoal 0xFF242424`,
`surfaceVariant 0xFF2A2A2A`, `surfaceDim 0xFF2E2E2E`, `surfaceMute 0xFF303030`,
`surfaceShadow 0xFF1F1F1F`, `surfaceCharcoal 0xFF1B1B1B` …) plus ~12 gold
variants only a few % apart.

**Problem:** When every card picks a slightly different near-black, the
dark-theme elevation ladder (background → surface → raised) stops being
*readable*. The skill stresses depth should *communicate* layering; too many
indistinguishable steps communicate nothing and make future screens
inconsistent by default.

**Recommendation:** Define a **canonical 3–4 step elevation ladder**
(`background` → `surface` → `surfaceRaised` → `surfaceOverlay`) and map the
long tail of one-off surfaces onto it. Keep the raw constants during migration,
but steer new code to the ladder. This is the highest-leverage consistency fix.

---

## 🟡 Medium Priority

### M1 — Token system is bypassed in ~100+ spots

**Evidence:** 82 inline `Color(0x…)` literals outside `colors.dart`, 26 raw
material `Colors.x`, 20 inline `TextStyle(` in widgets, 56 inline `fontSize:`
in `lib/features`. Top offenders: `application_under_review_card.dart` (21
literals), file-manager widgets (`fm_status_pill`, `fm_file_type_icon`,
`fm_file_card`), `success_screen.dart`.

**Problem:** Each leak is a spot the design system can't retheme (e.g. light
mode) and a place visual drift creeps in. The rules in CLAUDE.md explicitly
forbid inline `Color(0xFF…)`/`Colors.x`/`TextStyle()`.

**Recommendation:** Sweep the top offenders into tokens (file-manager feature
and `application_under_review_card` first). Add an analyzer/CI lint to fail new
inline color/textstyle literals so the gap doesn't regrow.

---

### M2 — Three competing text-field implementations

**Where:** `app_text_field.dart` (`AppTextField`, bordered `surfaceInput` fill),
`new_text_field.dart` (`CustomInputField`, floating label + gold 0.5px border),
`custom_text_field.dart`. Login uses `CustomInputField`; the "canonical"
`AppTextField` is used elsewhere.

**Problem:** Different border weights, fill treatment, label behavior, and
focus colors between forms → inputs don't feel like one app. Two of these also
differ in touch height.

**Recommendation:** Pick one canonical field (the floating-label
`CustomInputField` treatment is the more modern of the two), fold the others'
features into it, and migrate call sites. Delete the losers.

---

### M3 — Accessibility coverage is thin

**Evidence:** `Semantics(` appears in only 16 files across 45 screens; most
non-text icons (SVG `colorFilter` icons in toolbars, badges, nav) ship without
`semanticLabel`. Status is conveyed by **color-coded badges** (shoot /
meeting status) — the skill flags "relying on color alone for meaning" as an
anti-pattern.

**Recommendation:** (a) Add `semanticLabel` to icon-only actions (the
`AppIconTapTarget` already has the slot). (b) Status badges already pair an
icon + text, which is good — keep that pairing everywhere and never ship a
color-only state. (c) Run the app with TalkBack/VoiceOver once per feature.

---

### M4 — Fixed-pixel heights are brittle (ties into H3)

**Where:** 40+ sites with `height: 55/50/32` or `vertical: 8`. Shoot card image
hard-coded `180`, avatar math hard-coded, `Transform.translate(Offset(0,-70))`.

**Recommendation:** Convert content-bearing fixed heights to min-height +
padding. Reserve fixed sizes for genuinely fixed art (icons, avatars).

---

### M5 — Error color is pure `0xFFFF0000`

**Where:** `colors.dart:132` `error = Color(0xFFFF0000)`.

**Problem:** Pure RGB red is harsh and clashes with the warm luxury palette;
the skill's color guidance favors slightly desaturated/temperature-matched
semantics. The app already has nicer reds (`errorAccent 0xFFF66E6E`,
`meetingCancelledFg 0xFFD33732`).

**Recommendation:** Retune `error` to a desaturated brand-compatible red (e.g.
align with `0xFFD33732`) and keep `errorLight`/`errorAccent` as the softer
companions.

---

### M6 — Auth card uses a brittle negative-offset overlap

**Where:** `login_screen.dart:168` `Transform.translate(offset: Offset(0,-70))`
over a `clamp(220,320)` hero, with `Positioned`-style stacking.

**Problem:** Magic `-70` overlap + clamped hero height is fragile across device
sizes and will shift with any hero/typography change; combined with H3 it can
collide or gap.

**Recommendation:** Express the overlap with a `Stack` + `Align`/`Positioned`
driven by the hero's measured height (or a `LayoutBuilder`), not a fixed
translate, so it scales with the clamp.

---

## 🟢 Low Priority

### L1 — Spacing literals used where tokens exist
`home_screen.dart` uses `const SizedBox(height: 24)` / `18` repeatedly instead
of `AppSpacing.xxl` / `verticalXxl`, despite the token existing. Cosmetic
inconsistency; tidy during the next touch of each file.

### L2 — Bottom-nav labels at 10sp
`app_shell.dart:177` selected/unselected font 10sp sits at the readable floor.
Fine for nav, but verify legibility at the smallest supported device + confirm
it survives H3 scaling.

### L3 — Hand-tuned divider spacing via comments
`home_screen.dart` threads "18 + 6 = 24 visual gap" comments between
`HomeSectionDivider`s — works, but encode the intent in a small
`SectionGap` helper instead of comment arithmetic.

### L4 — Two notification patterns: `TopMessage` vs raw `SnackBar`
14 files still call `ScaffoldMessenger`/`SnackBar` directly while the app has a
branded `TopMessage`. Standardize on `TopMessage` for a consistent toast look.

### L5 — Light theme is a stub
`theme.dart:118` `light() => dark()`. Fine as a deliberate dark-only decision —
but it means the token leaks in M1 are latent light-mode bugs. Decide
explicitly: commit to dark-only (and document it) or schedule light mode.

### L6 — Debug credentials hardcoded in Login
`login_screen.dart:42-45` pre-fills a real-looking email/password under
`kDebugMode`. Harmless in release but move to an env/dart-define so it can't
leak into a screenshot/demo build.

---

## Suggested Sequencing

1. **Quick wins (hours):** H4 `BoxFit.cover` swap, M5 error color, L4/L6.
2. **Touch & feedback (1–2 days):** H1 subtle ripple, H2 adopt `AppIconTapTarget`
   + raise Accept/Decline hit boxes.
3. **Resilience (2–3 days):** H3 clamp text scaling + convert fixed heights (M4),
   M6 overlap refactor.
4. **Systemic (ongoing):** H5 elevation ladder, M1 token sweep + CI lint, M2
   unify text fields, M3 a11y pass.

---

## Manual Test Summary

| # | Step | Expected Result | Edge Cases |
|---|------|-----------------|------------|
| 1 | Tap any button / nav item after H1 | Visible subtle press feedback | Rapid double-tap; disabled state shows none |
| 2 | Tap "View Details", chip-close, Accept/Decline (H2) | Comfortable hit, no mis-tap | Small-screen device; adjacent targets not triggered |
| 3 | Set system font to largest, open Home + Shoots (H3) | No clipping / overflow; layout reflows | 1.3× cap holds; count-card strip & CTA intact |
| 4 | Open Login / signup / profile headers (H4) | Hero art not stretched | Tall & short devices; portrait only |
| 5 | Compare card surfaces across Home/Shoots/Files (H5) | Clear, consistent elevation steps | Same card type looks identical across features |
| 6 | Fill a form on each flow (M2) | Inputs look/behave identically | Focus, error, filled, disabled states match |
| 7 | VoiceOver/TalkBack sweep per feature (M3) | Every control announced; status not color-only | Icon-only actions have labels |
| 8 | Trigger an error toast anywhere (M5/L4) | Consistent branded `TopMessage`, retuned red | Offline + validation errors |