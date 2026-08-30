import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PdfsScreen extends StatefulWidget {
  final bool isAdmin;
  final VoidCallback? onBackToHome;

  const PdfsScreen({
    super.key,
    required this.isAdmin,
    this.onBackToHome,
  });

  @override
  State<PdfsScreen> createState() => _PdfsScreenState();
}

class _PdfsScreenState extends State<PdfsScreen> {
  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController searchController =
      TextEditingController();

  String searchQuery = '';

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // Listen to the controller directly.
    //
    // This keeps the TextField itself stable while the search
    // results update.
    searchController.addListener(_onSearchChanged);
  }

  // ============================================================
  // SEARCH CHANGED
  // ============================================================

  void _onSearchChanged() {
    final value = searchController.text;

    if (value == searchQuery) {
      return;
    }

    setState(() {
      searchQuery = value;
    });
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
      // ADMIN ADD PDF BUTTON
      // ==========================================================

      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _createPdf,
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: Text(
                'Add PDF',
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
        child: StreamBuilder<
            QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('pdfs')
              .orderBy(
                'createdAt',
                descending: true,
              )
              .snapshots(),

          builder: (context, snapshot) {
            // ====================================================
            // LOADING
            // ====================================================

            if (snapshot.connectionState ==
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

            if (snapshot.hasError) {
              return _buildErrorState(
                context,
                snapshot.error.toString(),
              );
            }

            // ====================================================
            // ALL PDFS
            // ====================================================

            final allPdfs =
                snapshot.data?.docs ?? [];

            // ====================================================
            // SEARCH
            // ====================================================

            final query =
                searchQuery.toLowerCase().trim();

            final pdfs = allPdfs.where((doc) {
              final data = doc.data();

              final title =
                  (data['title'] ?? '')
                      .toString()
                      .toLowerCase();

              final description =
                  (data['description'] ?? '')
                      .toString()
                      .toLowerCase();

              return title.contains(query) ||
                  description.contains(query);
            }).toList();

            // ====================================================
            // PAGE
            // ====================================================

            return SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),

              padding:
                  const EdgeInsets.fromLTRB(
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

                              onPressed:
                                  _goBack,

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

                          // TITLE
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  widget.isAdmin
                                      ? 'Manage PDFs'
                                      : 'PDF Library',

                                  style:
                                      GoogleFonts
                                          .poppins(
                                    color:
                                        colors
                                            .onSurface,

                                    fontSize: 26,

                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),

                                const SizedBox(
                                  height: 2,
                                ),

                                Text(
                                  widget.isAdmin
                                      ? 'Manage and organize your learning resources'
                                      : 'Browse and explore your learning resources',

                                  style:
                                      GoogleFonts
                                          .poppins(
                                    color: colors
                                        .onSurface
                                        .withOpacity(
                                      .55,
                                    ),

                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // PDF ICON
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
                                  .picture_as_pdf_rounded,
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
                      // SUMMARY
                      // ==================================================

                      Row(
                        children: [

                          Expanded(
                            child:
                                _buildSummaryCard(
                              context,
                              icon: Icons
                                  .picture_as_pdf_rounded,
                              value:
                                  allPdfs.length
                                      .toString(),
                              label:
                                  'Total PDFs',
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _buildSummaryCard(
                              context,
                              icon: Icons
                                  .download_rounded,
                              value:
                                  _calculateDownloads(
                                allPdfs,
                              ).toString(),
                              label:
                                  'Downloads',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 20,
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
                      // SECTION TITLE
                      // ==================================================

                      Row(
                        children: [

                          Text(
                            searchQuery.isEmpty
                                ? 'Learning Resources'
                                : 'Search Results',

                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  colors.onSurface,

                              fontSize: 18,

                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),

                          const Spacer(),

                          Text(
                            pdfs.length.toString(),

                            style:
                                GoogleFonts
                                    .poppins(
                              color: colors
                                  .onSurface
                                  .withOpacity(
                                .45,
                              ),

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

                      if (pdfs.isEmpty)
                        _buildEmptyState(
                          context,
                        )

                      // ==================================================
                      // PDF LIST
                      // ==================================================

                      else
                        ListView.separated(
                          shrinkWrap: true,

                          physics:
                              const NeverScrollableScrollPhysics(),

                          itemCount:
                              pdfs.length,

                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                            height: 12,
                          ),

                          itemBuilder:
                              (context, index) {
                            final doc =
                                pdfs[index];

                            final data =
                                doc.data();

                            final title =
                                (data['title'] ??
                                        'Untitled PDF')
                                    .toString();

                            final description =
                                (data[
                                            'description'] ??
                                        '')
                                    .toString();

                            final fileSize =
                                (data['fileSize'] ??
                                        '')
                                    .toString();

                            final downloads =
                                _toInt(
                              data[
                                  'downloads'],
                            );

                            return _buildPdfCard(
                              context,

                              pdfId:
                                  doc.id,

                              title:
                                  title,

                              description:
                                  description,

                              fileSize:
                                  fileSize,

                              downloads:
                                  downloads,
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
      controller:
          searchController,

      keyboardType:
          TextInputType.text,

      textInputAction:
          TextInputAction.search,

      autocorrect:
          false,

      enableSuggestions:
          false,

      style:
          GoogleFonts.poppins(
        color:
            colors.onSurface,
        fontSize:
            13,
      ),

      decoration:
          InputDecoration(
        hintText:
            'Search PDFs...',

        hintStyle:
            GoogleFonts.poppins(
          color: colors.onSurface
              .withOpacity(.40),
          fontSize: 13,
        ),

        prefixIcon:
            Icon(
          Icons.search_rounded,
          color:
              colors.primary,
        ),

        suffixIcon:
            searchQuery.isNotEmpty
                ? IconButton(
                    onPressed:
                        _clearSearch,

                    icon:
                        Icon(
                      Icons
                          .close_rounded,
                      color: colors
                          .onSurface
                          .withOpacity(
                        .50,
                      ),
                    ),
                  )
                : null,

        filled:
            true,

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
            color: colors
                .onSurface
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
            color:
                colors.primary,
            width:
                1.2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BACK
  // ============================================================

  void _goBack() {
    if (widget.onBackToHome != null) {
      widget.onBackToHome!();
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  void _clearSearch() {
    // The controller listener automatically updates
    // searchQuery and rebuilds the results.
    searchController.clear();

    // Put the cursor back inside the search field.
    FocusScope.of(context).requestFocus(
      FocusNode(),
    );
  }

  // ============================================================
  // PDF CARD
  // ============================================================

  Widget _buildPdfCard(
    BuildContext context, {
    required String pdfId,
    required String title,
    required String description,
    required String fileSize,
    required int downloads,
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
          _readPdf(
            pdfId,
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
                          blurRadius:
                              12,
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

              // ==================================================
              // TOP CONTENT
              // ==================================================

              Row(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  // PDF ICON
                  Container(
                    width: 54,
                    height: 54,

                    decoration:
                        BoxDecoration(
                      color: colors
                          .error
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
                          .picture_as_pdf_rounded,
                      color:
                          colors.error,
                      size: 27,
                    ),
                  ),

                  const SizedBox(
                    width: 14,
                  ),

                  // CONTENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [

                        Text(
                          title,

                          maxLines:
                              1,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style:
                              GoogleFonts
                                  .poppins(
                            color: colors
                                .onSurface,

                            fontSize:
                                15,

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
                              ? 'Learning resource'
                              : description,

                          maxLines:
                              2,

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

                            fontSize:
                                10.5,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Wrap(
                          spacing:
                              12,

                          runSpacing:
                              4,

                          children: [

                            if (fileSize
                                .isNotEmpty)
                              Row(
                                mainAxisSize:
                                    MainAxisSize
                                        .min,

                                children: [

                                  Icon(
                                    Icons
                                        .description_outlined,
                                    size:
                                        14,
                                    color:
                                        colors
                                            .primary,
                                  ),

                                  const SizedBox(
                                    width: 4,
                                  ),

                                  Text(
                                    fileSize,

                                    style:
                                        GoogleFonts
                                            .poppins(
                                      color: colors
                                          .onSurface
                                          .withOpacity(
                                        .50,
                                      ),

                                      fontSize:
                                          10,
                                    ),
                                  ),
                                ],
                              ),

                            Row(
                              mainAxisSize:
                                  MainAxisSize
                                      .min,

                              children: [

                                Icon(
                                  Icons
                                      .download_outlined,
                                  size:
                                      14,
                                  color:
                                      colors
                                          .primary,
                                ),

                                const SizedBox(
                                  width: 4,
                                ),

                                Text(
                                  '$downloads downloads',

                                  style:
                                      GoogleFonts
                                          .poppins(
                                    color: colors
                                        .onSurface
                                        .withOpacity(
                                      .50,
                                    ),

                                    fontSize:
                                        10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  // ADMIN DELETE
                  if (widget.isAdmin)
                    IconButton(
                      tooltip:
                          'Delete',

                      onPressed: () {
                        _deletePdf(
                          pdfId,
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

                      text:
                          'Read',

                      onTap: () {
                        _readPdf(
                          pdfId,
                          title,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                        _actionButton(
                      context,

                      icon: Icons
                          .download_rounded,

                      text:
                          'Download',

                      onTap: () {
                        _downloadPdf(
                          pdfId,
                          title,
                        );
                      },
                    ),
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  Expanded(
                    child:
                        _actionButton(
                      context,

                      icon: Icons
                          .share_rounded,

                      text:
                          'Share',

                      onTap: () {
                        _sharePdf(
                          pdfId,
                          title,
                        );
                      },
                    ),
                  ),

                  if (widget.isAdmin) ...[
                    const SizedBox(
                      width: 8,
                    ),

                    Container(
                      width: 42,
                      height: 42,

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
                          12,
                        ),
                      ),

                      child:
                          IconButton(
                        tooltip:
                            'Edit',

                        onPressed: () {
                          _editPdf(
                            pdfId,
                            title,
                          );
                        },

                        icon: Icon(
                          Icons
                              .edit_outlined,

                          color:
                              colors
                                  .primary,

                          size: 19,
                        ),
                      ),
                    ),
                  ],
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
        onPressed:
            onTap,

        icon: Icon(
          icon,
          size: 17,
        ),

        label: Text(
          text,

          style:
              GoogleFonts.poppins(
            fontSize:
                10.5,

            fontWeight:
                FontWeight.w600,
          ),
        ),

        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              colors.primary,

          side:
              BorderSide(
            color: colors
                .primary
                .withOpacity(
              .18,
            ),
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
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    final colors =
        Theme.of(context)
            .colorScheme;

    return Container(
      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          BoxDecoration(
        color: colors.primary
            .withOpacity(.08),

        borderRadius:
            BorderRadius.circular(
          18,
        ),

        border:
            Border.all(
          color: colors.primary
              .withOpacity(.10),
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 40,
            height: 40,

            decoration:
                BoxDecoration(
              color: colors
                  .primary
                  .withOpacity(
                .12,
              ),

              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              icon,
              color:
                  colors.primary,
              size: 21,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(
                  value,

                  style:
                      GoogleFonts
                          .poppins(
                    color: colors
                        .onSurface,

                    fontSize:
                        19,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                Text(
                  label,

                  style:
                      GoogleFonts
                          .poppins(
                    color: colors
                        .onSurface
                        .withOpacity(
                      .50,
                    ),

                    fontSize:
                        10.5,
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
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
    BuildContext context,
  ) {
    final colors =
        Theme.of(context)
            .colorScheme;

    final hasSearch =
        searchQuery.isNotEmpty;

    return Container(
      width:
          double.infinity,

      margin:
          const EdgeInsets.only(
        top: 10,
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
              color: colors
                  .primary
                  .withOpacity(
                .10,
              ),

              shape:
                  BoxShape.circle,
            ),

            child: Icon(
              hasSearch
                  ? Icons
                      .search_off_rounded
                  : Icons
                      .picture_as_pdf_outlined,

              color:
                  colors.primary,

              size: 30,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          Text(
            hasSearch
                ? 'No PDFs Found'
                : 'No PDFs Yet',

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,

              fontSize:
                  17,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            hasSearch
                ? 'Try searching with a different name.'
                : widget.isAdmin
                    ? 'Add your first PDF resource to get started.'
                    : 'Learning resources will appear here.',

            textAlign:
                TextAlign.center,

            style:
                GoogleFonts.poppins(
              color: colors
                  .onSurface
                  .withOpacity(.50),

              fontSize:
                  11.5,
            ),
          ),

          if (widget.isAdmin &&
              !hasSearch) ...[
            const SizedBox(
              height: 18,
            ),

            FilledButton.icon(
              onPressed:
                  _createPdf,

              icon:
                  const Icon(
                Icons.add_rounded,
              ),

              label:
                  const Text(
                'Add Your First PDF',
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
        Theme.of(context)
            .colorScheme;

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
              'Unable to load PDFs',

              style:
                  GoogleFonts.poppins(
                color:
                    colors.onSurface,

                fontSize:
                    16,

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

                fontSize:
                    11,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            OutlinedButton.icon(
              onPressed:
                  _goBack,

              icon:
                  const Icon(
                Icons
                    .arrow_back_rounded,
              ),

              label:
                  const Text(
                'Go Back',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CREATE PDF
  // ============================================================

  void _createPdf() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      const SnackBar(
        content: Text(
          'PDF upload screen will be connected next.',
        ),
      ),
    );
  }

  // ============================================================
  // READ PDF
  // ============================================================

  void _readPdf(
    String pdfId,
    String title,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Opening "$title"...',
        ),
      ),
    );
  }

  // ============================================================
  // DOWNLOAD PDF
  // ============================================================

  void _downloadPdf(
    String pdfId,
    String title,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Downloading "$title"...',
        ),
      ),
    );
  }

  // ============================================================
  // SHARE PDF
  // ============================================================

  void _sharePdf(
    String pdfId,
    String title,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing "$title"...',
        ),
      ),
    );
  }

  // ============================================================
  // EDIT PDF
  // ============================================================

  void _editPdf(
    String pdfId,
    String title,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content: Text(
          'Edit "$title" will be connected next.',
        ),
      ),
    );
  }

  // ============================================================
  // DELETE PDF
  // ============================================================

  Future<void> _deletePdf(
    String pdfId,
    String title,
  ) async {
    final colors =
        Theme.of(context)
            .colorScheme;

    final shouldDelete =
        await showDialog<bool>(
      context: context,

      builder:
          (dialogContext) {
        return AlertDialog(
          backgroundColor:
              colors.surface,

          title: Text(
            'Delete PDF?',

            style:
                GoogleFonts.poppins(
              color:
                  colors.onSurface,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          content: Text(
            'Are you sure you want to delete "$title"?',

            style:
                GoogleFonts.poppins(
              color: colors.onSurface
                  .withOpacity(.65),

              fontSize:
                  13,
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
      await FirebaseFirestore
          .instance
          .collection('pdfs')
          .doc(pdfId)
          .delete();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'PDF deleted successfully',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to delete PDF: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DOWNLOAD COUNT
  // ============================================================

  int _calculateDownloads(
    List<
        QueryDocumentSnapshot<
            Map<String, dynamic>>> pdfs,
  ) {
    int total = 0;

    for (final pdf in pdfs) {
      final data =
          pdf.data();

      total +=
          _toInt(
        data['downloads'],
      );
    }

    return total;
  }

  // ============================================================
  // SAFE INTEGER CONVERSION
  // ============================================================

  int _toInt(
    dynamic value,
  ) {
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

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    searchController.removeListener(
      _onSearchChanged,
    );

    searchController.dispose();

    super.dispose();
  }
}