import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../decks/create_deck_screen.dart';
import '../decks/decks_screen.dart';
import '../pdfs/create_pdf_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isAdmin;
  final VoidCallback? openQuiz;

  const HomeScreen({
    super.key,
    required this.isAdmin,
    this.openQuiz,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String uid;

  // ============================================================
  // BRAND COLORS
  // ============================================================

  static const Color primary = Color(0xFF6C63FF);
  static const Color navy = Color(0xFF18245C);
  static const Color cyan = Color(0xFF5BCAFF);
  static const Color orange = Color(0xFFFFA044);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  // ============================================================
  // FIREBASE - DECK COUNT
  // ============================================================

  Stream<int> getDeckCount() {
    if (uid.isEmpty) {
      return Stream.value(0);
    }

    // Admin sees all decks.
    // User sees only their own decks.
    if (widget.isAdmin) {
      return FirebaseFirestore.instance
          .collection("decks")
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    }

    return FirebaseFirestore.instance
        .collection("decks")
        .where(
          "userId",
          isEqualTo: uid,
        )
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ============================================================
  // FIREBASE - TOTAL CARD COUNT
  // ============================================================
  //
  // This is kept for ADMIN content statistics.
  //
  // IMPORTANT:
  // Normal users DO NOT use this value for the "Cards" stat.
  // Their Cards stat comes from users/{uid}/cardsStudied.
  //
  // ============================================================

  Stream<int> getCardCount() {
    if (uid.isEmpty) {
      return Stream.value(0);
    }

    return FirebaseFirestore.instance
        .collection("decks")
        .snapshots()
        .asyncMap((snapshot) async {
      int totalCards = 0;

      for (final deck in snapshot.docs) {
        final cards = await FirebaseFirestore.instance
            .collection("decks")
            .doc(deck.id)
            .collection("cards")
            .get();

        totalCards += cards.docs.length;
      }

      return totalCards;
    });
  }

  // ============================================================
  // FIREBASE - USER DATA
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream() {
    if (uid.isEmpty) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .snapshots();
  }

  // ============================================================
  // FIREBASE - QUIZ ACCURACY
  // ============================================================

  Stream<double> getAccuracy() {
    if (uid.isEmpty) {
      return Stream.value(0);
    }

    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("quizResults")
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return 0.0;
      }

      double totalAccuracy = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final accuracy = data["accuracy"];

        if (accuracy is num) {
          totalAccuracy += accuracy.toDouble();
        }
      }

      return totalAccuracy / snapshot.docs.length;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      body: SafeArea(
        bottom: false,

        child: StreamBuilder<int>(
          stream: getDeckCount(),

          builder: (context, deckSnapshot) {
            return StreamBuilder<int>(
              stream: getCardCount(),

              builder: (context, cardSnapshot) {
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: getUserStream(),

                  builder: (context, userSnapshot) {
                    return StreamBuilder<double>(
                      stream: getAccuracy(),

                      builder: (context, accuracySnapshot) {
                        // ==================================================
                        // DECKS
                        // ==================================================

                        final int deckCount =
                            deckSnapshot.data ?? 0;

                        // ==================================================
                        // TOTAL CARDS
                        // ==================================================

                        final int totalCardCount =
                            cardSnapshot.data ?? 0;

                        // ==================================================
                        // USER DATA
                        // ==================================================

                        final Map<String, dynamic> userData =
                            userSnapshot.data?.data() ?? {};

                        // ==================================================
                        // ⭐ CARDS STUDIED
                        // ==================================================
                        //
                        // THIS IS THE IMPORTANT FIX.
                        //
                        // ProgressScreen uses:
                        // userData["cardsStudied"]
                        //
                        // HomeScreen now uses the SAME field.
                        //
                        // Because getUserStream() uses snapshots(),
                        // this value updates automatically whenever
                        // users/{uid}/cardsStudied changes.
                        //
                        // ==================================================

                        final int cardsStudied =
                            _toInt(userData["cardsStudied"]);

                        // ==================================================
                        // STREAK
                        // ==================================================

                        final int streak =
                            _toInt(userData["streak"]);

                        // ==================================================
                        // QUIZ ATTEMPTS
                        // ==================================================

                        final int quizAttempts =
                            _toInt(userData["quizAttempts"]);

                        // ==================================================
                        // DAILY GOAL
                        // ==================================================

                        final int dailyCardsStudied =
                            _toInt(
                          userData["dailyCardsStudied"],
                        );

                        final int storedDailyGoal =
                            _toInt(
                          userData["dailyGoal"],
                        );

                        final int dailyGoal =
                            storedDailyGoal > 0
                                ? storedDailyGoal
                                : 10;

                        // ==================================================
                        // ACCURACY
                        // ==================================================

                        final double accuracy =
                            accuracySnapshot.data ?? 0;

                        final int accuracyPercent =
                            accuracy.clamp(0, 100).round();

                        // ==================================================
                        // DAILY PROGRESS
                        // ==================================================

                        final double dailyProgress =
                            dailyGoal > 0
                                ? (dailyCardsStudied / dailyGoal)
                                    .clamp(0.0, 1.0)
                                : 0.0;

                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              physics:
                                  const BouncingScrollPhysics(),

                              padding: EdgeInsets.only(
                                left: constraints.maxWidth > 700
                                    ? 40
                                    : 20,

                                right: constraints.maxWidth > 700
                                    ? 40
                                    : 20,

                                top: 18,

                                bottom: 100,
                              ),

                              child: Center(
                                child: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(
                                    maxWidth: 1100,
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      // ==================================================
                                      // HEADER
                                      // ==================================================

                                      _buildHeader(
                                        context,
                                      ),

                                      const SizedBox(
                                        height: 24,
                                      ),

                                      // ==================================================
                                      // HERO
                                      // ==================================================

                                      _buildHero(
                                        context,
                                        streak,
                                        accuracyPercent,
                                      ),

                                      const SizedBox(
                                        height: 28,
                                      ),

                                      // ==================================================
                                      // OVERVIEW
                                      // ==================================================

                                      _sectionTitle(
                                        context,
                                        widget.isAdmin
                                            ? "Content Overview"
                                            : "Your Overview",
                                        widget.isAdmin
                                            ? "Your learning content at a glance"
                                            : "Your learning activity at a glance",
                                      ),

                                      const SizedBox(
                                        height: 14,
                                      ),

                                      _buildStats(
                                        context,
                                        deckCount,

                                        // ⭐ IMPORTANT:
                                        // Admin sees total cards.
                                        // User sees cards studied.
                                        widget.isAdmin
                                            ? totalCardCount
                                            : cardsStudied,

                                        streak,
                                      ),

                                      const SizedBox(
                                        height: 28,
                                      ),

                                      // ==================================================
                                      // QUICK ACTIONS
                                      // ==================================================

                                      _sectionTitle(
                                        context,
                                        widget.isAdmin
                                            ? "Admin Actions"
                                            : "Quick Actions",
                                        widget.isAdmin
                                            ? "Manage your learning content"
                                            : "Jump back into learning",
                                      ),

                                      const SizedBox(
                                        height: 14,
                                      ),

                                      _buildActions(
                                        context,
                                        constraints.maxWidth,
                                      ),

                                      const SizedBox(
                                        height: 28,
                                      ),

                                      // ==================================================
                                      // DAILY GOAL
                                      // ==================================================

                                      if (!widget.isAdmin)
                                        _buildDailyGoal(
                                          context,
                                          dailyCardsStudied,
                                          dailyGoal,
                                          dailyProgress,
                                        ),

                                      if (!widget.isAdmin)
                                        const SizedBox(
                                          height: 20,
                                        ),

                                      // ==================================================
                                      // ADMIN INFORMATION
                                      // ==================================================

                                      if (widget.isAdmin)
                                        _buildAdminInfo(
                                          context,
                                        ),

                                      if (widget.isAdmin)
                                        const SizedBox(
                                          height: 20,
                                        ),

                                      // ==================================================
                                      // STUDY TIP
                                      // ==================================================

                                      if (!widget.isAdmin)
                                        _buildStudyTip(
                                          context,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    final user =
        FirebaseAuth.instance.currentUser;

    String name =
        user?.displayName ?? '';

    if (name.isEmpty) {
      name =
          user?.email?.split('@').first ??
              'Learner';
    }

    if (name.isNotEmpty) {
      name =
          name[0].toUpperCase() +
              name.substring(1);
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                widget.isAdmin
                    ? "Welcome back, Admin 👋"
                    : "Welcome back 👋",

                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: theme
                      .colorScheme
                      .onSurface
                      .withOpacity(.55),
                  fontWeight:
                      FontWeight.w500,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                name,

                maxLines: 1,

                overflow:
                    TextOverflow.ellipsis,

                style: GoogleFonts.poppins(
                  fontSize: 27,
                  fontWeight:
                      FontWeight.w700,
                  color: theme
                      .colorScheme
                      .onSurface,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                widget.isAdmin
                    ? "Manage your learning content"
                    : "Ready to learn something new?",

                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: theme
                      .colorScheme
                      .onSurface
                      .withOpacity(.50),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 15),

        Container(
          width: 48,
          height: 48,

          decoration: BoxDecoration(
            color: theme
                .colorScheme
                .primary,

            shape: BoxShape.circle,

            boxShadow: [
              BoxShadow(
                color: theme
                    .colorScheme
                    .primary
                    .withOpacity(.22),

                blurRadius: 12,

                offset:
                    const Offset(0, 5),
              ),
            ],
          ),

          child: Icon(
            widget.isAdmin
                ? Icons.admin_panel_settings_rounded
                : Icons.school_rounded,

            color: theme
                .colorScheme
                .onPrimary,

            size: 24,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // HERO
  // ============================================================

  Widget _buildHero(
    BuildContext context,
    int streak,
    int accuracy,
  ) {
    final theme = Theme.of(context);

    final double progress =
        accuracy / 100;

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            theme.brightness ==
                    Brightness.dark
                ? const Color(0xFF25295A)
                : navy,

            theme.brightness ==
                    Brightness.dark
                ? const Color(0xFF181B40)
                : primary,
          ],
        ),

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: theme
                .colorScheme
                .primary
                .withOpacity(.18),

            blurRadius: 20,

            offset:
                const Offset(0, 10),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ========================================================
          // BADGE
          // ========================================================

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color:
                  Colors.white.withOpacity(.12),

              borderRadius:
                  BorderRadius.circular(30),
            ),

            child: Row(
              mainAxisSize:
                  MainAxisSize.min,

              children: [
                Icon(
                  widget.isAdmin
                      ? Icons.admin_panel_settings_rounded
                      : Icons.local_fire_department_rounded,

                  color: widget.isAdmin
                      ? Colors.white
                      : Colors.orangeAccent,

                  size: 16,
                ),

                const SizedBox(width: 5),

                Text(
                  widget.isAdmin
                      ? "Admin Dashboard"
                      : streak > 0
                          ? "$streak day streak"
                          : "Start your streak",

                  style:
                      GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // ========================================================
          // HERO TITLE
          // ========================================================

          Text(
            widget.isAdmin
                ? "Build.\nOrganize. Teach."
                : "Keep learning.\nKeep growing.",

            style:
                GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 25,
              height: 1.2,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.isAdmin
                ? "Create flashcard decks and learning PDFs to help users learn better."
                : accuracy > 0
                    ? "Your current learning accuracy is $accuracy%. Keep practicing to improve your performance."
                    : "Start studying and taking quizzes to build your learning progress.",

            style:
                GoogleFonts.poppins(
              color:
                  Colors.white.withOpacity(.70),
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // ========================================================
          // DYNAMIC PROGRESS
          // ========================================================

          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),

                  child:
                      LinearProgressIndicator(
                    value: widget.isAdmin
                        ? 1.0
                        : progress,

                    minHeight: 7,

                    backgroundColor:
                        Colors.white
                            .withOpacity(.12),

                    valueColor:
                        const AlwaysStoppedAnimation(
                      cyan,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Text(
                widget.isAdmin
                    ? "Ready"
                    : "$accuracy%",

                style:
                    GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // ========================================================
          // HERO BUTTON
          // ========================================================

          SizedBox(
            height: 42,

            child:
                ElevatedButton.icon(
              onPressed: widget.isAdmin
                  ? _createDeck
                  : _openDecks,

              icon: Icon(
                widget.isAdmin
                    ? Icons.add_rounded
                    : Icons.play_arrow_rounded,

                size: 19,
              ),

              label: Text(
                widget.isAdmin
                    ? "Create a Deck"
                    : "Continue Studying",
              ),

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.white,

                foregroundColor:
                    navy,

                elevation: 0,

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                textStyle:
                    GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    BuildContext context,
    String title,
    String subtitle,
  ) {
    final color =
        Theme.of(context)
            .colorScheme
            .onSurface;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style:
              GoogleFonts.poppins(
            color: color,
            fontSize: 20,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,

          style:
              GoogleFonts.poppins(
            color:
                color.withOpacity(.48),
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats(
    BuildContext context,
    int decks,
    int cards,
    int streak,
  ) {
    final children = [
      _statCard(
        context,
        Icons.auto_stories_rounded,
        "$decks",
        "Decks",
        primary,
      ),

      _statCard(
        context,
        Icons.style_rounded,
        "$cards",
        "Cards",
        cyan,
      ),

      _statCard(
        context,
        Icons.local_fire_department_rounded,
        "$streak",
        "Streak",
        orange,
      ),
    ];

    return Row(
      children: [
        for (int i = 0;
            i < children.length;
            i++) ...[
          Expanded(
            child: children[i],
          ),

          if (i != children.length - 1)
            const SizedBox(width: 10),
        ],
      ],
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard(
    BuildContext context,
    IconData icon,
    String value,
    String title,
    Color iconColor,
  ) {
    final theme =
        Theme.of(context);

    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surface,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: theme
              .dividerColor
              .withOpacity(.7),
        ),

        boxShadow:
            theme.brightness ==
                    Brightness.light
                ? [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(.035),

                      blurRadius: 12,

                      offset:
                          const Offset(0, 5),
                    ),
                  ]
                : null,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Container(
            width: 38,
            height: 38,

            decoration: BoxDecoration(
              color:
                  iconColor.withOpacity(.12),

              borderRadius:
                  BorderRadius.circular(11),
            ),

            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,

            style:
                GoogleFonts.poppins(
              color: theme
                  .colorScheme
                  .onSurface,

              fontSize: 23,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          Text(
            title,

            style:
                GoogleFonts.poppins(
              color: theme
                  .colorScheme
                  .onSurface
                  .withOpacity(.50),

              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTIONS
  // ============================================================

  Widget _buildActions(
    BuildContext context,
    double width,
  ) {
    final List<Widget> actions = [];

    if (widget.isAdmin) {
      actions.add(
        _actionCard(
          context,
          Icons.add_box_rounded,
          "Create Deck",
          "Create and manage flashcard decks",
          primary,
          _createDeck,
        ),
      );

      actions.add(
        _actionCard(
          context,
          Icons.picture_as_pdf_rounded,
          "Create PDF",
          "Upload and manage learning PDFs",
          cyan,
          _createPdf,
        ),
      );
    } else {
      actions.add(
        _actionCard(
          context,
          Icons.menu_book_rounded,
          "Study Deck",
          "Review your flashcards",
          primary,
          _openDecks,
        ),
      );

      actions.add(
        _actionCard(
          context,
          Icons.quiz_rounded,
          "Start Quiz",
          "Test your knowledge",
          cyan,
          () {
            widget.openQuiz?.call();
          },
        ),
      );
    }

    if (width < 500) {
      return Column(
        children: [
          for (int i = 0;
              i < actions.length;
              i++) ...[
            actions[i],

            if (i != actions.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      );
    }

    return Row(
      children: [
        for (int i = 0;
            i < actions.length;
            i++) ...[
          Expanded(
            child: actions[i],
          ),

          if (i != actions.length - 1)
            const SizedBox(width: 14),
        ],
      ],
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _actionCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    final theme =
        Theme.of(context);

    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(18),

      child: Container(
        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: theme
              .colorScheme
              .surface,

          borderRadius:
              BorderRadius.circular(18),

          border: Border.all(
            color: theme
                .dividerColor
                .withOpacity(.7),
          ),
        ),

        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,

              decoration: BoxDecoration(
                color:
                    color.withOpacity(.12),

                borderRadius:
                    BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style:
                        GoogleFonts.poppins(
                      color: theme
                          .colorScheme
                          .onSurface,

                      fontSize: 13,

                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,

                    style:
                        GoogleFonts.poppins(
                      color: theme
                          .colorScheme
                          .onSurface
                          .withOpacity(.45),

                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons
                  .arrow_forward_ios_rounded,

              size: 14,

              color: theme
                  .colorScheme
                  .onSurface
                  .withOpacity(.30),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DAILY GOAL
  // ============================================================

  Widget _buildDailyGoal(
    BuildContext context,
    int studied,
    int goal,
    double progress,
  ) {
    final theme =
        Theme.of(context);

    final percentage =
        (progress * 100).round();

    final completed =
        studied >= goal;

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .primary
            .withOpacity(
              theme.brightness ==
                      Brightness.dark
                  ? .15
                  : .08,
            ),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: theme
              .colorScheme
              .primary
              .withOpacity(.15),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: theme
                  .colorScheme
                  .primary,

              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: Icon(
              completed
                  ? Icons.check_rounded
                  : Icons.track_changes_rounded,

              color: theme
                  .colorScheme
                  .onPrimary,

              size: 24,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  completed
                      ? "Today's Goal Completed 🎉"
                      : "Today's Learning Goal",

                  style:
                      GoogleFonts.poppins(
                    color: theme
                        .colorScheme
                        .onSurface,

                    fontSize: 13,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  completed
                      ? "Great work! You've reached your learning goal."
                      : "$studied of $goal cards studied today",

                  style:
                      GoogleFonts.poppins(
                    color: theme
                        .colorScheme
                        .onSurface
                        .withOpacity(.55),

                    fontSize: 10.5,
                  ),
                ),

                const SizedBox(height: 10),

                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(10),

                  child:
                      LinearProgressIndicator(
                    value: progress,

                    minHeight: 6,

                    backgroundColor:
                        theme
                            .colorScheme
                            .surface,

                    valueColor:
                        AlwaysStoppedAnimation(
                      theme
                          .colorScheme
                          .primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Text(
            "$percentage%",

            style:
                GoogleFonts.poppins(
              color: theme
                  .colorScheme
                  .primary,

              fontSize: 12,

              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADMIN INFORMATION
  // ============================================================

  Widget _buildAdminInfo(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .primary
            .withOpacity(
          theme.brightness ==
                  Brightness.dark
              ? .15
              : .08,
        ),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: theme
              .colorScheme
              .primary
              .withOpacity(.15),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration: BoxDecoration(
              color: theme
                  .colorScheme
                  .primary,

              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: Icon(
              Icons.dashboard_customize_rounded,

              color: theme
                  .colorScheme
                  .onPrimary,

              size: 23,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "Content Management",

                  style:
                      GoogleFonts.poppins(
                    color: theme
                        .colorScheme
                        .onSurface,

                    fontSize: 13,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "Create decks and upload PDFs to keep learning resources organized.",

                  style:
                      GoogleFonts.poppins(
                    color: theme
                        .colorScheme
                        .onSurface
                        .withOpacity(.55),

                    fontSize: 10.5,

                    height: 1.4,
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
  // STUDY TIP
  // ============================================================

  Widget _buildStudyTip(
    BuildContext context,
  ) {
    final theme =
        Theme.of(context);

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: theme
            .colorScheme
            .surface,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: theme
              .dividerColor
              .withOpacity(.7),
        ),
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          const Text(
            "💡",

            style: TextStyle(
              fontSize: 25,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  "Study Tip",

                  style:
                      GoogleFonts.poppins(
                    color: theme
                        .colorScheme
                        .onSurface,

                    fontSize: 13,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "Short, consistent study sessions are more effective than trying to memorize everything at once.",

                  style:
                      GoogleFonts.poppins(
                    color: theme
                        .colorScheme
                        .onSurface
                        .withOpacity(.55),

                    fontSize: 11,

                    height: 1.5,
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
  // CREATE DECK
  // ============================================================

  Future<void> _createDeck() async {
    final deckName =
        await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            const CreateDeckScreen(),
      ),
    );

    if (deckName != null &&
        deckName
            .toString()
            .trim()
            .isNotEmpty) {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        return;
      }

      await FirebaseFirestore.instance
          .collection("decks")
          .add({
        "title": deckName
            .toString()
            .trim(),

        "description": "",

        "cardCount": 0,

        "userId": user.uid,

        "createdAt":
            FieldValue.serverTimestamp(),
      });
    }
  }

  // ============================================================
  // CREATE PDF
  // ============================================================

  Future<void> _createPdf() async {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            const CreatePdfScreen(),
      ),
    );
  }

  // ============================================================
  // OPEN DECKS
  // ============================================================

  void _openDecks() {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            DecksScreen(
          isAdmin: widget.isAdmin,
        ),
      ),
    );
  }

  // ============================================================
  // INTEGER CONVERSION
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

    return int.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }
}
