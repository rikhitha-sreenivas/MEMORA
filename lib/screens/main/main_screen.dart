import 'package:flutter/material.dart';

import '../home/home_screen.dart';
import '../decks/decks_screen.dart';
import '../progress/progress_screen.dart';
import '../pdfs/pdfs_screen.dart';
import '../quiz/quiz_selection_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  final bool isAdmin;

  const MainScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // ============================================================
  // SAME INDEXES FOR ADMIN AND USER
  // ============================================================
  //
  // 0 = Home
  // 1 = Decks
  // 2 = Progress
  // 3 = PDFs
  // 4 = Quiz
  // 5 = Profile
  //
  // ============================================================

  int currentIndex = 0;

  // ============================================================
  // PAGE LIST
  // ============================================================

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();

    pages = [
      // ========================================================
      // 0 - HOME
      // ========================================================

      HomeScreen(
        isAdmin: widget.isAdmin,

        openQuiz: () {
          _goToPage(4);
        },
      ),

      // ========================================================
      // 1 - DECKS
      // ========================================================

      DecksScreen(
        isAdmin: widget.isAdmin,

        onBackToHome: () {
          _goToPage(0);
        },
      ),

      // ========================================================
      // 2 - PROGRESS
      // ========================================================

      ProgressScreen(
        onBackToHome: () {
          _goToPage(0);
        },
      ),

      // ========================================================
      // 3 - PDFs
      // ========================================================

      PdfsScreen(
        isAdmin: widget.isAdmin,

        onBackToHome: () {
          _goToPage(0);
        },
      ),

      // ========================================================
      // 4 - QUIZ
      // ========================================================

      QuizSelectionScreen(
        onBackToHome: () {
          _goToPage(0);
        },
      ),

      // ========================================================
      // 5 - PROFILE
      // ========================================================

      ProfileScreen(
        onBackToHome: () {
          _goToPage(0);
        },
      ),
    ];
  }

  // ============================================================
  // GO TO PAGE
  // ============================================================

  void _goToPage(int index) {
    if (!mounted) return;

    if (index < 0 || index >= pages.length) {
      return;
    }

    setState(() {
      currentIndex = index;
    });
  }

  // ============================================================
  // NAVIGATION BAR
  // ============================================================

  void _changePage(int index) {
    if (currentIndex == index) {
      return;
    }

    _goToPage(index);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ========================================================
      // PAGE
      // ========================================================

      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: SafeArea(
        top: false,

        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,

            border: Border(
              top: BorderSide(
                color: theme.dividerColor,
                width: 0.8,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  theme.brightness == Brightness.light
                      ? 0.06
                      : 0.20,
                ),
                blurRadius: 12,
                offset: const Offset(0, -3),
              ),
            ],
          ),

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 6,
            ),

            child: Row(
              children: [
                // ==================================================
                // HOME
                // ==================================================

                _buildNavItem(
                  context,
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Home',
                ),

                // ==================================================
                // DECKS
                // ==================================================

                _buildNavItem(
                  context,
                  index: 1,
                  icon: Icons.folder_outlined,
                  activeIcon: Icons.folder_rounded,
                  label: 'Decks',
                ),

                // ==================================================
                // PROGRESS
                // ==================================================

                _buildNavItem(
                  context,
                  index: 2,
                  icon: Icons.bar_chart_outlined,
                  activeIcon: Icons.bar_chart_rounded,
                  label: 'Progress',
                ),

                // ==================================================
                // PDFs
                // ==================================================

                _buildNavItem(
                  context,
                  index: 3,
                  icon: Icons.picture_as_pdf_outlined,
                  activeIcon:
                      Icons.picture_as_pdf_rounded,
                  label: 'PDFs',
                ),

                // ==================================================
                // QUIZ
                // ==================================================

                _buildNavItem(
                  context,
                  index: 4,
                  icon: Icons.quiz_outlined,
                  activeIcon: Icons.quiz_rounded,
                  label: 'Quiz',
                ),

                // ==================================================
                // PROFILE
                // ==================================================

                _buildNavItem(
                  context,
                  index: 5,
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final bool selected = currentIndex == index;

    final Color selectedColor = colors.primary;

    final Color unselectedColor =
        colors.onSurface.withOpacity(0.48);

    return Expanded(
      child: InkWell(
        onTap: () {
          _changePage(index);
        },

        borderRadius: BorderRadius.circular(12),

        child: SizedBox(
          height: 58,

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              // ==================================================
              // ICON
              // ==================================================

              AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 200,
                ),

                transitionBuilder:
                    (child, animation) {
                  return ScaleTransition(
                    scale: animation,
                    child: child,
                  );
                },

                child: Icon(
                  selected
                      ? activeIcon
                      : icon,

                  key: ValueKey(
                    '$label-$selected',
                  ),

                  size: selected ? 24 : 22,

                  color: selected
                      ? selectedColor
                      : unselectedColor,
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              // ==================================================
              // LABEL
              // ==================================================

              AnimatedDefaultTextStyle(
                duration: const Duration(
                  milliseconds: 200,
                ),

                style: TextStyle(
                  fontSize: 10,

                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,

                  color: selected
                      ? selectedColor
                      : unselectedColor,
                ),

                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
