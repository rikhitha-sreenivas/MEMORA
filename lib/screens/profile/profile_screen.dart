import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../welcome/welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required Null Function() onBackToHome});

  // ============================================================
  // USER DATA STREAM
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots();
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
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: getUserStream(),

          builder: (context, snapshot) {
            // ==================================================
            // LOADING
            // ==================================================

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: colors.primary),
              );
            }

            // ==================================================
            // ERROR
            // ==================================================

            if (snapshot.hasError) {
              return _buildErrorState(context, snapshot.error.toString());
            }

            // ==================================================
            // USER DATA
            // ==================================================

            final data = snapshot.data?.data() ?? {};

            final user = FirebaseAuth.instance.currentUser;

            final String name = (data["name"] ?? user?.displayName ?? "User")
                .toString();

            final String email = (data["email"] ?? user?.email ?? "")
                .toString();

            final String role = (data["role"] ?? "user").toString();

            final int decks = _toInt(data["decks"]);

            final int cardsStudied = _toInt(data["cardsStudied"]);

            final int quizAttempts = _toInt(data["quizAttempts"]);

            final int streak = _toInt(data["streak"]);

            final int accuracy = _getAccuracy(data);

            // ==================================================
            // CONTENT
            // ==================================================

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      // ==================================================
                      // TOP BAR WITH BACK BUTTON
                      // ==================================================
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },

                            icon: const Icon(Icons.arrow_back_rounded),

                            tooltip: "Back",

                            color: colors.onSurface,
                          ),

                          const SizedBox(width: 4),

                          Text(
                            "Profile",

                            style: GoogleFonts.poppins(
                              color: colors.onSurface,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 2),

                      Padding(
                        padding: const EdgeInsets.only(left: 12),

                        child: Text(
                          "Manage your account and view your learning activity",

                          style: GoogleFonts.poppins(
                            color: colors.onSurface.withOpacity(.55),
                            fontSize: 12.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // PROFILE CARD
                      // ==================================================
                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.all(22),

                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(.07),

                          borderRadius: BorderRadius.circular(22),

                          border: Border.all(
                            color: colors.primary.withOpacity(.10),
                          ),
                        ),

                        child: Column(
                          children: [
                            // PROFILE AVATAR
                            Container(
                              width: 88,
                              height: 88,

                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(.12),

                                shape: BoxShape.circle,

                                border: Border.all(
                                  color: colors.primary.withOpacity(.30),

                                  width: 2,
                                ),
                              ),

                              child: Icon(
                                Icons.person_rounded,
                                color: colors.primary,
                                size: 45,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // NAME
                            Text(
                              name,
                              textAlign: TextAlign.center,

                              style: GoogleFonts.poppins(
                                color: colors.onSurface,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 4),

                            // EMAIL
                            Text(
                              email,
                              textAlign: TextAlign.center,

                              style: GoogleFonts.poppins(
                                color: colors.onSurface.withOpacity(.55),
                                fontSize: 11.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // ROLE
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 7,
                              ),

                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(.10),

                                borderRadius: BorderRadius.circular(20),

                                border: Border.all(
                                  color: colors.primary.withOpacity(.15),
                                ),
                              ),

                              child: Row(
                                mainAxisSize: MainAxisSize.min,

                                children: [
                                  Icon(
                                    role.toLowerCase() == "admin"
                                        ? Icons.admin_panel_settings_rounded
                                        : Icons.person_outline_rounded,

                                    color: colors.primary,

                                    size: 16,
                                  ),

                                  const SizedBox(width: 6),

                                  Text(
                                    role.toUpperCase(),

                                    style: GoogleFonts.poppins(
                                      color: colors.primary,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: .5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // LEARNING ACTIVITY
                      // ==================================================
                      _sectionTitle(context, "Learning Activity"),

                      const SizedBox(height: 10),

                      GridView.count(
                        shrinkWrap: true,

                        physics: const NeverScrollableScrollPhysics(),

                        crossAxisCount: 2,

                        crossAxisSpacing: 12,

                        mainAxisSpacing: 12,

                        childAspectRatio: 1.35,

                        children: [
                          _statCard(
                            context,
                            icon: Icons.library_books_rounded,
                            value: "$decks",
                            title: "Decks",
                          ),

                          _statCard(
                            context,
                            icon: Icons.style_rounded,
                            value: "$cardsStudied",
                            title: "Cards Studied",
                          ),

                          _statCard(
                            context,
                            icon: Icons.quiz_rounded,
                            value: "$quizAttempts",
                            title: "Quiz Attempts",
                          ),

                          _statCard(
                            context,
                            icon: Icons.track_changes_rounded,
                            value: "$accuracy%",
                            title: "Accuracy",
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // LEARNING STREAK
                      // ==================================================
                      _sectionTitle(context, "Learning Streak"),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.all(20),

                        decoration: BoxDecoration(
                          color: colors.primary.withOpacity(.07),

                          borderRadius: BorderRadius.circular(20),

                          border: Border.all(
                            color: colors.primary.withOpacity(.10),
                          ),
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,

                              decoration: BoxDecoration(
                                color: colors.primary.withOpacity(.12),

                                borderRadius: BorderRadius.circular(15),
                              ),

                              child: Icon(
                                Icons.local_fire_department_rounded,
                                color: colors.primary,
                                size: 29,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "$streak Days",

                                    style: GoogleFonts.poppins(
                                      color: colors.onSurface,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    streak == 0
                                        ? "Start studying to build your streak!"
                                        : "Keep learning every day to maintain your streak.",

                                    style: GoogleFonts.poppins(
                                      color: colors.onSurface.withOpacity(.50),
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // ACCOUNT INFORMATION
                      // ==================================================
                      _sectionTitle(context, "Account Information"),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: colors.onSurface.withOpacity(.035),

                          borderRadius: BorderRadius.circular(20),

                          border: Border.all(
                            color: colors.onSurface.withOpacity(.07),
                          ),
                        ),

                        child: Column(
                          children: [
                            _infoRow(
                              context,
                              icon: Icons.person_outline_rounded,
                              title: "Name",
                              value: name,
                            ),

                            _divider(context),

                            _infoRow(
                              context,
                              icon: Icons.email_outlined,
                              title: "Email",
                              value: email,
                            ),

                            _divider(context),

                            _infoRow(
                              context,
                              icon: Icons.badge_outlined,
                              title: "Account Type",
                              value: role.toUpperCase(),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ==================================================
                      // ACCOUNT / LOGOUT
                      // ==================================================
                      _sectionTitle(context, "Account"),

                      const SizedBox(height: 10),

                      Container(
                        width: double.infinity,

                        decoration: BoxDecoration(
                          color: colors.error.withOpacity(.05),

                          borderRadius: BorderRadius.circular(18),

                          border: Border.all(
                            color: colors.error.withOpacity(.12),
                          ),
                        ),

                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 4,
                          ),

                          leading: Container(
                            width: 42,
                            height: 42,

                            decoration: BoxDecoration(
                              color: colors.error.withOpacity(.10),

                              borderRadius: BorderRadius.circular(12),
                            ),

                            child: Icon(
                              Icons.logout_rounded,
                              color: colors.error,
                              size: 21,
                            ),
                          ),

                          title: Text(
                            "Logout",

                            style: GoogleFonts.poppins(
                              color: colors.error,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          subtitle: Text(
                            "Sign out of your account",

                            style: GoogleFonts.poppins(
                              color: colors.onSurface.withOpacity(.45),
                              fontSize: 10,
                            ),
                          ),

                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: colors.onSurface.withOpacity(.35),
                            size: 15,
                          ),

                          onTap: () {
                            _showLogoutDialog(context);
                          },
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String title,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: colors.onSurface.withOpacity(.035),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: colors.onSurface.withOpacity(.07)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Icon(icon, color: colors.primary, size: 27),

          const SizedBox(height: 8),

          Text(
            value,

            style: GoogleFonts.poppins(
              color: colors.onSurface,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          Text(
            title,

            style: GoogleFonts.poppins(
              color: colors.onSurface.withOpacity(.50),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),

      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color: colors.primary.withOpacity(.08),

              borderRadius: BorderRadius.circular(11),
            ),

            child: Icon(icon, color: colors.primary, size: 19),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style: GoogleFonts.poppins(
                    color: colors.onSurface.withOpacity(.45),
                    fontSize: 9.5,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value.isEmpty ? "Not available" : value,

                  maxLines: 1,

                  overflow: TextOverflow.ellipsis,

                  style: GoogleFonts.poppins(
                    color: colors.onSurface,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Divider(height: 1, color: colors.onSurface.withOpacity(.07));
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(BuildContext context, String title) {
    final colors = Theme.of(context).colorScheme;

    return Text(
      title,

      style: GoogleFonts.poppins(
        color: colors.onSurface,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  Future<void> _showLogoutDialog(BuildContext context) async {
    final colors = Theme.of(context).colorScheme;

    final shouldLogout = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,

          title: Text(
            "Logout?",

            style: GoogleFonts.poppins(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),

          content: Text(
            "Are you sure you want to logout from your account?",

            style: GoogleFonts.poppins(
              color: colors.onSurface.withOpacity(.60),
              fontSize: 12.5,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },

              child: Text("Cancel", style: TextStyle(color: colors.primary)),
            ),

            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: colors.error),

              onPressed: () {
                Navigator.pop(dialogContext, true);
              },

              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(builder: (_) => const WelcomeScreen()),

        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Unable to logout: $e")));
    }
  }

  // ============================================================
  // ACCURACY
  // ============================================================

  int _getAccuracy(Map<String, dynamic> data) {
    if (data["accuracy"] != null) {
      return _toInt(data["accuracy"]);
    }

    final correctAnswers = _toInt(data["correctAnswers"]);

    final totalAnswers = _toInt(data["totalAnswers"]);

    if (totalAnswers == 0) {
      return 0;
    }

    return ((correctAnswers / totalAnswers) * 100).round();
  }

  // ============================================================
  // SAFE INTEGER CONVERSION
  // ============================================================

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? "") ?? 0;
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(BuildContext context, String error) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 45),

            const SizedBox(height: 12),

            Text(
              "Unable to load profile",

              style: GoogleFonts.poppins(
                color: colors.onSurface,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              error,

              textAlign: TextAlign.center,

              style: GoogleFonts.poppins(
                color: colors.onSurface.withOpacity(.50),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
