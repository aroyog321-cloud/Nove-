import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/tokens.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardPage> _pages = const [
    _OnboardPage(
      icon: Icons.edit_note_rounded,
      iconColor: NoveColors.terracotta,
      iconBg: Color(0xFFFAECE7),
      title: 'Write freely.\nOwn your thoughts.',
      subtitle:
          'Everything you write stays on your device. No cloud, no tracking — just you and your ideas.',
    ),
    _OnboardPage(
      icon: Icons.light_mode_rounded,
      iconColor: Color(0xFFBA7517),
      iconBg: Color(0xFFFAEEDA),
      title: 'Capture any thought\ninstantly.',
      subtitle:
          'The floating companion lets you drop a thought without leaving any app — always ready, always close.',
    ),
    _OnboardPage(
      icon: Icons.dashboard_rounded,
      iconColor: Color(0xFF0F6E56),
      iconBg: Color(0xFFE1F5EE),
      title: 'Brainstorm visually\non the board.',
      subtitle:
          'Sticky notes, color-coded ideas, and a canvas built for thinking out loud.',
    ),
  ];

  void _next() {
    HapticFeedback.lightImpact();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: NoveAnimation.normal,
        curve: Curves.easeInOut,
      );
    } else {
      widget.onDone();
    }
  }

  void _skip() {
    HapticFeedback.lightImpact();
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoveColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 24, 0),
                child: GestureDetector(
                  onTap: _skip,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: NoveColors.warmGray500,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentPage = i);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _OnboardPageView(page: _pages[index]);
                },
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (i) {
                return AnimatedContainer(
                  duration: NoveAnimation.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? NoveColors.terracotta
                        : NoveColors.warmGray300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // CTA button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: GestureDetector(
                onTap: _next,
                child: AnimatedContainer(
                  duration: NoveAnimation.fast,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: NoveColors.terracotta,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: NoveColors.terracotta.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage == _pages.length - 1
                            ? 'Get started'
                            : 'Next',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardPageView extends StatelessWidget {
  final _OnboardPage page;
  const _OnboardPageView({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: page.iconBg,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(page.icon, color: page.iconColor, size: 48),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: NoveColors.warmGray900,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            page.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: NoveColors.warmGray600,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardPage {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });
}