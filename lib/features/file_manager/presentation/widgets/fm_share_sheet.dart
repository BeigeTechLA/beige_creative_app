import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../domain/models/fm_share.dart';
import '../providers/shares_notifier.dart';

export '../../domain/models/fm_share.dart';

class FmShareSheet extends ConsumerStatefulWidget {
  const FmShareSheet({super.key, required this.target});
  final FmShareTarget target;

  static Future<void> show(
    BuildContext context, {
    required FmShareTarget target,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (_) => FmShareSheet(target: target),
    );
  }

  @override
  ConsumerState<FmShareSheet> createState() => _FmShareSheetState();
}

class _FmShareSheetState extends ConsumerState<FmShareSheet> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  SharesState get _state => ref.read(sharesNotifierProvider(widget.target));
  bool get _busy => _state.loading || _state.busy;
  SharesNotifier get _notifier =>
      ref.read(sharesNotifierProvider(widget.target).notifier);
  FmSharePermission _permission = FmSharePermission.canDownload;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onEmailChanged() => setState(() {});

  bool get _canInvite => !_busy && isValidEmail(_emailController.text.trim());

  Future<void> _invite() async {
    if (!_canInvite) return;
    final success = await _notifier.create(
      email: _emailController.text.trim(),
      message: _messageController.text.trim(),
      permission: _permission,
    );
    if (!mounted || !success) return;
    _emailController.clear();
    _messageController.clear();
    TopMessage.show(context, 'Share created', type: TopMessageType.success);
  }

  Future<void> _copyLink(FmShareRecipient recipient) async {
    final link = recipient.shareLink;
    if (link == null) return;
    try {
      await Clipboard.setData(ClipboardData(text: link));
      if (mounted) {
        TopMessage.show(context, 'Link copied', type: TopMessageType.success);
      }
    } catch (_) {
      if (mounted) {
        TopMessage.show(
          context,
          'Could not copy link',
          type: TopMessageType.error,
        );
      }
    }
  }

  void _activityLog() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (_) => _AccessLogSheet(target: widget.target),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sharesNotifierProvider(widget.target));
    final logs =
        ref.watch(shareAccessLogsProvider(widget.target)).asData?.value ??
        const <FmShareAccessLog>[];
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: FractionallySizedBox(
        heightFactor: 0.85,
        child: Column(
          children: [
            _handle(),
            _header(),
            const Divider(color: AppColors.dividerDark, height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                children: [
                  if (state.loading || state.busy)
                    const LinearProgressIndicator(),
                  if (state.error != null) ...[
                    Text(
                      state.error!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.errorAccent,
                      ),
                    ),
                    TextButton(
                      onPressed: _busy ? null : _notifier.refresh,
                      child: const Text('Retry loading access'),
                    ),
                  ],
                  Text(
                    'Anyone with the link',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Anyone with this link can view and download.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  ...state.shares
                      .where((share) => share.isPublic)
                      .map((share) => _recipientRow(share, logs)),
                  if (!state.shares.any((share) => share.isPublic))
                    OutlinedButton.icon(
                      onPressed: _busy
                          ? null
                          : () => _notifier.create(
                              permission: FmSharePermission.canDownload,
                            ),
                      icon: const Icon(Icons.link),
                      label: const Text('Create link'),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  _labeledField(
                    label: 'Invite by Email',
                    controller: _emailController,
                    hint: 'Enter an email address',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: AppSpacing.base),
                  _labeledField(
                    label: 'Add a Message (Optional)',
                    controller: _messageController,
                    hint: 'Add a note for the recipient...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Permission',
                    style: AppTextStyles.titleSmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _permissionToggle(),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _permission == FmSharePermission.canUploadAndDownload
                        ? 'Only invited recipients can upload files after verifying their email.'
                        : 'Recipients can view and download files after verifying their email.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _inviteButton(),
                  const SizedBox(height: AppSpacing.xl),
                  _peopleHeader(),
                  const SizedBox(height: AppSpacing.md),
                  if (!state.loading &&
                      state.error == null &&
                      !state.shares.any((share) => !share.isPublic))
                    _emptyPeople()
                  else
                    ...state.shares
                        .where((share) => !share.isPublic)
                        .map((share) => _recipientRow(share, logs)),
                ],
              ),
            ),
            const Divider(color: AppColors.dividerDark, height: 1),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _handle() => Container(
    margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: AppColors.textTertiary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.lg,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.md,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    const TextSpan(text: 'Share '),
                    TextSpan(
                      text: '(${widget.target.name})',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Invite people by email or create a link to share access.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _closeButton(),
      ],
    ),
  );

  Widget _closeButton() => Material(
    color: AppColors.surfaceMid,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: () => Navigator.of(context).pop(),
      child: const Padding(
        padding: EdgeInsets.all(AppSpacing.sm),
        child: Icon(Icons.close, size: 20, color: AppColors.textSecondary),
      ),
    ),
  );

  Widget _labeledField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: !_busy,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiary,
        ),
        filled: true,
        fillColor: AppColors.surfaceInput,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
          borderSide: const BorderSide(color: AppColors.borderGoldSolid),
        ),
      ),
    );
  }

  Widget _permissionToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceInput,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        children: [
          _permissionOption(
            FmSharePermission.canDownload,
            Icons.file_download_outlined,
          ),
          _permissionOption(
            FmSharePermission.canUploadAndDownload,
            Icons.cloud_upload_outlined,
          ),
        ],
      ),
    );
  }

  Widget _permissionOption(FmSharePermission value, IconData icon) {
    final selected = _permission == value;
    return Expanded(
      child: GestureDetector(
        onTap: _busy ? null : () => setState(() => _permission = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? AppColors.onPrimary : AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  value.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: selected
                        ? AppColors.onPrimary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inviteButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: _canInvite ? _invite : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.surfaceMid,
          disabledBackgroundColor: AppColors.surfaceMid.withValues(alpha: 0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.md),
          ),
        ),
        child: Text(
          'Invite',
          style: AppTextStyles.labelLarge.copyWith(
            color: _canInvite ? AppColors.primary : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _peopleHeader() => Wrap(
    alignment: WrapAlignment.spaceBetween,
    spacing: AppSpacing.md,
    runSpacing: AppSpacing.sm,
    children: [
      Text(
        'People with Access',
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      GestureDetector(
        onTap: _activityLog,
        child: Text(
          'Activity Log',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
      ),
    ],
  );

  Widget _emptyPeople() => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Text(
      'No one has access yet. Invite someone by email above.',
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
    ),
  );

  Widget _recipientRow(
    FmShareRecipient recipient,
    List<FmShareAccessLog> logs,
  ) {
    final eventCount = _eventCountFor(recipient, logs);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Row(
        children: [
          _fmShareAvatar(recipient.email ?? 'anyone'),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        recipient.email ?? 'Anyone with the link',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (eventCount > 0) ...[
                      const SizedBox(width: AppSpacing.sm),
                      _eventBadge(eventCount),
                    ],
                  ],
                ),
                Text(
                  recipient.permission.label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (recipient.shareLink != null) _copyLinkButton(recipient),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.errorAccent,
            ),
            tooltip: recipient.shareId == null
                ? 'Refresh access to enable removal'
                : 'Remove access',
            onPressed: _busy || recipient.shareId == null
                ? null
                : () => _notifier.revoke(recipient),
          ),
        ],
      ),
    );
  }

  /// Access-log entries attributable to [recipient]. Public link visitors are
  /// logged with a null/`anyone@…` email; named recipients match by address.
  static int _eventCountFor(
    FmShareRecipient recipient,
    List<FmShareAccessLog> logs,
  ) {
    if (recipient.isPublic) {
      return logs
          .where(
            (l) =>
                l.email == null ||
                l.email!.isEmpty ||
                l.email!.toLowerCase().startsWith('anyone@'),
          )
          .length;
    }
    final email = recipient.email!.toLowerCase();
    return logs.where((l) => l.email?.toLowerCase() == email).length;
  }

  Widget _eventBadge(int count) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: 2,
    ),
    decoration: BoxDecoration(
      color: AppColors.surfaceMid,
      borderRadius: BorderRadius.circular(AppRadii.sm),
    ),
    child: Text(
      count == 1 ? '1 EVENT' : '$count EVENTS',
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  );

  Widget _copyLinkButton(FmShareRecipient recipient) => OutlinedButton.icon(
    onPressed: () => _copyLink(recipient),
    style: OutlinedButton.styleFrom(
      side: const BorderSide(color: AppColors.dividerDark),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
    ),
    icon: const Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
    label: Text(
      'Copy Link',
      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary),
    ),
  );

  Widget _footer() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
          ),
          child: const Text('Done'),
        ),
      ),
    ),
  );
}

/// Circular initials avatar matching the web share UI. Initials are the first
/// two alphanumerics of the email local-part (`harsh.patel@…` → `HA`,
/// `anyone` → `AN`). Shared by the recipient rows and the activity log.
Widget _fmShareAvatar(String seed) => Container(
  width: 40,
  height: 40,
  alignment: Alignment.center,
  decoration: const BoxDecoration(
    color: AppColors.surfaceMid,
    shape: BoxShape.circle,
  ),
  child: Text(
    _fmShareInitials(seed),
    style: AppTextStyles.labelMedium.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w700,
    ),
  ),
);

String _fmShareInitials(String seed) {
  final local = seed.split('@').first;
  final letters = local.replaceAll(RegExp('[^A-Za-z0-9]'), '');
  if (letters.isEmpty) return '?';
  return letters.substring(0, letters.length >= 2 ? 2 : 1).toUpperCase();
}

/// Human label for an access-log action. Views (`content_view`,
/// `view_download`... ) collapse to friendlier verbs; unknown actions fall
/// back to the raw string so new server events still render.
String _fmActionLabel(String action) => switch (action) {
  'content_view' => 'View',
  'view_download' => 'View + Download',
  'upload_download' => 'Upload + Download',
  _ => action,
};

const _fmMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// `MMM dd, YYYY`, dropping the year for the current calendar year
/// (e.g. `Sep 18` this year, `Sep 18, 2025` otherwise).
String _fmLogDate(DateTime when) {
  final d = when.toLocal();
  final base = '${_fmMonths[d.month - 1]} ${d.day.toString().padLeft(2, '0')}';
  return d.year == DateTime.now().year ? base : '$base, ${d.year}';
}

class _AccessLogSheet extends ConsumerWidget {
  const _AccessLogSheet({required this.target});
  final FmShareTarget target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(shareAccessLogsProvider(target));
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.65,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Activity Log',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Expanded(
                child: logs.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Could not load activity.'),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(shareAccessLogsProvider(target)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (items) => items.isEmpty
                      ? const Center(child: Text('No activity yet.'))
                      : ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (_, index) {
                            final log = items[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: _fmShareAvatar(log.email ?? 'anyone'),
                              title: Text(
                                log.email ?? 'Link visitor',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                [
                                  _fmActionLabel(log.action),
                                  if (log.createdAt != null)
                                    _fmLogDate(log.createdAt!),
                                ].join(' · '),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
