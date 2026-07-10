import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/durations.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';

class DetailsSectionCard extends StatefulWidget {
  const DetailsSectionCard({
    super.key,
    required this.leading,
    required this.title,
    this.trailingCount,
    this.initiallyExpanded = false,
    this.collapsible = true,
    this.body,
    this.backgroundColor,
    this.titleColor,
  });

  final Widget leading;
  final String title;
  final int? trailingCount;
  final bool initiallyExpanded;

  /// When false, the body is always rendered and the chevron + tap toggle are
  /// suppressed. Use for sections that must stay open (e.g. participants).
  final bool collapsible;
  final Widget? body;
  final Color? backgroundColor;
  final Color? titleColor;

  @override
  State<DetailsSectionCard> createState() => _DetailsSectionCardState();
}

class _DetailsSectionCardState extends State<DetailsSectionCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.collapsible ? widget.initiallyExpanded : true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.surface,
        borderRadius: AppRadii.xlAll,
        border: Border.all(color: AppColors.participantBoxBorder, width: 1),
      ),
      child: Column(
        children: [
          Semantics(
            button: widget.body != null && widget.collapsible,
            label: widget.collapsible
                ? '${widget.title} section, '
                      '${_expanded ? 'expanded' : 'collapsed'}'
                : '${widget.title} section',
            child: InkWell(
              borderRadius: AppRadii.xlAll,
              onTap: (widget.body == null || !widget.collapsible)
                  ? null
                  : () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    widget.leading,
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: widget.titleColor ?? AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(text: widget.title),
                            if (widget.trailingCount != null)
                              TextSpan(
                                text: ' (${widget.trailingCount})',
                                style: TextStyle(
                                  color:
                                      widget.titleColor ??
                                      AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.body != null && widget.collapsible)
                      AnimatedRotation(
                        duration: AppDurations.fast,
                        turns: _expanded ? 0.25 : 0,
                        child: const Icon(
                          Icons.chevron_right,
                          color: AppColors.textTertiary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.participantBoxBorder,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: widget.body ?? const SizedBox.shrink(),
                ),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: AppDurations.fast,
          ),
        ],
      ),
    );
  }
}
