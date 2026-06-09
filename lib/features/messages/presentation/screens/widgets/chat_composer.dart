import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/durations.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';

/// Composer row — attach, text field, emoji, camera, mic. Send button replaces
/// the mic icon once the field is non-empty. Mic toggles a dummy record state
/// for now; real capture wires later.
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onSendText,
    required this.onAttachPressed,
    required this.onCameraPressed,
    required this.onEmojiPressed,
    required this.onMicToggle,
    required this.isRecording,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSendText;
  final VoidCallback onAttachPressed;
  final VoidCallback onCameraPressed;
  final VoidCallback onEmojiPressed;
  final VoidCallback onMicToggle;
  final bool isRecording;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  late final FocusNode _inputFocus;
  bool _hasText = false;
  bool _isFocused = false;

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
  }

  void _submit() {
    final value = widget.controller.text.trim();
    if (value.isEmpty) return;
    widget.onSendText(value);
    widget.controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRecording) return _RecordingBar(onCancel: widget.onMicToggle);

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
              IconButton(
                tooltip: 'Attach',
                onPressed: widget.onAttachPressed,
                icon: const Icon(
                  Icons.attach_file,
                  color: AppColors.textSecondary,
                ),
              ),
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
              IconButton(
                tooltip: 'Emoji',
                onPressed: widget.onEmojiPressed,
                icon: const Icon(
                  Icons.emoji_emotions_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
              IconButton(
                tooltip: 'Camera',
                onPressed: widget.onCameraPressed,
                icon: const Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.textSecondary,
                ),
              ),
              if (_hasText)
                _SendButton(onTap: _submit)
              else
                IconButton(
                  tooltip: 'Record voice message',
                  onPressed: widget.onMicToggle,
                  icon: const Icon(Icons.mic_none, color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      child: Semantics(
        button: true,
        label: 'Send message',
        child: Material(
          color: AppColors.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: const SizedBox(
              width: 44,
              height: 44,
              child: Icon(Icons.send, color: AppColors.onPrimary, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordingBar extends StatelessWidget {
  const _RecordingBar({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenH,
          vertical: AppSpacing.sm,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceInput,
            borderRadius: AppRadii.fullAll,
            border: Border.all(color: AppColors.dividerDark),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.fiber_manual_record,
                color: AppColors.error,
                size: 14,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Recording... tap mic to stop',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Stop recording',
                onPressed: onCancel,
                icon: const Icon(Icons.stop_circle, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
