import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/durations.dart';
import '../../../../app/routes.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../domain/entities/message.dart';
import '../providers/chat_thread_providers.dart';
import '../routes/messages_args.dart';
import 'widgets/attach_action_sheet.dart';
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

class _ChatThreadScreenState extends ConsumerState<ChatThreadScreen> {
  late final TextEditingController _composerCtrl;
  late final ScrollController _scrollCtrl;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _composerCtrl = TextEditingController();
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _composerCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
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

  Future<void> _openAttach(BuildContext ctx) async {
    final kind = await showAttachActionSheet(ctx);
    if (kind == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${kind.name} attach — wired in M6')),
    );
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
            contactName: widget.contactName ?? 'Chat',
            isOnline: state.peerOnline,
            isTyping: state.peerTyping,
            onOpenDetails: _openDetails,
          ),
          Expanded(
            child: _ThreadBody(state: state, scrollController: _scrollCtrl),
          ),
          ChatComposer(
            controller: _composerCtrl,
            isRecording: state.isRecording,
            onSendText: notifier.sendText,
            onAttachPressed: () => _openAttach(context),
            onCameraPressed: () => _openAttach(context),
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
          ),
        ],
      ),
    );
  }
}

class _ThreadBody extends StatelessWidget {
  const _ThreadBody({required this.state, required this.scrollController});

  final ChatThreadState state;
  final ScrollController scrollController;

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

    final sorted = [...state.messages]
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
      items.add(_Item.msg(m, showSenderHeader: showSenderHeader));
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
  _Item.day(this.day) : message = null, showSenderHeader = false;
  _Item.msg(this.message, {required this.showSenderHeader}) : day = null;

  final DateTime? day;
  final Message? message;
  final bool showSenderHeader;

  Widget build() {
    if (day != null) return DaySeparator(day: day!);
    final m = message!;
    final isMine = m.senderId == 'user_me';
    final isAudio = m.type == MessageType.file && (m.file?.isAudio ?? false);
    if (isAudio) {
      return _BubbleEntrance(
        key: ValueKey('message_${m.id}'),
        child: AudioBubble(
          message: m,
          isMine: isMine,
          showSenderHeader: showSenderHeader,
        ),
      );
    }
    return _BubbleEntrance(
      key: ValueKey('message_${m.id}'),
      child: MessageBubble(
        message: m,
        isMine: isMine,
        showSenderHeader: showSenderHeader,
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
