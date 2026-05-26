# Date/Time Centralization Plan

Audit of every date/time formatting site in `lib/`, plus consolidation plan onto the sample util at `testing/date_time_utils.dart`.

---

## 1. Current State

Date/time formatting is **fragmented across 3 utility classes and 7+ screens**, with direct `DateFormat()` calls and manual string interpolation living alongside half-used helpers.

### Existing utilities (all to be deleted/merged)

| File | Class / Method | Pattern | Notes |
|------|----------------|---------|-------|
| `lib/widgets/date_time.dart` | `DateTimeUtils.formatDate(String?)` | `dd-MM-yyyy` | Used by 3 screens |
| `lib/widgets/date_time.dart` | `DateTimeUtils.formatTime(String?)` | parses `HH:mm:ss` → `hh:mm a` | Used by 3 screens |
| `lib/widgets/date_time.dart` | `DateTimeUtils.formatDateTime(String?)` | `MMM d, yyyy h:mm a` | Used by 1 screen |
| `lib/utility/app_utils.dart` | `AppUtils.formatDate(DateTime)` | `dd MMM yyyy` | **No call sites found** — dead code |
| `lib/utility/app_utils.dart` | `AppUtils.selectDate(...)` | wraps `showDatePicker` | Used inline elsewhere too |
| `lib/manageavailability/manage_availability_screen.dart:96` | `_getMonthYear(DateTime)` (private) | manual `months[]` array → `"May 2026"` | **Missed by audit** — bypasses intl entirely |

---

## 2. Complete Screen Inventory

Every file in `lib/` that formats or parses dates/times.

### 2.1 Screens with direct `DateFormat()` calls

| File | Line(s) | Pattern | Purpose |
|------|---------|---------|---------|
| `lib/home/home_screen.dart` | 345 | `MMMM yyyy` | Calendar month header |
| `lib/home/home_screen.dart` | 355 | `MMM dd, yyyy` | Event card date |
| `lib/home/home_screen.dart` | 1186, 1453 | `DateFormat.E()` | Weekday abbr (Mon, Tue…) |
| `lib/shoots/shoots_screen.dart` | 348 | `MMM dd, yyyy` | Project card date |
| `lib/shoots/shoots_screen.dart` | 353–354 | `HH:mm:ss` (parse) | Parse API start/end time |
| `lib/shoots/shoots_screen.dart` | 357 | `hh:mm a` (×2) | Display time range |
| `lib/manageavailability/add_availability_screen.dart` | 119 | `dd/MM/yyyy` (parse) | Parse picker input |
| `lib/manageavailability/add_availability_screen.dart` | 122 | `yyyy-MM-dd` | API payload |
| `lib/manageavailability/add_availability_screen.dart` | 134 | `dd/MM/yyyy` (parse) | Parse until-date picker input |
| `lib/manageavailability/add_availability_screen.dart` | 138 | `yyyy-MM-dd` | API payload (until) |
| `lib/manageavailability/add_availability_screen.dart` | 259 | `hh:mm a` | Time picker display |
| `lib/manageavailability/add_availability_screen.dart` | 340 | `dd/MM/yyyy` | Date picker display |
| `lib/manageavailability/add_availability_screen.dart` | 372 | `dd/MM/yyyy` (parse) | Parse until-date |
| `lib/manageavailability/add_availability_screen.dart` | 375 | `MMMM d, yyyy` | Confirmation dialog date |

### 2.2 Screens consuming old `DateTimeUtils` (to be migrated to new util)

| File | Line(s) | Method | Notes |
|------|---------|--------|-------|
| `lib/home/home_screen.dart` | 1770, 1792 | `formatDate`, `formatTime` | Mixes with direct `DateFormat` calls in same file |
| `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart` | 218, 225, 345 | `formatDate`, `formatTime`, `formatDateTime` | Only consumer of `formatDateTime` |
| `lib/shoots/shoots_screen.dart` | 339, 343 | `formatDate`, `formatTime` | Mixes with direct `DateFormat` calls |

### 2.3 Screens with manual date math / interpolation

| File | Line(s) | Issue |
|------|---------|-------|
| `lib/manageavailability/manage_availability_screen.dart` | 96–112 | Manual `months[]` array → `"May 2026"`. Should use `DateFormat("MMMM yyyy")` |
| `lib/manageavailability/manage_availability_screen.dart` | 78 | `DateTime(date.year, date.month, date.day)` truncation — leave as is (not formatting) |
| `lib/home/home_screen.dart` | 289 | Same truncation pattern — leave as is |
| `lib/home/home_screen.dart` | 1129, 1145, 1301–1302, 1335–1336 | Month-stepping arithmetic — not formatting, leave as is |
| `lib/manageavailability/add_availability_screen.dart` | 256 | `DateTime(now.year, now.month, now.day, picked.hour, picked.minute)` — composing time-of-day into DateTime for formatting. Wrap with new `formatTimeOfDayShort` |

### 2.4 Models — `DateTime.parse` (out of scope, keep as is)

| File | Line | Purpose |
|------|------|---------|
| `lib/model_class/upcoming_shoots_model.dart` | 65 | DTO `fromJson` |
| `lib/model_class/shoots_model.dart` | 93 | DTO `fromJson` (uses `tryParse`) |
| `lib/model_class/create_dashboard_details_model.dart` | 84 | DTO `fromJson` |

Models are correct — they parse API ISO strings into `DateTime`. The util handles formatting on the way out.

### 2.5 `toIso8601String()` usage (out-bound serialization)

| File | Line | Notes |
|------|------|-------|
| `lib/home/home_screen.dart` | 1771 | Serializes `eventDate` to API. **Should swap to `DateTimeUtils.formatApiDate(date)`** (sample method exists) |
| `lib/shoots/shoots_screen.dart` | 340 | Same as above |

### 2.6 Picker call sites

| File | Line | Picker |
|------|------|--------|
| `lib/utility/app_utils.dart` | 30 | `showDatePicker` (wrapped as `AppUtils.selectDate`) |
| `lib/manageavailability/add_availability_screen.dart` | 295 | Direct `showDatePicker` |
| `lib/manageavailability/add_availability_screen.dart` | 219 | Direct `showTimePicker` |

### 2.7 Misleading hardcoded strings (not real date formatting, but flagged)

| File | Line | Issue |
|------|------|-------|
| `lib/file_manager/pre_production_screen.dart` | 178 | `"Opened 2 hours ago"` — hardcoded placeholder |
| `lib/file_manager/file_manager_screen.dart` | 535 | Same |
| `lib/file_manager/post_production_screen.dart` | 156 | Same |

These are static strings, **not** date computations. If real "time ago" logic is ever wired up, add a `formatRelativeTime(DateTime)` method to the util.

---

## 3. Items Missed by Initial Audit

Three findings the first pass didn't catch:

1. **`manage_availability_screen.dart` has a hand-rolled month-name array** (lines 96–112) that bypasses `intl` entirely. Migrate to `DateTimeUtils.formatFullMonthYear`.
2. **`upcoming_shoot_view_detils.dart`** uses old `DateTimeUtils` in 3 places — needs migration like the other consumers.
3. **`.toIso8601String()` for API outbound** at `home_screen.dart:1771` and `shoots_screen.dart:340`. Sample util exposes `formatApiDate(DateTime)` — should swap to it for consistency (avoids time component leaking into a date-only field).

---

## 4. Sample Util Reference

Source: `testing/date_time_utils.dart` → final destination `lib/utility/date_time_utils.dart`.

### Pattern constants (single source of truth)

```dart
kDatePattern              = "MM-dd-yyyy"
kReadableDatePattern      = "MMM d, yyyy"
kWeekdayDatePattern       = "EEE, dd MMM yyyy"
kTimelineDateTimePattern  = "EEE, dd MMM • hh:mm a"
kFullMonthDatePattern     = "MMMM dd, yyyy"
kMonthYearPattern         = "MMM yyyy"
kWeekdayShortPattern      = "EEE"
kTime24HmsPattern         = "HH:mm:ss"
kTime24HmPattern          = "HH:mm"
kTime12HourPattern        = "hh:mm a"
kTime12HourShortPattern   = "h:mm a"
kDayOfMonthPattern        = "d"
kMonthShortPattern        = "MMM"
kYearPattern              = "yyyy"
kMonthDayPattern          = "MMM d"
kDateTimePattern          = "MM-dd-yyyy hh:mm a"
```

### Methods exposed

`formatDate`, `formatDateValue`, `formatReadableDate`, `formatWeekdayDate`, `formatTimelineDateTime`, `formatFullMonthDate`, `formatMonthYear`, `formatWeekdayShort`, `formatTime`, `formatTimeWithoutLeadingZero`, `formatTimeOfDay`, `formatTimeOfDayShort`, `formatDuration`, `formatApiDate`, `formatApiTime`, `formatMonthDaysWithCommaYear`, `formatSelectedDaysWithLastMonthYear`, `formatGroupedSelectedDaysLabel`, `formatGroupedMonthDays`, `formatCardDateRange`, `formatDateTime`.

---

## 5. Gap Analysis — Patterns Not Yet in Sample

| Pattern | Used in | In sample? | Decision | Action |
|---------|---------|------------|----------|--------|
| `dd/MM/yyyy` | `add_availability_screen` ×4 | ❌ | **Keep `dd/MM/yyyy`** (non-US, intentional) | **Add** `kDatePickerInputPattern = "dd/MM/yyyy"` + `formatDatePickerInput(DateTime)` + `parseDatePickerInput(String?)` |
| `MMMM yyyy` | `home_screen:345`, `manage_availability:111` (manual) | ❌ (sample has `MMM yyyy`) | Keep `MMMM yyyy` (full month name) | **Add** `kFullMonthYearPattern = "MMMM yyyy"` + `formatFullMonthYear(DateTime?)` |
| `MMM dd, yyyy` | `home_screen:355`, `shoots_screen:348` | ⚠ sample has `MMM d, yyyy` | **Use `MMM dd, yyyy`** (leading zero) | **Override** sample → set `kReadableDatePattern = "MMM dd, yyyy"` |
| `dd-MM-yyyy` | old `DateTimeUtils.formatDate` consumers | ❌ (sample uses `MM-dd-yyyy`) | **Switch to `MM-dd-yyyy`** (US-style) — visual flip accepted at all 3 consumer sites | Use sample's `kDatePattern = "MM-dd-yyyy"` as-is |
| `MMMM d, yyyy` | `add_availability:375` | ✅ close to `kFullMonthDatePattern` (`MMMM dd, yyyy`) | Use sample `MMMM dd, yyyy` (leading zero) | Migrate to `formatFullMonthDate` |
| `MMM d, yyyy h:mm a` | old `DateTimeUtils.formatDateTime` | ⚠ sample has `EEE, dd MMM • hh:mm a` | Add separate readable variant (preserve current shape) | **Add** `kReadableDateTimePattern = "MMM dd, yyyy h:mm a"` + `formatReadableDateTime(String?)` |

### Additions/overrides required in the new util

```dart
// Override existing sample pattern (leading-zero day)
static const String kReadableDatePattern = "MMM dd, yyyy";

// New patterns
static const String kDatePickerInputPattern   = "dd/MM/yyyy";
static const String kFullMonthYearPattern     = "MMMM yyyy";
static const String kReadableDateTimePattern  = "MMM dd, yyyy h:mm a";

// New methods
static String formatDatePickerInput(DateTime? date, {String fallback = "--"});
static DateTime? parseDatePickerInput(String? input);
static String formatFullMonthYear(DateTime? date, {String fallback = "--"});
static String formatReadableDateTime(String? isoDateTime, {String fallback = "--"});
```

> **Note**: `kMonthDayPattern = "MMM d"` (used in range formatting like `May 19–21`) stays unchanged — short-form day-only is correct in that context.

---

## 6. Migration Plan — Per File

Each row maps an existing call site to its target call.

### `lib/manageavailability/add_availability_screen.dart` (8 sites + 1 picker)

| Line | Current | Target |
|------|---------|--------|
| 119 | `DateFormat("dd/MM/yyyy").parse(dateController.text)` | `DateTimeUtils.parseDatePickerInput(dateController.text)` |
| 122 | `DateFormat("yyyy-MM-dd").format(parsedDate)` | `DateTimeUtils.formatApiDate(parsedDate)` |
| 134 | `DateFormat("dd/MM/yyyy").parse(...)` | `DateTimeUtils.parseDatePickerInput(...)` |
| 138 | `DateFormat("yyyy-MM-dd").format(parsedUntil)` | `DateTimeUtils.formatApiDate(parsedUntil)` |
| 256–259 | `DateTime(now.y, m, d, picked.hour, picked.minute)` + `DateFormat("hh:mm a").format(dt)` | `DateTimeUtils.formatTimeOfDayShort(picked)` (or `formatApiTime` for backend) |
| 340 | `DateFormat("dd/MM/yyyy").format(picked)` | `DateTimeUtils.formatDatePickerInput(picked)` |
| 372 | `DateFormat("dd/MM/yyyy").parse(untilDate)` | `DateTimeUtils.parseDatePickerInput(untilDate)` |
| 375 | `DateFormat("MMMM d, yyyy").format(parsed)` | `DateTimeUtils.formatFullMonthDate(parsed)` (accepts `MMMM dd, yyyy` — leading-zero diff) |
| — | `import 'package:intl/intl.dart'` | **Remove** |

### `lib/home/home_screen.dart` (5 direct + 2 util + 1 ISO)

| Line | Current | Target |
|------|---------|--------|
| 345 | `DateFormat('MMMM yyyy').format(date)` | `DateTimeUtils.formatFullMonthYear(date)` |
| 355 | `DateFormat('MMM dd, yyyy').format(datum.eventDate)` | `DateTimeUtils.formatReadableDate(datum.eventDate.toIso8601String())` (renders `MMM dd, yyyy` — same shape) |
| 1186, 1453 | `DateFormat.E().format(day)` | `DateTimeUtils.formatWeekdayShort(day)` |
| 1770 | `DateTimeUtils.formatDate(...)` (old, `dd-MM-yyyy`) | `DateTimeUtils.formatDate(...)` (new, `MM-dd-yyyy`) — **visual flip accepted** |
| 1771 | `data?.eventDate.toIso8601String()` | `DateTimeUtils.formatApiDate(data?.eventDate)` |
| 1792 | `DateTimeUtils.formatTime(...)` | unchanged (signature compatible) |
| — | `import 'package:intl/intl.dart'` | **Remove** |

### `lib/shoots/shoots_screen.dart` (4 direct + 2 util + 1 ISO)

| Line | Current | Target |
|------|---------|--------|
| 339 | `DateTimeUtils.formatDate(...)` (old) | unchanged signature, new pattern (`MM-dd-yyyy`) — **visual flip accepted** |
| 340 | `shoot.eventDate.toIso8601String()` | `DateTimeUtils.formatApiDate(shoot.eventDate)` |
| 343 | `DateTimeUtils.formatTime(...)` | unchanged |
| 348 | `DateFormat('MMM dd, yyyy').format(project!.eventDate)` | `DateTimeUtils.formatReadableDate(project!.eventDate.toIso8601String())` (renders `MMM dd, yyyy`) |
| 353–354 | `DateFormat("HH:mm:ss").parse(...)` | **Delete** — `formatTime` handles parse internally |
| 357 | `"${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end)}"` | `"${DateTimeUtils.formatTime(project!.startTime)} - ${DateTimeUtils.formatTime(project.endTime)}"` |

### `lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart` (3 sites)

| Line | Current | Target |
|------|---------|--------|
| 218 | `DateTimeUtils.formatDate(...)` | unchanged signature, new pattern (`MM-dd-yyyy`) — **visual flip accepted** |
| 225 | `DateTimeUtils.formatTime(...)` | unchanged |
| 345 | `DateTimeUtils.formatDateTime(date, time)` | confirm new util's `formatDateTime` signature matches (it does — `(String?, String?)`) |

### `lib/manageavailability/manage_availability_screen.dart` (1 hidden site)

| Line | Current | Target |
|------|---------|--------|
| 96–112 | `_getMonthYear(DateTime)` private fn with `months[]` array | **Delete** entire method, replace call sites with `DateTimeUtils.formatFullMonthYear(date)` |

### `lib/utility/app_utils.dart`

| Line | Current | Target |
|------|---------|--------|
| 39–41 | `static String formatDate(DateTime date) => DateFormat("dd MMM yyyy").format(date)` | **Delete** — dead code |
| 6 | `import 'package:intl/intl.dart'` | **Remove** (no other intl use in file) |
| 30 | `showDatePicker` wrapper | Keep — picker wrapper is orthogonal to formatting |

### `lib/widgets/date_time.dart`

**Delete entire file** after all consumers re-point to `lib/utility/date_time_utils.dart`.

---

## 7. Decisions — Resolved

| # | Question | Decision |
|---|----------|----------|
| 1 | Short-date canonical format | **`MM-dd-yyyy`** (US-style). All sites previously using `dd-MM-yyyy` flip visually. Accepted. |
| 2 | Event card date format | **`MMM dd, yyyy`** (leading-zero day). Sample's `kReadableDatePattern` overridden from `MMM d, yyyy` to `MMM dd, yyyy`. |
| 3 | Date picker input format | **Keep `dd/MM/yyyy`** (non-US, intentional). See §11 summary note. |
| 4 | Locale init | **Skip** `initializeDateFormatting()`. App is English-only. No setup call needed in `startApp`. |
| 5 | PR slicing | Bundled PR is fine. No isolation required for `add_availability_screen`. |

---

## 8. Execution Sequence

```
Step 1 — Land util
  • Copy testing/date_time_utils.dart → lib/utility/date_time_utils.dart
  • Override kReadableDatePattern: "MMM d, yyyy" → "MMM dd, yyyy"
  • Add 3 new pattern constants:
      - kDatePickerInputPattern   = "dd/MM/yyyy"
      - kFullMonthYearPattern     = "MMMM yyyy"
      - kReadableDateTimePattern  = "MMM dd, yyyy h:mm a"
  • Add 4 new methods:
      - formatDatePickerInput(DateTime?)
      - parseDatePickerInput(String?)
      - formatFullMonthYear(DateTime?)
      - formatReadableDateTime(String?)
  • Delete testing/date_time_utils.dart

Step 2 — Migrate consumers (bundled PR)
  • lib/manageavailability/add_availability_screen.dart  (8 sites)
  • lib/home/home_screen.dart                            (5 direct + 2 util + 1 ISO)
  • lib/shoots/shoots_screen.dart                        (4 direct + 2 util + 1 ISO)
  • lib/upcomingshootviewdetils/upcoming_shoot_view_detils.dart (3 sites)
  • lib/manageavailability/manage_availability_screen.dart (delete _getMonthYear)

Step 3 — Delete old utils
  • Remove lib/widgets/date_time.dart
  • Remove AppUtils.formatDate from lib/utility/app_utils.dart
  • Drop unused 'package:intl/intl.dart' imports

Step 4 — Lint guard
  • CI grep: fail if `DateFormat(` appears outside lib/utility/date_time_utils.dart
  • Optional: enforce no direct `intl/intl.dart` import outside the util
```

> **Locale init**: skipped — app is English-only. If non-English support is added later, call `initializeDateFormatting('<locale>')` in `startApp` (`lib/main.dart`) before `runApp`, and set `Intl.defaultLocale`.

---

## 9. Acceptance Criteria

- [ ] Exactly one file imports `package:intl/intl.dart` (`lib/utility/date_time_utils.dart`)
- [ ] Zero direct `DateFormat(...)` calls in screens
- [ ] Zero manual `months[]` arrays or day/month interpolation for display
- [ ] All API-bound dates use `formatApiDate` / `formatApiTime` (no raw `.toIso8601String()` for date-only fields)
- [ ] `flutter analyze` clean
- [ ] Visual regression spot-check on: home calendar, shoots list card, upcoming shoot details, add-availability dialog

---

## 10. Summary of Final Canonical Formats

| Use case | Pattern | Util method |
|----------|---------|-------------|
| Short date (UI compact) | `MM-dd-yyyy` | `formatDate(String?)` / `formatDateValue(DateTime?)` |
| Readable date (cards, lists) | `MMM dd, yyyy` | `formatReadableDate(String?)` |
| Weekday + date | `EEE, dd MMM yyyy` | `formatWeekdayDate(String?)` |
| Full-month date | `MMMM dd, yyyy` | `formatFullMonthDate(DateTime?)` |
| Full-month + year (calendar header) | `MMMM yyyy` | `formatFullMonthYear(DateTime?)` |
| Short month + year | `MMM yyyy` | `formatMonthYear(DateTime?)` |
| Weekday short | `EEE` | `formatWeekdayShort(DateTime?)` |
| Time 12-hr | `hh:mm a` | `formatTime(String?)` |
| Time 12-hr (no leading zero) | `h:mm a` | `formatTimeWithoutLeadingZero(String?)`, `formatTimeOfDayShort(TimeOfDay?)` |
| Readable date-time (cards) | `MMM dd, yyyy h:mm a` | `formatReadableDateTime(String?)` |
| Timeline date-time | `EEE, dd MMM • hh:mm a` | `formatTimelineDateTime(String?)` |
| Date-time compact | `MM-dd-yyyy hh:mm a` | `formatDateTime(String?, String?)` |
| **API date payload** | `yyyy-MM-dd` | `formatApiDate(DateTime?)` |
| **API time payload** | `HH:mm:ss` | `formatApiTime(TimeOfDay?)` |
| **Date picker input (UI)** | `dd/MM/yyyy` | `formatDatePickerInput(DateTime?)`, `parseDatePickerInput(String?)` |
| Duration | `2h 30m` | `formatDuration(double?)` |

---

## 11. Notes / Locale Posture

- **Date picker input format is `dd/MM/yyyy`** (day-first), **not** `MM/dd/yyyy`. This is **intentional and locked in** — kept to match existing user expectations on `add_availability_screen`. The app does **not** currently target US-locale users for picker input. If US-locale support is ever added, switch `kDatePickerInputPattern` to a locale-aware resolver and update both `formatDatePickerInput` and `parseDatePickerInput`.
- **Short date display flipped from `dd-MM-yyyy` → `MM-dd-yyyy`** at 3 consumer sites (`home_screen:1770`, `shoots_screen:339`, `upcoming_shoot_view_detils:218`). This is a visual change accepted as part of this consolidation.
- **App is English-only.** No `initializeDateFormatting()` or `Intl.defaultLocale` setup. Non-English locales require explicit init in `lib/main.dart` `startApp()` before any formatting runs.
- **Picker input format vs API format are distinct on purpose** — `dd/MM/yyyy` is human-friendly; `yyyy-MM-dd` is the backend contract. Do not unify these.
