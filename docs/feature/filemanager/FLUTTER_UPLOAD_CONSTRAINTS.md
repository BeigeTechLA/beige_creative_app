# Flutter Upload Constraints — Beige File Manager Feature

Use this as a project rules file for Claude Code. Backend: AWS S3 (direct-to-S3 multipart). Content: RAW photos + high-bitrate video.

## Hard Limits
- Max total size per batch/session: **5GB**
- Max file count per batch: **50 files**
- Both limits are enforced client-side before any network call is made — never after upload starts.
- If either limit is exceeded, block the entire batch from starting. Do not allow a partial batch to proceed while the user trims it — reject, show which files put it over, let them resolve, then re-validate.

## Validation Rules (pre-upload, before any request is sent)
1. Sum selected file sizes immediately after selection completes.
2. Reject if sum > 5GB. Reject if count > 50. Check both independently — one passing does not imply the other passes.
3. Validate file type against an explicit allowlist. Do not trust file extension alone if actual content type is checkable.
4. Validation must fully complete before the "upload" action becomes available in the UI — no race where upload starts before validation finishes.

## Architecture Rules
- Direct-to-S3 multipart upload only. The app backend issues signed URLs and tracks state — it never receives or proxies file bytes.
- Each file in a batch is its own independent multipart upload with its own upload ID.
- One file failing must never abort or block the other files in the batch.
- Batch state = a manifest of per-file states (queued / uploading / paused / failed / complete), not a single batch-wide flag.

## Chunking Rules
- Fixed part size: 8–16MB.
- Never load a full file into memory before splitting it — stream reads only, part by part.
- Chunk reads must not run on the UI/main isolate.

## Background Transfer Rules
- Use the OS-native background transfer mechanism (not a plain foreground HTTP call) so uploads survive backgrounding and app suspension.
- Persist each part's completion status locally as it happens.
- On app relaunch mid-batch, resume from persisted state — never re-upload parts already confirmed complete.

## Network Rules
- Default to Wi-Fi-only for any file or batch over 50MB total. Cellular requires an explicit user override, not a default.
- Detect connectivity loss mid-upload: pause automatically, resume automatically on reconnect. No silent failure and no requirement for the user to manually restart.

## Error Handling & Retry Rules
- Retry at the part level only — never restart a whole file because one chunk failed.
- Exponential backoff between retries, with a capped max retry count per part before that file is marked failed.
- A file exhausting retries must not stop the rest of the batch from continuing.
- Failed files must be surfaced individually in the UI — never swallowed into a generic "upload failed" state.

## Integrity Rules
- Verify a checksum per part before marking that part complete.
- Only call the "complete multipart upload" step after every part for that file is confirmed.

## Cleanup Rules
- User-cancelled uploads must explicitly abort the multipart upload — never leave orphaned parts in the bucket.
- Coordinate with infra: bucket lifecycle policy should auto-abort incomplete multipart uploads after a few days, independent of client behavior.

## State Persistence Rules
- Persist the full batch queue (file list, sizes, per-part progress) locally so an app kill mid-batch is recoverable, not lost.
- A batch is not "complete" until every file's multipart upload is individually confirmed complete — no optimistic batch-complete state.

## Anti-Patterns — Do NOT
- Do NOT proxy file bytes through the app backend.
- Do NOT upload any file over the part-size threshold as a single PUT request.
- Do NOT block the UI thread during file reads or chunking.
- Do NOT allow upload to start before size + count validation both pass.
- Do NOT retry an entire file when only one chunk failed.
- Do NOT drop a failed file silently without surfacing it to the user.
- Do NOT treat the batch as complete while any file is still in a failed or in-progress state.
