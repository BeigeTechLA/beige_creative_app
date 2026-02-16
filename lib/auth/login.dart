import 'package:flutter/material.dart';

import '../utility/ColorCode.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [

                /// 🔝 TOP IMAGE + TITLE SECTION
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.28,
                  child: Stack(
                    children: [

                      /// 🖼️ BACKGROUND IMAGE
                      Positioned.fill(
                        child: Image.asset(
                          "assets/images/Rectangle_574057023.png",
                          fit: BoxFit.fill,
                        ),
                      ),

                      /// 🔙 BACK BUTTON
                      Positioned(
                        top: 50,
                        left: 16,
                        right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            /// 🔙 BACK BUTTON
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                "assets/icons/Reply.png",
                                height: 24,
                                color: Colors.white,
                              ),
                            ),

                            /// 📄 STEP COUNT
                            const Text(
                              "1/3",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: "Outfit",
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// 🏷️ TITLE + SUBTITLE (CENTER)
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children:  [

                            Text(
                              "Welcome Back",
                              style: TextStyle(
                                fontFamily: "Unbounded",
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: ColorCode.white,
                              ),
                            ),

                            SizedBox(height: 10),

                            Text(
                              "Enter your details to access your account. Continue\n managing your bookings and profile.",

                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: "Outfit",
                                fontSize: 14,
                                color: ColorCode.kWhiteOpacity70,
                              ),
                            ),
                            SizedBox(height: 10),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                /// 📦 FORM CONTAINER (NICHE)
                Transform.translate(
                  offset: const Offset(0, -40),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [

                      /// 🧱 MAIN FORM CONTAINER
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 36, 20, 20), // 👈 top extra
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: ColorCode.bcakgroundcolor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
]
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      /// 🏷️ FLOATING CHIP (BORDER PE STUCK)
                      Positioned(
                        top: -24,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            height: 50,
                            decoration: BoxDecoration(
                              color: ColorCode.k282828,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.12),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  height: 28,
                                  width: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_outline,
                                    size: 16,
                                    color: ColorCode.kWhiteOpacity70,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  "Tell Us About Yourself & Add Details",
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: ColorCode.kWhiteOpacity70,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                     /* Positioned(
                        top: -30,
                        left: 20,
                        right: 20,
                        child: _userPreviewCard(),
                      ),*/

                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have an account? ",
                      style: TextStyle(
                        color: ColorCode.kWhiteOpacity60,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        /*   Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>  NewLoginScreen(),
                            ),
                          );*/
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          );

  }
}
