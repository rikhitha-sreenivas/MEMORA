import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressScreen extends StatelessWidget {
  // ============================================================
  // BACK CALLBACK
  // ============================================================

  final VoidCallback? onBackToHome;

  const ProgressScreen({
    super.key,
    this.onBackToHome,
  });

  // ============================================================
  // USER DATA
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserData() {
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
  // DECK COUNT
  // ============================================================

  Stream<int> getDeckCount() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(0);
    }

    return FirebaseFirestore.instance
        .collection("decks")
        .where(
          "userId",
          isEqualTo: user.uid,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.length,
        );
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

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: StreamBuilder<
            DocumentSnapshot<Map<String, dynamic>>>(
          stream: getUserData(),

          builder: (context, userSnapshot) {
            // ====================================================
            // LOADING
            // ====================================================

            if (userSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: colors.primary,
                ),
              );
            }

            // ====================================================
            // ERROR
            // ====================================================

            if (userSnapshot.hasError) {
              return _errorState(
                context,
                userSnapshot.error.toString(),
              );
            }

            // ====================================================
            // USER DATA
            // ====================================================

            final data =
                userSnapshot.data?.data() ?? {};

            // ====================================================
            // TOTAL CARDS STUDIED
            // ====================================================

            final int cardsStudied =
                _toInt(data["cardsStudied"]);

            // ====================================================
            // TODAY'S CARDS STUDIED
            // ====================================================

            final int dailyCardsStudied =
                _toInt(data["dailyCardsStudied"]);

            // ====================================================
            // DAILY GOAL
            // ====================================================

            final int dailyGoal =
                _toInt(data["dailyGoal"]) > 0
                    ? _toInt(data["dailyGoal"])
                    : 10;

            // ====================================================
            // STREAK
            // ====================================================

            final int streak =
                _toInt(data["streak"]);

            // ====================================================
            // QUIZ ATTEMPTS
            // ====================================================

            final int quizAttempts =
                _toInt(data["quizAttempts"]);

            // ====================================================
            // CORRECT ANSWERS
            // ====================================================

            final int correctAnswers =
                _toInt(data["correctAnswers"]);

            // ====================================================
            // TOTAL ANSWERS
            // ====================================================

            final int totalAnswers =
                _toInt(data["totalAnswers"]);

            // ====================================================
            // STUDY TIME
            // ====================================================

            final int studyMinutes =
                _toInt(data["studyMinutes"]);

            // ====================================================
            // ACCURACY
            // ====================================================

            final int accuracy =
                totalAnswers > 0
                    ? ((correctAnswers /
                                totalAnswers) *
                            100)
                        .round()
                    : 0;

            // ====================================================
            // DAILY LEARNING GOAL PROGRESS
            // ====================================================

            final double goalProgress =
                dailyGoal > 0
                    ? (dailyCardsStudied / dailyGoal)
                        .clamp(0.0, 1.0)
                    : 0.0;

            final int goalPercentage =
                (goalProgress * 100).round();

            // ====================================================
            // LEARNING LEVEL
            // ====================================================

            String level;
            String levelDescription;

            if (cardsStudied < 25) {
              level = "Beginner";
              levelDescription =
                  "You're just getting started.";
            } else if (cardsStudied < 100) {
              level = "Learner";
              levelDescription =
                  "You're building a strong foundation.";
            } else if (cardsStudied < 250) {
              level = "Intermediate";
              levelDescription =
                  "Your learning habit is growing.";
            } else if (cardsStudied < 500) {
              level = "Advanced";
              levelDescription =
                  "You're becoming a consistent learner.";
            } else {
              level = "Master";
              levelDescription =
                  "Outstanding learning consistency!";
            }

            // ====================================================
            // ACHIEVEMENT
            // ====================================================

            String achievement;
            IconData achievementIcon;

            if (streak >= 30) {
              achievement = "Master Learner";
              achievementIcon =
                  Icons.emoji_events_rounded;
            } else if (streak >= 14) {
              achievement = "Consistency Champion";
              achievementIcon =
                  Icons.workspace_premium_rounded;
            } else if (streak >= 7) {
              achievement = "Rising Scholar";
              achievementIcon =
                  Icons.star_rounded;
            } else if (cardsStudied >= 50) {
              achievement = "Fast Learner";
              achievementIcon =
                  Icons.bolt_rounded;
            } else {
              achievement = "Getting Started";
              achievementIcon =
                  Icons.flag_rounded;
            }

            // ====================================================
            // PERSONALIZED MESSAGE
            // ====================================================

            String learningMessage;

            if (cardsStudied == 0) {
              learningMessage =
                  "Start studying your first flashcard to begin your learning journey.";
            } else if (accuracy >= 90) {
              learningMessage =
                  "Excellent accuracy! You're mastering your flashcards.";
            } else if (accuracy >= 75) {
              learningMessage =
                  "Great work! Keep practicing to push your accuracy even higher.";
            } else if (streak >= 7) {
              learningMessage =
                  "Your consistency is excellent. Keep your streak alive!";
            } else if (dailyCardsStudied >= dailyGoal) {
              learningMessage =
                  "You've completed today's learning goal. Great job!";
            } else {
              learningMessage =
                  "Keep practicing regularly to improve your memory retention.";
            }

            // ====================================================
            // DECK COUNT
            // ====================================================

            return StreamBuilder<int>(
              stream: getDeckCount(),

              builder: (context, deckSnapshot) {
                final int deckCount =
                    deckSnapshot.data ?? 0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    100,
                  ),

                  child: Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(
                        maxWidth: 900,
                      ),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          // ==================================================
                          // HEADER
                          // ==================================================

                          Row(
                            children: [
                              // BACK BUTTON
                              Container(
                                width: 42,
                                height: 42,

                                decoration:
                                    BoxDecoration(
                                  color: colors.primary
                                      .withOpacity(.10),

                                  borderRadius:
                                      BorderRadius.circular(
                                    13,
                                  ),
                                ),

                                child: IconButton(
                                  padding:
                                      EdgeInsets.zero,

                                  onPressed: () {
                                    if (onBackToHome != null) {
                                      onBackToHome!();
                                    } else if (Navigator
                                        .canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },

                                  icon: Icon(
                                    Icons
                                        .arrow_back_rounded,
                                    color:
                                        colors.primary,
                                    size: 22,
                                  ),
                                ),
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              // TITLE + SUBTITLE
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,

                                  children: [
                                    Text(
                                      "Progress",

                                      style:
                                          GoogleFonts.poppins(
                                        color:
                                            colors.onSurface,
                                        fontSize: 26,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 2,
                                    ),

                                    Text(
                                      "See how your learning journey is progressing",

                                      style:
                                          GoogleFonts.poppins(
                                        color: colors
                                            .onSurface
                                            .withOpacity(.55),
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // PROGRESS ICON
                              Container(
                                width: 48,
                                height: 48,

                                decoration:
                                    BoxDecoration(
                                  color: colors.primary
                                      .withOpacity(.10),

                                  borderRadius:
                                      BorderRadius.circular(
                                    14,
                                  ),
                                ),

                                child: Icon(
                                  Icons
                                      .trending_up_rounded,
                                  color:
                                      colors.primary,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // OVERVIEW
                          // ==================================================

                          GridView.count(
                            shrinkWrap: true,

                            physics:
                                const NeverScrollableScrollPhysics(),

                            crossAxisCount: 2,

                            mainAxisSpacing: 12,

                            crossAxisSpacing: 12,

                            childAspectRatio: 1.35,

                            children: [
                              _statCard(
                                context,
                                Icons.library_books_rounded,
                                "$deckCount",
                                "Total Decks",
                              ),

                              _statCard(
                                context,
                                Icons.style_rounded,
                                "$cardsStudied",
                                "Cards Studied",
                              ),

                              _statCard(
                                context,
                                Icons.local_fire_department_rounded,
                                "$streak",
                                "Day Streak",
                              ),

                              _statCard(
                                context,
                                Icons.quiz_rounded,
                                "$quizAttempts",
                                "Quiz Attempts",
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ==================================================
                          // LEARNING GOAL
                          // ==================================================

                          _sectionTitle(
                            context,
                            "Today's Learning Goal",
                          ),

                          const SizedBox(height: 10),

                          Container(
                            width: double.infinity,

                            padding:
                                const EdgeInsets.all(20),

                            decoration: BoxDecoration(
                              color: colors.primary
                                  .withOpacity(.08),

                              borderRadius:
                                  BorderRadius.circular(20),

                              border: Border.all(
                                color: colors.primary
                                    .withOpacity(.10),
                              ),
                            ),

                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,

                                      decoration:
                                          BoxDecoration(
                                        color: colors
                                            .primary
                                            .withOpacity(
                                          .12,
                                        ),

                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          13,
                                        ),
                                      ),

                                      child: Icon(
                                        dailyCardsStudied >=
                                                dailyGoal
                                            ? Icons
                                                .check_rounded
                                            : Icons
                                                .flag_rounded,
                                        color:
                                            colors.primary,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [
                                          Text(
                                            dailyCardsStudied >=
                                                    dailyGoal
                                                ? "Goal Completed 🎉"
                                                : "$dailyGoal Card Daily Goal",

                                            style:
                                                GoogleFonts
                                                    .poppins(
                                              color: colors
                                                  .onSurface,
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),

                                          Text(
                                            "$dailyCardsStudied / $dailyGoal cards studied today",

                                            style:
                                                GoogleFonts
                                                    .poppins(
                                              color: colors
                                                  .onSurface
                                                  .withOpacity(
                                                .50,
                                              ),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    Text(
                                      "$goalPercentage%",

                                      style:
                                          GoogleFonts.poppins(
                                        color:
                                            colors.primary,
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(
                                    20,
                                  ),

                                  child:
                                      LinearProgressIndicator(
                                    value:
                                        goalProgress,

                                    minHeight: 10,

                                    backgroundColor:
                                        colors.onSurface
                                            .withOpacity(
                                      .08,
                                    ),

                                    color:
                                        colors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // PERFORMANCE
                          // ==================================================

                          _sectionTitle(
                            context,
                            "Performance",
                          ),

                          const SizedBox(height: 10),

                          Row(
                            children: [
                              Expanded(
                                child:
                                    _performanceCard(
                                  context,
                                  icon:
                                      Icons.track_changes_rounded,
                                  title:
                                      "Accuracy",
                                  value:
                                      "$accuracy%",
                                  description:
                                      totalAnswers == 0
                                          ? "No quizzes yet"
                                          : "$correctAnswers correct answers",
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child:
                                    _performanceCard(
                                  context,
                                  icon:
                                      Icons.timer_outlined,
                                  title:
                                      "Study Time",
                                  value:
                                      "$studyMinutes",
                                  description:
                                      "minutes",
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // LEARNING PROFILE
                          // ==================================================

                          _sectionTitle(
                            context,
                            "Learning Profile",
                          ),

                          const SizedBox(height: 10),

                          Container(
                            width: double.infinity,

                            padding:
                                const EdgeInsets.all(20),

                            decoration: BoxDecoration(
                              color: colors.onSurface
                                  .withOpacity(.035),

                              borderRadius:
                                  BorderRadius.circular(20),

                              border: Border.all(
                                color: colors.onSurface
                                    .withOpacity(.07),
                              ),
                            ),

                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 55,
                                      height: 55,

                                      decoration:
                                          BoxDecoration(
                                        color: colors.primary
                                            .withOpacity(
                                          .10,
                                        ),

                                        shape:
                                            BoxShape.circle,
                                      ),

                                      child: Icon(
                                        Icons
                                            .rocket_launch_rounded,
                                        color:
                                            colors.primary,
                                        size: 27,
                                      ),
                                    ),

                                    const SizedBox(
                                      width: 14,
                                    ),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,

                                        children: [
                                          Text(
                                            level,
                                            style:
                                                GoogleFonts
                                                    .poppins(
                                              color: colors
                                                  .onSurface,
                                              fontSize: 18,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                            ),
                                          ),

                                          Text(
                                            levelDescription,
                                            style:
                                                GoogleFonts
                                                    .poppins(
                                              color: colors
                                                  .onSurface
                                                  .withOpacity(
                                                .50,
                                              ),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                Divider(
                                  color: colors.onSurface
                                      .withOpacity(.08),
                                ),

                                const SizedBox(height: 10),

                                _profileRow(
                                  context,
                                  "Achievement",
                                  achievement,
                                  achievementIcon,
                                ),

                                _profileRow(
                                  context,
                                  "Quiz Accuracy",
                                  "$accuracy%",
                                  Icons
                                      .track_changes_rounded,
                                ),

                                _profileRow(
                                  context,
                                  "Cards Completed",
                                  "$cardsStudied",
                                  Icons
                                      .check_circle_outline_rounded,
                                ),

                                _profileRow(
                                  context,
                                  "Current Streak",
                                  "$streak days",
                                  Icons
                                      .local_fire_department_outlined,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // ==================================================
                          // LEARNING INSIGHT
                          // ==================================================

                          _sectionTitle(
                            context,
                            "Your Learning Insight",
                          ),

                          const SizedBox(height: 10),

                          Container(
                            width: double.infinity,

                            padding:
                                const EdgeInsets.all(20),

                            decoration: BoxDecoration(
                              color: colors.primary
                                  .withOpacity(.07),

                              borderRadius:
                                  BorderRadius.circular(20),

                              border: Border.all(
                                color: colors.primary
                                    .withOpacity(.10),
                              ),
                            ),

                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [
                                Container(
                                  width: 42,
                                  height: 42,

                                  decoration:
                                      BoxDecoration(
                                    color: colors.primary
                                        .withOpacity(.12),

                                    shape:
                                        BoxShape.circle,
                                  ),

                                  child: Icon(
                                    Icons
                                        .lightbulb_outline_rounded,
                                    color:
                                        colors.primary,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    learningMessage,
                                    style:
                                        GoogleFonts.poppins(
                                      color:
                                          colors.onSurface,
                                      fontSize: 12,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
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
    BuildContext context,
    IconData icon,
    String value,
    String title,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: colors.onSurface
            .withOpacity(.035),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: colors.onSurface
              .withOpacity(.07),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [
          Icon(
            icon,
            color: colors.primary,
            size: 27,
          ),

          const SizedBox(height: 8),

          Text(
            value,

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,
              fontSize: 22,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          Text(
            title,

            style:
                GoogleFonts.poppins(
              color: colors.onSurface
                  .withOpacity(.50),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PERFORMANCE CARD
  // ============================================================

  Widget _performanceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String description,
  }) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: colors.onSurface
            .withOpacity(.035),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color: colors.onSurface
              .withOpacity(.07),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: colors.primary,
            size: 25,
          ),

          const SizedBox(height: 10),

          Text(
            value,

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,
              fontSize: 22,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          Text(
            title,

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            description,

            style:
                GoogleFonts.poppins(
              color: colors.onSurface
                  .withOpacity(.45),
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROFILE ROW
  // ============================================================

  Widget _profileRow(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        children: [
          Icon(
            icon,
            color: colors.primary,
            size: 19,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,

              style:
                  GoogleFonts.poppins(
                color: colors.onSurface
                    .withOpacity(.60),
                fontSize: 11,
              ),
            ),
          ),

          Text(
            value,

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,
              fontSize: 11,
              fontWeight:
                  FontWeight.w600,
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
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Text(
      title,

      style:
          GoogleFonts.poppins(
        color: colors.onSurface,
        fontSize: 18,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(
    BuildContext context,
    String error,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons.error_outline_rounded,
              color: colors.error,
              size: 45,
            ),

            const SizedBox(height: 12),

            Text(
              "Unable to load progress",

              style:
                  GoogleFonts.poppins(
                color:
                    colors.onSurface,
                fontSize: 16,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              error,

              textAlign:
                  TextAlign.center,

              style:
                  GoogleFonts.poppins(
                color: colors.onSurface
                    .withOpacity(.50),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
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

    return int.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }
}
