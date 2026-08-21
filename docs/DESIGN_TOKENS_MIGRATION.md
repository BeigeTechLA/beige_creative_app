# Design Tokens — Migration Mapping

> **Audience:** Engineers migrating widgets off legacy tokens (ColorCode, inline literals) onto the centralised `AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadii`, `AppShadows`.
>
> **Companion:** `DESIGN_IMPROVE_PHASE1.md` · `DESIGN_TOKENS_RULES.md`

---

## 1. ColorCode → AppColors

Every `ColorCode.*` field is now an alias of an `AppColors.*` constant — no rename is strictly required to land Phase 1, but new code and Phase 2 migrations should reference `AppColors` directly.

### Brand

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.primary` | `AppColors.primary` | `0xFFE8D1AB` |
| `ColorCode.kButtonColor` | `AppColors.primary` | `0xFFE8D1AB` |
| `ColorCode.kChampagneGold` | `AppColors.primary` | `0xFFE8D1AB` |
| `ColorCode.kCreamSoft` | `AppColors.accent` | `0xFFECE1CE` |
| `ColorCode.kHeadingColor` | `AppColors.textHeading` | `0xFF1D1D1B` |
| `ColorCode.kSubtextColor` | `AppColors.textSubtle` | `0xFF474746` |
| `ColorCode.soft` | `AppColors.goldSoftSand` | `0xFFD6C3A1` |
| `ColorCode.borderGold` | `AppColors.borderGold` | `0x80E8D1AB` |

### Background / surface

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.backgroundColor` | `AppColors.background` | `0xFF1D1D1B` |
| `ColorCode.k262624` | `AppColors.surface` | `0xFF262624` |
| `ColorCode.k2A2A2A` | `AppColors.surfaceVariant` | `0xFF2A2A2A` |
| `ColorCode.k282828` | `AppColors.surfaceMid` | `0xFF282828` |
| `ColorCode.kPrimaryDark` | `AppColors.surfaceStats` | `0xFF1E1E1E` |
| `ColorCode.lightBlack` | `AppColors.darkGrey333` | `0xFF333333` |
| `ColorCode.singuptextColor` | `AppColors.disabled` | `0xFF5D5D5D` |

### Text

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.k777571` | `AppColors.textTertiary` | `0xFF777571` |
| `ColorCode.k737373` | `AppColors.greyShade737` | `0xFF737373` |
| `ColorCode.kSubtextOpacity` | `AppColors.subtextOpacity60` | `0x991D1D1B` |
| `ColorCode.hint_text` | `AppColors.hintLavender` | `0xFF9995B4` |
| `ColorCode.grey` | `AppColors.lavenderGrey` | `0xFF9B97B5` |
| `ColorCode.grey_white` | `AppColors.greyWash` | `0xFFF1F2F5` |

### Border / divider

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.kCircleBorder` | `AppColors.border` | `0xFFDDDDDD` |
| `ColorCode.lightGrey` | `AppColors.border` | `0xFFDDDDDD` |
| `ColorCode.kGoldBorder50` | `AppColors.borderGold` | `0x80E8D1AB` |
| `ColorCode.kDividerWhite12` | `AppColors.dividerDark` | `0x1FFFFFFF` |
| `ColorCode.white12` | `AppColors.dividerDark` | `0x1FFFFFFF` |
| `ColorCode.textfieldbordercollor` | `AppColors.textfieldBorderLegacy` | `0xFFE8D1AB80` (40-bit legacy) |
| `ColorCode.kCircleBorderDark` | `AppColors.background` | `0xFF1D1D1B` |
| `ColorCode.darkCharcoal` | `AppColors.darkCharcoal` | `0xFF3D3D3D` |

### White opacity variants

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.white` | `AppColors.white` | `0xFFFFFFFF` |
| `ColorCode.whiteTransparent` | `AppColors.whiteTransparent` | `0x00FFFFFF` |
| `ColorCode.whiteOpacity10` | `AppColors.white10` | `0x1AFFFFFF` |
| `ColorCode.whiteOpacity20` | `AppColors.white20` | `0x33FFFFFF` |
| `ColorCode.white24` | `AppColors.white24` | `0x3DFFFFFF` |
| `ColorCode.white30` | `AppColors.white30` | `0x4DFFFFFF` |
| `ColorCode.kWhiteOpacity30` | `AppColors.white30` | `0x4DFFFFFF` |
| `ColorCode.kWhiteOpacity70` | `AppColors.white30` | `0x4DFFFFFF` (legacy bug — name says 70, value = 30) |
| `ColorCode.white54` | `AppColors.white54` | `0x8AFFFFFF` |
| `ColorCode.white60` | `AppColors.white60` | `0x99FFFFFF` |
| `ColorCode.kWhiteOpacity60` | `AppColors.white60` | `0x99FFFFFF` |
| `ColorCode.kWhiteOpacity_60` | `AppColors.white60` | `0x99FFFFFF` |

### Black opacity variants

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.black` | `AppColors.black` | `0xFF000000` |
| `ColorCode.kBlackOpacity10` | `AppColors.black10` | `0x1A000000` |
| `ColorCode.kBlackOpacity12` | `AppColors.black12` | `0x1F000000` |
| `ColorCode.softShadow` | `AppColors.shadow` | `0x11000000` |

### Gold / gradient

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.kGoldGradientLight` | `AppColors.borderGold` | `0x80E8D1AB` |
| `ColorCode.kGoldGradientDark` | `AppColors.goldGradientDark` | `0xFFD4A14D` |
| `ColorCode.kGold40` | `AppColors.goldOpacity40` | `0x66E9BE78` |
| `ColorCode.k1D1D1B_Opacity70` | `AppColors.backgroundOpacity70` | `0xB21D1D1B` |
| `ColorCode.kCircleGradientTop` | `AppColors.circleGradientTop` | `0xFF1D1D1B` |
| `ColorCode.kCircleGradientBottom` | `AppColors.circleGradientBottom` | `0xFF434341` |
| `ColorCode.kGradientLight` | `AppColors.primary.withValues(alpha: 0.40)` | runtime |
| `ColorCode.kGradientMedium` | `AppColors.primary.withValues(alpha: 0.28)` | runtime |
| `ColorCode.kGradientDark` | `AppColors.primary.withValues(alpha: 0.04)` | runtime |

### Semantic

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.red` | `AppColors.error` | `0xFFFF0000` |
| `ColorCode.kLightRed` | `AppColors.errorLight` | `0xFFFFC9C9` |
| `ColorCode.green` | `AppColors.success` | `0xFF4CAF50` |
| `ColorCode.orange` | `AppColors.orange` | `0xFFFF9800` |
| `ColorCode.primaryBlue` | `AppColors.info` | `0xFF0066FF` |
| `ColorCode.kPrimaryPurple` | `AppColors.magenta` | `0xFFC026D3` |
| `ColorCode.wine` | `AppColors.wine` | `0xFF5A0760` |
| `ColorCode.classic_teal` | `AppColors.teal` | `0xFF008080` |
| `ColorCode.tealLight` | `AppColors.tealLight` | `0xFF2DBB9A` |
| `ColorCode.tealDark` | `AppColors.tealDark` | `0xFF1FAF8A` |

### Soft / pastel

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.kSoftPeach` | `AppColors.softPeach` | `0xFFEECCC9` |
| `ColorCode.kSoftMint` | `AppColors.softMint` | `0xFFD8FDE6` |
| `ColorCode.kSoftLightBlue` | `AppColors.softLightBlue` | `0xFFC8E1FF` |

### Cards / UI

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.transparent` | `AppColors.transparent` | `0x00000000` |
| `ColorCode.cardBg` | `AppColors.white` | `0xFFFFFFFF` |
| `ColorCode.shootStatsCardTop` | `AppColors.shootStatsCardTop` | `0xFF2B2A28` |
| `ColorCode.shootStatsCardBottom` | `AppColors.shootStatsCardBottom` | `0xFF1E1D1B` |
| `ColorCode.shootStatsCardBorder` | `AppColors.shootStatsCardBorder` | `0x1AE8D1AB` |
| `ColorCode.shootStatsIconBg` | `AppColors.primary` | `0xFFE8D1AB` |
| `ColorCode.dashboardPanel` | `AppColors.surfaceMid` | `0xFF282828` |
| `ColorCode.dashboardPanelDark` | `AppColors.dashboardPanelDark` | `0xFF161616` |
| `ColorCode.dashboardPanelBorder` | `AppColors.darkCharcoal` | `0xFF3D3D3D` |
| `ColorCode.dashboardMutedText` | `AppColors.textTertiary` | `0xFF777571` |
| `ColorCode.calendarCell` | `AppColors.calendarCell` | `0xFF202020` |
| `ColorCode.calendarHeader` | `AppColors.background` | `0xFF1D1D1B` |
| `ColorCode.calendarGrid` | `AppColors.calendarGrid` | `0xFF3A3A3A` |

### Status / map / chart

| ColorCode (legacy) | Replace with | Hex |
|---|---|---|
| `ColorCode.statusOnWay` | `AppColors.statusOnWay` | `0xFFFFA000` |
| `ColorCode.statusArrived` | `AppColors.statusArrived` | `0xFF4CAF50` |
| `ColorCode.statusPending` | `AppColors.statusPending` | `0xFFE53935` |
| `ColorCode.mapBlue` | `AppColors.mapBlue` | `0xFF1A73E8` |
| `ColorCode.mapGrey` | `AppColors.mapGrey` | `0xFF757575` |
| `ColorCode.arcPurple` | `AppColors.arcPurple` | `0xFFA678F1` |
| `ColorCode.arcBlue` | `AppColors.arcBlue` | `0xFF5CC4FF` |
| `ColorCode.arcYellow` | `AppColors.arcYellow` | `0xFFFFC04F` |
| `ColorCode.arcGreen` | `AppColors.arcGreen` | `0xFF2DC497` |

---

## 2. Raw pixel → AppSpacing

| Raw value | Token | Notes |
|---|---|---|
| `2` | `AppSpacing.xxxs` | Icon-label align |
| `4` | `AppSpacing.xxs` | Tiny inline gap |
| `6` | `AppSpacing.xs` | Chip padding |
| `8` | `AppSpacing.sm` | Icon–text gap |
| `10` | `AppSpacing.smd` | Compact list items |
| `12` | `AppSpacing.md` | Card gap |
| `14` | `AppSpacing.mld` | Input/button vertical |
| `16` | `AppSpacing.base` | Default screen padding |
| `18` | `AppSpacing.lg` | Medium-large |
| `20` | `AppSpacing.xl` | Comfortable |
| `24` | `AppSpacing.xxl` | Section gap |
| `32` | `AppSpacing.xxxl` | Large section |
| `36` | `AppSpacing.huge` | Extra large |
| `40` | `AppSpacing.massive` | Hero |
| `48` | `AppSpacing.jumbo` | Major divider |
| `64` | `AppSpacing.max` | Maximum |
| `1.5` | `AppSpacing.hairline` | Borders |
| `0.6` | `AppSpacing.fine` | Gradient inset |

**Convenience insets (prefer these over `EdgeInsets.symmetric/all` literals):**
- `AppSpacing.screenPadding` — `EdgeInsets.symmetric(horizontal: 16, vertical: 20)`
- `AppSpacing.cardInsets` — `EdgeInsets.all(16)`
- `AppSpacing.buttonPadding` — `EdgeInsets.symmetric(horizontal: 24, vertical: 14)`
- `AppSpacing.authCardPadding` — `EdgeInsets.fromLTRB(20, 32, 20, 20)`
- `AppSpacing.authCardMargin` — `EdgeInsets.symmetric(horizontal: 16)`
- `AppSpacing.insetsHBase` — `EdgeInsets.symmetric(horizontal: 16)`
- `AppSpacing.insetsHXl` — `EdgeInsets.symmetric(horizontal: 20)`

**Vertical/horizontal gap SizedBoxes:**
- `AppSpacing.verticalXs`, `verticalSm`, `verticalMd`, `verticalBase`, `verticalXl`, `verticalXxl`, `verticalXxxl`
- `AppSpacing.gapHXs`, `gapHSm`, `gapHMd`, `gapHBase`, `gapHXl`

---

## 3. Raw radius → AppRadii

| Raw value | Token | Convenience BorderRadius |
|---|---|---|
| `4` | `AppRadii.xs` | `AppRadii.xsAll` |
| `6` | `AppRadii.sm` | `AppRadii.smAll` |
| `8` | `AppRadii.md` | `AppRadii.mdAll` |
| `10` | `AppRadii.mld` | — |
| `12` | `AppRadii.lg` | `AppRadii.lgAll` |
| `11.5` | `AppRadii.statsInner` | `AppRadii.statsInnerAll` |
| `14` | `AppRadii.xl` | `AppRadii.xlAll` |
| `16` | `AppRadii.xxl` | `AppRadii.xxlAll` |
| `18` | `AppRadii.xxxl` | `AppRadii.xxxlAll` |
| `20` | `AppRadii.huge` | `AppRadii.hugeAll` |
| `22` | `AppRadii.portfolioCompact` / `authCard` | `portfolioCompactAll` / `authCardAll` |
| `24` | `AppRadii.massive` | `AppRadii.massiveAll` |
| `25` | `AppRadii.portfolio` | `AppRadii.portfolioAll` |
| `28` | `AppRadii.header` | — (top/bottom only) |
| `30` | `AppRadii.round` | `AppRadii.roundAll` |
| `32` | `AppRadii.sheet` | — (top only) |
| `38` | `AppRadii.roundLg` | — |
| `40` | `AppRadii.pillSm` | `AppRadii.pillSmAll` |
| `50` | `AppRadii.pill` | `AppRadii.pillAll` |
| `64` | `AppRadii.enormous` | `AppRadii.enormousAll` |
| `999` | `AppRadii.full` | `AppRadii.fullAll` |

**Top/bottom-only:**
- `AppRadii.topHuge` — top corners 20
- `AppRadii.topSheet` — top corners 32
- `AppRadii.topXl` — top corners 14
- `AppRadii.bottomHeader` — bottom corners 28
- `AppRadii.bottomPillSm` — bottom corners 40

---

## 4. Inline TextStyle → AppTextStyles

| When the inline style is… | Use |
|---|---|
| Hero / splash heading | `AppTextStyles.displayLarge` |
| Onboarding heading | `AppTextStyles.displayMedium` |
| Large section title | `AppTextStyles.displaySmall` |
| App bar title | `AppTextStyles.titleLarge` |
| Screen section header | `AppTextStyles.titleMedium` |
| Card / dialog title | `AppTextStyles.titleSmall` |
| Primary body / description | `AppTextStyles.bodyLarge` |
| Default list item / paragraph | `AppTextStyles.bodyMedium` |
| Secondary info / metadata | `AppTextStyles.bodySmall` |
| Compact list paragraph (13 sp) | `AppTextStyles.bodyCompact` |
| Link text | `AppTextStyles.linkMedium` |
| OTP digit | `AppTextStyles.otpDigit` |
| Primary button (16 sp) | `AppTextStyles.buttonLarge` |
| Secondary button (14 sp) | `AppTextStyles.buttonMedium` |
| Small button (12 sp) | `AppTextStyles.buttonSmall` |
| Tab / chip / tag | `AppTextStyles.labelMedium` |
| Badge / overline | `AppTextStyles.labelSmall` |
| Timestamp / hint | `AppTextStyles.caption` |
| Italic Helvetica detail | `AppTextStyles.detailingText` |

**Need a one-off colour or weight?** Use `copyWith`:

```dart
// Before
Text('Total', style: TextStyle(
  fontFamily: 'Outfit', fontSize: 14, fontWeight: FontWeight.w500,
  color: ColorCode.kSubtextColor,
))

// After
Text('Total', style: AppTextStyles.labelLarge.copyWith(color: AppColors.textSubtle))
```

---

## 5. Inline BoxShadow → AppShadows

| Inline pattern | Use |
|---|---|
| Subtle drop shadow | `AppShadows.sm` |
| Card elevation | `AppShadows.md` |
| Modal / floating panel | `AppShadows.lg` |
| Large floating element | `AppShadows.xl` |
| No shadow | `AppShadows.none` |

```dart
BoxDecoration(
  boxShadow: AppShadows.md,
  // …
)
```

---

## 6. Phase 2 — Hotspot file priority

Migrate in this order — top three contain ~30 % of all violations.

| Priority | File | Inline TextStyle | Magic colors | EdgeInsets | BorderRadius |
|---|---|---|---|---|---|
| 1 | `lib/auth/sign_up/signup3_screen.dart` | 59 | — | 53 | 57 |
| 2 | `lib/Profile/myprofile.dart` | 48 | — | 48 | 43 |
| 3 | `lib/Home/home_screen.dart` | 70 | 21 | 42 | 39 |
| 4 | `lib/manageavailability/add_availability_screen.dart` | — | 48 | — | — |
| 5 | `lib/manageavailability/manage_availability_screen.dart` | — | 36 | — | — |
| 6 | `lib/auth/sign_up/signup1_screen.dart` | 35 | — | 21 | 23 |
| 7 | `lib/UpcomingShootViewdetils/upcoming_shoot_view_detils.dart` | 37 | — | — | — |
| 8 | `lib/file_manager/file_manager_screen.dart` | — | 19 | — | — |
| 9 | `lib/Profile/featured_work_list.dart` | — | — | 23 | 25 |
| 10 | `lib/Shoots/pre_production_screen.dart` | — | 15 | — | — |

After top 10: remaining ~38 files in any order, then delete unused ColorCode aliases.

---

## 7. Migration steps (per file)

For each widget file:

1. Replace `ColorCode.x` → `AppColors.y` per Section 1 table.
2. Replace inline `Color(0xFF…)` → matching `AppColors` constant (add if missing).
3. Replace inline `TextStyle(…)` → `AppTextStyles.<name>` (use `copyWith` for variants).
4. Replace `EdgeInsets.all(N)` etc. → `EdgeInsets.all(AppSpacing.<token>)`.
5. Replace `BorderRadius.circular(N)` → `AppRadii.<token>All`.
6. Replace inline `BoxShadow(…)` → `AppShadows.<level>`.
7. Run `flutter analyze` — zero new warnings.
8. Visual smoke test on the affected screen.
9. Remove `ColorCode` import if no remaining references.

Commit one file at a time. Keep diff small for review.

---

## Changelog

| Version | Date | Notes |
|---------|------|-------|
| 1.0 | 2026-05-23 | Initial migration mapping |
