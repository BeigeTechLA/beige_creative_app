import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/radii.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../shared/layouts/app_scaffold.dart';

final appPreferencesDarkModeProvider =
    StateProvider.autoDispose<bool>((_) => false);

class AppPreferencesScreen extends ConsumerWidget {
  const AppPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(appPreferencesDarkModeProvider);

    return AppScaffold(
      body: Padding(
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.pop(),
                child: SvgPicture.asset(
                  AppAssets.back,
                  height: 24,
                  // ignore: deprecated_member_use
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'App Preferences',
                style: AppTextStyles.displayStrong16w600.copyWith(
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.smd),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.lgAll,
                      color: AppColors.surfaceMid,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              AppAssets.moon,
                              height: 24,
                              width: 24,
                              colorFilter: const ColorFilter.mode(
                                AppColors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Dark Mode',
                              style: AppTextStyles.inherit14.copyWith(
                                color: AppColors.white,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isDarkMode,
                          activeThumbColor: AppColors.arcYellow,
                          onChanged: (value) => ref
                              .read(appPreferencesDarkModeProvider.notifier)
                              .state = value,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () =>
                        context.pushNamed(Routes.deleteAccount.name),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        borderRadius: AppRadii.lgAll,
                        color: AppColors.surfaceMid,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(
                                AppAssets.delete,
                                height: 24,
                                width: 24,
                                colorFilter: const ColorFilter.mode(
                                  AppColors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Delete Account',
                                style: AppTextStyles.inherit14.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                          SvgPicture.asset(
                            AppAssets.goto,
                            height: 20,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.lgAll,
                      color: AppColors.surfaceMid,
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          AppAssets.appVersion,
                          height: 24,
                          width: 24,
                          colorFilter: const ColorFilter.mode(
                            AppColors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'App Version V1.0',
                          style: AppTextStyles.inherit13.copyWith(
                            color: AppColors.white24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),
        ),
    );
  }
}
