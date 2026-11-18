import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/providers/core_providers.dart';
import '../providers/delete_account_providers.dart';
import '../widgets/delete_flow_widgets.dart';

class AccountDeletionPendingScreen extends ConsumerStatefulWidget {
  const AccountDeletionPendingScreen({super.key});

  @override
  ConsumerState<AccountDeletionPendingScreen> createState() => _PendingState();
}

class _PendingState extends ConsumerState<AccountDeletionPendingScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) ref.read(deletionProvider.notifier).load();
    });
  }

  Future<void> _close() async {
    await ref.read(authStateProvider.notifier).logout();
    if (mounted) context.goNamed(Routes.login.name);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deletionProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            ExcludeSemantics(
              child: Image.asset(
                'assets/images/delete_flow_backdrop.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: ColoredBox(
                color: AppColors.background.withValues(alpha: .48),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 480,
                  maxHeight: MediaQuery.sizeOf(context).height * .88,
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF282828),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 6),
                          Container(
                            width: 36,
                            height: 5,
                            decoration: BoxDecoration(
                              color: AppColors.white60,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 8, 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: DeleteFlowStyle.warning.withValues(
                                      alpha: .2,
                                    ),
                                  ),
                                  child: Center(
                                    child: SvgPicture.asset(
                                      'assets/svg/delete_flow_pending_warning.svg',
                                      width: 20,
                                      height: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your Account Is Pending Deletion',
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Close and return to login',
                                  onPressed: _close,
                                  icon: SvgPicture.asset(
                                    'assets/svg/delete_flow_close.svg',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DeletionDateText(
                                  prefix:
                                      'Your Beige account has been deactivated following your deletion request. Your eligible data is scheduled for deletion on ',
                                  date: state.request?.dateLabel,
                                ),
                                if (state.request?.id case final String id) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Request ID: $id',
                                    style: DeleteFlowStyle.body,
                                  ),
                                ],
                                if (state.request?.status
                                    case final String status)
                                  Text(
                                    'Status: ${status.replaceAll('_', ' ')}',
                                    style: DeleteFlowStyle.body,
                                  ),
                                const SizedBox(height: 14),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF281704),
                                    border: Border.all(
                                      color: const Color(0xFF975710),
                                      width: .5,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'If you change your mind, you can cancel your deletion request before this date and restore access to your account.',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                DeletionFeedback(
                                  state: state,
                                  onRetry: () => ref
                                      .read(deletionProvider.notifier)
                                      .load(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Divider(
                            height: 1,
                            color: DeleteFlowStyle.border,
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: DeleteFlowButton(
                              label: 'Restore Account & Cancel Deletion',
                              onPressed: state.busy || state.request == null
                                  ? null
                                  : () => context.goNamed(
                                      Routes.cancelAccountDeletion.name,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CancelAccountDeletionScreen extends ConsumerStatefulWidget {
  const CancelAccountDeletionScreen({super.key});

  @override
  ConsumerState<CancelAccountDeletionScreen> createState() => _CancelState();
}

class _CancelState extends ConsumerState<CancelAccountDeletionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted && ref.read(deletionProvider).request == null) {
        ref.read(deletionProvider.notifier).load();
      }
    });
  }

  void _back() => context.goNamed(
    ref.read(deletionProvider).cancelled
        ? Routes.home.name
        : Routes.accountDeletionPending.name,
  );

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(deletionProvider);
    final email = ref.watch(currentSessionUserProvider)?.email ??
        ref.read(prefsProvider).getString('email') ??
        '';
    final at = email.indexOf('@');
    final masked = at > 0
        ? '${email.substring(0, 1)}***${email.substring(at)}'
        : 'your account';
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !state.busy) _back();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (constraints.maxHeight - 24).clamp(
                        0,
                        double.infinity,
                      ),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!state.cancelled) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                tooltip: 'Back',
                                onPressed: state.busy ? null : _back,
                                icon: SvgPicture.asset(
                                  'assets/svg/delete_flow_back.svg',
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Cancel Account Deletion?',
                              style: AppTextStyles.titleSmall.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            DeletionDateText(
                              prefix:
                                  'Your account is currently scheduled for deletion on ',
                              date: state.request?.dateLabel,
                              suffix:
                                  '. If you cancel this process, your account access will be restored. Data already deleted or no longer available may not be recoverable.',
                            ),
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3627),
                                border: Border.all(
                                  color: const Color(0xFF57E48B),
                                  width: .5,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/svg/delete_flow_shield.svg',
                                    width: 30,
                                    height: 30,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Signed in as $masked',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: const Color(0xFF57E48B),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const SizedBox(height: 24),
                            const DeletionSuccessContent(cancelled: true),
                          ],
                          DeletionFeedback(
                            state: state,
                            onRetry: state.cancelled
                                ? null
                                : () => ref
                                      .read(deletionProvider.notifier)
                                      .load(),
                          ),
                          const SizedBox(height: 24),
                          const Spacer(),
                          DeleteFlowButton(
                            label: state.cancelled
                                ? 'Go to Account'
                                : state.busy
                                ? 'Please wait…'
                                : 'Cancel Deletion Request',
                            onPressed: state.busy
                                ? null
                                : state.cancelled
                                ? () => context.goNamed(Routes.home.name)
                                : state.request == null
                                ? null
                                : () => ref
                                      .read(deletionProvider.notifier)
                                      .cancel(),
                          ),
                          if (!state.cancelled) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: state.busy ? null : _back,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(56),
                                  side: const BorderSide(
                                    color: AppColors.white60,
                                    width: .5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                ),
                                child: Text(
                                  'Keep Deletion Request Active',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.titleSmall.copyWith(
                                    fontSize: 14,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
