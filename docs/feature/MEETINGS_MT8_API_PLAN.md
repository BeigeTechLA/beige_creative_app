# Meetings Module — MT8 API Integration Plan

**Status:** ✅ Complete (2026-06-17) — 13/13 tasks shipped
**Owner:** Mobile (crew app)
**Scope:** Wire crew-side Meetings UI (MT1–MT7) to the real `external-meetings` REST API. UI is frozen; this phase only swaps the repository implementation behind the existing `MeetingsRepository` contract. No socket transport — Meetings is REST-only.
**Prerequisite reading:**
- `docs/feature/MEETINGS_UI_PLAN.md` (UI complete, contract locked)
- `docs/feature/MEETINGS_API.md` (REST surface + confirmed quirks)
- `docs/feature/MESSAGES_M6_API_SOCKET_PLAN.md` (precedent — same pattern, REST-only subset)

---

## 0. Guiding Principles

1. **Contract is frozen — almost.** `MeetingsRepository` (`lib/features/meetings/domain/repositories/meetings_repository.dart`) stays as-is for `list` / `getById` / `create`. New methods (`update`, `delete`, `addParticipants`) added incrementally; existing UI does not change unless an Edit/Delete affordance ships in MT8+.
2. **Single seam = `useDummyMeetingsProvider`.** Default flips `true → false`. Dummy source stays compiled (used by widget tests).
3. **Two-step create flow.** Per `MEETINGS_API.md` §3, the create-body `participants` field is a confirmed dead path. `MeetingsRepositoryImpl.create()` posts the meeting, then conditionally POSTs `/participants` when `input.participants.isNotEmpty`, then returns the final read-back. Caller still sees one `Future<Meeting>`.
4. **Client-side filtering for list.** Server only documents `limit/page/sortBy` query params (`MEETINGS_API.md` §1). `tab` + `MeetingFilter` (category / status / date range) stay client-applied on the fetched page, matching the dummy source's behavior. Backend filter params remain an open question (see §11).
5. **No widget/notifier ever imports `dio`.** Always behind sources. Reuse `dioClientProvider` — base URL `Env.apiUrl` already matches `{{URL}} = https://mobile.beige.app/api/`.

---

## 1. Task Ledger

| Task | Status | Output |
|---|---|---|
| MT8.01 — Env + auth header check | ✅ (2026-06-17) | `AuthInterceptor` already injects `Bearer <token>` (verified against same backend in messages M6 — Q3 strike-through below). `url_launcher: ^6.3.0` already in `pubspec.yaml` from earlier work. Zero code changes — task is verification-only. |
| MT8.02 — Response DTOs | ✅ (2026-06-17) | `data/mappers/meeting_enum_mapper.dart` (status/category/platform), `data/dto/meeting_user_dto.dart` (sub-object → `MeetingParticipant`), `data/dto/meeting_dto.dart` (full Meeting payload → domain). `meeting_order_dto.dart` skipped — collapses to one line in `MeetingDto` (`order?['name']`). `meeting_participant_response_dto.dart` skipped — RSVPs out of MT8 scope (§12). `pagination_envelope.dart` reused from messages M6 unchanged. Analyze clean. |
| MT8.03 — `MeetingsRemoteSource` impl | ✅ (2026-06-17) | 6 methods shipped (`list`/`getById`/`create`/`addParticipants`/`update`/`delete`). `ApiEndpoints` extended w/ `meetings`, `meetingById`, `meetingParticipants`. `_guard` funnel via `ExceptionHandler.mapDioException`. List returns `MeetingsPage{items, hasMore}` (sets up future infinite scroll without UI churn). Create body strips `participants`/`duration`; `created_by_id` resolved from `SessionStore.readUser()`; `reminder_minutes` forwarded pending Q4. `update` defensively strips `duration`. Analyze clean. |
| MT8.04 — Repository impl (composition) | ✅ (2026-06-17) | `data/repositories/meetings_repository_impl.dart` Dio-backed. `create()` chains POST → optional POST `/participants` (only when input has any participant id). Skip re-read GET — `addParticipants` response is full updated Meeting (saves one round-trip). `list()` calls remote then applies client-side `tab` + `MeetingFilter` (lifted verbatim from dummy). `getById` direct passthrough. Analyze clean. |
| MT8.05 — Contract widening (additive) | ✅ (2026-06-17) | `MeetingsRepository` extended w/ `update` / `delete` / `addParticipants`. New `UpdateMeetingInput` domain model (nullable fields; `duration` deliberately absent). Impl serializes to snake_case patch body w/ null-skip. Dummy stubs `UnimplementedError`. `_FakeMeetingsRepository` in widget tests updated w/ matching stubs. Meetings test suite 5/5 green; analyze clean. |
| MT8.06 — Enum mapping layer | ✅ (2026-06-17; folded into MT8.02) | Shipped as `data/mappers/meeting_enum_mapper.dart` during MT8.02 — `statusFromServer`/`statusToServer`, `categoryFromServer`/`categoryToServer`, `platformFromLink`. Open-enum-safe fallback (`MeetingStatus.upcoming`, `MeetingCategory.commercial`). |
| MT8.07 — Platform derivation from `meetLink` | ✅ (2026-06-17; folded into MT8.02) | `MeetingEnumMapper.platformFromLink(String?)` — case-insensitive host-match `zoom.us`/`zoom.com → zoom`, `teams.microsoft.com`/`teams.live.com → teams`, default `meet`. Called from `MeetingDto.fromRestJson`. |
| MT8.08 — Provider wiring | ✅ (2026-06-17) | `meetings_repository_provider.dart` extended w/ `_remoteMeetingsSourceProvider` + `_remoteMeetingsRepositoryProvider`. `meetingsRepositoryProvider` switch arm: `useDummy ? dummy : remote impl`. Flag still defaults `true` until MT8.11 flip. Meetings tests 5/5 green; analyze clean. |
| MT8.09 — Notifier adjustments | ✅ (2026-06-17) | `meetings_list_notifier.dart` + `create_meeting_notifier.dart`: catch blocks now extract `AppException.message` (vs ugly `toString()`) w/ generic fallback strings (`Failed to load meetings` / `Could not create meeting`). Auto-logout on `UnauthorizedException` via `authStateProvider.notifier.logout()` (matches messages M6 conversation list pattern). `meeting_details_providers.dart` untouched — `AutoDisposeFutureProviderFamily` re-throws and existing MT6.07 Retry button covers reload. No signature changes. Analyze clean; tests 5/5 green. |
| MT8.10 — `url_launcher` for Join CTA | ✅ (2026-06-17) | New `presentation/util/launch_meeting_link.dart` helper: `Uri.tryParse` + scheme guard → `launchUrl(externalApplication)` → snackbar fallback on parse fail / `canLaunch` false / thrown `PlatformException`. `meetings_screen._onJoin` (MT2.02 stub) + `meeting_details_sheet._onJoin` (MT6.06 stub) both delegate. Empty-link snackbar guards against missing `meetLink`. `url_launcher: ^6.3.0` already in pubspec (MT8.01). Analyze clean; tests 5/5 green. |
| MT8.11 — Flag flip + dummy retention | ✅ (2026-06-17) | `useDummyMeetingsProvider` default flipped `true → false`. Dummy source + seed retained (widget tests override `meetingsRepositoryProvider.overrideWithValue(_FakeMeetingsRepository())` wholesale per MT7 pattern, so flag arm untouched). Meetings test suite 5/5 green; full `flutter test` = 527 pass / 1 fail (pre-existing `messages_bubbles_dark.png` pixel diff from commit `1e1ee75` chat bubble redesign — unrelated to meetings work, golden needs refresh in next messages pass). |
| MT8.12 — Integration tests | ✅ (2026-06-17) | 14 new tests across 2 files (mocktail instead of `http_mock_adapter` — matches messages M6.12 precedent). **Remote source** (8): list envelope → `MeetingsPage`; page/limit/sortBy forwarded; 500 → `ServerException`; getById map; create POST body omits participants+duration & carries `created_by_id` from session; addParticipants body (`role:'participant'`, string `user_ids`); update PATCH strips `duration`; delete on 2xx. **Repository impl** (6): tab=upcoming excludes completed; tab=completed isolates; `MeetingFilter` category shrink + asc sort; 2-step skip when no participants; 2-step chain when participants present; empty-id participants skipped. Meetings suite 19/19 green; analyze clean. |
| MT8.13 — Analyze + smoke | ✅ (2026-06-17) | Static: `flutter analyze` clean repo-wide. Full `flutter test` = 541 pass / 1 fail. Single failure is pre-existing `test/golden/messages_test.dart` `messages_bubbles_dark.png` (11.61% pixel diff from commit `1e1ee75` chat bubble redesign — unrelated to MT8; golden needs refresh in next messages pass). MT8 net delta: +14 tests (527 → 541), every MT8 test green. Manual smoke runbook in §15. |

---

## 2. Env + Dependencies

### 2.1 `pubspec.yaml`
**Resolved (2026-06-17):** `url_launcher: ^6.3.0` already present from earlier UI work. No new socket or networking deps — `dio` already wired.

### 2.2 Env keys
`Env.apiUrl` already matches `MEETINGS_API.md` `{{URL}}`:
- dev → `https://mobile.beige.app/api/`
- prod → `https://mobile.prod.beige.app/api/`

No new env field needed.

### 2.3 Auth header
**Resolved (2026-06-17):** `AuthInterceptor` (`lib/core/network/interceptors/auth_interceptor.dart`) injects `Authorization: Bearer <token>` on every request. Messages M6 confirmed `Bearer` works against the shared backend; meetings inherits without override. `MEETINGS_API.md` §Conventions ⚠️ stems from documentation gap, not enforcement.

### 2.4 Dummy fixtures
Keep `lib/features/meetings/data/dummy/dummy_meetings.dart`. Widget tests in MT7 instantiate the dummy repo directly via provider override; flag flip does not affect them.

---

## 3. Response Shapes & Domain Mapping

Live data confirmed in `MEETINGS_API.md` § Meeting object. Mapping below collapses the rich server shape into the lean client domain (`Meeting`, `MeetingParticipant`).

### 3.1 Meeting (read)

Server payload (trimmed — full structure in `MEETINGS_API.md` §Meeting object):
```json
{
  "id": 34,
  "meeting_status": "rescheduled",
  "meeting_date_time": "2026-06-11T13:30:00.000Z",
  "meeting_end_time": "2026-06-11T14:30:00.000Z",
  "meeting_type": "post_production",
  "meeting_title": "BRAND_PRODUCT Shoot - Punyashree Catch-up",
  "description": null,
  "meetLink": "https://meet.google.com/azi-kwdf-tuo",
  "duration": 60,
  "order": { "id": 4434, "name": "STUDIO Shoot - Rach Studio" },
  "client":  { "id": 198, "name": "Arpit S", "email": "...", "role": "admin" },
  "admin":   { "id": 258, "name": "Beige Sales", ... },
  "cps": [ /* User[] */ ],
  "participants": [ /* User[] */ ],
  "created_by": { "id": 198, ... },
  "participant_responses": [ ... ],
  "change_request": null
}
```

**Mapping → `Meeting`** (`lib/features/meetings/domain/models/meeting.dart`):

| Client field | Server source | Notes |
|---|---|---|
| `id` | `"$id"` | Server int → client String. Stringify at DTO boundary. |
| `title` | `meeting_title` | |
| `description` | `description ?? ''` | Nullable on server; client uses empty string. |
| `project` | `order?.name ?? ''` | Server returns nested `{id, name}`; flatten to name. |
| `platform` | `_platformFromLink(meetLink)` | Derived — server has no `platform` field. See §MT8.07. |
| `startAt` | `meeting_date_time` (ISO 8601) | Parse to `DateTime` (UTC; convert to local for display layer). |
| `endAt` | `meeting_end_time` (ISO 8601) | Same. |
| `link` | `meetLink` | camelCase on server (intentional inconsistency, `MEETINGS_API.md` Q14). |
| `reminderMinutes` | n/a | Not in server payload — default `15`. Send on create but don't expect roundtrip. |
| `status` | `meeting_status` via `meeting_enum_mapper` | Server `pending`/`rescheduled` → `MeetingStatus.upcoming`; server `cancelled`/`completed` → `MeetingStatus.completed`. `initiated`/`reviewer` are filter-only client values, never inbound. |
| `category` | `meeting_type` via mapper | Only `post_production` observed; map → `MeetingCategory.commercial` for now (placeholder until backend expands). Open enum — fall back to `commercial` on unknown. |
| `agenda` | n/a | Server has no structured agenda. Either: (a) leave empty, or (b) split `description` on newlines. Pick (a) for MT8 — UI just renders empty list. |
| `participants` | `participants[]` mapped to `MeetingParticipant` | `MeetingParticipant{id: "$id", name, avatarUrl: null}` — server User has `email`/`role` but client doesn't model them. Drop or extend `MeetingParticipant` if Details sheet needs the extra fields. |

**Cross-field nullables observed in API:**
- `description`, `client`, `admin`, `created_by`, `change_request` — can all be `null` in live data. Mapper must guard each.
- `order` can be `null` per schema (Q6 in MEETINGS_API.md — `null` despite valid `order_id`). Treat as `project: ''`.

### 3.2 List envelope

```json
{ "results": [Meeting], "page", "limit", "totalPages", "totalResults" }
```

Reuse `pagination_envelope.dart` from messages M6.02 (generic `PaginationEnvelope<T>`). List source returns `(items, hasMore)` where `hasMore = page < totalPages`. UI doesn't paginate yet (MT2 list is single-shot `limit=100`); cursor scaffolding lands here for future infinite scroll without touching UI.

### 3.3 Create request

Client → Server body (per `MEETINGS_API.md` §3):
```json
{
  "order_id": null,
  "meeting_date_time": "<startAt UTC ISO>",
  "meeting_end_time": "<endAt UTC ISO>",
  "meeting_status": "pending",
  "meeting_type": "post_production",
  "meeting_title": "<title>",
  "description": "<description>",
  "meetLink": "<link>",
  "cp_ids": [],
  "admin_id": null,
  "created_by_id": <currentUserId>,
  "send_notification": true
}
```

**Omitted on purpose:**
- `participants` — confirmed dead path (`MEETINGS_API.md` §3 + Q3). Sent separately in step 2.
- `duration` — server-computed (`MEETINGS_API.md` §5). Never send.
- `id` — server-assigned.

**Field sourcing:**
- `order_id` / `admin_id` — no UI affordance today; send `null` (and let server default). Verify nullability with backend (Q6 below).
- `created_by_id` — from `SessionStore.readUser().id`. Parse string → int.
- `meeting_status` — always `"pending"` on create. UI does not collect status at create time.
- `meeting_type` — currently hardcoded `"post_production"` (only value observed). Open Q7 / MT4 deviation: when UI gains category picker, map `MeetingCategory` → server type.
- `reminderMinutes` — **not in API**. Send under a TBD key (`reminder_minutes`?) and confirm backend stores it. If backend rejects, drop from request and surface as "local reminder only" in UI.

### 3.4 Update (PATCH)

Partial — send only changed scalars. `participants`, `cp_ids`, `order_id` mutability via PATCH is **unconfirmed** (`MEETINGS_API.md` Q12). MT8 update flow handles scalars only; relational changes deferred until backend confirms.

### 3.5 Delete

Response undocumented. Treat any 2xx as success. Throw `MeetingsNetworkException` otherwise.

### 3.6 Add participants

POST `external-meetings/{id}/participants` body:
```json
{ "role": "manager", "user_ids": ["4"] }
```
- `user_ids` is **strings** (per `MEETINGS_API.md` §4 quirk note — diverges from int `cp_ids` in create body).
- `role` field has no effect on result (server always returns `role: "participant"`). Mirror what works: send `"participant"`, ignore the value.
- Response is the **full updated Meeting** — reuse meeting DTO mapper, no separate response shape.

---

## 4. `MeetingsRemoteSource` Implementation

Single Dio-backed source. No socket, no streams, no listeners.

### 4.1 Wiring

```dart
class MeetingsRemoteSource {
  MeetingsRemoteSource(this._client, this._session);
  final DioClient _client;
  final SessionStore _session;
  Dio get _dio => _client.dio;
}
```

Provider:
```dart
final _remoteMeetingsSourceProvider = Provider<MeetingsRemoteSource>(
  (ref) => MeetingsRemoteSource(
    ref.watch(dioClientProvider),
    ref.watch(sessionStoreProvider),
  ),
);
```

### 4.2 Method-by-method

| Contract method | HTTP call | Notes |
|---|---|---|
| `list({page, limit, sortBy})` | `GET external-meetings?page=1&limit=100&sortBy=meeting_date_time:desc` | Returns `PaginationEnvelope<MeetingDto>`. `tab`/`MeetingFilter` applied client-side by repository (§5). |
| `getById(id)` | `GET external-meetings/{id}` | Unwrapped — single object, not paginated. |
| `create(input)` | `POST external-meetings` body per §3.3 | Returns created Meeting (without participants — see §5). |
| `addParticipants(id, userIds)` | `POST external-meetings/{id}/participants` body `{role: 'participant', user_ids: <stringified>}` | Returns full updated Meeting. |
| `update(id, patch)` | `PATCH external-meetings/{id}` body — only fields in `patch`. Strip `duration` defensively. | |
| `delete(id)` | `DELETE external-meetings/{id}` | Return void on 2xx. |

### 4.3 Endpoints constants

Append to `lib/core/network/api_endpoints.dart`:
```dart
// ───── Meetings (MT8) ─────────────────────────────────────
static const String meetings = 'external-meetings';
static String meetingById(String id) => 'external-meetings/$id';
static String meetingParticipants(String id) =>
    'external-meetings/$id/participants';
```

### 4.4 Error handling

Wrap each call:
```dart
try { ... }
on DioException catch (e) {
  throw ExceptionHandler.mapDioException(e); // already used by messages M6
}
```
Notifier catches and surfaces via existing `MeetingsListStatus.error` / `CreateMeetingSubmitStatus.error`.

---

## 5. `MeetingsRepositoryImpl` (Composition)

Orchestrates 2-step create + client-side filter without leaking either to UI.

```dart
class MeetingsRepositoryImpl implements MeetingsRepository {
  MeetingsRepositoryImpl(this._remote);
  final MeetingsRemoteSource _remote;

  @override
  Future<List<Meeting>> list({MeetingStatus? tab, MeetingFilter? filter}) async {
    final envelope = await _remote.list(
      page: 1, limit: 100, sortBy: 'meeting_date_time:desc',
    );
    final items = envelope.results.map((dto) => dto.toDomain()).toList();
    return _applyClientFilters(items, tab, filter);
  }

  @override
  Future<Meeting> getById(String id) async => (await _remote.getById(id)).toDomain();

  @override
  Future<Meeting> create(CreateMeetingInput input) async {
    final created = await _remote.create(input);                   // step 1
    if (input.participants.isEmpty) return created.toDomain();
    final ids = input.participants.map((p) => p.id).toList();
    final patched = await _remote.addParticipants(created.id, ids); // step 2 (returns full Meeting)
    return patched.toDomain();
  }

  // MT8.05 additions
  @override
  Future<Meeting> update(String id, UpdateMeetingInput patch) async =>
      (await _remote.update(id, patch)).toDomain();

  @override
  Future<void> delete(String id) => _remote.delete(id);

  List<Meeting> _applyClientFilters(...) { /* lifted verbatim from dummy */ }
}
```

**Why re-read on create with participants:** add-participants response is documented as the full updated Meeting — no extra GET needed. Saves one round-trip.

**Why client-side filter:** server filter params undocumented (Q1 below). Volumes today (≤30 meetings in observed data) make in-memory filter acceptable. Re-evaluate at pagination time.

---

## 6. Contract Adjustments

### 6.1 Additive new methods (`MeetingsRepository`)

```dart
abstract class MeetingsRepository {
  Future<List<Meeting>> list({MeetingStatus? tab, MeetingFilter? filter});
  Future<Meeting> getById(String id);
  Future<Meeting> create(CreateMeetingInput input);

  // MT8.05 additions — dummy source stubs throw UnimplementedError until UI lands.
  Future<Meeting> update(String id, UpdateMeetingInput patch);
  Future<void> delete(String id);
  Future<Meeting> addParticipants(String id, List<String> userIds);
}
```

`UpdateMeetingInput` (new) mirrors `CreateMeetingInput` but every field nullable — `null` = unchanged. Strip `duration` defensively before serialization.

### 6.2 `CreateMeetingInput.participants`

Currently typed `List<MeetingParticipant>` (with name/avatar). Server only needs IDs. Keep the rich type at the UI boundary; impl extracts `.id` before the network call. No UI churn.

### 6.3 `MeetingParticipant`

Server User sub-object carries `email` + `role`. Current `MeetingParticipant{id, name, avatarUrl}` drops both. Extend only if Details sheet needs them; otherwise leave lean. **Decision: leave lean for MT8.** Track as optional follow-up.

---

## 7. Notifier + UI Wiring

No signature changes — repository contract stable for UI callers.

- **`meetingsListNotifier`**: unchanged. Already calls `repo.list(tab, filter)`. Error envelope routed through existing `MeetingsListStatus.error`.
- **`createMeetingNotifier`**: unchanged. Already catches and surfaces via `CreateMeetingSubmitStatus.error`. Verify error `message` field is populated from `mapDioException` (matches messages M6 pattern).
- **`meetingDetailsProvider`**: unchanged. `AutoDisposeFutureProviderFamily` retries via existing UI Retry button (MT6.07).
- **MT2.02 / MT6.06 Join CTA**: snackbar stub replaced with `launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication)`. Wrap in try/catch → snackbar on `LaunchUrlException`.

---

## 8. Error + Network UX

- Reuse `ExceptionHandler.mapDioException` (already used by messages M6.03). Surfaces:
  - `UnauthorizedException` on 401 → drives session-store logout via existing app shell listener.
  - `NetworkException` on connection failures → list shows error column + Retry; create surfaces snackbar.
  - `ServerException` on 5xx → same path.
- No offline-queue or retry-tap UX in MT8. Failed create surfaces error; user retries by tapping submit again.
- No socket → no reconnect banner.

---

## 9. Flag Flip + Dummy Retention

- `useDummyMeetingsProvider` default → `false`.
- Override to `true` in `test/features/meetings/...` widget tests (MT7 pattern — already overrides `meetingsRepositoryProvider` wholesale, so this flag is belt-and-suspenders).
- Dummy source + seed data remain bundled. No build-flavor stripping.

---

## 10. Test Plan (MT8.12)

| Layer | What | Tooling |
|---|---|---|
| Remote source | Each REST method maps payloads correctly; sort/page query params; raises `MeetingsNetworkException` on Dio errors | `http_mock_adapter` |
| Repository impl | 2-step create only chains add-participants when ids present; client-side `tab` excludes `completed` from `upcoming`; `MeetingFilter` category/status/dateRange shrink results | Provider container w/ fake remote source |
| Enum mapper | Each server status maps to client `MeetingStatus`; unknown values fall back to `upcoming`; same for `meeting_type → MeetingCategory` | Pure unit |
| Notifier | Error envelope drives `MeetingsListStatus.error`; create error drives `CreateMeetingSubmitStatus.error` | Provider container + manual throw injection |
| Smoke | Real dev backend: list / details / create-with-participants / join-link / delete-via-cURL roundtrip | Manual |

---

## 10.1 Status Code Envelope (confirmed 2026-06-17)

**Success:**
- `200 OK` — list / getById / addParticipants / update / delete
- `201 CREATED` — create

**Errors:**
- `400 BAD REQUEST` — malformed body / validation
- `401 UNAUTHORIZED` — missing or expired token
- `403 FORBIDDEN` — authed but no permission for the resource
- `404 NOT FOUND` — meeting id or sub-resource missing
- `500 INTERNAL SERVER ERROR` — backend failure

**Client mapping** (via `ExceptionHandler.mapDioException`):

| Status | `AppException` subtype | UI behavior |
|---|---|---|
| 400 | `ServerException` (default bucket; no dedicated `BadRequestException`) | Snackbar w/ server message |
| 401 | `UnauthorizedException` | `meetings_list_notifier` / `create_meeting_notifier` auto-call `authStateProvider.notifier.logout()` (MT8.09) |
| 403 | `ForbiddenException` | Snackbar |
| 404 | `NotFoundException` | Snackbar / details sheet Retry |
| 500 | `ServerException` | Snackbar |

No code change needed — `_mapStatusCode` already covers all of these; 400 → `ServerException` default branch is acceptable (no `ValidationException` separation for this feature today).

---

## 11. Open Questions for Backend (resolve before MT8.03)

1. **Filter query params** on `GET external-meetings` — does the API support `meeting_status` / `meeting_type` / date range, or is client-side filter forever? (MT8 assumes client-side.)
2. **`sortBy` allowed fields** — only `meeting_date_time:desc` observed; backend confirms full sortable field set.
3. ~~**Auth header format** — `Bearer {{CP_TOKEN}}` or raw?~~ **RESOLVED 2026-06-17** — `AuthInterceptor` injects `Bearer <token>`; messages M6 confirmed against same backend. `MEETINGS_API.md` §Conventions ⚠️ inferred from snippet, not enforced.
4. **`reminder_minutes`** — accept on POST/PATCH? If not, drop from request body and document as local-only.
5. **`meeting_type` allowed values** — only `post_production` observed across 30 records; client needs full set to map `MeetingCategory`.
6. **`order_id` / `admin_id` nullability** — can create body omit / send `null` when UI has no order picker?
7. **`participant.role` on add-participants** — backend confirms it's ignored (per `MEETINGS_API.md` §4) — should client send anything, or omit?
8. ~~**DELETE response**~~ **RESOLVED 2026-06-17** — `200 OK` on success. Soft vs hard still unconfirmed but irrelevant client-side; impl treats 2xx as success.
9. ~~**Create response status**~~ **RESOLVED 2026-06-17** — `201 CREATED`. Source/impl accept any 2xx (Dio default), so no code change needed.
10. **PATCH on relational fields** (`participants`, `cp_ids`, `order_id`) — supported? (`MEETINGS_API.md` Q12.)
11. **`meetLink` casing** — intentional camelCase or backend typo? Locking to camelCase for now (matches all 30 read records).
12. **`change_request` shape** — always `null` in samples (`MEETINGS_API.md` Q8); structure when populated.
13. **User `role` open enum** — `creative` surfaced late; client treats as open enum w/ fallback.
14. ~~**Error response shape**~~ **RESOLVED 2026-06-17** — status code envelope confirmed (see §10.1).

---

## 12. Out of Scope (MT8)

- Edit-meeting UI surface (PATCH plumbing lands; UI ships separately).
- Delete-meeting UI surface (plumbing lands; UI ships separately).
- Participant invite picker / search / removal UI.
- Order / admin / category pickers on Create form.
- Push reminders, calendar export, ICS download.
- RSVP / accept-decline flow (`participant_responses` is read-only in MT8).
- Real-time updates (no socket; meetings refresh only on pull-to-refresh + `ref.invalidate` post-create).
- Pagination UI (single-shot `limit=100` matches MT2 list behavior).

---

## 13. Sequence: Create Meeting (end-to-end)

```
User fills form + taps "Create & Send Invite"
  ↓ CreateMeetingScreen → createMeetingNotifier.submit()
  ↓ build CreateMeetingInput from state
  ↓ repo.create(input)
     ↓ MeetingsRemoteSource.create → POST /external-meetings (no participants)
     ↓ 200/201 → MeetingDto (participants: [])
     ↓ if input.participants.isEmpty → return mapped Meeting
     ↓ else MeetingsRemoteSource.addParticipants(id, userIds)
        ↓ POST /external-meetings/:id/participants { role:'participant', user_ids: [...] }
        ↓ 200 → full updated MeetingDto (participants populated)
        ↓ return mapped Meeting
  ↓ notifier sets CreateMeetingSubmitStatus.success
  ↓ ref.listen on screen: invalidate meetingsListNotifierProvider + pushReplacementNamed(meetingScheduled)
```

## 14. Sequence: List + Filter

```
MeetingsScreen built → meetingsListNotifier.build()
  ↓ repo.list(tab: currentTab, filter: currentFilter)
     ↓ MeetingsRemoteSource.list(page:1, limit:100, sortBy:'meeting_date_time:desc')
     ↓ PaginationEnvelope<MeetingDto> → List<Meeting>
     ↓ _applyClientFilters(items, tab, filter) (lifted from dummy)
     ↓ sort by startAt asc
  ↓ render
User taps filter sheet → applies → notifier.applyFilter(new)
  ↓ same path; re-applies client filter without re-fetching
```

---

## 15. Manual Smoke Runbook (MT8.13)

Run on a real device against dev backend.

```bash
flutter run --flavor dev --dart-define-from-file=env/dev.json -t lib/main_dev.dart
```

| # | Action | Expected | What it verifies |
|---|---|---|---|
| 1 | Cold start, log in, open Meetings tab | List renders from `GET external-meetings`; meetings sorted by start time | `list` + envelope unwrap + enum mapper |
| 2 | Pull to refresh | Re-fetches; list updates if backend changed | Notifier refresh hook |
| 3 | Tap "Filter" → pick Category + status → Apply | List shrinks to matches | Client-side `MeetingFilter` |
| 4 | Tap a meeting card | Details sheet opens; agenda empty, participants populated | `getById` + DTO mapper + nullable guard |
| 5 | Tap "Join Meeting" | `meetLink` opens in external browser / Meet app | `url_launcher` + platform-derived chip |
| 6 | Tap "+ Create" → fill form → submit | Network: POST `/external-meetings` (single call when no participants); success screen → list refreshed w/ new row | `create` step 1 only |
| 7 | Repeat (6) with at least one participant attached | Network: POST `/external-meetings` then POST `/external-meetings/:id/participants`; details sheet for new row shows participant | `create` 2-step chain |
| 8 | Disable network + submit form | Snackbar "Network error…"; form stays editable | `mapDioException` → `CreateMeetingSubmitStatus.error` |
| 9 | Log out from drawer | Subsequent API hits would 401 — verified by re-opening list (re-login flow) | Auth header tear-down |

### Known live limitations (carried from MT2 / MT6)
- **Edit / Delete UI**: deferred. PATCH / DELETE plumbing lives but no surface.
- **Participant invite picker**: still static. Form sends whatever the dummy `MeetingParticipant` list contains (currently empty in production form — MT4 deviation).
- **`reminder_minutes`**: sent but backend behavior unconfirmed (Q4).
- **`meeting_type`**: hardcoded `"post_production"` on create until category mapping confirmed (Q5).
- **Prod base URL**: `Env.apiUrl = https://mobile.prod.beige.app/api/` — verify w/ backend before prod build.

### Bug-report template (if smoke uncovers issues)

```
Step #: ___
Expected: ___
Actual: ___
Console log snippet: ___
Network tab / backend log: ___
```