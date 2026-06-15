import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

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
    final ok =
        await ref.read(enterProfessionalNotifierProvider.notifier).submit(
              experience: experienceController.text,
              hourlyRate: rateController.text,
              bio: bioController.text,
            );
    if (!mounted) return;
    if (ok) {
      TopMessage.show(context, 'Profile Updated');
      context.pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<EnterProfessionalState>(enterProfessionalNotifierProvider,
        (prev, next) {
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
      body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(true),
                        child: SvgPicture.asset(
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
                  ),
                  const SizedBox(height: 22),
                  CustomTextField(
                    label: 'Hourly Rate',
                    controller: rateController,
                    keyboardType: TextInputType.number,
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
                    value: state.selectedSkills.join(', '),
                    hasValue: state.selectedSkills.isNotEmpty,
                    onTap: () async => _openSkillsBottomSheet(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            if (state.isLoadingInitial || state.isSubmitting)
              const ColoredBox(
                color: Color(0x66000000),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: SizedBox(
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: const Color(0xFF1D1D1B),
              shape: RoundedRectangleBorder(borderRadius: AppRadii.xlAll),
            ),
            onPressed: state.isSubmitting ? null : _save,
            child: const Text('Save', style: AppTextStyles.buttonMedium),
          ),
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
                          title: Text(role,
                              style: AppTextStyles.body14Medium),
                          activeColor: AppColors.primary,
                          checkColor: AppColors.black,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.lavenderGrey,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.smAll),
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
                            borderRadius: AppRadii.lgAll),
                      ),
                      child: const Text('Done', style: AppTextStyles.buttonMedium),
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
                    'Select Skills',
                    style: AppTextStyles.bodyLargeMedium,
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: initial.skillList.length,
                      itemBuilder: (sheetCtx, index) {
                        final skill = initial.skillList[index];
                        final isSelected = draft.contains(skill);
                        return CheckboxListTile(
                          value: isSelected,
                          activeColor: AppColors.primary,
                          checkColor: AppColors.black,
                          title: Text(skill,
                              style: AppTextStyles.bodyMedium),
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
                            borderRadius: AppRadii.lgAll),
                      ),
                      child: const Text('Done', style: AppTextStyles.buttonMedium),
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
}
