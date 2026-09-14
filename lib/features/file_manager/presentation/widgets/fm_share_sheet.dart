import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../domain/models/fm_node.dart';

/// Access level granted to a share recipient. Mirrors the two-state
/// permission toggle in the share sheet.
enum FmSharePermission { canDownload, canUploadAndDownload }

extension FmSharePermissionX on FmSharePermission {
  /// Label shown under a recipient row + in the permission toggle.
  String get label {
    switch (this) {
      case FmSharePermission.canDownload:
        return 'Can Download';
      case FmSharePermission.canUploadAndDownload:
        return 'Can Upload & Download';
    }
  }

  /// Stable value for the share endpoint payload.
  String get apiValue {
    switch (this) {
      case FmSharePermission.canDownload:
        return 'download';
      case FmSharePermission.canUploadAndDownload:
        return 'upload_download';
    }
  }
}

/// The folder or file being shared. Drives the sheet title/subtitle.
@immutable
class FmShareTarget {
  final String id;
  final FmNodeKind kind;
  final String name;

  const FmShareTarget({
    required this.id,
    required this.kind,
    required this.name,
  });
}

/// One person already granted access. `shareLink` (if present) backs the
/// per-row "Copy Link" action.
@immutable
class FmShareRecipient {
  final String email;
  final FmSharePermission permission;
  final String? shareLink;

  const FmShareRecipient({
    required this.email,
    required this.permission,
    this.shareLink,
  });

  FmShareRecipient copyWith({FmSharePermission? permission}) =>
      FmShareRecipient(
        email: email,
        permission: permission ?? this.permission,
        shareLink: shareLink,
      );
}

/// Payload emitted when the user taps **Invite**.
@immutable
class FmShareInvite {
  final String email;
  final String? message;
  final FmSharePermission permission;

  const FmShareInvite({
    required this.email,
    required this.message,
    required this.permission,
  });
}

/// Reusable share bottom sheet for any file-manager node.
///
/// Pure presentation: it owns the transient form state (email, message,
/// permission toggle, working copy of the recipient list) and delegates
/// every side effect back to the caller via callbacks. Reuse it for any
/// folder or file by passing that node's [target] + [recipients] and
/// wiring the callbacks to the relevant repository command.
class FmShareSheet extends StatefulWidget {
  final FmShareTarget target;
  final List<FmShareRecipient> recipients;

  /// One-line rule shown under the title. Defaults to the OTP notice.
  final String subtitle;

  /// Default rule copy — recipients verify via OTP before access.
  static const defaultSubtitle =
      'Recipients must verify their email with an OTP before accessing this file.';

  final ValueChanged<FmShareInvite>? onInvite;
  final ValueChanged<FmShareRecipient>? onCopyLink;
  final ValueChanged<FmShareRecipient>? onRemove;
  final ValueChanged<List<FmShareRecipient>>? onSaveChanges;
  final VoidCallback? onActivityLog;

  const FmShareSheet({
    super.key,
    required this.target,
    this.recipients = const [],
    this.subtitle = defaultSubtitle,
    this.onInvite,
    this.onCopyLink,
    this.onRemove,
    this.onSaveChanges,
    this.onActivityLog,
  });

  static Future<void> show(
    BuildContext context, {
    required FmShareTarget target,
    List<FmShareRecipient> recipients = const [],
    String? subtitle,
    ValueChanged<FmShareInvite>? onInvite,
    ValueChanged<FmShareRecipient>? onCopyLink,
    ValueChanged<FmShareRecipient>? onRemove,
    ValueChanged<List<FmShareRecipient>>? onSaveChanges,
    VoidCallback? onActivityLog,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // Push on the root navigator so the sheet covers the bottom nav
      // shell instead of rendering beneath it.
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (_) => FmShareSheet(
        target: target,
        recipients: recipients,
        subtitle: subtitle ?? defaultSubtitle,
        onInvite: onInvite,
        onCopyLink: onCopyLink,
        onRemove: onRemove,
        onSaveChanges: onSaveChanges,
        onActivityLog: onActivityLog,
      ),
    );
  }

  @override
  State<FmShareSheet> createState() => _FmShareSheetState();
}

class _FmShareSheetState extends State<FmShareSheet> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  late List<FmShareRecipient> _recipients;
  FmSharePermission _permission = FmSharePermission.canDownload;

  @override
  void initState() {
    super.initState();
    _recipients = List.of(widget.recipients);
    _emailController.addListener(_onEmailChanged);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _onEmailChanged() => setState(() {});

  bool get _canInvite {
    final email = _emailController.text.trim();
    return email.contains('@') && email.contains('.');
  }

  void _invite() {
    if (!_canInvite) return;
    final message = _messageController.text.trim();
    widget.onInvite?.call(
      FmShareInvite(
        email: _emailController.text.trim(),
        message: message.isEmpty ? null : message,
        permission: _permission,
      ),
    );
    // Optimistically reflect the new recipient in the local list so the
    // caller sees it in `onSaveChanges` even before a server round-trip.
    setState(() {
      _recipients = [
        ..._recipients,
        FmShareRecipient(
          email: _emailController.text.trim(),
          permission: _permission,
        ),
      ];
      _emailController.clear();
      _messageController.clear();
    });
  }

  void _remove(FmShareRecipient recipient) {
    widget.onRemove?.call(recipient);
    setState(() => _recipients = _recipients
        .where((r) => r.email != recipient.email)
        .toList(growable: false));
  }

  @override
  Widget build(BuildContext context) {
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
                  if (_recipients.isEmpty)
                    _emptyPeople()
                  else
                    ..._recipients.map(_recipientRow),
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
                widget.subtitle,
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
        onTap: () => setState(() => _permission = value),
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

  Widget _peopleHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'People with Access',
        style: AppTextStyles.titleSmall.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (widget.onActivityLog != null)
        GestureDetector(
          onTap: widget.onActivityLog,
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

  Widget _recipientRow(FmShareRecipient recipient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.base),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMid,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
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
          if (recipient.shareLink != null && widget.onCopyLink != null)
            _copyLinkButton(recipient),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.errorAccent,
            ),
            onPressed: () => _remove(recipient),
          ),
        ],
      ),
    );
  }

  Widget _copyLinkButton(FmShareRecipient recipient) => OutlinedButton.icon(
    onPressed: () => widget.onCopyLink?.call(recipient),
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
      style: AppTextStyles.labelMedium.copyWith(
        color: AppColors.textSecondary,
      ),
    ),
  );

  Widget _footer() => SafeArea(
    top: false,
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onSaveChanges?.call(List.unmodifiable(_recipients));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              child: Text(
                'Save Changes',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.surfaceMid,
                side: const BorderSide(color: AppColors.dividerDark),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
              ),
              child: Text(
                'Close',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
