import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:google_fonts/google_fonts.dart';

import '../flashcards/add_flashcard_screen.dart';
import '../flashcards/edit_flashcard_screen.dart';

class MyDeckScreen extends StatefulWidget {
  final String deckId;
  final String deckTitle;
  final bool isAdmin;

  const MyDeckScreen({
    super.key,
    required this.deckId,
    required this.deckTitle,
    required this.isAdmin,
  });

  @override
  State<MyDeckScreen> createState() => _MyDeckScreenState();
}

class _MyDeckScreenState extends State<MyDeckScreen> {
  late PageController controller;

  int currentIndex = 0;

  // ============================================================
  // STUDIED CARDS
  // ============================================================

  // Local cache.
  // Permanent record is also stored in Firestore.
  final Set<String> studiedCards = {};

  // ============================================================
  // STUDY TIME
  // ============================================================

  DateTime? _studyStartTime;

  bool _isSavingStudyTime = false;

  bool _studyTimeSaved = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    controller = PageController(
      viewportFraction: 0.82,
    );

    // Only normal users should accumulate study time.
    if (!widget.isAdmin) {
      _studyStartTime = DateTime.now();
    }

    _loadStudiedCards();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    controller.dispose();

    // Save study time when the screen is destroyed.
    //
    // This is intentionally not awaited because dispose()
    // cannot be async.
    if (!widget.isAdmin && !_studyTimeSaved) {
      _saveStudyTime();
    }

    super.dispose();
  }

  // ============================================================
  // LOAD ALREADY STUDIED CARDS
  // ============================================================

  Future<void> _loadStudiedCards() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        return;
      }

      final data = userDoc.data();

      if (data == null) {
        return;
      }

      final storedCards = data["studiedCards"];

      if (storedCards is List) {
        if (!mounted) {
          return;
        }

        setState(() {
          studiedCards.addAll(
            storedCards.map(
              (card) => card.toString(),
            ),
          );
        });
      }
    } catch (e) {
      debugPrint(
        "Error loading studied cards: $e",
      );
    }
  }

  // ============================================================
  // UPDATE STUDY PROGRESS
  // ============================================================

  Future<void> updateCardsStudied(
    String cardId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    // ----------------------------------------------------------
    // FIRST CHECK LOCAL CACHE
    // ----------------------------------------------------------

    if (studiedCards.contains(cardId)) {
      return;
    }

    final uid = user.uid;

    final userRef = FirebaseFirestore.instance
        .collection("users")
        .doc(uid);

    try {
      // --------------------------------------------------------
      // GET LATEST USER DATA
      // --------------------------------------------------------

      final userSnapshot = await userRef.get();

      final userData =
          userSnapshot.data() ?? {};

      // --------------------------------------------------------
      // GET PERMANENTLY STUDIED CARDS
      // --------------------------------------------------------

      final List<String> firebaseStudiedCards = [];

      final storedCards =
          userData["studiedCards"];

      if (storedCards is List) {
        firebaseStudiedCards.addAll(
          storedCards.map(
            (card) => card.toString(),
          ),
        );
      }

      // --------------------------------------------------------
      // CHECK AGAINST FIRESTORE
      //
      // Prevents duplicate counting when:
      // - card is flipped again
      // - screen is reopened
      // - app is restarted
      // - local Set is cleared
      // --------------------------------------------------------

      if (firebaseStudiedCards.contains(cardId)) {
        studiedCards.add(cardId);
        return;
      }

      // --------------------------------------------------------
      // ADD CARD TO PERMANENT STUDIED LIST
      // --------------------------------------------------------

      firebaseStudiedCards.add(cardId);

      // --------------------------------------------------------
      // CURRENT VALUES
      // --------------------------------------------------------

      int cardsStudied =
          _toInt(userData["cardsStudied"]);

      int dailyCardsStudied =
          _toInt(userData["dailyCardsStudied"]);

      int streak =
          _toInt(userData["streak"]);

      // --------------------------------------------------------
      // DAILY GOAL
      // --------------------------------------------------------

      int dailyGoal =
          _toInt(userData["dailyGoal"]);

      if (dailyGoal <= 0) {
        dailyGoal = 10;
      }

      // --------------------------------------------------------
      // DATE HANDLING
      // --------------------------------------------------------

      final now = DateTime.now();

      final today =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final lastStudyDate =
          userData["lastStudyDate"]?.toString();

      // --------------------------------------------------------
      // RESET DAILY COUNT IF NEW DAY
      // --------------------------------------------------------

      if (lastStudyDate != today) {
        dailyCardsStudied = 0;
      }

      // --------------------------------------------------------
      // UPDATE DAILY STUDY COUNT
      // --------------------------------------------------------

      dailyCardsStudied++;

      // --------------------------------------------------------
      // UPDATE STREAK
      // --------------------------------------------------------

      if (lastStudyDate == null ||
          lastStudyDate.isEmpty) {
        // First ever study.
        streak = 1;
      } else if (lastStudyDate == today) {
        // Already studied today.
        // Keep existing streak.
        streak = streak > 0 ? streak : 1;
      } else {
        final previousDate =
            DateTime.tryParse(lastStudyDate);

        if (previousDate != null) {
          final previousDay = DateTime(
            previousDate.year,
            previousDate.month,
            previousDate.day,
          );

          final currentDay = DateTime(
            now.year,
            now.month,
            now.day,
          );

          final difference =
              currentDay.difference(previousDay).inDays;

          if (difference == 1) {
            // Studied yesterday.
            // Continue streak.
            streak++;
          } else {
            // Missed one or more days.
            // Restart streak.
            streak = 1;
          }
        } else {
          streak = 1;
        }
      }

      // --------------------------------------------------------
      // UPDATE FIRESTORE
      // --------------------------------------------------------

      await userRef.set(
        {
          "cardsStudied":
              cardsStudied + 1,

          "dailyCardsStudied":
              dailyCardsStudied,

          "dailyGoal":
              dailyGoal,

          "streak":
              streak,

          "lastStudyDate":
              today,

          "studiedCards":
              firebaseStudiedCards,
        },
        SetOptions(
          merge: true,
        ),
      );

      // --------------------------------------------------------
      // UPDATE LOCAL CACHE
      // --------------------------------------------------------

      studiedCards.add(cardId);

      debugPrint(
        "Card studied successfully: $cardId",
      );

      debugPrint(
        "Total cards studied: ${cardsStudied + 1}",
      );

      debugPrint(
        "Today's cards studied: $dailyCardsStudied",
      );

      debugPrint(
        "Current streak: $streak",
      );
    } catch (e) {
      debugPrint(
        "Error updating study progress: $e",
      );
    }
  }

  // ============================================================
  // SAVE STUDY TIME
  // ============================================================

  Future<void> _saveStudyTime() async {
    // ----------------------------------------------------------
    // Do not record study time for admins.
    // ----------------------------------------------------------

    if (widget.isAdmin) {
      return;
    }

    // ----------------------------------------------------------
    // Prevent duplicate saving.
    // ----------------------------------------------------------

    if (_studyTimeSaved ||
        _isSavingStudyTime) {
      return;
    }

    final user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    if (_studyStartTime == null) {
      return;
    }

    _isSavingStudyTime = true;

    try {
      // --------------------------------------------------------
      // CALCULATE SESSION DURATION
      // --------------------------------------------------------

      final now = DateTime.now();

      final duration =
          now.difference(_studyStartTime!);

      final seconds =
          duration.inSeconds;

      // --------------------------------------------------------
      // Ignore extremely short sessions.
      //
      // This prevents accidental navigation from adding time.
      // --------------------------------------------------------

      if (seconds <= 0) {
        _studyTimeSaved = true;
        return;
      }

      // --------------------------------------------------------
      // CONVERT TO MINUTES
      //
      // We round up so that:
      //
      // 30 seconds -> 1 minute
      // 1 minute 20 seconds -> 1 minute
      // 2 minutes 40 seconds -> 3 minutes
      //
      // This makes short study sessions visible in Progress.
      // --------------------------------------------------------

      final studyMinutes =
          (seconds / 60).round();

      if (studyMinutes <= 0) {
        _studyTimeSaved = true;
        return;
      }

      // --------------------------------------------------------
      // ADD TIME TO EXISTING FIRESTORE VALUE
      // --------------------------------------------------------

      final userRef = FirebaseFirestore
          .instance
          .collection("users")
          .doc(user.uid);

      await userRef.set(
        {
          "studyMinutes":
              FieldValue.increment(
            studyMinutes,
          ),
        },
        SetOptions(
          merge: true,
        ),
      );

      _studyTimeSaved = true;

      debugPrint(
        "Study session saved: $studyMinutes minute(s)",
      );
    } catch (e) {
      debugPrint(
        "Error saving study time: $e",
      );
    } finally {
      _isSavingStudyTime = false;
    }
  }

  // ============================================================
  // EXIT DECK
  // ============================================================

  Future<void> _exitDeck() async {
    if (_isSavingStudyTime) {
      return;
    }

    if (!widget.isAdmin) {
      await _saveStudyTime();
    }

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  // ============================================================
  // NEXT CARD
  // ============================================================

  void nextCard(int length) {
    if (currentIndex < length - 1) {
      controller.animateToPage(
        currentIndex + 1,
        duration:
            const Duration(
          milliseconds: 300,
        ),
        curve:
            Curves.easeInOut,
      );
    }
  }

  // ============================================================
  // PREVIOUS CARD
  // ============================================================

  void previousCard() {
    if (currentIndex > 0) {
      controller.animateToPage(
        currentIndex - 1,
        duration:
            const Duration(
          milliseconds: 300,
        ),
        curve:
            Curves.easeInOut,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // --------------------------------------------------------
      // Prevent the route from immediately closing.
      //
      // This gives us a chance to save study time first.
      // --------------------------------------------------------

      canPop: false,

      onPopInvokedWithResult:
          (didPop, result) async {
        if (didPop) {
          return;
        }

        await _exitDeck();
      },

      child: Scaffold(
        floatingActionButton:
            widget.isAdmin
                ? FloatingActionButton(
                    backgroundColor:
                        Colors.cyanAccent,
                    foregroundColor:
                        Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddFlashcardScreen(
                            deckId:
                                widget.deckId,
                          ),
                        ),
                      );
                    },
                    child:
                        const Icon(
                      Icons.add,
                    ),
                  )
                : null,

        body: Container(
          width: double.infinity,
          height: double.infinity,

          decoration:
              const BoxDecoration(
            gradient:
                LinearGradient(
              colors: [
                Color(0xFF070B34),
                Color(0xFF111B5A),
                Color(0xFF070B34),
              ],
            ),
          ),

          child: SafeArea(
            child:
                StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore
                  .instance
                  .collection("decks")
                  .doc(widget.deckId)
                  .collection("cards")
                  .snapshots(),

              builder:
                  (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final cards =
                    snapshot.data!.docs;

                if (cards.isEmpty) {
                  return Center(
                    child: Text(
                      "No Flashcards Yet",
                      style:
                          GoogleFonts.poppins(
                        color:
                            Colors.white,
                      ),
                    ),
                  );
                }

                return Column(
                  children: [

                    // ==================================================
                    // HEADER
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.all(
                        15,
                      ),

                      child: Row(
                        children: [

                          IconButton(
                            onPressed:
                                _exitDeck,

                            icon:
                                const Icon(
                              Icons
                                  .arrow_back_ios,
                              color:
                                  Colors.white,
                            ),
                          ),

                          Expanded(
                            child:
                                Text(
                              widget.deckTitle,
                              textAlign:
                                  TextAlign
                                      .center,

                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    Colors
                                        .white,
                                fontSize:
                                    24,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 45,
                          ),
                        ],
                      ),
                    ),

                    Text(
                      "Swipe or use buttons",

                      style:
                          GoogleFonts.poppins(
                        color:
                            Colors.white70,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // ==================================================
                    // FLASHCARDS
                    // ==================================================

                    Expanded(
                      child:
                          PageView.builder(
                        controller:
                            controller,

                        itemCount:
                            cards.length,

                        physics:
                            const BouncingScrollPhysics(),

                        onPageChanged:
                            (value) {
                          setState(() {
                            currentIndex =
                                value;
                          });
                        },

                        itemBuilder:
                            (context, index) {
                          final card =
                              cards[index]
                                      .data()
                                  as Map<
                                      String,
                                      dynamic>;

                          return AnimatedContainer(
                            duration:
                                const Duration(
                              milliseconds:
                                  300,
                            ),

                            margin:
                                EdgeInsets
                                    .symmetric(
                              horizontal:
                                  10,

                              vertical:
                                  currentIndex ==
                                          index
                                      ? 10
                                      : 35,
                            ),

                            child:
                                Stack(
                              children: [

                                Center(
                                  child:
                                      FlipCard(
                                    direction:
                                        FlipDirection
                                            .HORIZONTAL,

                                    onFlip:
                                        () {
                                      // ------------------------------------------------
                                      // IMPORTANT
                                      //
                                      // Only normal users are counted.
                                      //
                                      // updateCardsStudied()
                                      // checks both the local cache
                                      // AND Firestore before counting.
                                      // ------------------------------------------------

                                      if (!widget
                                          .isAdmin) {
                                        updateCardsStudied(
                                          cards[index]
                                              .id,
                                        );
                                      }
                                    },

                                    front:
                                        buildCard(
                                      Icons
                                          .help_outline,
                                      Colors
                                          .cyanAccent,
                                      card[
                                              "question"] ??
                                          "",
                                      "Tap to Flip",
                                    ),

                                    back:
                                        buildCard(
                                      Icons
                                          .lightbulb_outline,
                                      Colors
                                          .greenAccent,
                                      card[
                                              "answer"] ??
                                          "",
                                      "Answer",
                                    ),
                                  ),
                                ),

                                // ==================================================
                                // ADMIN EDIT BUTTON
                                // ==================================================

                                if (widget
                                    .isAdmin)
                                  Positioned(
                                    top: 10,
                                    right: 10,

                                    child:
                                        IconButton(
                                      onPressed:
                                          () {
                                        Navigator
                                            .push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) =>
                                                    EditFlashcardScreen(
                                              deckId:
                                                  widget.deckId,
                                              cardId:
                                                  cards[index].id,
                                            ),
                                          ),
                                        );
                                      },

                                      icon:
                                          const Icon(
                                        Icons
                                            .edit,
                                        color:
                                            Colors
                                                .cyanAccent,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // ==================================================
                    // NAVIGATION BUTTONS
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [

                        ElevatedButton(
                          onPressed:
                              currentIndex ==
                                      0
                                  ? null
                                  : previousCard,

                          child:
                              const Text(
                            "Previous",
                          ),
                        ),

                        const SizedBox(
                          width: 20,
                        ),

                        ElevatedButton(
                          onPressed:
                              currentIndex ==
                                      cards.length -
                                          1
                                  ? null
                                  : () =>
                                      nextCard(
                                        cards.length,
                                      ),

                          child:
                              const Text(
                            "Next",
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    // ==================================================
                    // CARD NUMBER
                    // ==================================================

                    Text(
                      "${currentIndex + 1}/${cards.length}",

                      style:
                          GoogleFonts.poppins(
                        color:
                            Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FLASHCARD UI
  // ============================================================

  Widget buildCard(
    IconData icon,
    Color color,
    String text,
    String bottom,
  ) {
    return Container(
      width: 350,
      height: 400,

      padding:
          const EdgeInsets.all(25),

      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(.1),

        borderRadius:
            BorderRadius.circular(30),

        border: Border.all(
          color: Colors.white24,
        ),
      ),

      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Icon(
            icon,
            size: 45,
            color: color,
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
            text,

            textAlign:
                TextAlign.center,

            style:
                GoogleFonts.poppins(
              color:
                  Colors.white,
              fontSize: 20,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          Text(
            bottom,

            style:
                GoogleFonts.poppins(
              color:
                  Colors.white70,
            ),
          ),
        ],
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