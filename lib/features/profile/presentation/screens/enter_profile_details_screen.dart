import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import 'package:beige_creative_app/shared/widgets/app_icon_tap_target.dart';
import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/custom_multi_selectfield.dart'
    show CustomMultiSelectField;
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/top_message.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../providers/profile_details_providers.dart';

class EnterProfileDetailsScreen extends ConsumerStatefulWidget {
  const EnterProfileDetailsScreen({super.key});

  @override
  ConsumerState<EnterProfileDetailsScreen> createState() =>
      _EnterProfileDetailsScreenState();
}

class _EnterProfileDetailsScreenState
    extends ConsumerState<EnterProfileDetailsScreen> {
  final experienceController = TextEditingController();
  final rateController = TextEditingController();
  final bioController = TextEditingController();
  bool _initialised = false;

  @override
  void dispose() {
    experienceController.dispose();
    rateController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _hydrateOnce(EnterProfessionalState state) {
    if (_initialised || state.initial == null) return;
    final data = state.initial!;
    experienceController.text = data.yearsOfExperience.toString();
    rateController.text = data.hourlyRate.toString();
    bioController.text = data.bio;
    _initialised = true;
  }

  Future<void> _save() async {
    final ok = await ref
        .read(enterProfessionalNotifierProvider.notifier)
        .submit(
          experience: experienceController.text,
          hourlyRate: rateController.text,
          bio: bioController.text,
        );
    if (!mounted) return;
    if (ok) {
      TopMessage.show(
        context,
        'Profile Updated',
        type: TopMessageType.success,
      );
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EnterProfessionalState>(enterProfessionalNotifierProvider, (
      prev,
      next,
    ) {
      _hydrateOnce(next);
      final v = next.validationMessage;
      if (v != null && v != prev?.validationMessage) {
        TopMessage.show(context, v);
      }
      final e = next.errorMessage;
      if (e != null && e != prev?.errorMessage) {
        TopMessage.show(context, e);
      }
    });

    final state = ref.watch(enterProfessionalNotifierProvider);
    _hydrateOnce(state);

    return AppScaffold(
      safeBottomNavigationBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Row(
                  children: [
                    AppIconTapTarget(
                      semanticLabel: 'Back',
                      onTap: () => context.pop(true),
                      icon: SvgPicture.asset(
                        AppAssets.back,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          AppColors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Edit Professional Details',
                    style: AppTextStyles.headingOutfitLg,
                  ),
                ),
                const SizedBox(height: 30),
                CustomMultiSelectField(
                  label: 'Primary Role*',
                  value: state.selectedRoles.join(', '),
                  hasValue: state.selectedRoles.isNotEmpty,
                  onTap: () async => _openRolesBottomSheet(),
                ),
                const SizedBox(height: 22),
                CustomTextField(
                  label: 'Year of Experience',
                  controller: experienceController,
                  keyboardType: TextInputType.number,
                  maxLength: 2,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
                const SizedBox(height: 22),
                CustomTextField(
                  label: 'Hourly Rate',
                  controller: rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  hint: '0.00',
                  prefixIcon: SizedBox(
                    width: 30,
                    child: Center(
                      child: Text(
                        '\$',
                        style: AppTextStyles.body15.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final regExp = RegExp(r'^\d*\.?\d{0,2}$');
                      if (regExp.hasMatch(newValue.text)) {
                        return newValue;
                      }
                      return oldValue;
                    }),
                  ],
                ),
                const SizedBox(height: 22),
                CustomTextField(
                  label: 'Bio / About',
                  controller: bioController,
                  maxLines: 4,
                ),
                const SizedBox(height: 22),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Highlight your creative focus.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                const SizedBox(height: 12),
                CustomMultiSelectField(
                  label: 'Edit Skills',
                  value: '',
                  hasValue: false,
                  onTap: () async => _openSkillsBottomSheet(),
                ),
                if (state.selectedSkills.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: state.selectedSkills
                          .map(
                            (item) => Chip(
                              label: Text(
                                item,
                                style: AppTextStyles.inherit.copyWith(
                                  color: AppColors.white,
                                  fontSize: 13,
                                ),
                              ),
                              backgroundColor: AppColors.white.withValues(alpha: 0.15),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                              deleteIcon: const Icon(Icons.close, size: 14, color: AppColors.white),
                              onDeleted: () {
                                final draft = List<String>.from(state.selectedSkills)
                                  ..remove(item);
                                ref
                                    .read(enterProfessionalNotifierProvider.notifier)
                                    .setSelectedSkills(draft);
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
          if (state.isLoadingInitial || state.isSubmitting)
            const AppLoadingOverlay(dimOpacity: 0.4),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: AppCtaButton(
          label: 'Save',
          height: 55,
          enabled: !state.isSubmitting,
          onPressed: _save,
        ),
      ),
    );
  }

  void _openRolesBottomSheet() {
    FocusScope.of(context).unfocus();
    final notifier = ref.read(enterProfessionalNotifierProvider.notifier);
    final initial = ref.read(enterProfessionalNotifierProvider);
    final draft = List<String>.from(initial.selectedRoles);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.base,
                AppSpacing.xxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.white24,
                      borderRadius: AppRadii.xsAll,
                    ),
                  ),
                  const Text(
                    'Select Roles',
                    style: AppTextStyles.bodyLargeMedium,
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: initial.roleList.map((role) {
                        final isSelected = draft.contains(role);
                        return CheckboxListTile(
                          value: isSelected,
                          title: Text(role, style: AppTextStyles.body14Medium),
                          activeColor: AppColors.primary,
                          checkColor: AppColors.black,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.lavenderGrey,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.smAll,
                          ),
                          onChanged: (val) {
                            setModalState(() {
                              if (val == true) {
                                if (!draft.contains(role)) draft.add(role);
                              } else {
                                draft.remove(role);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        notifier.setSelectedRoles(draft);
                        sheetCtx.pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: const Color(0xFF1D1D1B),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadii.lgAll,
                        ),
                      ),
                      child: const Text(
                        'Done',
                        style: AppTextStyles.buttonMedium,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openSkillsBottomSheet() {
    final notifier = ref.read(enterProfessionalNotifierProvider.notifier);
    final initial = ref.read(enterProfessionalNotifierProvider);
    final draft = List<String>.from(initial.selectedSkills);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceCropSheet,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.topHuge),
      builder: (sheetCtx) {
        final sheetHeight = MediaQuery.of(sheetCtx).size.height * 0.9;
        return StatefulBuilder(
          builder: (sheetCtx, setModalState) {
            return SafeArea(
              bottom: false,
              child: Container(
                height: sheetHeight,
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.base,
                  AppSpacing.base,
                  AppSpacing.base,
                  MediaQuery.of(sheetCtx).padding.bottom + AppSpacing.xxl,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.white24,
                        borderRadius: AppRadii.xsAll,
                      ),
                    ),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select Skills',
                        style: AppTextStyles.bodyLargeMedium,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: initial.skillList.length,
                        itemBuilder: (sheetCtx, index) {
                          final skill = initial.skillList[index];
                          final isSelected = draft.contains(skill);
                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: AppColors.primary,
                            checkColor: AppColors.black,
                            title: Text(skill, style: AppTextStyles.bodyMedium),
                            onChanged: (checked) {
                              setModalState(() {
                                if (checked == true) {
                                  if (!draft.contains(skill)) draft.add(skill);
                                } else {
                                  draft.remove(skill);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          notifier.setSelectedSkills(draft);
                          sheetCtx.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: const Color(0xFF1D1D1B),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadii.lgAll,
                          ),
                        ),
                        child: const Text(
                          'Done',
                          style: AppTextStyles.buttonMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
