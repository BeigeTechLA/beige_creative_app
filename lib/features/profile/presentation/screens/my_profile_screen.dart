import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../../../../shared/widgets/loading.dart';
import '../../../../shared/widgets/common_uploader.dart';
import '../../../../shared/widgets/top_message.dart';
import '../providers/my_profile_providers.dart';
import '../widgets/profile_action_buttons.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_link_mappers.dart';
import '../widgets/profile_links_section.dart';
import '../widgets/profile_portfolio_links_sheet.dart';
import '../widgets/profile_section_list.dart';
import '../widgets/profile_social_links_sheet.dart';
import '../widgets/profile_stats_panel.dart';
import '../../../home/presentation/widgets/common/home_section_divider.dart';

class Myprofile extends ConsumerStatefulWidget {
  const Myprofile({super.key});

  @override
  ConsumerState<Myprofile> createState() => _MyprofileState();
}

class _MyprofileState extends ConsumerState<Myprofile> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  File? _profileImage;

  static const _socialNames = [
    'Instagram',
    'TikTok',
    'Facebook',
    'Vimeo',
    'Behance',
    'Google Drive',
    'YouTube',
  ];
  static const _socialIcons = [
    AppAssets.insta,
    AppAssets.tiktok,
    AppAssets.facebook,
    AppAssets.vimeo,
    AppAssets.behance,
    AppAssets.googleDrive,
    AppAssets.youtube,
  ];

  static const _portfolioNames = ['Website', 'Design Portfolio', 'YouTube'];
  static const _portfolioIcons = [
    AppAssets.activeAffiliate,
    AppAssets.behance,
    AppAssets.youtube,
  ];

  @override
  void dispose() {
    nameController.dispose();
    linkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await CommonUploader.pickFromGallery();
    if (file == null || !mounted) return;
    final cropped = await context.pushNamed<File?>(
      Routes.cropImage.name,
      extra: file,
    );
    if (cropped != null && mounted) {
      setState(() => _profileImage = cropped);
      await ref.read(myProfileNotifierProvider.notifier).uploadPhoto(cropped);
    }
  }

  void _openSocialDialog({bool startInEditMode = false}) {
    final notifier = ref.read(myProfileNotifierProvider.notifier);
    final s = ref.read(myProfileNotifierProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => ProfileSocialLinksSheet(
        socialLinks: notifier.mutableSocialLinks,
        socialNames: _socialNames,
        socialIcons: _socialIcons,
        nameController: nameController,
        linkController: linkController,
        initialSelectedSocialIndex: s.selectedSocialIndex,
        initialEditingIndex: s.editingIndex,
        startInEditMode: startInEditMode,
        onParentMutate: (mutator) {
          mutator();
          notifier.commitSocial();
        },
        onSaveAll: notifier.saveSocialLinksToApi,
        onSelectionChanged: (selected, editing, editingFlag) {
          notifier.setSocialSelection(
            selectedIndex: selected,
            editingIndex: editing,
            isEditing: editingFlag,
          );
        },
      ),
    );
  }

  void _openPortfolioDialog({bool startInEditMode = false}) {
    final notifier = ref.read(myProfileNotifierProvider.notifier);
    final s = ref.read(myProfileNotifierProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (_) => ProfilePortfolioLinksSheet(
        portfolioLinks: notifier.mutablePortfolioLinks,
        portfolioNames: _portfolioNames,
        portfolioIcons: _portfolioIcons,
        nameController: nameController,
        linkController: linkController,
        initialSelectedPortfolioIndex: s.selectedPortfolioIndex,
        initialEditingIndex: s.editingIndex,
        startInEditMode: startInEditMode,
        onParentMutate: (mutator) {
          mutator();
          notifier.commitPortfolio();
        },
        onSaveLink:
            ({
              required void Function(bool) setUpdating,
              required bool Function() getUpdating,
              VoidCallback? onAdded,
            }) => _handlePortfolioSaveLink(
              setUpdating: setUpdating,
              getUpdating: getUpdating,
              onAdded: onAdded,
            ),
        onSaveAll: notifier.savePortfolioLinksToApi,
        onSelectionChanged: (selected, editing) {
          notifier.setPortfolioSelection(
            selectedIndex: selected,
            editingIndex: editing,
          );
        },
      ),
    );
  }

  Future<void> _handlePortfolioSaveLink({
    required void Function(bool) setUpdating,
    required bool Function() getUpdating,
    VoidCallback? onAdded,
  }) async {
    final s = ref.read(myProfileNotifierProvider);
    final notifier = ref.read(myProfileNotifierProvider.notifier);
    if (s.selectedPortfolioIndex == -1 || linkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select platform & enter link'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (s.editingIndex != -1) {
      final id = notifier.mutablePortfolioLinks[s.editingIndex]['id']
          ?.toString();
      if (id == null || id.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid link ID'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      setUpdating(true);
      await notifier.editPortfolioLinkApi(
        id: int.parse(id),
        url: linkController.text.trim(),
        platform: portfolioKey(_portfolioNames[s.selectedPortfolioIndex]),
        title: _portfolioNames[s.selectedPortfolioIndex],
      );
      if (mounted) setUpdating(false);
      return;
    }

    notifier.addPortfolioLocal(
      name: _portfolioNames[s.selectedPortfolioIndex],
      url: linkController.text.trim(),
      icon: _portfolioIcons[s.selectedPortfolioIndex],
    );
    nameController.clear();
    linkController.clear();
    onAdded?.call();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MyProfileState>(myProfileNotifierProvider, (prev, next) {
      if (next.toastMessage != null &&
          next.toastMessage != prev?.toastMessage) {
        TopMessage.show(
          context,
          next.toastMessage!,
          type: TopMessageType.success,
        );
        ref.read(myProfileNotifierProvider.notifier).clearMessage();
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        TopMessage.show(context, next.errorMessage!);
        ref.read(myProfileNotifierProvider.notifier).clearMessage();
      }
      if (next.dismissSheetSignal != prev?.dismissSheetSignal) {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    });

    final state = ref.watch(myProfileNotifierProvider);
    final profile = state.profile;
    final currentUser = ref.watch(currentSessionUserProvider);
    final isPendingReview =
        (currentUser?.isRegistrationComplete == 1) &&
        (currentUser?.isCrewVerified == 0);

    return AppScaffold(
      safeTop: false,
      safeBottomNavigationBar: true,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                ProfileHeader(
                  localImage: _profileImage,
                  profileImageUrl: profile?.profileImageUrl ?? '',
                  onEditTap: _pickImage,
                ),
                const SizedBox(height: 60),
                Text(
                  '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}',
                  style: AppTextStyles.body20Medium.copyWith(
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 4),
                _identityRow(profile?.email ?? '', profile?.location ?? ''),
                const SizedBox(height: 14),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.base,
                  ),
                  child: Column(
                    children: [
                      if (isPendingReview) ...[
                        _buildUnderReviewBanner(),
                        const SizedBox(height: 20),
                      ],
                      ProfileStatsPanel(
                        hourlyRateLabel:
                            '\$${double.tryParse(profile?.hourlyRate ?? '0')?.toInt() ?? 0}',
                        experienceLabel:
                            '${(profile?.yearsOfExperience ?? 0).toString().padLeft(2, '0')} yrs',
                        radiusLabel: profile?.workingDistance ?? '',
                        skills: (profile?.skills ?? [])
                            .map((e) => e.name)
                            .toList(),
                      ),
                      const HomeSectionDivider(centerAlpha: 0.24),
                      ProfileSocialLinksList(
                        socialLinks: state.socialLinks,
                        onOpen: _openSocialDialog,
                      ),
                      const SizedBox(height: 20),
                      ProfilePortfolioLinksList(
                        portfolioLinks: state.portfolioLinks,
                        onOpen: _openPortfolioDialog,
                      ),
                    ],
                  ),
                ),
                const ProfileSectionList(),
                const SizedBox(height: 30),
              ],
            ),
          ),
          if (state.isLoading || state.isUploadingImage) AppLoader(),
        ],
      ),
      bottomNavigationBar: const ProfileLogoutButton(),
    );
  }

  Widget _identityRow(String email, String location) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              email,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(color: AppColors.white60),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            child: Text(
              '|',
              style: AppTextStyles.inherit14.copyWith(color: AppColors.white60),
            ),
          ),
          Flexible(
            child: Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.body14.copyWith(color: AppColors.white60),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnderReviewBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surfaceWarm,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.borderGold, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_filled_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Application Under Review',
                style: AppTextStyles.body15Strong.copyWith(
                  color: AppColors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.shootStatusPendingBg,
                  borderRadius: AppRadii.xsAll,
                ),
                child: Text(
                  'Pending Review',
                  style: AppTextStyles.bodySmallBold.copyWith(
                    color: AppColors.shootStatusPendingFg,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your registration is currently under review by our admin team. You can view and edit your profile while your application is being verified.',
            style: AppTextStyles.body14.copyWith(
              color: AppColors.white80,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
