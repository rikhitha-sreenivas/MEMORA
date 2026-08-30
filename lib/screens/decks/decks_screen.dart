import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'create_deck_screen.dart';
import 'my_deck_screen.dart';

class DecksScreen extends StatefulWidget {
  final bool isAdmin;

  // Callback provided by MainScreen.
  final VoidCallback? onBackToHome;

  const DecksScreen({
    super.key,
    required this.isAdmin,
    this.onBackToHome,
  });

  @override
  State<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends State<DecksScreen> {
  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController searchController =
      TextEditingController();

  final FocusNode searchFocusNode = FocusNode();

  String searchQuery = '';

  // ============================================================
  // FIRESTORE STREAM
  //
  // IMPORTANT:
  // The stream is created ONLY ONCE.
  //
  // Previously, snapshots() was being called every time build()
  // ran. Since search calls setState(), this could recreate the
  // stream and cause the TextField to lose focus.
  // ============================================================

  late final Stream<QuerySnapshot<Map<String, dynamic>>>
      decksStream;

  // ============================================================
  // FIRESTORE COLLECTION
  // ============================================================

  CollectionReference<Map<String, dynamic>> get decksCollection =>
      FirebaseFirestore.instance.collection('decks');

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Create the Firestore stream only once.
    decksStream = decksCollection.snapshots();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();

    super.dispose();
  }

  // ============================================================
  // GO TO HOME
  // ============================================================

  void _goToHome() {
    if (widget.onBackToHome != null) {
      widget.onBackToHome!();
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
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

      // ==========================================================
      // ADMIN ADD DECK BUTTON
      // ==========================================================

      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _createDeck,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: Text(
                'Add Deck',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          // IMPORTANT:
          // Use the stored stream instead of calling snapshots()
          // again during every rebuild.
          stream: decksStream,

          builder: (context, snapshot) {
            // ====================================================
            // LOADING
            // ====================================================

            if (snapshot.connectionState ==
                    ConnectionState.waiting &&
                !snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  color: colors.primary,
                ),
              );
            }

            // ====================================================
            // ERROR
            // ====================================================

            if (snapshot.hasError) {
              return _buildErrorState(
                context,
                snapshot.error.toString(),
              );
            }

            // ====================================================
            // GET ALL DECKS
            // ====================================================

            final allDecks = [
              ...(snapshot.data?.docs ?? []),
            ];

            // ====================================================
            // SORT DECKS
            // ====================================================

            allDecks.sort((a, b) {
              final aCreated = a.data()['createdAt'];
              final bCreated = b.data()['createdAt'];

              if (aCreated == null && bCreated == null) {
                return 0;
              }

              if (aCreated == null) {
                return 1;
              }

              if (bCreated == null) {
                return -1;
              }

              if (aCreated is Timestamp &&
                  bCreated is Timestamp) {
                return bCreated.compareTo(aCreated);
              }

              return 0;
            });

            // ====================================================
            // SEARCH
            // ====================================================

            final query = searchQuery.toLowerCase();

            final decks = allDecks.where((doc) {
              final data = doc.data();

              final title = (data['title'] ?? '')
                  .toString()
                  .toLowerCase();

              final description = (data['description'] ?? '')
                  .toString()
                  .toLowerCase();

              return title.contains(query) ||
                  description.contains(query);
            }).toList();

            // ====================================================
            // PAGE
            // ====================================================

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),

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

                              onPressed: _goToHome,

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

                          // TITLE + SUBTITLE
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  widget.isAdmin
                                      ? 'Manage Decks'
                                      : 'My Decks',

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
                                  widget.isAdmin
                                      ? 'Create and organize your flashcard content'
                                      : 'Choose a deck and start studying',

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

                          // DECK ICON
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
                              Icons.auto_stories_rounded,
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
                      // SEARCH FIELD
                      // ==================================================

                      _buildSearchField(
                        context,
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
                            searchQuery.isEmpty
                                ? 'Learning Decks'
                                : 'Search Results',

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
                            '${decks.length}',

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

                      // ==================================================
                      // DECK LIST
                      // ==================================================

                      else
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
                            final doc =
                                decks[index];

                            final data =
                                doc.data();

                            final title =
                                (data['title'] ??
                                        'Untitled Deck')
                                    .toString();

                            final description =
                                (data['description'] ??
                                        '')
                                    .toString();

                            final cardCount =
                                _toInt(
                              data['cardCount'],
                            );

                            return _buildDeckCard(
                              context,

                              deckId:
                                  doc.id,

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
  // SEARCH FIELD
  // ============================================================

  Widget _buildSearchField(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return TextField(
      controller: searchController,

      focusNode: searchFocusNode,

      // ----------------------------------------------------------
      // IMPORTANT
      //
      // Do NOT trim the text while typing.
      //
      // The search field should behave like a normal real-world
      // search bar.
      // ----------------------------------------------------------

      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },

      textInputAction:
          TextInputAction.search,

      keyboardType:
          TextInputType.text,

      style: GoogleFonts.poppins(
        color: colors.onSurface,
        fontSize: 13,
      ),

      decoration: InputDecoration(
        hintText:
            'Search decks...',

        hintStyle:
            GoogleFonts.poppins(
          color: colors.onSurface
              .withOpacity(.40),
          fontSize: 13,
        ),

        prefixIcon: Icon(
          Icons.search_rounded,
          color: colors.primary,
        ),

        // --------------------------------------------------------
        // CLEAR BUTTON
        // --------------------------------------------------------

        suffixIcon:
            searchQuery.isNotEmpty
                ? IconButton(
                    tooltip:
                        'Clear search',

                    onPressed: () {
                      // Clear the actual text.
                      searchController.clear();

                      // Update filtering.
                      setState(() {
                        searchQuery = '';
                      });

                      // Put the cursor back into the search box.
                      searchFocusNode.requestFocus();
                    },

                    icon: Icon(
                      Icons.close_rounded,
                      color: colors
                          .onSurface
                          .withOpacity(
                        .50,
                      ),
                    ),
                  )
                : null,

        filled: true,

        fillColor:
            colors.onSurface
                .withOpacity(.045),

        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),

          borderSide:
              BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),

          borderSide:
              BorderSide(
            color: colors.onSurface
                .withOpacity(.08),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            15,
          ),

          borderSide:
              BorderSide(
            color: colors.primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DECK CARD
  // ============================================================

  Widget _buildDeckCard(
    BuildContext context, {
    required String deckId,
    required String title,
    required String description,
    required int cardCount,
  }) {
    final theme =
        Theme.of(context);

    final colors =
        theme.colorScheme;

    return Material(
      color:
          colors.surface,

      borderRadius:
          BorderRadius.circular(
        20,
      ),

      child: InkWell(
        borderRadius:
            BorderRadius.circular(
          20,
        ),

        onTap: () {
          _openDeck(
            deckId,
            title,
          );
        },

        child: Container(
          padding:
              const EdgeInsets.all(
            17,
          ),

          decoration:
              BoxDecoration(
            borderRadius:
                BorderRadius.circular(
              20,
            ),

            border:
                Border.all(
              color: colors
                  .onSurface
                  .withOpacity(.08),
            ),

            boxShadow:
                theme.brightness ==
                        Brightness.light
                    ? [
                        BoxShadow(
                          color: Colors
                              .black
                              .withOpacity(
                            .025,
                          ),
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

          child: Column(
            children: [
              Row(
                children: [

                  // ==================================================
                  // ICON
                  // ==================================================

                  Container(
                    width: 55,
                    height: 55,

                    decoration:
                        BoxDecoration(
                      color: colors
                          .primary
                          .withOpacity(
                        .10,
                      ),

                      borderRadius:
                          BorderRadius
                              .circular(
                        15,
                      ),
                    ),

                    child: Icon(
                      Icons
                          .auto_stories_rounded,

                      color:
                          colors.primary,

                      size: 27,
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
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          title,

                          maxLines: 1,

                          overflow:
                              TextOverflow
                                  .ellipsis,

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

                        const SizedBox(
                          height: 4,
                        ),

                        Text(
                          description
                                  .isEmpty
                              ? 'Flashcard learning deck'
                              : description,

                          maxLines: 2,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              GoogleFonts
                                  .poppins(
                            color: colors
                                .onSurface
                                .withOpacity(
                              .50,
                            ),

                            fontSize: 10.5,

                            height: 1.4,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons
                                  .style_outlined,

                              color:
                                  colors
                                      .primary,

                              size: 14,
                            ),

                            const SizedBox(
                              width: 4,
                            ),

                            Text(
                              '$cardCount cards',

                              style:
                                  GoogleFonts
                                      .poppins(
                                color: colors
                                    .onSurface
                                    .withOpacity(
                                  .50,
                                ),

                                fontSize: 10,

                                fontWeight:
                                    FontWeight
                                        .w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  // ==================================================
                  // ADMIN DELETE
                  // ==================================================

                  if (widget.isAdmin)
                    IconButton(
                      tooltip:
                          'Delete',

                      onPressed: () {
                        _deleteDeck(
                          deckId,
                          title,
                        );
                      },

                      icon: Icon(
                        Icons
                            .delete_outline_rounded,

                        color:
                            colors.error,

                        size: 21,
                      ),
                    ),
                ],
              ),

              const SizedBox(
                height: 14,
              ),

              // ==================================================
              // ACTION BUTTONS
              // ==================================================

              Row(
                children: [

                  Expanded(
                    child:
                        _actionButton(
                      context,

                      icon: Icons
                          .menu_book_rounded,

                      text: 'Study',

                      onTap: () {
                        _openDeck(
                          deckId,
                          title,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  if (widget.isAdmin)
                    Expanded(
                      child:
                          _actionButton(
                        context,

                        icon: Icons
                            .edit_outlined,

                        text: 'Edit',

                        onTap: () {
                          _editDeck(
                            deckId,
                            title,
                          );
                        },
                      ),
                    ),

                  if (widget.isAdmin)
                    const SizedBox(
                      width: 8,
                    ),

                  Expanded(
                    child:
                        _actionButton(
                      context,

                      icon:
                          Icons.quiz_rounded,

                      text: 'Quiz',

                      onTap: () {
                        _startQuiz(
                          deckId,
                          title,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION BUTTON
  // ============================================================

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    final colors =
        Theme.of(context).colorScheme;

    return SizedBox(
      height: 42,

      child:
          OutlinedButton.icon(
        onPressed: onTap,

        icon: Icon(
          icon,
          size: 17,
        ),

        label: Text(
          text,

          style:
              GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight:
                FontWeight.w600,
          ),
        ),

        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              colors.primary,

          side: BorderSide(
            color: colors.primary
                .withOpacity(.18),
          ),

          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),

          padding:
              const EdgeInsets
                  .symmetric(
            horizontal: 6,
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
      width:
          double.infinity,

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

        border:
            Border.all(
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

              shape:
                  BoxShape.circle,
            ),

            child: Icon(
              searchQuery.isEmpty
                  ? Icons
                      .auto_stories_outlined
                  : Icons
                      .search_off_rounded,

              color:
                  colors.primary,

              size: 30,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Text(
            searchQuery.isEmpty
                ? 'No Decks Yet'
                : 'No Decks Found',

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
            searchQuery.isEmpty
                ? widget.isAdmin
                    ? 'Create your first deck to get started.'
                    : 'Your learning decks will appear here.'
                : 'Try searching with a different name.',

            textAlign:
                TextAlign.center,

            style:
                GoogleFonts.poppins(
              color: colors.onSurface
                  .withOpacity(.50),

              fontSize: 11.5,
            ),
          ),

          if (widget.isAdmin &&
              searchQuery.isEmpty) ...[
            const SizedBox(
              height: 18,
            ),

            FilledButton.icon(
              onPressed:
                  _createDeck,

              icon:
                  const Icon(
                Icons.add_rounded,
              ),

              label:
                  const Text(
                'Create Your First Deck',
              ),
            ),
          ],
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
            const EdgeInsets.all(
          30,
        ),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            Icon(
              Icons
                  .error_outline_rounded,

              color:
                  colors.error,

              size: 45,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              'Unable to load decks',

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
              onPressed:
                  _goToHome,

              icon: const Icon(
                Icons.arrow_back_rounded,
              ),

              label: const Text(
                'Go Back',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CREATE DECK
  // ============================================================

  Future<void> _createDeck() async {
    final result =
        await Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            const CreateDeckScreen(),
      ),
    );

    if (!mounted) return;

    if (result == null) {
      return;
    }

    if (result is String &&
        result.trim().isNotEmpty) {
      final user =
          FirebaseAuth.instance.currentUser;

      if (user == null) {
        _showMessage(
          'User is not logged in.',
        );

        return;
      }

      try {
        await decksCollection.add({
          'title':
              result.trim(),

          'description':
              '',

          'cardCount':
              0,

          'userId':
              user.uid,

          'createdAt':
              FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        _showMessage(
          'Deck created successfully.',
        );
      } catch (e) {
        if (!mounted) return;

        _showMessage(
          'Unable to create deck: $e',
        );
      }
    }
  }

  // ============================================================
  // OPEN DECK
  // ============================================================

  void _openDeck(
    String deckId,
    String title,
  ) {
    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            MyDeckScreen(
          deckId:
              deckId,

          deckTitle:
              title,

          isAdmin:
              widget.isAdmin,
        ),
      ),
    );
  }

  // ============================================================
  // START QUIZ
  // ============================================================

  void _startQuiz(
    String deckId,
    String title,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Starting quiz for "$title"...',
        ),
      ),
    );

    // ==========================================================
    // CONNECT YOUR QUIZ SCREEN HERE
    // ==========================================================
  }

  // ============================================================
  // EDIT DECK
  // ============================================================

  Future<void> _editDeck(
    String deckId,
    String oldTitle,
  ) async {
    final controller =
        TextEditingController(
      text: oldTitle,
    );

    final colors =
        Theme.of(context).colorScheme;

    final newTitle =
        await showDialog<String>(
      context: context,

      builder:
          (dialogContext) {
        return AlertDialog(
          backgroundColor:
              colors.surface,

          title: Text(
            'Edit Deck',

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          content: TextField(
            controller:
                controller,

            autofocus:
                true,

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,

              fontSize: 13,
            ),

            decoration:
                InputDecoration(
              labelText:
                  'Deck title',

              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },

              child:
                  const Text(
                'Cancel',
              ),
            ),

            FilledButton(
              onPressed: () {
                final value =
                    controller.text
                        .trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  value,
                );
              },

              child:
                  const Text(
                'Save',
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newTitle == null ||
        newTitle.trim().isEmpty) {
      return;
    }

    try {
      await decksCollection
          .doc(deckId)
          .update({
        'title':
            newTitle.trim(),

        'updatedAt':
            FieldValue
                .serverTimestamp(),
      });

      if (!mounted) return;

      _showMessage(
        'Deck updated successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to update deck: $e',
      );
    }
  }

  // ============================================================
  // DELETE DECK
  // ============================================================

  Future<void> _deleteDeck(
    String deckId,
    String title,
  ) async {
    final colors =
        Theme.of(context).colorScheme;

    final shouldDelete =
        await showDialog<bool>(
      context: context,

      builder:
          (dialogContext) {
        return AlertDialog(
          backgroundColor:
              colors.surface,

          title: Text(
            'Delete Deck?',

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          content: Text(
            'Are you sure you want to delete "$title"?\n\n'
            'All flashcards inside this deck will also be deleted.',

            style:
                GoogleFonts.poppins(
              color: colors.onSurface
                  .withOpacity(.65),

              fontSize: 13,

              height: 1.5,
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

              child: Text(
                'Cancel',

                style:
                    TextStyle(
                  color:
                      colors.primary,
                ),
              ),
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
                  const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      // ========================================================
      // GET CARDS
      // ========================================================

      final cardsSnapshot =
          await decksCollection
              .doc(deckId)
              .collection('cards')
              .get();

      // ========================================================
      // DELETE CARDS
      // ========================================================

      if (cardsSnapshot.docs.isNotEmpty) {
        final batch =
            FirebaseFirestore.instance
                .batch();

        for (final card
            in cardsSnapshot.docs) {
          batch.delete(
            card.reference,
          );
        }

        await batch.commit();
      }

      // ========================================================
      // DELETE DECK
      // ========================================================

      await decksCollection
          .doc(deckId)
          .delete();

      if (!mounted) return;

      _showMessage(
        'Deck deleted successfully.',
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Unable to delete deck: $e',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
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