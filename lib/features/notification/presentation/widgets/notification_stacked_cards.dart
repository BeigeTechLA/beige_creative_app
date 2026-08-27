import 'package:flutter/material.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../domain/models/notification_item.dart';
import 'notification_item_card.dart';

class NotificationStackedCards extends StatefulWidget {
  const NotificationStackedCards({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<NotificationItem> items;
  final VoidCallback? onTap;

  @override
  State<NotificationStackedCards> createState() =>
      _NotificationStackedCardsState();
}

class _NotificationStackedCardsState extends State<NotificationStackedCards>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (widget.items.isNotEmpty) {
          setState(() {
            _currentIndex = (_currentIndex + 1) % widget.items.length;
          });
          _controller.reset();
        }
      }
    });
  }

  @override
  void didUpdateWidget(covariant NotificationStackedCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      if (_currentIndex >= widget.items.length && widget.items.isNotEmpty) {
        _currentIndex = 0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSwipeNext() {
    if (!_controller.isAnimating && widget.items.isNotEmpty) {
      _controller.forward();
    }
  }

  void _onSwipePrevious() {
    if (!_controller.isAnimating && widget.items.isNotEmpty) {
      setState(() {
        _currentIndex = (_currentIndex - 1 + widget.items.length) % widget.items.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    final n = widget.items.length;

    // Only 1 item -> No stack, just the card
    if (n == 1) {
      return NotificationItemCard(
        item: widget.items[0],
        onTap: widget.onTap, // Still support fallback tap if only 1 item
      );
    }

    // Multiple items -> Swipe + Stack animation
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: GestureDetector(
        onTap: () {
          if (!_controller.isAnimating && widget.items.isNotEmpty) {
            _controller.forward();
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity == null) return;
          if (details.primaryVelocity! > 0) {
            _onSwipePrevious();
          } else if (details.primaryVelocity! < 0) {
            _onSwipeNext();
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final totalWidth = constraints.maxWidth;

            final currentDatum = widget.items[_currentIndex % n];
            final nextDatum = widget.items[(_currentIndex + 1) % n];
            final next2Datum = n > 2 ? widget.items[(_currentIndex + 2) % n] : null;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Layer 3 (Back-most)
                if (next2Datum != null)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: _controller.isAnimating ? -32 : -24,
                    left: totalWidth * 0.07,
                    right: totalWidth * 0.07,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _controller.isAnimating ? 0.5 : 1,
                      child: NotificationItemCard(
                        item: next2Datum,
                        isBackCard: true,
                        onTap: null,
                      ),
                    ),
                  ),

                // Layer 2 (Middle)
                if (n >= 2)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: _controller.isAnimating ? -20 : -12,
                    left: totalWidth * 0.035,
                    right: totalWidth * 0.035,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _controller.isAnimating ? 0.7 : 1,
                      child: NotificationItemCard(
                        item: nextDatum,
                        isBackCard: true,
                        onTap: null,
                      ),
                    ),
                  ),

                // Layer 1 (Main/Front)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _controller.value * 200),
                      child: Opacity(
                        opacity: 1 - _controller.value,
                        child: child,
                      ),
                    );
                  },
                  child: NotificationItemCard(
                    item: currentDatum,
                    onTap: null,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
