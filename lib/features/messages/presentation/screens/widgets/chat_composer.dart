import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/durations.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';

/// Idle window before composer emits `stopTyping`. Matches common chat
/// clients (WhatsApp ≈ 3s).
const Duration kComposerTypingIdle = Duration(seconds: 3);

/// Composer row — text field + send button. Send is the only trailing
/// affordance; it dims when the field is empty. Emoji / mic / attach /
/// camera affordances intentionally absent — file attach is Admin-side on
/// web per booking spec.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSendText,
    this.onTypingPulse,
    this.onTypingStop,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSendText;

  /// Fires once when text becomes non-empty after being empty, then is
  /// suppressed until [onTypingStop] runs.
  final VoidCallback? onTypingPulse;

  /// Fires either after [kComposerTypingIdle] of no edits, or when the field
  /// is cleared / submitted / disposed while still in the typing state.
  final VoidCallback? onTypingStop;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  late final FocusNode _inputFocus;
  bool _hasText = false;
  bool _isFocused = false;

  bool _isTyping = false;
  Timer? _idleTimer;

  @override
  void initState() {
    super.initState();
    _inputFocus = FocusNode();
    _inputFocus.addListener(_onFocusChanged);
    widget.controller.addListener(_onChanged);
    _hasText = widget.controller.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _idleTimer?.cancel();
    if (_isTyping) widget.onTypingStop?.call();
    _inputFocus.removeListener(_onFocusChanged);
    _inputFocus.dispose();
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (_inputFocus.hasFocus != _isFocused) {
      setState(() => _isFocused = _inputFocus.hasFocus);
    }
  }

  void _onChanged() {
    final next = widget.controller.text.trim().isNotEmpty;
    if (next != _hasText) setState(() => _hasText = next);
    _pulseTyping(hasContent: next);
  }

  /// Typing state machine — fires `onTypingPulse` once per typing session,
  /// `onTypingStop` after [kComposerTypingIdle] of silence or when the field
  /// goes empty.
  void _pulseTyping({required bool hasContent}) {
    if (!hasContent) {
      _idleTimer?.cancel();
      _idleTimer = null;
      if (_isTyping) {
        _isTyping = false;
        widget.onTypingStop?.call();
      }
      return;
    }
    if (!_isTyping) {
      _isTyping = true;
      widget.onTypingPulse?.call();
    }
    _idleTimer?.cancel();
    _idleTimer = Timer(kComposerTypingIdle, _emitStopTyping);
  }

  void _emitStopTyping() {
    if (!_isTyping) return;
    _isTyping = false;
    widget.onTypingStop?.call();
  }

  void _submit() {
    final value = widget.controller.text.trim();
    if (value.isEmpty) return;
    widget.onSendText(value);
    widget.controller.clear();
    // Clear cancels the timer + fires stop via _onChanged → _pulseTyping(false).
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.sm,
        ),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: AppRadii.fullAll,
            border: Border.all(
              color: _isFocused
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.dividerDark,
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: _isFocused ? AppSpacing.xxs : 0,
          ),
          child: Row(
            children: [
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _inputFocus,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: 'Write a message...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ),
              _SendButton(enabled: _hasText, onTap: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.enabled, required this.onTap});

  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: 'Send message',
        child: Material(
          color: enabled ? AppColors.primary : AppColors.disabled,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onTap : null,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                Icons.send,
                color: enabled
                    ? AppColors.onPrimary
                    : AppColors.textTertiary,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
