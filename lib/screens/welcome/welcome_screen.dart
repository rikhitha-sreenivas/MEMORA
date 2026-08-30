import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/admin_register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.surface,

      body: SafeArea(
        child: Stack(
          children: [

            // ============================================================
            // DECORATIVE BACKGROUND ELEMENTS
            // ============================================================

            Positioned(
              top: 60,
              right: 25,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              top: 300,
              left: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: 100,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // ============================================================
            // MAIN CONTENT
            // ============================================================

            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  30,
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 850,
                    ),

                    child: Column(
                      children: [

                        // ==================================================
                        // TOP BAR
                        // ==================================================

                        Align(
                          alignment: Alignment.topRight,

                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const LoginScreen(),
                                ),
                              );
                            },

                            child: Text(
                              "Sign In",
                              style: GoogleFonts.poppins(
                                color: colors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ==================================================
                        // LOGO
                        // ==================================================

                        Container(
                          width: 115,
                          height: 115,

                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            color: colors.primary.withOpacity(.08),

                            shape: BoxShape.circle,

                            border: Border.all(
                              color: colors.primary.withOpacity(.15),
                            ),
                          ),

                          child: Image.asset(
                            "assets/images/memora_logo.png",
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // MEMORA TITLE
                        // ==================================================

                        Text(
                          "MEMORA",
                          textAlign: TextAlign.center,

                          style: GoogleFonts.poppins(
                            color: colors.onSurface,
                            fontSize: width > 600 ? 55 : 42,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          "Learn smart. Remember better.",
                          textAlign: TextAlign.center,

                          style: GoogleFonts.poppins(
                            color: colors.onSurface.withOpacity(.55),
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // INTRODUCTION CARD
                        // ==================================================

                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(22),

                          decoration: BoxDecoration(
                            color: colors.onSurface.withOpacity(.035),

                            borderRadius:
                                BorderRadius.circular(22),

                            border: Border.all(
                              color: colors.onSurface.withOpacity(.07),
                            ),
                          ),

                          child: Column(
                            children: [

                              Icon(
                                Icons.auto_awesome_rounded,
                                color: colors.primary,
                                size: 32,
                              ),

                              const SizedBox(height: 12),

                              Text(
                                "Your Learning Companion",
                                textAlign: TextAlign.center,

                                style: GoogleFonts.poppins(
                                  color: colors.onSurface,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 7),

                              Text(
                                "Create flashcards, practice with quizzes, "
                                "track your progress and build better "
                                "learning habits with Memora.",
                                textAlign: TextAlign.center,

                                style: GoogleFonts.poppins(
                                  color: colors.onSurface.withOpacity(.55),
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ==================================================
                        // FEATURES
                        // ==================================================

                        Row(
                          children: [

                            Expanded(
                              child: _featureCard(
                                context,
                                Icons.layers_rounded,
                                "Smart Decks",
                                "Create & organize",
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: _featureCard(
                                context,
                                Icons.quiz_rounded,
                                "Practice",
                                "Test your knowledge",
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: _featureCard(
                                context,
                                Icons.insights_rounded,
                                "Progress",
                                "Track your growth",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // GET STARTED BUTTON
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton.icon(
                            onPressed: () {
                              _showRegistrationChoice(context);
                            },

                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                            ),

                            label: Text(
                              "Get Started",
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,

                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ==================================================
                        // LOGIN
                        // ==================================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [

                            Text(
                              "Already have an account? ",
                              style: GoogleFonts.poppins(
                                color: colors.onSurface.withOpacity(.50),
                                fontSize: 12,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const LoginScreen(),
                                  ),
                                );
                              },

                              child: Text(
                                "Sign In",
                                style: GoogleFonts.poppins(
                                  color: colors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // REGISTRATION CHOICE
  // ================================================================

  void _showRegistrationChoice(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,

      backgroundColor: colors.surface,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              25,
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                // ==========================================================
                // HANDLE
                // ==========================================================

                Container(
                  width: 40,
                  height: 4,

                  decoration: BoxDecoration(
                    color: colors.onSurface.withOpacity(.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                Text(
                  "Create Your Account",
                  style: GoogleFonts.poppins(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Choose how you want to use Memora",
                  style: GoogleFonts.poppins(
                    color: colors.onSurface.withOpacity(.50),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 20),

                // ==========================================================
                // USER
                // ==========================================================

                _accountTypeButton(
                  context: context,
                  icon: Icons.person_rounded,
                  title: "Continue as User",
                  subtitle:
                      "Learn, practice and track your progress",
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RegisterScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // ==========================================================
                // ADMIN
                // ==========================================================

                _accountTypeButton(
                  context: context,
                  icon: Icons.admin_panel_settings_rounded,
                  title: "Continue as Admin",
                  subtitle:
                      "Manage decks, PDFs and learning content",
                  onTap: () {
                    Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const AdminRegisterScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  child: Text(
                    "Cancel",
                    style: GoogleFonts.poppins(
                      color: colors.onSurface.withOpacity(.45),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================================================================
  // ACCOUNT TYPE BUTTON
  // ================================================================

  Widget _accountTypeButton({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(18),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: colors.onSurface.withOpacity(.035),

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: colors.onSurface.withOpacity(.07),
          ),
        ),

        child: Row(
          children: [

            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color: colors.primary.withOpacity(.10),

                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color: colors.primary,
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: colors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      color:
                          colors.onSurface.withOpacity(.45),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.arrow_forward_ios_rounded,
              color:
                  colors.onSurface.withOpacity(.35),
              size: 15,
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // FEATURE CARD
  // ================================================================

  Widget _featureCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 125,

      padding: const EdgeInsets.all(10),

      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(.035),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: colors.onSurface.withOpacity(.07),
        ),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            color: colors.primary,
            size: 27,
          ),

          const SizedBox(height: 9),

          Text(
            title,
            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(
              color: colors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            subtitle,
            textAlign: TextAlign.center,

            style: GoogleFonts.poppins(
              color: colors.onSurface.withOpacity(.45),
              fontSize: 8.5,
            ),
          ),
        ],
      ),
    );
  }
}