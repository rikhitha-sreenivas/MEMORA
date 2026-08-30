import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String deckId;
  final String quizTitle;

  const QuizScreen({
    super.key,
    required this.deckId,
    required this.quizTitle,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> quizQuestions = [];

  int currentIndex = 0;
  int score = 0;

  bool isLoading = true;
  bool answered = false;

  String? selectedOption;
  String? correctAnswer;

  @override
  void initState() {
    super.initState();
    loadQuiz();
  }

  // ============================================================
  // LOAD QUIZ
  // ============================================================

  Future<void> loadQuiz() async {
    try {
      List<Map<String, dynamic>> cards = [];

      final snapshot = await FirebaseFirestore.instance
          .collection("decks")
          .doc(widget.deckId)
          .collection("cards")
          .get();

      for (final card in snapshot.docs) {
        final data = card.data();

        if (data["question"] != null &&
            data["answer"] != null &&
            data["question"].toString().trim().isNotEmpty &&
            data["answer"].toString().trim().isNotEmpty) {
          cards.add({
            "question": data["question"].toString(),
            "answer": data["answer"].toString(),
          });
        }
      }

      if (cards.isEmpty) {
        if (!mounted) return;

        setState(() {
          quizQuestions = [];
          isLoading = false;
        });

        return;
      }

      // Shuffle all cards
      cards.shuffle();

      List<Map<String, dynamic>> generated = [];

      // Maximum 10 questions
      final questionCount = min(10, cards.length);

      for (int i = 0; i < questionCount; i++) {
        final current = cards[i];

        List<String> options = [
          current["answer"].toString(),
        ];

        // Get incorrect answers
        List<Map<String, dynamic>> others = List.from(cards);

        others.removeWhere(
          (item) =>
              item["answer"].toString() ==
              current["answer"].toString(),
        );

        others.shuffle();

        // Add maximum 3 incorrect options
        for (int j = 0; j < min(3, others.length); j++) {
          options.add(
            others[j]["answer"].toString(),
          );
        }

        options.shuffle();

        generated.add({
          "question": current["question"].toString(),
          "answer": current["answer"].toString(),
          "options": options,
        });
      }

      if (!mounted) return;

      setState(() {
        quizQuestions = generated;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        quizQuestions = [];
        isLoading = false;
      });
    }
  }

  // ============================================================
  // CHECK ANSWER
  // ============================================================

  void checkAnswer(String option) {
    if (answered) return;

    final answer =
        quizQuestions[currentIndex]["answer"].toString();

    setState(() {
      answered = true;
      selectedOption = option;
      correctAnswer = answer;

      if (option == answer) {
        score++;
      }
    });
  }

  // ============================================================
  // NEXT QUESTION
  // ============================================================

  Future<void> nextQuestion() async {
    if (currentIndex < quizQuestions.length - 1) {
      setState(() {
        currentIndex++;
        answered = false;
        selectedOption = null;
        correctAnswer = null;
      });
    } else {
      // Save result before leaving
      await saveQuizResult();

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            score: score,
            totalQuestions: quizQuestions.length,
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAVE QUIZ RESULT + UPDATE PROGRESS
  // ============================================================

  Future<void> saveQuizResult() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || quizQuestions.isEmpty) {
      return;
    }

    final firestore =
        FirebaseFirestore.instance;

    final userRef =
        firestore.collection("users").doc(user.uid);

    final quizResultsRef =
        userRef.collection("quizResults");

    final totalQuestions =
        quizQuestions.length;

    final accuracy =
        ((score / totalQuestions) * 100).round();

    try {
      // ----------------------------------------------------------
      // SAVE INDIVIDUAL QUIZ RESULT
      // ----------------------------------------------------------

      await quizResultsRef.add({
        "deckId": widget.deckId,
        "quizTitle": widget.quizTitle,
        "score": score,
        "totalQuestions": totalQuestions,
        "accuracy": accuracy,
        "createdAt": FieldValue.serverTimestamp(),
      });

      // ----------------------------------------------------------
      // UPDATE USER PROGRESS
      // ----------------------------------------------------------

      await userRef.set(
        {
          "quizAttempts":
              FieldValue.increment(1),

          "correctAnswers":
              FieldValue.increment(score),

          "totalAnswers":
              FieldValue.increment(totalQuestions),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint(
        "Error saving quiz result: $e",
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

    if (isLoading) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: Center(
          child: CircularProgressIndicator(
            color: colors.primary,
          ),
        ),
      );
    }

    // ----------------------------------------------------------
    // NO QUESTIONS
    // ----------------------------------------------------------

    if (quizQuestions.isEmpty) {
      return Scaffold(
        backgroundColor: colors.surface,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    color: colors.primary,
                    size: 55,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    "No Questions Available",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colors.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "This deck doesn't contain enough valid flashcards to start a quiz.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: colors.onSurface
                          .withOpacity(.55),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(height: 20),

                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
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
          ),
        ),
      );
    }

    final question =
        quizQuestions[currentIndex];

    return Scaffold(
      backgroundColor: colors.surface,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            14,
            20,
            20,
          ),

          child: Column(
            children: [

              // ==================================================
              // HEADER
              // ==================================================

              Row(
                children: [

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
                        Navigator.pop(context);
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

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      widget.quizTitle,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      textAlign:
                          TextAlign.center,

                      style:
                          GoogleFonts.poppins(
                        color:
                            colors.onSurface,

                        fontSize: 20,

                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 54),
                ],
              ),

              const SizedBox(height: 14),

              // ==================================================
              // QUESTION PROGRESS
              // ==================================================

              Row(
                children: [

                  Text(
                    "Question ${currentIndex + 1}",
                    style:
                        GoogleFonts.poppins(
                      color: colors
                          .onSurface
                          .withOpacity(.55),
                      fontSize: 11,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "${currentIndex + 1}/${quizQuestions.length}",
                    style:
                        GoogleFonts.poppins(
                      color:
                          colors.primary,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(10),

                child:
                    LinearProgressIndicator(
                  value:
                      (currentIndex + 1) /
                          quizQuestions.length,

                  minHeight: 7,

                  backgroundColor:
                      colors.onSurface
                          .withOpacity(.08),

                  color:
                      colors.primary,
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // QUESTION CARD
              // ==================================================

              Container(
                width: double.infinity,

                padding:
                    const EdgeInsets.all(24),

                decoration:
                    BoxDecoration(
                  color: colors.primary
                      .withOpacity(.07),

                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),

                  border: Border.all(
                    color: colors.primary
                        .withOpacity(.10),
                  ),
                ),

                child: Column(
                  children: [

                    Container(
                      width: 44,
                      height: 44,

                      decoration:
                          BoxDecoration(
                        color: colors.primary
                            .withOpacity(.12),

                        borderRadius:
                            BorderRadius.circular(
                          13,
                        ),
                      ),

                      child: Icon(
                        Icons.help_outline_rounded,
                        color:
                            colors.primary,
                        size: 25,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      question["question"]
                          .toString(),

                      textAlign:
                          TextAlign.center,

                      style:
                          GoogleFonts.poppins(
                        color:
                            colors.onSurface,

                        fontSize: 18,

                        fontWeight:
                            FontWeight.w600,

                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // OPTIONS
              // ==================================================

              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.only(
                    bottom: 10,
                  ),

                  itemCount:
                      question["options"]
                          .length,

                  itemBuilder:
                      (context, index) {

                    final option =
                        question["options"]
                            [index]
                            .toString();

                    final isCorrect =
                        answered &&
                            option ==
                                correctAnswer;

                    final isSelected =
                        answered &&
                            option ==
                                selectedOption;

                    return GestureDetector(
                      onTap: () {
                        checkAnswer(option);
                      },

                      child: AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 200,
                        ),

                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 17,
                          vertical: 17,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              getOptionColor(
                            option,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),

                          border: Border.all(
                            color:
                                getOptionBorderColor(
                              option,
                            ),
                            width:
                                isCorrect ||
                                        isSelected
                                    ? 1.3
                                    : 1,
                          ),
                        ),

                        child: Row(
                          children: [

                            Container(
                              width: 32,
                              height: 32,

                              alignment:
                                  Alignment.center,

                              decoration:
                                  BoxDecoration(
                                color: colors
                                    .onSurface
                                    .withOpacity(
                                  .06,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),

                              child: Text(
                                String.fromCharCode(
                                  65 + index,
                                ),

                                style:
                                    GoogleFonts
                                        .poppins(
                                  color: colors
                                      .onSurface
                                      .withOpacity(
                                    .65,
                                  ),
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 12,
                            ),

                            Expanded(
                              child: Text(
                                option,

                                style:
                                    GoogleFonts
                                        .poppins(
                                  color: colors
                                      .onSurface,
                                  fontSize: 13,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ),

                            if (isCorrect)
                              Icon(
                                Icons
                                    .check_circle_rounded,
                                color:
                                    Colors.green,
                                size: 22,
                              )
                            else if (isSelected)
                              Icon(
                                Icons
                                    .cancel_rounded,
                                color:
                                    colors.error,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ==================================================
              // NEXT / FINISH
              // ==================================================

              SizedBox(
                width: double.infinity,

                child: FilledButton(
                  onPressed:
                      answered
                          ? nextQuestion
                          : null,

                  style:
                      FilledButton.styleFrom(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),

                  child: Text(
                    currentIndex ==
                            quizQuestions
                                    .length -
                                1
                        ? "Finish Quiz"
                        : "Next Question",

                    style:
                        GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // OPTION COLOR
  // ============================================================

  Color getOptionColor(String option) {
    final colors =
        Theme.of(context).colorScheme;

    if (!answered) {
      return colors.onSurface
          .withOpacity(.035);
    }

    if (option == correctAnswer) {
      return Colors.green.withOpacity(.12);
    }

    if (option == selectedOption) {
      return colors.error.withOpacity(.12);
    }

    return colors.onSurface
        .withOpacity(.035);
  }

  // ============================================================
  // OPTION BORDER COLOR
  // ============================================================

  Color getOptionBorderColor(
    String option,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    if (!answered) {
      return colors.onSurface
          .withOpacity(.08);
    }

    if (option == correctAnswer) {
      return Colors.green
          .withOpacity(.45);
    }

    if (option == selectedOption) {
      return colors.error
          .withOpacity(.45);
    }

    return colors.onSurface
        .withOpacity(.08);
  }
}