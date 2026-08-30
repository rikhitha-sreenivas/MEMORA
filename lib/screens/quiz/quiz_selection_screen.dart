import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'quiz_screen.dart';

class QuizSelectionScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;

  const QuizSelectionScreen({
    super.key,
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection("decks")
              .snapshots(),

          builder: (context, snapshot) {
            // ============================================================
            // LOADING
            // ============================================================

            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: colors.primary,
                ),
              );
            }

            // ============================================================
            // ERROR
            // ============================================================

            if (snapshot.hasError) {
              return _buildErrorState(
                context,
                snapshot.error.toString(),
              );
            }

            final decks = snapshot.data?.docs ?? [];

            // ============================================================
            // CONTENT
            // ============================================================

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                14,
                20,
                100,
              ),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
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

                            decoration: BoxDecoration(
                              color: colors.primary
                                  .withOpacity(.10),

                              borderRadius:
                                  BorderRadius.circular(
                                13,
                              ),
                            ),

                            child: IconButton(
                              padding: EdgeInsets.zero,

                              onPressed: () {
                                if (onBackToHome != null) {
                                  onBackToHome!();
                                }
                              },

                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: colors.primary,
                                size: 22,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  "Choose Quiz",

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
                                  "Select a deck and test your knowledge",

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

                          // QUIZ ICON
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
                              Icons.quiz_rounded,
                              color:
                                  colors.primary,
                              size: 25,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ==================================================
                      // INFO CARD
                      // ==================================================

                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(
                          18,
                        ),

                        decoration:
                            BoxDecoration(
                          color: colors.primary
                              .withOpacity(.07),

                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),

                          border: Border.all(
                            color: colors.primary
                                .withOpacity(.10),
                          ),
                        ),

                        child: Row(
                          children: [

                            Container(
                              width: 42,
                              height: 42,

                              decoration:
                                  BoxDecoration(
                                color: colors.primary
                                    .withOpacity(.12),

                                borderRadius:
                                    BorderRadius.circular(
                                  12,
                                ),
                              ),

                              child: Icon(
                                Icons
                                    .lightbulb_outline_rounded,
                                color:
                                    colors.primary,
                                size: 22,
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child: Text(
                                "Choose a deck to begin a quiz. Each quiz can contain up to 10 questions.",

                                style:
                                    GoogleFonts.poppins(
                                  color: colors
                                      .onSurface
                                      .withOpacity(.65),

                                  fontSize: 11.5,

                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // ==================================================
                      // SECTION HEADER
                      // ==================================================

                      Row(
                        children: [

                          Text(
                            "Available Quizzes",

                            style:
                                GoogleFonts.poppins(
                              color:
                                  colors.onSurface,

                              fontSize: 18,

                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "${decks.length}",

                            style:
                                GoogleFonts.poppins(
                              color: colors
                                  .onSurface
                                  .withOpacity(.45),

                              fontSize: 12,

                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // ==================================================
                      // EMPTY STATE
                      // ==================================================

                      if (decks.isEmpty)
                        _buildEmptyState(
                          context,
                        )
                      else

                        // ==================================================
                        // QUIZ LIST
                        // ==================================================

                        ListView.separated(
                          shrinkWrap: true,

                          physics:
                              const NeverScrollableScrollPhysics(),

                          itemCount:
                              decks.length,

                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                            height: 12,
                          ),

                          itemBuilder:
                              (context, index) {

                            final deck =
                                decks[index].data();

                            final title =
                                (deck["title"] ??
                                        "Untitled Quiz")
                                    .toString();

                            final description =
                                (deck["description"] ??
                                        "")
                                    .toString();

                            final cardCount =
                                _toInt(
                              deck["cardCount"],
                            );

                            return _buildQuizCard(
                              context,

                              deckId:
                                  decks[index].id,

                              title:
                                  title,

                              description:
                                  description,

                              cardCount:
                                  cardCount,
                            );
                          },
                        ),
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
  // QUIZ CARD
  // ============================================================

  Widget _buildQuizCard(
    BuildContext context, {
    required String deckId,
    required String title,
    required String description,
    required int cardCount,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,

      borderRadius:
          BorderRadius.circular(20),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(20),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizScreen(
                deckId: deckId,
                quizTitle: title,
              ),
            ),
          );
        },

        child: Container(
          padding:
              const EdgeInsets.all(17),

          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(20),

            border: Border.all(
              color: colors.onSurface
                  .withOpacity(.08),
            ),

            boxShadow:
                theme.brightness ==
                        Brightness.light
                    ? [
                        BoxShadow(
                          color: Colors.black
                              .withOpacity(.025),

                          blurRadius: 12,

                          offset:
                              const Offset(
                            0,
                            5,
                          ),
                        ),
                      ]
                    : null,
          ),

          child: Row(
            children: [

              // ==================================================
              // QUIZ ICON
              // ==================================================

              Container(
                width: 52,
                height: 52,

                decoration:
                    BoxDecoration(
                  color: colors.primary
                      .withOpacity(.10),

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: Icon(
                  Icons.quiz_rounded,

                  color:
                      colors.primary,

                  size: 26,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              // ==================================================
              // CONTENT
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          GoogleFonts.poppins(
                        color:
                            colors.onSurface,

                        fontSize: 15,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(
                      description.trim().isEmpty
                          ? "$cardCount cards available"
                          : description,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          GoogleFonts.poppins(
                        color: colors
                            .onSurface
                            .withOpacity(.50),

                        fontSize: 10.5,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      children: [

                        Icon(
                          Icons.style_outlined,

                          size: 14,

                          color:
                              colors.primary,
                        ),

                        const SizedBox(
                          width: 4,
                        ),

                        Text(
                          "$cardCount Cards",

                          style:
                              GoogleFonts.poppins(
                            color: colors
                                .onSurface
                                .withOpacity(.55),

                            fontSize: 10.5,

                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              // ==================================================
              // ARROW
              // ==================================================

              Container(
                width: 38,
                height: 38,

                decoration:
                    BoxDecoration(
                  color:
                      colors.primary,

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Icon(
                  Icons
                      .arrow_forward_rounded,

                  color:
                      colors.onPrimary,

                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,

      margin:
          const EdgeInsets.only(
        top: 8,
      ),

      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 25,
      ),

      decoration:
          BoxDecoration(
        color: colors.onSurface
            .withOpacity(.035),

        borderRadius:
            BorderRadius.circular(
          20,
        ),

        border: Border.all(
          color: colors.onSurface
              .withOpacity(.07),
        ),
      ),

      child: Column(
        children: [

          Container(
            width: 65,
            height: 65,

            decoration:
                BoxDecoration(
              color: colors.primary
                  .withOpacity(.10),

              shape: BoxShape.circle,
            ),

            child: Icon(
              Icons.quiz_outlined,

              color:
                  colors.primary,

              size: 30,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Text(
            "No Quizzes Available",

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,

              fontSize: 17,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            "Create a deck with flashcards to start taking quizzes.",

            textAlign:
                TextAlign.center,

            style:
                GoogleFonts.poppins(
              color: colors
                  .onSurface
                  .withOpacity(.50),

              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
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

              color:
                  colors.error,

              size: 45,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              "Unable to load quizzes",

              style:
                  GoogleFonts.poppins(
                color:
                    colors.onSurface,

                fontSize: 16,

                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              error,

              textAlign:
                  TextAlign.center,

              style:
                  GoogleFonts.poppins(
                color: colors
                    .onSurface
                    .withOpacity(.50),

                fontSize: 11,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            FilledButton.icon(
              onPressed: () {
                if (onBackToHome != null) {
                  onBackToHome!();
                }
              },

              icon: const Icon(
                Icons.arrow_back_rounded,
              ),

              label: const Text(
                "Go Back",
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

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
          value?.toString() ?? "",
        ) ??
        0;
  }
}