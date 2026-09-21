import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/repositories/shares_repository_remote.dart';
import '../../domain/models/fm_share.dart';
import '../../domain/repositories/shares_repository.dart';

final sharesRepositoryProvider = Provider<SharesRepository>(
  (ref) => SharesRepositoryRemote(ref.watch(dioClientProvider)),
);

class SharesState {
  const SharesState({
    this.shares = const [],
    this.loading = true,
    this.busy = false,
    this.error,
  });
  final List<FmShareRecipient> shares;
  final bool loading;
  final bool busy;
  final String? error;
}

class SharesNotifier
    extends AutoDisposeFamilyNotifier<SharesState, FmShareTarget> {
  late FmShareTarget _target;
  bool _disposed = false;
  bool _refreshing = false;
  SharesRepository get _repo => ref.read(sharesRepositoryProvider);

  @override
  SharesState build(FmShareTarget arg) {
    _target = arg;
    ref.onDispose(() => _disposed = true);
    Future.microtask(() {
      if (!_disposed) refresh();
    });
    return const SharesState();
  }

  Future<void> refresh() async {
    if (_refreshing || state.busy) return;
    _refreshing = true;
    final keepAlive = ref.keepAlive();
    final previous = state.shares;
    state = SharesState(shares: previous, loading: true);
    try {
      final shares = await _repo.list(_target);
      state = SharesState(shares: List.unmodifiable(shares), loading: false);
    } catch (_) {
      state = SharesState(
        shares: previous,
        loading: false,
        error: 'Could not load current access. Please retry.',
      );
    } finally {
      _refreshing = false;
      keepAlive.close();
    }
  }

  bool _sameShare(FmShareRecipient a, FmShareRecipient b) {
    if (a.email != b.email || a.permission != b.permission) return false;
    if (a.shareId != null && b.shareId != null) return a.shareId == b.shareId;
    if (a.shareToken != null && b.shareToken != null) {
      return a.shareToken == b.shareToken;
    }
    return a.shareLink == null ||
        b.shareLink == null ||
        a.shareLink == b.shareLink;
  }

  Future<bool> create({
    String? email,
    required FmSharePermission permission,
    String message = '',
  }) async {
    if (state.busy || state.loading) return false;
    final keepAlive = ref.keepAlive();
    final previous = state.shares;
    state = SharesState(shares: previous, loading: false, busy: true);
    try {
      final created = await _repo.create(
        _target,
        email: email,
        permission: permission,
        message: message,
      );
      final updated = [
        ...previous.where((s) => !_sameShare(s, created)),
        created,
      ];
      // The create contract omits shareId. Re-fetch to obtain the ID used by
      // revoke; retain the returned link if that independent read fails.
      try {
        final shares = await _repo.list(_target);
        final found = shares.any((s) => _sameShare(s, created));
        final merged = shares
            .map(
              (s) => _sameShare(s, created)
                  ? FmShareRecipient(
                      shareId: s.shareId,
                      email: s.email,
                      permission: s.permission,
                      shareToken: s.shareToken ?? created.shareToken,
                      shareLink: s.shareLink ?? created.shareLink,
                    )
                  : s,
            )
            .toList();
        state = SharesState(
          shares: List.unmodifiable(found ? merged : [...shares, created]),
          loading: false,
          error: found
              ? null
              : 'Share created. Refresh access before removing it.',
        );
      } catch (_) {
        state = SharesState(
          shares: List.unmodifiable(updated),
          loading: false,
          error:
              'Share created, but current access could not be refreshed. You can copy the new link.',
        );
      }
      return true;
    } catch (_) {
      state = SharesState(
        shares: previous,
        loading: false,
        error: 'Could not create the share. Please try again.',
      );
      return false;
    } finally {
      keepAlive.close();
    }
  }

  Future<void> revoke(FmShareRecipient share) async {
    if (state.busy || state.loading || share.shareId == null) return;
    final keepAlive = ref.keepAlive();
    final previous = state.shares;
    state = SharesState(shares: previous, loading: false, busy: true);
    try {
      await _repo.revoke(share.shareId!);
      state = SharesState(
        shares: List.unmodifiable(
          previous.where((s) => s.shareId != share.shareId),
        ),
        loading: false,
      );
    } catch (_) {
      state = SharesState(
        shares: previous,
        loading: false,
        error: 'Could not remove access. Please try again.',
      );
    } finally {
      keepAlive.close();
    }
  }
}

final sharesNotifierProvider = NotifierProvider.autoDispose
    .family<SharesNotifier, SharesState, FmShareTarget>(SharesNotifier.new);
final shareAccessLogsProvider = FutureProvider.autoDispose
    .family<List<FmShareAccessLog>, FmShareTarget>(
      (ref, target) => ref.watch(sharesRepositoryProvider).accessLogs(target),
    );
