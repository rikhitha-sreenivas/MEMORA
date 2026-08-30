import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class EditFlashcardScreen extends StatefulWidget {
  final String deckId;
  final String cardId;

  const EditFlashcardScreen({
    super.key,
    required this.deckId,
    required this.cardId,
  });

  @override
  State<EditFlashcardScreen> createState() =>
      _EditFlashcardScreenState();
}

class _EditFlashcardScreenState
    extends State<EditFlashcardScreen> {
  final TextEditingController questionController =
      TextEditingController();

  final TextEditingController answerController =
      TextEditingController();

  bool isLoading = true;
  bool isSaving = false;

  // ============================================================
  // LOAD CARD
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadCard();
  }

  Future<void> loadCard() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('decks')
          .doc(widget.deckId)
          .collection('cards')
          .doc(widget.cardId)
          .get();

      if (!doc.exists) {
        if (!mounted) return;

        _showMessage(
          'Flashcard not found.',
        );

        Navigator.pop(context);
        return;
      }

      final data = doc.data()!;

      questionController.text =
          (data['question'] ?? '').toString();

      answerController.text =
          (data['answer'] ?? '').toString();

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Unable to load flashcard: $e',
      );
    }
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<void> updateCard() async {
    final question =
        questionController.text.trim();

    final answer =
        answerController.text.trim();

    if (question.isEmpty ||
        answer.isEmpty) {
      _showMessage(
        'Question and answer cannot be empty.',
      );
      return;
    }

    try {
      setState(() {
        isSaving = true;
      });

      await FirebaseFirestore.instance
          .collection('decks')
          .doc(widget.deckId)
          .collection('cards')
          .doc(widget.cardId)
          .update({
        'question': question,
        'answer': answer,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _showMessage(
        'Flashcard updated successfully.',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to update flashcard: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> deleteCard() async {
    final colors =
        Theme.of(context).colorScheme;

    final confirm =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              colors.surface,

          title: Text(
            'Delete Flashcard?',
            style:
                GoogleFonts.poppins(
              fontWeight:
                  FontWeight.w700,
              color:
                  colors.onSurface,
            ),
          ),

          content: Text(
            'This flashcard will be permanently deleted.',
            style:
                GoogleFonts.poppins(
              color: colors.onSurface
                  .withOpacity(.60),
              fontSize: 13,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),

            FilledButton(
              style:
                  FilledButton.styleFrom(
                backgroundColor:
                    colors.error,
              ),

              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('decks')
          .doc(widget.deckId)
          .collection('cards')
          .doc(widget.cardId)
          .delete();

      await FirebaseFirestore.instance
          .collection('decks')
          .doc(widget.deckId)
          .update({
        'cardCount':
            FieldValue.increment(-1),
      });

      if (!mounted) return;

      _showMessage(
        'Flashcard deleted.',
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to delete flashcard: $e',
      );
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
    final colors =
        Theme.of(context).colorScheme;

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
          'Edit Flashcard',
          style:
              GoogleFonts.poppins(
            color:
                colors.onSurface,
            fontWeight:
                FontWeight.w700,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Delete',
            onPressed:
                isLoading
                    ? null
                    : deleteCard,
            icon: Icon(
              Icons
                  .delete_outline_rounded,
              color:
                  colors.error,
            ),
          ),
        ],
      ),

      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator(
                color:
                    colors.primary,
              ),
            )
          : SafeArea(
              child:
                  SingleChildScrollView(
                padding:
                    const EdgeInsets.all(
                  20,
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(
                      maxWidth: 700,
                    ),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          'Edit your Flashcard',
                          style:
                              GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight:
                                FontWeight.w700,
                            color:
                                colors.onSurface,
                          ),
                        ),

                        const SizedBox(
                          height: 25,
                        ),

                        Text(
                          'Question',
                          style:
                              GoogleFonts.poppins(
                            fontWeight:
                                FontWeight.w700,
                            color:
                                colors.onSurface,
                          ),
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
                              _inputDecoration(
                            context,
                            'Enter question...',
                            Icons
                                .help_outline_rounded,
                          ),
                        ),

                        const SizedBox(
                          height: 22,
                        ),

                        Text(
                          'Answer',
                          style:
                              GoogleFonts.poppins(
                            fontWeight:
                                FontWeight.w700,
                            color:
                                colors.onSurface,
                          ),
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
                              _inputDecoration(
                            context,
                            'Enter answer...',
                            Icons
                                .lightbulb_outline_rounded,
                          ),
                        ),

                        const SizedBox(
                          height: 30,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          height: 52,
                          child:
                              FilledButton.icon(
                            onPressed:
                                isSaving
                                    ? null
                                    : updateCard,

                            icon: isSaving
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
                                        .save_rounded,
                                  ),

                            label: Text(
                              isSaving
                                  ? 'Saving...'
                                  : 'Save Changes',
                              style:
                                  GoogleFonts.poppins(
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
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
    BuildContext context,
    String hint,
    IconData icon,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,

      hintStyle:
          GoogleFonts.poppins(
        color: colors.onSurface
            .withOpacity(.40),
        fontSize: 13,
      ),

      prefixIcon: Icon(
        icon,
        color: colors.primary,
      ),

      filled: true,

      fillColor: colors.onSurface
          .withOpacity(.04),

      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            BorderSide(
          color: colors.onSurface
              .withOpacity(.08),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(16),
        borderSide:
            BorderSide(
          color:
              colors.primary,
          width: 1.2,
        ),
      ),
    );
  }
}