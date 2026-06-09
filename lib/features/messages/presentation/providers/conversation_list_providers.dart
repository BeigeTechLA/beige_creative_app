import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/conversation.dart';
import 'messages_repository_provider.dart';

const Duration kConversationSearchDebounce = Duration(milliseconds: 250);

@immutable
class ConversationListState {
  final ConversationTab tab;
  final String query;
  final List<Conversation> items;
  final bool isLoading;
  final String? errorMessage;

  const ConversationListState({
    this.tab = ConversationTab.all,
    this.query = '',
    this.items = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ConversationListState copyWith({
    ConversationTab? tab,
    String? query,
    List<Conversation>? items,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ConversationListState(
      tab: tab ?? this.tab,
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

  @override
  ConversationListState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _debounce = null;
    });
    Future.microtask(refresh);
    return const ConversationListState(isLoading: true);
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await ref
          .read(messagesRepositoryProvider)
          .listConversations(tab: state.tab, query: state.query);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e, st) {
      AppLogger.e('Conversations refresh failed', e, st);
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load conversations',
      );
    }
  }

  void selectTab(ConversationTab tab) {
    if (state.tab == tab) return;
    state = state.copyWith(tab: tab);
    refresh();
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
