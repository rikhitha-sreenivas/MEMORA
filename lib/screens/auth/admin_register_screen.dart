import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_screen.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() =>
      _AdminRegisterScreenState();
}

class _AdminRegisterScreenState
    extends State<AdminRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final adminCodeController = TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool hideAdminCode = true;

  bool isLoading = false;

  // ============================================================
  // TEMPORARY ADMIN REGISTRATION CODE
  // ============================================================
  //
  // IMPORTANT:
  // This is only for development/testing.
  //
  // Later we should move admin authorization to a secure
  // Firebase-based system.
  //

  static const String adminRegistrationCode =
      "MEMORA_ADMIN_2026";

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    adminCodeController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTER ADMIN
  // ============================================================

  Future<void> registerAdmin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    // ----------------------------------------------------------
    // VERIFY ADMIN CODE
    // ----------------------------------------------------------

    if (adminCodeController.text.trim() !=
        adminRegistrationCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Invalid admin registration code.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // --------------------------------------------------------
      // CREATE FIREBASE AUTH ACCOUNT
      // --------------------------------------------------------

      final UserCredential userCredential =
          await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final String uid = userCredential.user!.uid;

      // --------------------------------------------------------
      // CREATE ADMIN DOCUMENT
      // --------------------------------------------------------

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set({
        "name": fullNameController.text.trim(),
        "email": emailController.text.trim(),

        // IMPORTANT
        // This account is explicitly an ADMIN.
        "role": "admin",

        // Admin account information
        "createdAt": FieldValue.serverTimestamp(),

        // Optional admin statistics
        "decksCreated": 0,
        "cardsCreated": 0,
      });

      // --------------------------------------------------------
      // SIGN OUT AFTER REGISTRATION
      // --------------------------------------------------------

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // --------------------------------------------------------
      // SUCCESS MESSAGE
      // --------------------------------------------------------

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Admin account created successfully! Please login.",
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
              Theme.of(context).colorScheme.primary,
        ),
      );

      // --------------------------------------------------------
      // GO TO LOGIN
      // --------------------------------------------------------

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case "email-already-in-use":
          message =
              "An account already exists with this email.";
          break;

        case "invalid-email":
          message =
              "Please enter a valid email address.";
          break;

        case "weak-password":
          message =
              "The password is too weak.";
          break;

        case "operation-not-allowed":
          message =
              "Email/password registration is disabled.";
          break;

        default:
          message =
              e.message ?? "Admin registration failed.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Something went wrong. Please try again.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
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
  // PASSWORD VALIDATION
  // ============================================================

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter your password";
    }

    if (value.length < 8) {
      return "Minimum 8 characters";
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Must contain at least 1 digit";
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Must contain at least 1 special character";
    }

    return null;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: colors.surface,

      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND DECORATION
            // ==================================================

            Positioned(
              top: -100,
              right: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(.08),
                ),
              ),
            ),

            Positioned(
              bottom: -120,
              left: -100,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withOpacity(.06),
                ),
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                30,
              ),

              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [
                      // ==================================================
                      // TOP BAR
                      // ==================================================

                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,

                            decoration: BoxDecoration(
                              color: colors.onSurface
                                  .withOpacity(.05),

                              borderRadius:
                                  BorderRadius.circular(13),

                              border: Border.all(
                                color: colors.onSurface
                                    .withOpacity(.08),
                              ),
                            ),

                            child: IconButton(
                              padding: EdgeInsets.zero,

                              onPressed: () {
                                Navigator.pop(context);
                              },

                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: colors.onSurface,
                                size: 21,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "MEMORA",
                            style: GoogleFonts.poppins(
                              color: colors.primary,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 45),

                      // ==================================================
                      // TITLE
                      // ==================================================

                      Text(
                        "Admin Registration",
                        style: GoogleFonts.poppins(
                          color: colors.onSurface,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Create an administrator account for managing Memora.",
                        style: GoogleFonts.poppins(
                          color:
                              colors.onSurface.withOpacity(.55),
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ==================================================
                      // ADMIN BADGE
                      // ==================================================

                      Container(
                        padding: const EdgeInsets.all(15),

                        decoration: BoxDecoration(
                          color:
                              colors.primary.withOpacity(.08),

                          borderRadius:
                              BorderRadius.circular(16),

                          border: Border.all(
                            color:
                                colors.primary.withOpacity(.18),
                          ),
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,

                              decoration: BoxDecoration(
                                color: colors.primary
                                    .withOpacity(.12),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),

                              child: Icon(
                                Icons.admin_panel_settings_outlined,
                                color: colors.primary,
                                size: 23,
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    "Administrator Account",
                                    style:
                                        GoogleFonts.poppins(
                                      color:
                                          colors.onSurface,
                                      fontSize: 12.5,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    "Requires authorized registration",
                                    style:
                                        GoogleFonts.poppins(
                                      color: colors.onSurface
                                          .withOpacity(.5),
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // ==================================================
                      // FORM CARD
                      // ==================================================

                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.all(22),

                        decoration: BoxDecoration(
                          color: colors.onSurface
                              .withOpacity(.035),

                          borderRadius:
                              BorderRadius.circular(24),

                          border: Border.all(
                            color: colors.onSurface
                                .withOpacity(.08),
                          ),
                        ),

                        child: Form(
                          key: _formKey,

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              // ==================================================
                              // FULL NAME
                              // ==================================================

                              _fieldLabel(
                                context,
                                "Full Name",
                              ),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller:
                                    fullNameController,

                                textInputAction:
                                    TextInputAction.next,

                                style: GoogleFonts.poppins(
                                  color: colors.onSurface,
                                  fontSize: 13,
                                ),

                                decoration:
                                    _inputDecoration(
                                  context,
                                  hint:
                                      "Enter your full name",
                                  icon: Icons
                                      .person_outline_rounded,
                                ),

                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return "Please enter your name.";
                                  }

                                  if (value.trim().length < 2) {
                                    return "Please enter a valid name.";
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // ==================================================
                              // EMAIL
                              // ==================================================

                              _fieldLabel(
                                context,
                                "Admin Email Address",
                              ),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller:
                                    emailController,

                                keyboardType:
                                    TextInputType.emailAddress,

                                textInputAction:
                                    TextInputAction.next,

                                style: GoogleFonts.poppins(
                                  color: colors.onSurface,
                                  fontSize: 13,
                                ),

                                decoration:
                                    _inputDecoration(
                                  context,
                                  hint:
                                      "Enter admin email",
                                  icon:
                                      Icons.email_outlined,
                                ),

                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return "Please enter your email.";
                                  }

                                  final emailRegex =
                                      RegExp(
                                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                  );

                                  if (!emailRegex.hasMatch(
                                    value.trim(),
                                  )) {
                                    return "Please enter a valid email.";
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // ==================================================
                              // PASSWORD
                              // ==================================================

                              _fieldLabel(
                                context,
                                "Password",
                              ),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller:
                                    passwordController,

                                obscureText:
                                    hidePassword,

                                textInputAction:
                                    TextInputAction.next,

                                style: GoogleFonts.poppins(
                                  color: colors.onSurface,
                                  fontSize: 13,
                                ),

                                decoration:
                                    _inputDecoration(
                                  context,
                                  hint:
                                      "Create a password",
                                  icon: Icons
                                      .lock_outline_rounded,
                                  suffixIcon:
                                      IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePassword =
                                            !hidePassword;
                                      });
                                    },

                                    icon: Icon(
                                      hidePassword
                                          ? Icons
                                              .visibility_off_outlined
                                          : Icons
                                              .visibility_outlined,
                                      color: colors.onSurface
                                          .withOpacity(.45),
                                      size: 20,
                                    ),
                                  ),
                                ),

                                validator:
                                    validatePassword,
                              ),

                              const SizedBox(height: 20),

                              // ==================================================
                              // CONFIRM PASSWORD
                              // ==================================================

                              _fieldLabel(
                                context,
                                "Confirm Password",
                              ),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller:
                                    confirmPasswordController,

                                obscureText:
                                    hideConfirmPassword,

                                textInputAction:
                                    TextInputAction.next,

                                style: GoogleFonts.poppins(
                                  color: colors.onSurface,
                                  fontSize: 13,
                                ),

                                decoration:
                                    _inputDecoration(
                                  context,
                                  hint:
                                      "Re-enter your password",
                                  icon: Icons
                                      .lock_outline_rounded,
                                  suffixIcon:
                                      IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hideConfirmPassword =
                                            !hideConfirmPassword;
                                      });
                                    },

                                    icon: Icon(
                                      hideConfirmPassword
                                          ? Icons
                                              .visibility_off_outlined
                                          : Icons
                                              .visibility_outlined,
                                      color: colors.onSurface
                                          .withOpacity(.45),
                                      size: 20,
                                    ),
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty) {
                                    return "Please confirm your password.";
                                  }

                                  if (value !=
                                      passwordController.text) {
                                    return "Passwords do not match.";
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // ==================================================
                              // ADMIN REGISTRATION CODE
                              // ==================================================

                              _fieldLabel(
                                context,
                                "Admin Registration Code",
                              ),

                              const SizedBox(height: 8),

                              TextFormField(
                                controller:
                                    adminCodeController,

                                obscureText:
                                    hideAdminCode,

                                textInputAction:
                                    TextInputAction.done,

                                style: GoogleFonts.poppins(
                                  color: colors.onSurface,
                                  fontSize: 13,
                                ),

                                decoration:
                                    _inputDecoration(
                                  context,
                                  hint:
                                      "Enter authorization code",
                                  icon: Icons
                                      .key_outlined,
                                  suffixIcon:
                                      IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hideAdminCode =
                                            !hideAdminCode;
                                      });
                                    },

                                    icon: Icon(
                                      hideAdminCode
                                          ? Icons
                                              .visibility_off_outlined
                                          : Icons
                                              .visibility_outlined,
                                      color: colors.onSurface
                                          .withOpacity(.45),
                                      size: 20,
                                    ),
                                  ),
                                ),

                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return "Enter the admin registration code.";
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              // ==================================================
                              // CREATE ADMIN BUTTON
                              // ==================================================

                              SizedBox(
                                width: double.infinity,
                                height: 52,

                                child: FilledButton(
                                  onPressed: isLoading
                                      ? null
                                      : registerAdmin,

                                  style:
                                      FilledButton.styleFrom(
                                    backgroundColor:
                                        colors.primary,

                                    foregroundColor:
                                        colors.onPrimary,

                                    disabledBackgroundColor:
                                        colors.primary
                                            .withOpacity(.45),

                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(
                                        15,
                                      ),
                                    ),
                                  ),

                                  child: isLoading
                                      ? SizedBox(
                                          width: 21,
                                          height: 21,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth: 2.3,
                                            color:
                                                colors.onPrimary,
                                          ),
                                        )
                                      : Text(
                                          "Create Admin Account",
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

                      const SizedBox(height: 25),

                      // ==================================================
                      // LOGIN
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [
                          Text(
                            "Already have an account? ",
                            style: GoogleFonts.poppins(
                              color: colors.onSurface
                                  .withOpacity(.55),
                              fontSize: 11.5,
                            ),
                          ),

                          GestureDetector(
                            onTap: isLoading
                                ? null
                                : () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },

                            child: Text(
                              "Sign In",
                              style: GoogleFonts.poppins(
                                color: colors.primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // SECURITY MESSAGE
                      // ==================================================

                      Center(
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            Icon(
                              Icons
                                  .security_outlined,
                              color: colors.onSurface
                                  .withOpacity(.3),
                              size: 14,
                            ),

                            const SizedBox(width: 6),

                            Text(
                              "Authorized administrators only",
                              style: GoogleFonts.poppins(
                                color: colors.onSurface
                                    .withOpacity(.3),
                                fontSize: 9.5,
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _fieldLabel(
    BuildContext context,
    String label,
  ) {
    final colors =
        Theme.of(context).colorScheme;

    return Text(
      label,
      style: GoogleFonts.poppins(
        color: colors.onSurface,
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final colors =
        Theme.of(context).colorScheme;

    return InputDecoration(
      hintText: hint,

      hintStyle: GoogleFonts.poppins(
        color: colors.onSurface.withOpacity(.35),
        fontSize: 12,
      ),

      prefixIcon: Icon(
        icon,
        color: colors.primary.withOpacity(.75),
        size: 20,
      ),

      suffixIcon: suffixIcon,

      filled: true,

      fillColor:
          colors.onSurface.withOpacity(.045),

      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide: BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide: BorderSide(
          color: colors.onSurface
              .withOpacity(.07),
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide: BorderSide(
          color: colors.primary,
          width: 1.2,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide: BorderSide(
          color: colors.error,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),

        borderSide: BorderSide(
          color: colors.error,
          width: 1.2,
        ),
      ),
    );
  }
}