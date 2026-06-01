import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/shadows.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/widgets/app_loader.dart' show AppLoader;
import '../../../../shared/widgets/top_message.dart';
import '../providers/signup_notifier.dart';
import '../providers/signup_state.dart';
import '../widgets/signup3_constants.dart';
import '../widgets/signup3_document_block.dart';
import '../widgets/signup3_featured_sheet.dart';
import '../widgets/signup3_header.dart';
import '../widgets/signup3_portfolio_sheet.dart';
import '../widgets/signup3_preview_card.dart';
import '../widgets/signup3_sections.dart';
import '../widgets/signup3_social_sheet.dart';

class SignUp3Screen extends ConsumerStatefulWidget {
  final int? crewMemberId;
  final File? profileImage;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? location;
  final String? workingDistance;
  final int step2Progress;
  final String primaryRole;
  final String experience;
  final String hourlyRate;
  final String bio;
  final String skills;
  final String equipments;

  const SignUp3Screen({
    super.key,
    this.crewMemberId,
    this.profileImage,
    this.email,
    this.firstName,
    this.lastName,
    this.location,
    this.workingDistance,
    this.primaryRole = '',
    this.experience = '',
    this.hourlyRate = '',
    this.bio = '',
    this.skills = '',
    this.equipments = '',
    required this.step2Progress,
  });

  @override
  ConsumerState<SignUp3Screen> createState() => SignUp3ScreenState();
}

class SignUp3ScreenState extends ConsumerState<SignUp3Screen> {
  final TextEditingController nameLinkController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController enterWorkTitleController =
      TextEditingController();
  final TextEditingController portfolioLinkController = TextEditingController();

  // Sheet-local cursor state (UI-only — survives sheet reopen for the same
  // mount, doesn't need to live in the notifier).
  int _selectedSocialIndex = -1;
  int? _editingSocialIndex;
  int _selectedPortfolioIndex = -1;
  int? _editingPortfolioIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(signupNotifierProvider.notifier).seedStep3FromRoute(
            crewMemberId: widget.crewMemberId,
            primaryRole: widget.primaryRole,
            experience: widget.experience,
            hourlyRate: widget.hourlyRate,
            bio: widget.bio,
            skills: widget.skills,
            equipments: widget.equipments,
            step2Progress: widget.step2Progress,
          );
    });
  }

  @override
  void dispose() {
    nameLinkController.dispose();
    linkController.dispose();
    enterWorkTitleController.dispose();
    portfolioLinkController.dispose();
    super.dispose();
  }

  void _showSnack(String message) => TopMessage.show(context, message);

  SignupNotifier get _notifier => ref.read(signupNotifierProvider.notifier);

  Future<void> _pickCertificate() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      _notifier.addCertificate(File(result.files.single.path!));
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      _notifier.setResumeFile(File(result.files.single.path!));
    }
  }

  Future<void> _pickPortfolio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      _notifier.setPortfolioFile(File(result.files.single.path!));
    }
  }

  Future<void> _openSocialSheet() async {
    final state = ref.read(signupNotifierProvider);
    final controller = Signup3SocialSheetController(
      savedLinks: state.savedSocialLinks,
      nameLinkController: nameLinkController,
      linkController: linkController,
      selectedSocialIndex: _selectedSocialIndex,
      editingIndex: _editingSocialIndex,
      commitLinks: _notifier.setSocialLinks,
      onError: _showSnack,
    );
    await showSignup3SocialSheet(context: context, controller: controller);
    _selectedSocialIndex = controller.selectedSocialIndex;
    _editingSocialIndex = controller.editingIndex;
  }

  Future<void> _openPortfolioSheet() async {
    final state = ref.read(signupNotifierProvider);
    final controller = Signup3PortfolioSheetController(
      savedLinks: state.savedPortfolioLinks,
      nameController: nameLinkController,
      linkController: portfolioLinkController,
      selectedIndex: _selectedPortfolioIndex,
      editingIndex: _editingPortfolioIndex,
      commitLinks: _notifier.setPortfolioLinks,
      onError: _showSnack,
    );
    await showSignup3PortfolioSheet(context: context, controller: controller);
    _selectedPortfolioIndex = controller.selectedIndex;
    _editingPortfolioIndex = controller.editingIndex;
  }

  Future<void> _openFeaturedSheet({int? editIndex}) async {
    final state = ref.read(signupNotifierProvider);
    final tempImages = editIndex != null
        ? [...state.featuredProjects[editIndex]]
        : <File>[];
    if (editIndex != null && editIndex < state.featuredProjectsTitles.length) {
      enterWorkTitleController.text = state.featuredProjectsTitles[editIndex];
    } else {
      enterWorkTitleController.clear();
    }
    final controller = Signup3FeaturedSheetController(
      titleController: enterWorkTitleController,
      tempImages: tempImages,
      editingProjectIndex: editIndex,
      featuredProjects: state.featuredProjects,
      featuredProjectsTitles: state.featuredProjectsTitles,
      selectedTags: state.selectedFeaturedTags,
      commit: _notifier.setFeaturedProjects,
      onError: _showSnack,
    );
    await showSignup3FeaturedSheet(context: context, controller: controller);
  }

  Future<void> _submit() async {
    final ok = await _notifier.submitStep3();
    if (!mounted) return;
    if (ok) {
      context.goNamed(Routes.login.name);
    }
  }

  List<File> _flattenedFeaturedImages(SignupState state) =>
      state.featuredProjects.expand((p) => p).toList();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupNotifierProvider);

    ref.listen<String?>(
      signupNotifierProvider.select((s) => s.errorMessage),
      (prev, next) {
        if (next != null && next.isNotEmpty) {
          _showSnack(next);
        }
      },
    );

    final flattenedFeatured = _flattenedFeaturedImages(state);
    final progress = state.step2Progress + _progressFromState(state);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SignUp3Header(),
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
                            const SizedBox(height: 20),
                            if (state.savedSocialLinks.isNotEmpty)
                              Column(
                                children: state.savedSocialLinks
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  return SignUp3SavedLinkRow(
                                    item: e.value,
                                    backgroundColor: AppColors.black,
                                    onEdit: () {
                                      _editingSocialIndex = e.key;
                                      _selectedSocialIndex =
                                          kSignup3SocialNames
                                              .indexOf(e.value['name']);
                                      nameLinkController.text =
                                          e.value['name'];
                                      linkController.text = e.value['url'];
                                      _openSocialSheet();
                                    },
                                    onDelete: () =>
                                        _notifier.removeSocialLinkAt(e.key),
                                  );
                                }).toList(),
                              ),
                            SignUp3AddTile(
                              title: 'Add Social Links',
                              onTap: _openSocialSheet,
                            ),
                            const SizedBox(height: 20),
                            if (state.savedPortfolioLinks.isNotEmpty)
                              Column(
                                children: state.savedPortfolioLinks
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  return SignUp3SavedLinkRow(
                                    item: e.value,
                                    backgroundColor: AppColors.textSubtle,
                                    onEdit: () {
                                      _editingPortfolioIndex = e.key;
                                      _selectedPortfolioIndex =
                                          kSignup3PortfolioNames
                                              .indexOf(e.value['name']);
                                      portfolioLinkController.text =
                                          e.value['url'];
                                      _openPortfolioSheet();
                                    },
                                    onDelete: () => _notifier
                                        .removePortfolioLinkAt(e.key),
                                  );
                                }).toList(),
                              ),
                            SignUp3AddTile(
                              title: 'Add Portfolio Link (Optional)',
                              onTap: _openPortfolioSheet,
                            ),
                            const SizedBox(height: 20),
                            SignUp3FeaturedSection(
                              featuredProjects: state.featuredProjects,
                              featuredProjectsTitles:
                                  state.featuredProjectsTitles,
                              onAdd: _openFeaturedSheet,
                              onEdit: (index) =>
                                  _openFeaturedSheet(editIndex: index),
                              onDelete: _notifier.removeFeaturedProjectAt,
                            ),
                            const SizedBox(height: 16),
                            SignUp3CertificatesSection(
                              certificateFiles: state.certificateFiles,
                              onPick: _pickCertificate,
                              onDelete: _notifier.removeCertificateAt,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.base),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: AppRadii.xxlAll,
                                border:
                                    Border.all(color: AppColors.white24),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Upload Documents',
                                    style: AppTextStyles.inherit14Strong
                                        .copyWith(color: AppColors.white),
                                  ),
                                  const SizedBox(height: 12),
                                  SignUp3DocumentBlock(
                                    label: 'Upload Resume/CV',
                                    file: state.resumeFile,
                                    onUpload: _pickDocument,
                                    onDelete: () =>
                                        _notifier.setResumeFile(null),
                                  ),
                                  const SizedBox(height: 12),
                                  SignUp3DocumentBlock(
                                    label: 'Upload Portfolio',
                                    file: state.portfolioFile,
                                    onUpload: _pickPortfolio,
                                    onDelete: () =>
                                        _notifier.setPortfolioFile(null),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed:
                                    state.isSubmittingStep3 ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppRadii.xlAll,
                                  ),
                                ),
                                child: Text(
                                  'Create Profile',
                                  style: AppTextStyles.displayLabel16
                                      .copyWith(color: AppColors.textHeading),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Already have an account? ',
                                    style: AppTextStyles.inherit.copyWith(
                                      color: AppColors.white30,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () =>
                                        context.pushNamed(Routes.login.name),
                                    child: Text(
                                      'Login',
                                      style: AppTextStyles.inheritSemiBold
                                          .copyWith(color: AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Positioned(
                        top: -24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.base,
                            ),
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMid,
                              borderRadius: AppRadii.lgAll,
                              border: Border.all(
                                color:
                                    AppColors.white.withValues(alpha: 0.12),
                                width: 1,
                              ),
                              boxShadow: AppShadows.ctaDark,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 28,
                                  width: 28,
                                  decoration: BoxDecoration(
                                    color: AppColors.white
                                        .withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: AppColors.white30,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Tell Us About Yourself & Add Details',
                                  style: AppTextStyles.body11MediumLetter02
                                      .copyWith(color: AppColors.white30),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: -30,
                        left: 20,
                        right: 20,
                        child: SignUp3PreviewCard(
                          firstName: widget.firstName?.trim() ?? '',
                          lastName: widget.lastName?.trim() ?? '',
                          email: widget.email?.trim() ?? '',
                          profileImage: widget.profileImage,
                          location: widget.location ?? '',
                          workingDistance: widget.workingDistance ?? '',
                          primaryRole: widget.primaryRole,
                          experience: widget.experience,
                          hourlyRate: widget.hourlyRate,
                          bio: widget.bio,
                          skills: widget.skills,
                          equipments: widget.equipments,
                          featuredImages: flattenedFeatured,
                          completionPercent: progress,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (state.isSubmittingStep3) const AppLoader(),
        ],
      ),
    );
  }

  int _progressFromState(SignupState state) {
    const int total = 5;
    int filled = 0;
    if (state.savedSocialLinks.isNotEmpty) filled++;
    if (state.featuredProjects.isNotEmpty) filled++;
    if (state.certificateFiles.isNotEmpty) filled++;
    if (state.resumeFile != null) filled++;
    if (state.portfolioFile != null || state.savedPortfolioLinks.isNotEmpty) {
      filled++;
    }
    return ((filled / total) * 30).toInt();
  }
}
