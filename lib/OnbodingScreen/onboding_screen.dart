import 'package:flutter/material.dart';


import '../auth/New_Creative_sing_up_follow/new_build_your_creative_profile.dart';
import '../auth/creative_sign_up/build_your_creative_profile_sign_up.dart';
import '../auth/login/login.dart';
import '../utility/ColorCode.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> pages = [
/*    {
      "image": "assets/Onboding/Frame 2087328917.png",
      "title": "Book Your Dream\nShoot",
      "description":
      "Instantly book creatives for any shoot\nanywhere. 🎥✨",
    },*/
    // {
    //   "image": "assets/Onboding/Group 2087329238.png",
    //   "title": "Find Video & Photo\nWork",
    //   "description":
    //   "Find local photo, video, and editing work.\nBook. Shoot. Earn. 📍⚡",
    // },
    {
      "image": "assets/Onboding/onboding_new_image.png",
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

                        const SizedBox(height: 20),

                        Text(
                          pages[index]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: "Unbounded",
                            color: ColorCode.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            pages[index]['description']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: "Outfit",
                              color: ColorCode.kWhiteOpacity60,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 30),

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
              //             ? ColorCode.white
              //             : ColorCode.kWhiteOpacity60,
              //         borderRadius: BorderRadius.circular(4),
              //       ),
              //     ),
              //   ),
              // ),

              const SizedBox(height: 30),

              /// ---------------- LOGIN BUTTON ----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>  Login(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorCode.kButtonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontFamily: "Unbounded",
                        fontSize: 14,
                        color: ColorCode.kHeadingColor,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// ---------------- SIGN UP TEXT ----------------
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>  New_build_your_creativeScreen(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.only(bottom: 20),
                  child: Text.rich(
                    TextSpan(
                      text: "Don’t have an account? ",
                      style: TextStyle(
                        fontFamily: "Outfit",
                        color: ColorCode.kWhiteOpacity60,
                        fontSize: 14,
                      ),
                      children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            fontFamily: "Outfit",
                            color: ColorCode.white,
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
                  *//*   onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewLoginScreen(),
                      ),
                    );
                  },*//*
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontFamily: "Outfit",
                      color: ColorCode.white,
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