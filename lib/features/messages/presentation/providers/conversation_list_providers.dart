import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/conversation.dart';
import '../../domain/events/chat_socket_event.dart';
import 'messages_repository_provider.dart';

const Duration kConversationSearchDebounce = Duration(milliseconds: 250);

/// Coalesces bursts of socket-driven list refreshes (e.g. many messages
/// arriving back-to-back). 500ms is short enough to feel live but long
/// enough to batch chatter.
const Duration kConversationRefreshThrottle = Duration(milliseconds: 500);

@immutable
class ConversationListState {
  final String query;
  final List<Conversation> items;
  final bool isLoading;
  final String? errorMessage;

  const ConversationListState({
    this.query = '',
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ConversationListState copyWith({
    String? query,
    List<Conversation>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConversationListState(
      query: query ?? this.query,
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ConversationListNotifier
    extends AutoDisposeNotifier<ConversationListState> {
  Timer? _debounce;
  Timer? _refreshThrottle;
  StreamSubscription<ChatSocketEvent>? _eventsSub;

  @override
  ConversationListState build() {
    final repo = ref.read(messagesRepositoryProvider);
    ref.onDispose(() {
      _debounce?.cancel();
      _debounce = null;
      _refreshThrottle?.cancel();
      _refreshThrottle = null;
      _eventsSub?.cancel();
      _eventsSub = null;
    });
    _eventsSub = repo.globalEvents().listen(_onGlobalEvent);
    Future.microtask(refresh);
    return const ConversationListState(isLoading: true);
  }

  /// Cross-room signal — any of these means the list view is stale.
  /// Coalesced with [kConversationRefreshThrottle] to absorb bursts.
  void _onGlobalEvent(ChatSocketEvent event) {
    switch (event) {
      case MessageReceived():
      case MessageEdited():
      case MessageDeleted():
      case RoomPreviewUpdated():
      case ParticipantsChanged():
      case RoomStatusChanged():
      case NotificationReceived():
        _scheduleRefresh();
      case _:
        break;
    }
  }

  void _scheduleRefresh() {
    if (_refreshThrottle?.isActive ?? false) return;
    _refreshThrottle = Timer(kConversationRefreshThrottle, refresh);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await ref
          .read(messagesRepositoryProvider)
          .listConversations(query: state.query);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e, st) {
      AppLogger.e('Conversations refresh failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load conversations',
      );
    }
  }

  void updateSearch(String query) {
    state = state.copyWith(query: query);
    _debounce?.cancel();
    _debounce = Timer(kConversationSearchDebounce, refresh);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final conversationListProvider =
    AutoDisposeNotifierProvider<
      ConversationListNotifier,
      ConversationListState
    >(ConversationListNotifier.new);
