import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../routes/signup_args.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/app_loader.dart' show AppLoader;
import '../../../../shared/widgets/custom_multi_selectfield.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/signup_notifier.dart';
import '../providers/signup_state.dart';
import '../widgets/signup2_header.dart';
import '../widgets/signup2_lookup_sheet.dart';
import '../widgets/signup2_preview_card.dart';

class SignUp2Screen extends ConsumerStatefulWidget {
  final int? crewMemberId;
  final File? profileImage;
  final String? email;
  final String? firstName;
  final String? lastName;
  final int step1Progress;
  final String? location;
  final String? workingDistance;

  const SignUp2Screen({
    super.key,
    this.crewMemberId,
    this.profileImage,
    this.email,
    this.firstName,
    this.lastName,
    this.location,
    this.workingDistance,
    required this.step1Progress,
  });

  @override
  ConsumerState<SignUp2Screen> createState() => SignUp2ScreenState();
}

class SignUp2ScreenState extends ConsumerState<SignUp2Screen> {
  final TextEditingController bioController = TextEditingController();
  final TextEditingController yearOfExperienceController =
      TextEditingController();
  final TextEditingController hourlyRateController = TextEditingController();
  final TextEditingController equipmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    yearOfExperienceController.addListener(() => setState(() {}));
    hourlyRateController.addListener(() => setState(() {}));
    bioController.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signupNotifierProvider.notifier).loadStep2Lookups();
    });
  }

  @override
  void dispose() {
    bioController.dispose();
    yearOfExperienceController.dispose();
    hourlyRateController.dispose();
    equipmentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final notifier = ref.read(signupNotifierProvider.notifier);
    final ok = await notifier.submitStep2(
      yearsOfExperience: yearOfExperienceController.text,
      hourlyRate: hourlyRateController.text,
      bio: bioController.text,
    );
    if (!ok || !mounted) return;
    final state = ref.read(signupNotifierProvider);
    context.pushNamed(
      Routes.signupStep3.name,
      extra: SignUpStep3Args(
        crewMemberId: widget.crewMemberId,
        profileImage: widget.profileImage,
        email: widget.email,
        firstName: widget.firstName,
        lastName: widget.lastName,
        location: widget.location,
        workingDistance: widget.workingDistance,
        primaryRole: state.selectedRoles.join(', '),
        experience: yearOfExperienceController.text.trim(),
        hourlyRate: hourlyRateController.text.trim(),
        bio: bioController.text.trim(),
        skills: state.selectedSkills.join(', '),
        equipments: state.selectedEquipments.join(', '),
        step2Progress: state.step2Progress,
      ).toExtra(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupNotifierProvider);
    final notifier = ref.read(signupNotifierProvider.notifier);

    ref.listen<SignupState>(signupNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
      }
    });

    final completionPercent = notifier.calculateStep2Progress(
      yearsOfExperience: yearOfExperienceController.text,
      hourlyRate: hourlyRateController.text,
      bio: bioController.text,
    );

    return AppScaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SignUp2Header(),
                const SizedBox(height: 20),
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.xl,
                          100,
                          AppSpacing.xl,
                          AppSpacing.xl,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadii.massiveAll,
                          border: Border.all(
                            color: AppColors.white.withValues(alpha: 0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: 50),
                            CustomMultiSelectField(
                              label: 'Primary Role*',
                              value: state.selectedRoles.join(', '),
                              hasValue: state.selectedRoles.isNotEmpty,
                              onTap: () async {
                                await showSignUp2LookupSheet(
                                  context: context,
                                  title: 'Select Roles',
                                  options: state.roles
                                      .map((r) => r.name)
                                      .toList(),
                                  initiallySelected: state.selectedRoles,
                                  onToggle: (name, selected) => notifier
                                      .toggleRole(name, selected: selected),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: 'Year of Experience*',
                              controller: yearOfExperienceController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: 'Hourly Rate*',
                              controller: hourlyRateController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: 'Bio / About',
                              controller: bioController,
                              maxLines: 4,
                              keyboardType: TextInputType.multiline,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  '  Highlight your creative focus.',
                                  style: AppTextStyles.body12.copyWith(
                                    color: AppColors.greyShade737,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            CustomMultiSelectField(
                              label: 'Add Skills',
                              value: state.selectedSkills.join(', '),
                              hasValue: state.selectedSkills.isNotEmpty,
                              onTap: () async {
                                await showSignUp2LookupSheet(
                                  context: context,
                                  title: 'Select Skills',
                                  options: state.skills
                                      .map((s) => s.name)
                                      .toList(),
                                  initiallySelected: state.selectedSkills,
                                  onToggle: (name, selected) => notifier
                                      .toggleSkill(name, selected: selected),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            _EquipmentSection(
                              controller: equipmentController,
                              suggestions: state.equipmentSuggestions
                                  .map((e) => e.name)
                                  .toList(),
                              selected: state.selectedEquipments,
                              isLoading: state.isLoadingEquipments,
                              onQueryChanged: (value) async {
                                await notifier.searchEquipments(value);
                              },
                              onPickSuggestion: (name) {
                                equipmentController.clear();
                                notifier.addEquipment(name);
                              },
                              onRemove: notifier.removeEquipment,
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: state.isSubmittingStep2
                                    ? null
                                    : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.xlAll,
                                  ),
                                ),
                                child: Text(
                                  'Next',
                                  style: AppTextStyles.inherit16Medium
                                      .copyWith(color: AppColors.textHeading),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: AppTextStyles.body15Medium
                                      .copyWith(color: AppColors.white60),
                                ),
                                InkWell(
                                  onTap: () =>
                                      context.pushNamed(Routes.login.name),
                                  child: Text(
                                    'Login',
                                    style: AppTextStyles.body15Strong.copyWith(
                                      color: AppColors.white,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Positioned(
                        top: -40,
                        left: 20,
                        right: 20,
                        child: SignUp2PreviewCard(
                          firstName: widget.firstName ?? '',
                          lastName: widget.lastName ?? '',
                          email: widget.email ?? '',
                          profileImage: widget.profileImage,
                          location: widget.location ?? '',
                          workingDistance: widget.workingDistance ?? '',
                          primaryRole: state.selectedRoles.join(', '),
                          experience: yearOfExperienceController.text.trim(),
                          hourlyRate: hourlyRateController.text.trim(),
                          bio: bioController.text.trim(),
                          skills: state.selectedSkills.join(', '),
                          equipments: state.selectedEquipments.join(', '),
                          completionPercent: completionPercent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.isLoadingLookups || state.isSubmittingStep2)
            const AppLoader(),
        ],
      ),
    );
  }
}

class _EquipmentSection extends StatelessWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final List<String> selected;
  final bool isLoading;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onPickSuggestion;
  final ValueChanged<String> onRemove;

  const _EquipmentSection({
    required this.controller,
    required this.suggestions,
    required this.selected,
    required this.isLoading,
    required this.onQueryChanged,
    required this.onPickSuggestion,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: controller,
          label: 'Add Equipment',
          onChanged: onQueryChanged,
        ),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.md),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.surfaceCropSheet,
              borderRadius: AppRadii.lgAll,
              border: Border.all(color: AppColors.white24),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final item = suggestions[index];
                return ListTile(
                  title: Text(
                    item,
                    style: AppTextStyles.inherit.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                  onTap: () => onPickSuggestion(item),
                );
              },
            ),
          ),
        if (selected.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selected
                  .map(
                    (item) => Chip(
                      label: Text(
                        item,
                        style: AppTextStyles.inherit
                            .copyWith(color: AppColors.white),
                      ),
                      backgroundColor:
                          AppColors.textHeading.withValues(alpha: 0.9),
                      deleteIconColor: AppColors.white,
                      onDeleted: () => onRemove(item),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
