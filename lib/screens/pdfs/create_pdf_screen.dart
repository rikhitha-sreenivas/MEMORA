import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePdfScreen extends StatefulWidget {
  const CreatePdfScreen({super.key});

  @override
  State<CreatePdfScreen> createState() => _CreatePdfScreenState();
}

class _CreatePdfScreenState extends State<CreatePdfScreen> {
  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController urlController =
      TextEditingController();

  bool isLoading = false;

  // ============================================================
  // CREATE PDF
  // ============================================================

  Future<void> createPdf() async {
    final title = titleController.text.trim();
    final description = descriptionController.text.trim();
    final url = urlController.text.trim();

    if (title.isEmpty) {
      _showMessage("Please enter a PDF title");
      return;
    }

    if (url.isEmpty) {
      _showMessage("Please enter the PDF URL");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage("User is not logged in");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await FirebaseFirestore.instance
          .collection("pdfs")
          .add({
        "title": title,
        "description": description,
        "url": url,
        "createdBy": user.uid,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
        "downloads": 0,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "PDF created successfully",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        "Unable to create PDF: $e",
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
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

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,

        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colors.onSurface,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "Create PDF",
          style: GoogleFonts.poppins(
            color: colors.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 700,
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // ==================================================
                  // HEADER
                  // ==================================================

                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(20),

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

                    child: Row(
                      children: [

                        Container(
                          width: 52,
                          height: 52,

                          decoration: BoxDecoration(
                            color: colors.primary
                                .withOpacity(.12),

                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),

                          child: Icon(
                            Icons.picture_as_pdf_rounded,
                            color: colors.primary,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [

                              Text(
                                "Add Learning Material",
                                style:
                                    GoogleFonts.poppins(
                                  color:
                                      colors.onSurface,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                "Add a PDF for students to read and download.",
                                style:
                                    GoogleFonts.poppins(
                                  color: colors.onSurface
                                      .withOpacity(.55),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ==================================================
                  // PDF TITLE
                  // ==================================================

                  _buildLabel(
                    context,
                    "PDF Title",
                  ),

                  const SizedBox(height: 8),

                  _buildTextField(
                    context,
                    controller: titleController,
                    hintText: "Enter PDF title",
                    icon: Icons.title_rounded,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  _buildLabel(
                    context,
                    "Description",
                  ),

                  const SizedBox(height: 8),

                  _buildTextField(
                    context,
                    controller:
                        descriptionController,
                    hintText:
                        "Enter a short description",
                    icon:
                        Icons.description_outlined,
                    maxLines: 4,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // PDF URL
                  // ==================================================

                  _buildLabel(
                    context,
                    "PDF URL",
                  ),

                  const SizedBox(height: 8),

                  _buildTextField(
                    context,
                    controller: urlController,
                    hintText:
                        "Paste PDF download/view URL",
                    icon:
                        Icons.link_rounded,
                    keyboardType:
                        TextInputType.url,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Example: Firebase Storage download URL",
                    style: GoogleFonts.poppins(
                      color: colors.onSurface
                          .withOpacity(.45),
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // CREATE BUTTON
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: FilledButton.icon(
                      onPressed:
                          isLoading
                              ? null
                              : createPdf,

                      icon: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .add_circle_outline_rounded,
                            ),

                      label: Text(
                        isLoading
                            ? "Creating PDF..."
                            : "Create PDF",
                        style:
                            GoogleFonts.poppins(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // INFORMATION
                  // ==================================================

                  Container(
                    width: double.infinity,

                    padding:
                        const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: colors.onSurface
                          .withOpacity(.035),

                      borderRadius:
                          BorderRadius.circular(16),

                      border: Border.all(
                        color: colors.onSurface
                            .withOpacity(.07),
                      ),
                    ),

                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Icon(
                          Icons.info_outline_rounded,
                          color: colors.primary,
                          size: 20,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            "Students will be able to view and download this PDF. "
                            "Make sure the provided URL is publicly accessible "
                            "or accessible to authenticated users.",
                            style:
                                GoogleFonts.poppins(
                              color: colors.onSurface
                                  .withOpacity(.55),
                              fontSize: 10.5,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
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
        Theme.of(context).colorScheme;

    return Text(
      text,
      style: GoogleFonts.poppins(
        color: colors.onSurface,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    final colors =
        Theme.of(context).colorScheme;

    return TextField(
      controller: controller,

      maxLines: maxLines,

      keyboardType: keyboardType,

      style: GoogleFonts.poppins(
        color: colors.onSurface,
        fontSize: 13,
      ),

      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: GoogleFonts.poppins(
          color:
              colors.onSurface.withOpacity(.40),
          fontSize: 12,
        ),

        prefixIcon: Icon(
          icon,
          color: colors.primary,
          size: 21,
        ),

        filled: true,

        fillColor:
            colors.onSurface.withOpacity(.045),

        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),

        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colors.onSurface
                .withOpacity(.08),
          ),
        ),

        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(15),
          borderSide: BorderSide(
            color: colors.primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    urlController.dispose();
    super.dispose();
  }
}