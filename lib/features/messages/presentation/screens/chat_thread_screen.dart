import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/durations.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../domain/entities/message.dart';
import '../../domain/entities/participant.dart';
import '../providers/chat_thread_providers.dart';
import '../routes/messages_args.dart';
import 'widgets/audio_bubble.dart';
import 'widgets/chat_app_bar.dart';
import 'widgets/chat_composer.dart';
import 'widgets/day_separator.dart';
import 'widgets/message_bubble.dart';

class ChatThreadScreen extends ConsumerStatefulWidget {
  const ChatThreadScreen({
    super.key,
    required this.conversationId,
    this.contactName,
  });

  final String conversationId;
  final String? contactName;

  @override
  ConsumerState<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _composerCtrl;
  late final TextEditingController _searchCtrl;
  late final ScrollController _scrollCtrl;
  int _lastCount = 0;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _composerCtrl = TextEditingController();
    _searchCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _composerCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchCtrl.clear();
        _searchQuery = '';
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // App returned to foreground — bump read pointer for the room the user
    // is looking at. Notifier swallows failures (best-effort receipt).
    ref.read(chatThreadProvider(widget.conversationId).notifier).markRead();
  }

  void _maybeScrollToLatest(int count) {
    if (count == _lastCount) return;
    _lastCount = count;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: AppDurations.fast,
        curve: Curves.easeOut,
      );
    });
  }

  void _openDetails() {
    context.pushNamed(
      Routes.chatDetails.name,
      extra: ChatDetailsArgs(conversationId: widget.conversationId).toExtra(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final familyArg = widget.conversationId;
    final state = ref.watch(chatThreadProvider(familyArg));
    final notifier = ref.read(chatThreadProvider(familyArg).notifier);

    ref.listen<ChatThreadState>(chatThreadProvider(familyArg), (prev, next) {
      if (next.errorMessage != null &&
          prev?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
        notifier.clearError();
      }
      _maybeScrollToLatest(next.messages.length);
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          ChatAppBar(
            // Title matches the list tile (`conversation.title` / room name).
            // Don't override with `state.peerName` — chat details may resolve
            // a different display name and that would diverge from the list.
            contactName: widget.contactName ?? state.peerName ?? 'Chat',
            isOnline: state.peerOnline,
            isTyping: state.peerTyping,
            peerRole: state.peerRole,
            onSearch: _toggleSearch,
            onOpenDetails: _openDetails,
          ),
          if (_isSearching)
            _SearchRow(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              onClose: _toggleSearch,
            ),
          Expanded(
            child: _ThreadBody(
              state: state,
              scrollController: _scrollCtrl,
              searchQuery: _searchQuery,
            ),
          ),
          ChatComposer(
            controller: _composerCtrl,
            isRecording: state.isRecording,
            onSendText: notifier.sendText,
            onEmojiPressed: () {
              FocusScope.of(context).unfocus();
            },
            onMicToggle: () {
              if (state.isRecording) {
                notifier.finishRecording(const Duration(seconds: 3));
              } else {
                notifier.toggleRecording();
              }
            },
            onTypingPulse: notifier.notifyTyping,
            onTypingStop: notifier.notifyStopTyping,
          ),
        ],
      ),
    );
  }
}

class _ThreadBody extends StatelessWidget {
  const _ThreadBody({
    required this.state,
    required this.scrollController,
    this.searchQuery = '',
  });

  final ChatThreadState state;
  final ScrollController scrollController;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.messages.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state.errorMessage != null && state.messages.isEmpty) {
      return AppEmptyState(
        icon: Icons.error_outline,
        title: 'Could not load',
        description: state.errorMessage,
      );
    }
    if (state.messages.isEmpty) {
      return const AppEmptyState(
        icon: Icons.chat_bubble_outline,
        title: 'No messages yet',
        description: 'Say hi to start the conversation.',
      );
    }

    final query = searchQuery.trim().toLowerCase();
    final filtered = query.isEmpty
        ? state.messages
        : state.messages.where((m) {
            if ((m.body ?? '').toLowerCase().contains(query)) return true;
            final p = state.participantsById[m.senderId];
            final name = (p?.name.isNotEmpty ?? false)
                ? p!.name
                : m.senderName;
            return name.toLowerCase().contains(query);
          }).toList();

    if (filtered.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off,
        title: 'No matches',
        description: 'No messages matched "$searchQuery".',
      );
    }

    final sorted = [...filtered]
      ..sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final items = <_Item>[];
    DateTime? prevDay;
    for (var i = 0; i < sorted.length; i++) {
      final m = sorted[i];
      final day = DateTime(m.sentAt.year, m.sentAt.month, m.sentAt.day);
      if (prevDay == null || day != prevDay) {
        items.add(_Item.day(day));
        prevDay = day;
      }
      final prev = i > 0 ? sorted[i - 1] : null;
      final showSenderHeader =
          prev == null ||
          prev.senderId != m.senderId ||
          m.sentAt.difference(prev.sentAt).inMinutes > 5;
      items.add(_Item.msg(
        m,
        showSenderHeader: showSenderHeader,
        currentUserId: state.currentUserId,
        participant: state.participantsById[m.senderId],
        peerName: state.peerName,
        peerRole: state.peerRole,
      ));
    }
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) => items[index].build(),
    );
  }
}

class _Item {
  _Item.day(this.day)
      : message = null,
        showSenderHeader = false,
        currentUserId = null,
        participant = null,
        peerName = null,
        peerRole = null;
  _Item.msg(
    this.message, {
    required this.showSenderHeader,
    required this.currentUserId,
    this.participant,
    this.peerName,
    this.peerRole,
  }) : day = null;

  final DateTime? day;
  final Message? message;
  final bool showSenderHeader;
  final String? currentUserId;
  /// Resolved by id match (`message.senderId` == `participant.id`) from the
  /// chat-details `participants.items` list. Null = unknown sender → fall
  /// back to peer/room-level identity.
  final Participant? participant;
  final String? peerName;
  final String? peerRole;

  Widget build() {
    if (day != null) return DaySeparator(day: day!);
    final m = message!;
    final isMine =
        m.senderId == 'user_me' ||
        (currentUserId != null && m.senderId == currentUserId);
    final isAudio = m.type == MessageType.file && (m.file?.isAudio ?? false);
    final senderRole = participant?.role ?? (isMine ? null : peerRole);
    final resolvedName = (participant?.name.isNotEmpty ?? false)
        ? participant!.name
        : (m.senderName.isNotEmpty
            ? m.senderName
            : (isMine ? 'You' : (peerName ?? '')));
    final senderName = resolvedName;
    if (isAudio) {
      return _BubbleEntrance(
        key: ValueKey('message_${m.id}'),
        child: AudioBubble(
          message: m,
          isMine: isMine,
          showSenderHeader: showSenderHeader,
          senderRole: senderRole,
          senderName: senderName,
        ),
      );
    }
    return _BubbleEntrance(
      key: ValueKey('message_${m.id}'),
      child: MessageBubble(
        message: m,
        isMine: isMine,
        showSenderHeader: showSenderHeader,
        senderRole: senderRole,
        senderName: senderName,
      ),
    );
  }
}

class _BubbleEntrance extends StatefulWidget {
  const _BubbleEntrance({super.key, required this.child});

  final Widget child;

  @override
  State<_BubbleEntrance> createState() => _BubbleEntranceState();
}

class _BubbleEntranceState extends State<_BubbleEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.fast);
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _opacity = curve;
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(curve);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({
    required this.controller,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenH,
        AppSpacing.xs,
        AppSpacing.screenH,
        AppSpacing.sm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: AppRadii.lgAll,
          border: Border.all(color: AppColors.dividerDark),
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          children: [
            const Icon(
              Icons.search,
              color: AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                autofocus: true,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  hintText: 'Search in conversation...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Close search',
              onPressed: onClose,
              icon: const Icon(
                Icons.close,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
