import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AddFlashcardScreen extends StatefulWidget {
  final String deckId;

  const AddFlashcardScreen({
    super.key,
    required this.deckId,
  });

  @override
  State<AddFlashcardScreen> createState() =>
      _AddFlashcardScreenState();
}

class _AddFlashcardScreenState
    extends State<AddFlashcardScreen> {
  final TextEditingController questionController =
      TextEditingController();

  final TextEditingController answerController =
      TextEditingController();

  bool isLoading = false;

  // ============================================================
  // ADD FLASHCARD
  // ============================================================

  Future<void> addFlashcard() async {
    final question =
        questionController.text.trim();

    final answer =
        answerController.text.trim();

    if (question.isEmpty) {
      _showMessage(
        'Please enter a question.',
      );
      return;
    }

    if (answer.isEmpty) {
      _showMessage(
        'Please enter an answer.',
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final deckReference =
          FirebaseFirestore.instance
              .collection('decks')
              .doc(widget.deckId);

      // ========================================================
      // ADD CARD
      // ========================================================

      await deckReference
          .collection('cards')
          .add({
        'question': question,
        'answer': answer,
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      // ========================================================
      // UPDATE CARD COUNT
      // ========================================================

      await deckReference.update({
        'cardCount':
            FieldValue.increment(1),
      });

      if (!mounted) return;

      _showMessage(
        'Flashcard added successfully.',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to add flashcard: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    questionController.dispose();
    answerController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context);

    final colors =
        theme.colorScheme;

    return Scaffold(
      backgroundColor:
          colors.surface,

      appBar: AppBar(
        backgroundColor:
            colors.surface,

        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: Icon(
            Icons.arrow_back_rounded,
            color:
                colors.onSurface,
          ),
        ),

        title: Text(
          'Add Flashcard',
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(20),

          child: Center(
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 700,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  Text(
                    'Create a Flashcard',
                    style:
                        GoogleFonts.poppins(
                      color:
                          colors.onSurface,
                      fontSize: 27,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    'Add a question and its answer to your deck.',
                    style:
                        GoogleFonts.poppins(
                      color: colors
                          .onSurface
                          .withOpacity(.50),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  // ==================================================
                  // QUESTION
                  // ==================================================

                  _buildLabel(
                    context,
                    'Question',
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                        questionController,

                    maxLines: 5,

                    style:
                        GoogleFonts.poppins(
                      color:
                          colors.onSurface,
                      fontSize: 13,
                    ),

                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter your question...',

                      hintStyle:
                          GoogleFonts.poppins(
                        color: colors
                            .onSurface
                            .withOpacity(.40),
                        fontSize: 13,
                      ),

                      prefixIcon:
                          Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 55,
                        ),
                        child: Icon(
                          Icons
                              .help_outline_rounded,
                          color:
                              colors.primary,
                        ),
                      ),

                      filled: true,

                      fillColor: colors
                          .onSurface
                          .withOpacity(.04),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),

                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                        borderSide:
                            BorderSide(
                          color: colors
                              .onSurface
                              .withOpacity(
                            .08,
                          ),
                        ),
                      ),

                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                        borderSide:
                            BorderSide(
                          color:
                              colors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // ==================================================
                  // ANSWER
                  // ==================================================

                  _buildLabel(
                    context,
                    'Answer',
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  TextField(
                    controller:
                        answerController,

                    maxLines: 7,

                    style:
                        GoogleFonts.poppins(
                      color:
                          colors.onSurface,
                      fontSize: 13,
                    ),

                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter the answer...',

                      hintStyle:
                          GoogleFonts.poppins(
                        color: colors
                            .onSurface
                            .withOpacity(.40),
                        fontSize: 13,
                      ),

                      prefixIcon:
                          Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          bottom: 80,
                        ),
                        child: Icon(
                          Icons
                              .lightbulb_outline_rounded,
                          color:
                              colors.primary,
                        ),
                      ),

                      filled: true,

                      fillColor: colors
                          .onSurface
                          .withOpacity(.04),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),

                      enabledBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                        borderSide:
                            BorderSide(
                          color: colors
                              .onSurface
                              .withOpacity(
                            .08,
                          ),
                        ),
                      ),

                      focusedBorder:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          16,
                        ),
                        borderSide:
                            BorderSide(
                          color:
                              colors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  // ==================================================
                  // BUTTON
                  // ==================================================

                  SizedBox(
                    width:
                        double.infinity,

                    height: 52,

                    child:
                        FilledButton.icon(
                      onPressed:
                          isLoading
                              ? null
                              : addFlashcard,

                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .add_rounded,
                            ),

                      label: Text(
                        isLoading
                            ? 'Adding...'
                            : 'Add Flashcard',
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
        ),
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(
    BuildContext context,
    String text,
  ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Text(
      text,
      style:
          GoogleFonts.poppins(
        color:
            colors.onSurface,
        fontSize: 13,
        fontWeight:
            FontWeight.w700,
      ),
    );
  }
}