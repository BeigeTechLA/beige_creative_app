import 'package:beige_creative_app/app/assets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/colors.dart';
import '../app/radii.dart';
import '../app/route_names.dart';
import '../app/spacing.dart';
import '../app/text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image": AppAssets.onboding1,
      "title": "Find Your Next\nCreative Gig",
      "description":
          "Access shoots, collaborate with brands, and\nmanage your work — all in one place. Shoot. Edit. Earn.📍⚡",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              /// ---------------- PAGE VIEW ----------------
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Expanded(
                          child: Image.asset(
                            pages[index]['image']!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        Text(
                          pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.heading18Unbounded.copyWith(
                            color: AppColors.white,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xs),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                          child: Text(
                            pages[index]['description']!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body12.copyWith(
                              color: AppColors.white60,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              /// ---------------- DOT INDICATOR ----------------
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: List.generate(
              //     pages.length,
              //         (index) => Container(
              //       margin: const EdgeInsets.symmetric(horizontal: 4),
              //       width: 40,
              //       height: 4,
              //       decoration: BoxDecoration(
              //         color: _currentPage == index
              //             ? AppColors.white
              //             : AppColors.white60,
              //         borderRadius: AppRadii.xsAll,
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: AppSpacing.xxxl),

              /// ---------------- LOGIN BUTTON ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushNamed(RouteNames.login);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadii.xxlAll,
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Login",
                      style: AppTextStyles.bodyMediumStrongUnbounded.copyWith(
                        color: AppColors.textHeading,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              /// ---------------- SIGN UP TEXT ----------------
              GestureDetector(
                onTap: () {
                  context.pushNamed(RouteNames.signupStep1);
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: Text.rich(
                    TextSpan(
                      text: "Don’t have an account? ",
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white60,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign Up",
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

          /// ---------------- SKIP BUTTON ----------------
          /*  SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20, right: 20),
                child: GestureDetector(
                  */
          /*   onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewLoginScreen(),
                      ),
                    );
                  },*/
          /*
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),*/
        ],
      ),
    );
  }
}
