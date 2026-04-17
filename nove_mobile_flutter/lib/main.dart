import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/sticky_board_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/tokens.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: NoveApp()));
}

class NoveApp extends StatelessWidget {
  const NoveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NOVE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: NoveColors.cream,
        colorScheme: ColorScheme.fromSeed(
          seedColor: NoveColors.terracotta,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.dmSansTextTheme().copyWith(
          displayLarge: GoogleFonts.lora(),
          displayMedium: GoogleFonts.lora(),
          displaySmall: GoogleFonts.lora(),
          headlineLarge: GoogleFonts.lora(),
          headlineMedium: GoogleFonts.lora(),
          headlineSmall: GoogleFonts.lora(),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: NoveColors.cream,
          elevation: 0,
          centerTitle: false,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: NoveColors.terracotta,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: NoveColors.warmWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(NoveRadii.lg),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const NoveShell(),
    );
  }
}

class NoveShell extends StatefulWidget {
  const NoveShell({super.key});

  @override
  State<NoveShell> createState() => _NoveShellState();
}

class _NoveShellState extends State<NoveShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    StickyBoardScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _NoveTabBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

// ─── Custom Tab Bar ───────────────────────────────────────────────────────────
class _NoveTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NoveTabBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final items = [
      _TabItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: 'Notes'),
      _TabItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Board'),
      _TabItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCF9F3),
        border: Border(top: BorderSide(color: NoveColors.warmGray200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = currentIndex == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: isActive ? NoveColors.terracotta : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? Colors.white : NoveColors.warmGray500,
                          size: 20,
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 6),
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontFamily: 'DMSans',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({required this.icon, required this.activeIcon, required this.label});
}
