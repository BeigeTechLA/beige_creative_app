import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../routes/signup_args.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/app_cta_button.dart';
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
                              maxLength: 2,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              label: 'Hourly Rate*',
                              controller: hourlyRateController,
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
                              value: '',
                              hasValue: false,
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
                                          onDeleted: () => notifier.toggleSkill(
                                            item,
                                            selected: false,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            CustomMultiSelectField(
                              label: 'Add Equipment',
                              value: '',
                              hasValue: false,
                              onTap: () async {
                                await showModalBottomSheet(
                                  context: context,
                                  backgroundColor: AppColors.surfaceCropSheet,
                                  isScrollControlled: true,
                                  useSafeArea: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: AppRadii.topHuge,
                                  ),
                                  builder: (_) => const _EquipmentSelectionSheet(),
                                );
                              },
                            ),
                            if (state.selectedEquipments.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: state.selectedEquipments
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
                                          onDeleted: () => notifier.removeEquipment(item),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ],
                            const SizedBox(height: 30),
                            AppCtaButton(
                              label: 'Next',
                              height: 55,
                              enabled: !state.isSubmittingStep2,
                              onPressed: _submit,
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

class _EquipmentSelectionSheet extends ConsumerStatefulWidget {
  const _EquipmentSelectionSheet();

  @override
  ConsumerState<_EquipmentSelectionSheet> createState() =>
      _EquipmentSelectionSheetState();
}

class _EquipmentSelectionSheetState extends ConsumerState<_EquipmentSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupNotifierProvider);
    final notifier = ref.read(signupNotifierProvider.notifier);
    final sheetHeight = MediaQuery.of(context).size.height * 0.9;

    return Container(
      height: sheetHeight,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.base,
        AppSpacing.base,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Select Equipment',
              style: AppTextStyles.bodyLargeMedium.copyWith(color: AppColors.white),
            ),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _searchController,
            label: 'Search Equipment',
            onChanged: (value) async {
              await notifier.searchEquipments(value);
            },
          ),
          if (state.selectedEquipments.isNotEmpty) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: state.selectedEquipments
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
                        onDeleted: () => notifier.removeEquipment(item),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: state.isLoadingEquipments
                ? const Center(
                    child: AppCircularLoader(
                      size: 22,
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : state.equipmentSuggestions.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.trim().isEmpty
                              ? 'Search to find equipment'
                              : 'No equipment found',
                          style: AppTextStyles.body14.copyWith(color: AppColors.white60),
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.equipmentSuggestions.length,
                        itemBuilder: (context, index) {
                          final item = state.equipmentSuggestions[index].name;
                          final isSelected = state.selectedEquipments.contains(item);
                          return CheckboxListTile(
                            value: isSelected,
                            title: Text(
                              item,
                              style: AppTextStyles.body14Medium.copyWith(color: AppColors.white),
                            ),
                            activeColor: AppColors.primary,
                            checkColor: AppColors.black,
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.lavenderGrey,
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadii.smAll,
                            ),
                            onChanged: (checked) {
                              if (checked == true) {
                                notifier.addEquipment(item);
                              } else {
                                notifier.removeEquipment(item);
                              }
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
                notifier.searchEquipments('');
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadii.lgAll,
                ),
              ),
              child: Text(
                'Done',
                style: AppTextStyles.body15.copyWith(color: AppColors.textHeading),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
