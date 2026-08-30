import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import '../main/main_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isHidden = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    try {
      setState(() {
        isLoading = true;
      });

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final String uid = userCredential.user!.uid;

      // ----------------------------------------------------------
      // GET USER ROLE
      // ----------------------------------------------------------

      final DocumentSnapshot<Map<String, dynamic>> userDoc =
          await FirebaseFirestore.instance
              .collection("users")
              .doc(uid)
              .get();

      bool isAdmin = false;

      if (userDoc.exists) {
        final data = userDoc.data();

        if (data != null) {
          isAdmin = data["role"]?.toString().toLowerCase() == "admin";
        }
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            isAdmin: isAdmin,
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case "invalid-credential":
        case "wrong-password":
        case "user-not-found":
          message = "Invalid email or password.";
          break;

        case "invalid-email":
          message = "Please enter a valid email address.";
          break;

        case "user-disabled":
          message = "This account has been disabled.";
          break;

        case "too-many-requests":
          message =
              "Too many login attempts. Please try again later.";
          break;

        case "network-request-failed":
          message =
              "Network error. Please check your internet connection.";
          break;

        default:
          message = e.message ?? "Unable to sign in.";
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
          content: Text("Something went wrong. Please try again."),
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
                  constraints: BoxConstraints(
                    maxWidth: width > 700 ? 500 : 500,
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
                                Icons
                                    .arrow_back_rounded,

                                color:
                                    colors.onSurface,

                                size: 21,
                              ),
                            ),
                          ),

                          const Spacer(),

                          Text(
                            "MEMORA",

                            style:
                                GoogleFonts.poppins(
                              color:
                                  colors.primary,

                              fontSize: 15,

                              fontWeight:
                                  FontWeight.w800,

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
                        "Welcome Back",
                        style:
                            GoogleFonts.poppins(
                          color:
                              colors.onSurface,

                          fontSize: 30,

                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "Sign in to continue your learning journey.",
                        style:
                            GoogleFonts.poppins(
                          color: colors.onSurface
                              .withOpacity(.55),

                          fontSize: 12.5,

                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // LOGIN CARD
                      // ==================================================

                      Container(
                        width: double.infinity,

                        padding:
                            const EdgeInsets.all(22),

                        decoration:
                            BoxDecoration(
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
                                CrossAxisAlignment
                                    .start,

                            children: [
                              // ==================================================
                              // EMAIL
                              // ==================================================

                              _fieldLabel(
                                context,
                                "Email Address",
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              TextFormField(
                                controller:
                                    emailController,

                                keyboardType:
                                    TextInputType
                                        .emailAddress,

                                textInputAction:
                                    TextInputAction
                                        .next,

                                style:
                                    GoogleFonts.poppins(
                                  color:
                                      colors.onSurface,

                                  fontSize: 13,
                                ),

                                decoration:
                                    _inputDecoration(
                                  context,

                                  hint:
                                      "Enter your email",

                                  icon: Icons
                                      .email_outlined,
                                ),

                                validator:
                                    (value) {
                                  if (value ==
                                          null ||
                                      value
                                          .trim()
                                          .isEmpty) {
                                    return "Please enter your email.";
                                  }

                                  if (!value
                                      .contains("@")) {
                                    return "Please enter a valid email.";
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(
                                height: 20,
                              ),

                              // ==================================================
                              // PASSWORD
                              // ==================================================

                              _fieldLabel(
                                context,
                                "Password",
                              ),

                              const SizedBox(
                                height: 8,
                              ),

                              TextFormField(
                                controller:
                                    passwordController,

                                obscureText:
                                    isHidden,

                                textInputAction:
                                    TextInputAction
                                        .done,

                                onFieldSubmitted:
                                    (_) {
                                  if (!isLoading) {
                                    loginUser();
                                  }
                                },

                                style:
                                    GoogleFonts.poppins(
                                  color:
                                      colors.onSurface,

                                  fontSize: 13,
                                ),

                                decoration:
                                    _inputDecoration(
                                  context,

                                  hint:
                                      "Enter your password",

                                  icon: Icons
                                      .lock_outline_rounded,

                                  suffixIcon:
                                      IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isHidden =
                                            !isHidden;
                                      });
                                    },

                                    icon: Icon(
                                      isHidden
                                          ? Icons
                                              .visibility_off_outlined
                                          : Icons
                                              .visibility_outlined,

                                      color: colors
                                          .onSurface
                                          .withOpacity(
                                        .45,
                                      ),

                                      size: 20,
                                    ),
                                  ),
                                ),

                                validator:
                                    (value) {
                                  if (value ==
                                          null ||
                                      value
                                          .isEmpty) {
                                    return "Please enter your password.";
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(
                                height: 28,
                              ),

                              // ==================================================
                              // SIGN IN BUTTON
                              // ==================================================

                              SizedBox(
                                width:
                                    double.infinity,

                                height: 52,

                                child:
                                    FilledButton(
                                  onPressed:
                                      isLoading
                                          ? null
                                          : loginUser,

                                  style:
                                      FilledButton
                                          .styleFrom(
                                    backgroundColor:
                                        colors
                                            .primary,

                                    foregroundColor:
                                        colors
                                            .onPrimary,

                                    disabledBackgroundColor:
                                        colors.primary
                                            .withOpacity(
                                      .45,
                                    ),

                                    shape:
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius
                                              .circular(
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
                                            strokeWidth:
                                                2.3,
                                            color: colors
                                                .onPrimary,
                                          ),
                                        )
                                      : Text(
                                          "Sign In",
                                          style:
                                              GoogleFonts
                                                  .poppins(
                                            fontSize:
                                                13,
                                            fontWeight:
                                                FontWeight
                                                    .w600,
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
                      // REGISTER
                      // ==================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Text(
                            "Don't have an account? ",

                            style:
                                GoogleFonts.poppins(
                              color: colors
                                  .onSurface
                                  .withOpacity(.55),

                              fontSize: 11.5,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,

                                MaterialPageRoute(
                                  builder: (_) =>
                                      const RegisterScreen(),
                                ),
                              );
                            },

                            child: Text(
                              "Create one",

                              style:
                                  GoogleFonts.poppins(
                                color:
                                    colors.primary,

                                fontSize: 11.5,

                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),

                      // ==================================================
                      // FOOTER
                      // ==================================================

                      Center(
                        child: Text(
                          "Learn Smart • Remember Forever",

                          style:
                              GoogleFonts.poppins(
                            color: colors.onSurface
                                .withOpacity(.35),

                            fontSize: 10,

                            letterSpacing: .3,
                          ),
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