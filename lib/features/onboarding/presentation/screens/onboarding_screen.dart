import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/assets.dart';
import '../../../../app/colors.dart';
import '../../../../app/routes.dart';
import '../../../../app/spacing.dart';
import '../../../../app/text_styles.dart';
import '../../../../core/providers/guest_mode_provider.dart';
import '../../../../shared/widgets/app_cta_button.dart';
import '../../../../shared/layouts/app_scaffold.dart';
import '../providers/onboarding_notifier.dart';

/// Onboarding hero pager + Login / Sign-up CTAs.
///
/// The page index lives in `OnboardingNotifier`; the `PageController` stays
/// in the widget because controllers are widget-lifecycle bound and don't
/// belong in provider memory.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      image: AppAssets.onboardingHero,
      title: 'Find Your Next\nCreative Gig',
      description:
          'Access shoots, collaborate with brands, and\nmanage your work — all in one place. Shoot. Edit. Earn.📍⚡',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingNotifierProvider.notifier)
          .configurePageCount(_pages.length);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onLoginTap() async {
    await ref.read(onboardingNotifierProvider.notifier).markSeen();
    if (!mounted) return;
    context.pushNamed(Routes.login.name);
  }

  Future<void> _onSignupTap() async {
    await ref.read(onboardingNotifierProvider.notifier).markSeen();
    if (!mounted) return;
    context.pushNamed(Routes.signupStep1.name);
  }

  void _onSkipTap() {
    ref.read(guestModeProvider.notifier).enter();
    if (!mounted) return;
    context.goNamed(Routes.home.name);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    ref
                        .read(onboardingNotifierProvider.notifier)
                        .setPage(index);
                  },
                  itemBuilder: (context, index) => _PageBody(page: _pages[index]),
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const SizedBox(height: AppSpacing.xxxl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AppCtaButton(
                  label: 'Login',
                  onPressed: _onLoginTap,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              GestureDetector(
                onTap: _onSignupTap,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: Text.rich(
                    TextSpan(
                      text: 'Don’t have an account? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white60,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign Up',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  right: AppSpacing.lg,
                ),
                child: GestureDetector(
                  onTap: _onSkipTap,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String image;
  final String title;
  final String description;
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
  });
}

class _PageBody extends StatelessWidget {
  final _OnboardingPage page;
  const _PageBody({required this.page});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Image.asset(
            page.image,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          page.title,
          textAlign: TextAlign.center,
          style: AppTextStyles.heading18Unbounded.copyWith(
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Text(
            page.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.body12.copyWith(
              color: AppColors.white60,
            ),
          ),
        ),
      ],
    );
  }
}
