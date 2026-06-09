import 'package:flutter/material.dart';

import '../../../../../app/colors.dart';
import '../../../../../app/durations.dart';
import '../../../../../app/radii.dart';
import '../../../../../app/spacing.dart';
import '../../../../../app/text_styles.dart';

class DetailsSectionCard extends StatefulWidget {
  const DetailsSectionCard({
    super.key,
    required this.icon,
    required this.title,
    this.trailingCount,
    this.initiallyExpanded = false,
    this.body,
  });

  final IconData icon;
  final String title;
  final int? trailingCount;
  final bool initiallyExpanded;
  final Widget? body;

  @override
  State<DetailsSectionCard> createState() => _DetailsSectionCardState();
}

class _DetailsSectionCardState extends State<DetailsSectionCard> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenH,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.xlAll,
      ),
      child: Column(
        children: [
          Semantics(
            button: widget.body != null,
            label:
                '${widget.title} section, '
                '${_expanded ? 'expanded' : 'collapsed'}',
            child: InkWell(
              borderRadius: AppRadii.xlAll,
              onTap: widget.body == null
                  ? null
                  : () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.body15Medium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          children: [
                            TextSpan(text: widget.title),
                            if (widget.trailingCount != null)
                              TextSpan(
                                text: ' (${widget.trailingCount})',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (widget.body != null)
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
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: widget.body ?? const SizedBox.shrink(),
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
