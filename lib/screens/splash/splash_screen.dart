import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main/main_screen.dart';
import '../welcome/welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    checkUser();
  }

  // ============================================================
  // CHECK LOGGED-IN USER
  // ============================================================

  Future<void> checkUser() async {
    // Keep splash visible for a short time.
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;

    final user =
        FirebaseAuth.instance.currentUser;

    // ==========================================================
    // USER IS LOGGED IN
    // ==========================================================

    if (user != null) {
      bool isAdmin = false;

      try {
        final userData =
            await FirebaseFirestore.instance
                .collection("users")
                .doc(user.uid)
                .get();

        if (userData.exists) {
          final data =
              userData.data();

          if (data != null) {
            isAdmin =
                data["role"]
                        ?.toString()
                        .toLowerCase() ==
                    "admin";
          }
        }
      } catch (e) {
        // If role cannot be read,
        // treat the account as a normal user.
        isAdmin = false;
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            isAdmin: isAdmin,
          ),
        ),
      );
    }

    // ==========================================================
    // USER IS NOT LOGGED IN
    // ==========================================================

    else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      body: SafeArea(
        child: Stack(
          children: [

            // ==================================================
            // BACKGROUND DECORATION
            // ==================================================

            Positioned(
              top: -80,
              right: -60,

              child: Container(
                width: 220,
                height: 220,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: colors.primary
                      .withOpacity(.07),
                ),
              ),
            ),

            Positioned(
              bottom: -120,
              left: -100,

              child: Container(
                width: 300,
                height: 300,

                decoration: BoxDecoration(
                  shape: BoxShape.circle,

                  color: colors.primary
                      .withOpacity(.05),
                ),
              ),
            ),

            // ==================================================
            // SMALL DECORATIVE CIRCLE
            // ==================================================

            Positioned(
              top: 110,
              left: 35,

              child: Container(
                width: 12,
                height: 12,

                decoration: BoxDecoration(
                  color: colors.primary
                      .withOpacity(.20),

                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: 180,
              right: 40,

              child: Container(
                width: 9,
                height: 9,

                decoration: BoxDecoration(
                  color: colors.primary
                      .withOpacity(.18),

                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 30,
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    // ==========================================
                    // LOGO
                    // ==========================================

                    Container(
                      width: 145,
                      height: 145,

                      padding:
                          const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: colors.primary
                            .withOpacity(.07),

                        shape: BoxShape.circle,

                        border: Border.all(
                          color: colors.primary
                              .withOpacity(.12),

                          width: 1.5,
                        ),
                      ),

                      child: Image.asset(
                        "assets/images/memora_logo.png",

                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    // ==========================================
                    // APP NAME
                    // ==========================================

                    Text(
                      "MEMORA",

                      style:
                          GoogleFonts.poppins(
                        color:
                            colors.onSurface,

                        fontSize: 42,

                        letterSpacing: 2,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    // ==========================================
                    // TAGLINE
                    // ==========================================

                    RichText(
                      textAlign:
                          TextAlign.center,

                      text: TextSpan(
                        style:
                            GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w500,
                        ),

                        children: [

                          TextSpan(
                            text: "Learn ",
                            style: TextStyle(
                              color:
                                  colors.onSurface,
                            ),
                          ),

                          TextSpan(
                            text: "Smart",
                            style: TextStyle(
                              color:
                                  colors.primary,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          TextSpan(
                            text: ". Remember ",
                            style: TextStyle(
                              color:
                                  colors.onSurface,
                            ),
                          ),

                          TextSpan(
                            text: "Forever",
                            style: TextStyle(
                              color:
                                  colors.primary,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      height: 45,
                    ),

                    // ==========================================
                    // LOADING INDICATOR
                    // ==========================================

                    SizedBox(
                      width: 220,

                      child:
                          LinearProgressIndicator(
                        minHeight: 5,

                        borderRadius:
                            BorderRadius.circular(
                          20,
                        ),

                        backgroundColor:
                            colors.onSurface
                                .withOpacity(.08),

                        color:
                            colors.primary,
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ==========================================
                    // LOADING TEXT
                    // ==========================================

                    Text(
                      "Loading your knowledge...",

                      style:
                          GoogleFonts.poppins(
                        color: colors
                            .onSurface
                            .withOpacity(.50),

                        fontSize: 10.5,

                        fontWeight:
                            FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ==================================================
            // VERSION / BRANDING
            // ==================================================

            Positioned(
              bottom: 22,
              left: 0,
              right: 0,

              child: Text(
                "SMART LEARNING • BETTER MEMORY",

                textAlign:
                    TextAlign.center,

                style:
                    GoogleFonts.poppins(
                  color: colors
                      .onSurface
                      .withOpacity(.30),

                  fontSize: 8.5,

                  letterSpacing: 1.2,

                  fontWeight:
                      FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}