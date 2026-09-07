# Design Audit — Alignment, Padding, and Margins

**Date:** 2026-08-19  
**Scope:** Flutter UI under `lib/features/`, `lib/shared/`, and `lib/app/`  
**Audit type:** Read-only static review plus focused responsive tests  
**Implementation status:** No UI fixes applied; every change requires approval

## Executive Summary

Phone layouts are generally safe, but spacing consistency and responsive
coverage are incomplete. The audit found one high-risk layout concern, five
medium-priority concerns, and substantial spacing-token debt.

The application already uses `AppSpacing` extensively, with 936 references in
the audited UI. However, 61 `EdgeInsets` declarations and 471 `SizedBox`
declarations still contain direct numeric layout values. Not every literal is a
visible defect, but they make global rhythm and alignment changes difficult to
apply reliably.

## Priority Findings

| ID | Priority | Finding | Evidence |
|---|---|---|---|
| AP-01 | High | The profile cropper can clip horizontally or overflow vertically on compact phones. It uses a fixed 330px backdrop and a fixed 350px crop area alongside the header, toolbar, slider, and action button. | `lib/features/profile/presentation/screens/crop_image_screen.dart:47-48`, `:371-374` |
| AP-02 | Medium | Tablet layouts stretch almost completely full-width. Across 57 screen files, there is no reusable centered maximum-width content wrapper. This was previously deferred as responsive item R-05. | `docs/IPHONE_IPAD_RESPONSIVE_FIX_PLAN.md` R-05 |
| AP-03 | Medium | Shoot status/category overlays can overflow when the backend returns a long shoot type. The positioned rows have no width constraint, `Flexible`, or ellipsis behavior. | `lib/features/home/presentation/widgets/home_pending_shoot_card.dart:153-214`, `lib/features/shoots/presentation/screens/shoots_screen.dart:453-515` |
| AP-04 | Medium | Meeting-card metadata has similar long-content risk. Date/time text, participant-count labels, and status/platform badge rows are placed in unconstrained rows. | `lib/features/meetings/presentation/widgets/meeting_card.dart:184-220`, `:230-253`, `:439-461` |
| AP-05 | Medium | Signup Step 1 positions its progress counter 30px from the top, while Steps 2 and 3 use `AppSpacing.sm` (8px). This creates a visible alignment jump between steps. Steps 2 and 3 also force subtitle line breaks instead of allowing natural wrapping. | `lib/features/auth/presentation/widgets/signup1_header.dart:21-24`, `signup2_header.dart:40-43`, `signup3_header.dart:42-45` |
| AP-06 | Medium | Bottom-sheet sizing is inconsistent. The app mixes draggable 50–95%, fixed 88–90%, and `FractionallySizedBox` 75–85% patterns, producing different keyboard, compact-phone, and tablet behavior. This was previously deferred as responsive item R-08. | `meeting_details_sheet.dart:46-50`, `view_details_screen.dart:53-59`, `signup2_lookup_sheet.dart:28-35`, `fm_upload_sheet.dart:324-325`, `fm_file_preview_sheet.dart:199-200` |
| AP-07 | Low | The Signup Success “View Details” button uses `Size.zero` and `MaterialTapTargetSize.shrinkWrap`, making its visual and touch spacing much smaller than surrounding actions. | `lib/features/auth/presentation/screens/signup_success_screen.dart:222-230` |

## Spacing Inventory

| Area | UI files audited | Raw `EdgeInsets` | Raw `SizedBox` | `AppSpacing` references |
|---|---:|---:|---:|---:|
| Auth | 34 | 21 | 188 | 124 |
| Availability | 4 | 3 | 5 | 56 |
| File manager | 36 | 2 | 5 | 141 |
| Home | 14 | 5 | 24 | 89 |
| Meetings | 13 | 7 | 23 | 71 |
| Menu placeholders | 1 | 0 | 0 | 0 |
| Messages | 23 | 4 | 8 | 113 |
| Onboarding | 3 | 0 | 0 | 10 |
| Profile | 38 | 10 | 199 | 180 |
| Shared UI | 33 | 3 | 4 | 55 |
| Shoots | 9 | 6 | 15 | 97 |
| Splash | 3 | 0 | 0 | 0 |
| **Total** | **211** | **61** | **471** | **936** |

The repository design-token gate uses a simpler single-line pattern and reports
24 raw `EdgeInsets` and 403 raw `SizedBox` instances. The larger totals above
come from a multiline scan of complete constructor calls.

## Screen-Edge Alignment

Screen-edge padding is not consistent across features:

| Feature/example | Horizontal spacing |
|---|---:|
| Shoots sections | 14px and 16px |
| Meetings lists | 16px |
| File Manager lists | 16px |
| Availability content/footer | 18px and 20px |
| Home content | 20px |
| Signup Success | 24px |
| Onboarding sections | 18px and 24px |

The individual values are usable, but navigating between screens produces
different left and right visual anchors. A future approved fix should establish
one default screen gutter, with explicitly documented exceptions for hero,
carousel, and full-bleed content.

## Feature Assessment

| Feature | Assessment | Main concern |
|---|---|---|
| Auth | Needs review | Header alignment, raw spacing concentration, and multiple sheet patterns |
| Profile | Highest priority | Compact-device cropper risk and the largest number of raw `SizedBox` values |
| Home | Moderate | Long status/category overlay content can exceed available width |
| Shoots | Moderate | Long status/category overlay content and mixed 14px/16px gutters |
| Meetings | Moderate | Unconstrained metadata rows; spacing literals concentrated in `MeetingCard` |
| Messages | Generally consistent | Tablet width remains unrestricted; specialized screens manage SafeArea manually |
| File Manager | Generally consistent | Fixed fractional sheet heights differ from the rest of the app |
| Availability | Low risk | Minor 18px/20px gutter differences |
| Onboarding | Low risk | No raw layout constructors found; two deliberate gutter widths remain |
| Splash | Low risk | No notable padding or margin concern found |
| Shared shell | Strong | Shared SafeArea and custom footer handling are in place |

## Positive Findings

- `AppScaffold` centralizes the standard top/left/right SafeArea behavior and
  supports bottom-safe custom navigation bars.
- The messages composer applies a bottom SafeArea.
- Meeting details use `DraggableScrollableSheet`, which is the most adaptable
  sheet implementation currently in the app.
- Message bubbles constrain their maximum width.
- Major hero/card images were previously migrated to aspect-ratio or constrained
  layouts.
- Search-field vertical alignment was recently consolidated through
  `AppSearchField`.
- Signup header device-matrix goldens cover 320×568, 393×852, and 744×1133.

## Verification

The following focused responsive suite passed:

```text
flutter test \
  test/golden/device_matrix_test.dart \
  test/shared/layouts/app_scaffold_test.dart \
  test/shared/widgets/common_calendar_test.dart
```

Verified behavior:

- Signup headers match their existing baselines at 320×568, 393×852, and
  744×1133.
- `AppScaffold` applies its documented SafeArea defaults.
- Calendar event labels remain readable at 320px width.

These tests do not render complete screens, the cropper, cards with long API
values, or the 32 modal-bottom-sheet call sites. A broader mixed widget-test run
also encountered three existing `MyProfileScreen` expectation failures. They
were content/state expectation failures rather than reported `RenderFlex`
layout exceptions.

## Recommended Approval Order

No work below has been applied.

1. Approve a compact-device cropper correction and add a 320×568 regression
   test.
2. Approve width constraints and ellipsis/wrapping for shoot and meeting card
   metadata.
3. Approve signup-header alignment normalization.
4. Approve a reusable tablet maximum-width layout wrapper.
5. Approve a bottom-sheet device matrix and then standardize only the sheets
   that fail it.
6. Approve spacing-literal migration separately from visual spacing changes so
   tokenization can remain pixel-preserving.

## Approval Gate

This document is a report only. No padding, margin, alignment, responsive
constraint, token, widget, test, or screen implementation should be changed
without explicit approval.
