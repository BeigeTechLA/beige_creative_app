import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/spacing.dart';
import '../../../domain/entities/message.dart';
import 'message_actions_sheet.dart';

/// Swipe-to-reply threshold — matches WhatsApp's ~72dp before releasing
/// commits the reply.
const double _kReplySwipeThreshold = 72;

/// Max horizontal drag before offset resistance kicks in — keeps the bubble
/// from following the finger past sensible bounds.
const double _kMaxDrag = 100;

/// Wraps a message bubble with long-press → action sheet + horizontal
/// swipe → reply. Swipe direction is asymmetric:
///  - peer bubbles: swipe right reveals the reply icon
///  - own bubbles:  swipe left reveals the reply icon
class MessageGestureWrapper extends StatefulWidget {
  const MessageGestureWrapper({
    super.key,
    required this.message,
    required this.isMine,
    required this.onReply,
    required this.onReact,
    required this.child,
  });

  final Message message;
  final bool isMine;
  final VoidCallback onReply;
  final ValueChanged<String> onReact;
  final Widget child;

  @override
  State<MessageGestureWrapper> createState() => _MessageGestureWrapperState();
}

class _MessageGestureWrapperState extends State<MessageGestureWrapper>
    with SingleTickerProviderStateMixin {
  double _dragOffset = 0;
  bool _thresholdReached = false;
  late final AnimationController _snapController;
  late Animation<double> _snapAnimation;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _snapAnimation = AlwaysStoppedAnimation(0);
    _snapController.addListener(() {
      setState(() => _dragOffset = _snapAnimation.value);
    });
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  bool get _isInteractive => widget.message.type != MessageType.system;

  double _normalize(double raw) {
    if (widget.isMine) {
      return raw > 0 ? 0 : raw.clamp(-_kMaxDrag, 0);
    }
    return raw < 0 ? 0 : raw.clamp(0, _kMaxDrag);
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_isInteractive) return;
    final next = _normalize(_dragOffset + d.delta.dx);
    final reached = next.abs() >= _kReplySwipeThreshold;
    if (reached != _thresholdReached) {
      _thresholdReached = reached;
    }
    setState(() => _dragOffset = next);
  }

  void _onDragEnd(DragEndDetails _) {
    if (!_isInteractive) return;
    if (_thresholdReached) {
      widget.onReply();
    }
    _thresholdReached = false;
    _snapAnimation = Tween<double>(begin: _dragOffset, end: 0).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOut),
    );
    _snapController.forward(from: 0);
  }

  Future<void> _onLongPress() async {
    if (!_isInteractive) return;
    final result = await showMessageActionsSheet(
      context,
      message: widget.message,
      isMine: widget.isMine,
    );
    if (result == null) return;
    if (result.isReply) {
      widget.onReply();
    } else if (result.isReaction && result.emoji != null) {
      widget.onReact(result.emoji!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        (_dragOffset.abs() / _kReplySwipeThreshold).clamp(0.0, 1.0);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: _onLongPress,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: Stack(
        alignment: widget.isMine
            ? Alignment.centerRight
            : Alignment.centerLeft,
        children: [
          if (progress > 0)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.screenH + AppSpacing.sm,
              ),
              child: Opacity(
                opacity: progress,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.reply_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ),
          Transform.translate(
            offset: Offset(_dragOffset, 0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
