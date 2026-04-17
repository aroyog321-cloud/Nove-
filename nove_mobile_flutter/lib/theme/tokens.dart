import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// NOVE Mobile Design Tokens
/// Premium, analogue-inspired design system
class NoveColors {
  // Primary Brand Colors
  static const Color terracotta = Color(0xFFC0452A);
  static const Color terracottaLight = Color(0xFFD65A3E);
  static const Color terracottaDark = Color(0xFF9A3720);

  // Accent Colors
  static const Color amber = Color(0xFFF5C842);
  static const Color amberLight = Color(0xFFF9D567);
  static const Color amberDark = Color(0xFFD4A820);

  // Base Light Theme
  static const Color cream = Color(0xFFF5F2EC);
  static const Color creamLight = Color(0xFFF9F6F2);
  static const Color warmWhite = Color(0xFFFEFCF8);

  // Warm Gray Scale
  static const Color warmGray50 = Color(0xFFFBFAF8);
  static const Color warmGray100 = Color(0xFFF3EBE0);
  static const Color warmGray200 = Color(0xFFEBE5D9);
  static const Color warmGray300 = Color(0xFFD4C9B8);
  static const Color warmGray400 = Color(0xFFA39C93);
  static const Color warmGray500 = Color(0xFF8C8273);
  static const Color warmGray600 = Color(0xFF72685E);
  static const Color warmGray700 = Color(0xFF5C5449);
  static const Color warmGray800 = Color(0xFF3D3630);
  static const Color warmGray900 = Color(0xFF242018);

  // Base Dark Theme
  static const Color deepDark = Color(0xFF1A1714);
  static const Color cardDark = Color(0xFF242018);
  static const Color cardDarkLight = Color(0xFF2F2A22);

  // Sticky Note Colors
  static const Color stickyYellow = Color(0xFFF5C842);
  static const Color stickyYellowLight = Color(0xFFF9D567);
  static const Color stickyPink = Color(0xFFF2C2D8);
  static const Color stickyPinkLight = Color(0xFFF7D5E5);
  static const Color stickyGreen = Color(0xFFB8E0B2);
  static const Color stickyGreenLight = Color(0xFFC9EAC5);
  static const Color stickyBlue = Color(0xFFB2CEFF);
  static const Color stickyBlueLight = Color(0xFFC7DCFF);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Overlay
  static const Color overlay = Color(0x801A1714); // 50% opacity
  static const Color overlayLight = Color(0x4D1A1714); // 30% opacity
}

/// Border radius values
class NoveRadii {
  static const double none = 0;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 9999;
}

/// Spacing values
class NoveSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double xxxx = 48;
}

/// Typography values
class NoveTypography {
  // Font Families
  static TextStyle lora({TextStyle? style}) => GoogleFonts.lora(textStyle: style);
  static TextStyle dmsans({TextStyle? style}) => GoogleFonts.dmSans(textStyle: style);
  static TextStyle caveat({TextStyle? style}) => GoogleFonts.caveat(textStyle: style);

  // Font Sizes
  static const double fontSizeXs = 11;
  static const double fontSizeSm = 13;
  static const double fontSizeMd = 15;
  static const double fontSizeLg = 18;
  static const double fontSizeXl = 22;
  static const double fontSizeXxl = 28;
  static const double fontSizeXxxl = 36;
  static const double fontSizeXxxx = 48;

  // Font Weights
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;
  static const double lineHeightLoose = 2.0;

  // Letter Spacing
  static const double letterSpacingTighter = -0.5;
  static const double letterSpacingTight = 0;
  static const double letterSpacingNormal = 0.5;
  static const double letterSpacingWide = 1;
  static const double letterSpacingWider = 2;
  static const double letterSpacingWidest = 4;
}

/// Animation durations
class NoveAnimation {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration slower = Duration(milliseconds: 500);
  static const Duration entrance = Duration(milliseconds: 600);
}

/// Shadow styles
class NoveShadows {
  static List<BoxShadow> get none => const [
    BoxShadow(color: Colors.transparent, offset: Offset(0, 0), blurRadius: 0),
  ];

  static List<BoxShadow> get xs => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.02),
      offset: const Offset(0, 1),
      blurRadius: 2,
    ),
  ];

  static List<BoxShadow> get sm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.03),
      offset: const Offset(0, 1),
      blurRadius: 4,
    ),
  ];

  static List<BoxShadow> get md => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      offset: const Offset(0, 2),
      blurRadius: 8,
    ),
  ];

  static List<BoxShadow> get lg => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];

  static List<BoxShadow> get xl => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      offset: const Offset(0, 8),
      blurRadius: 20,
    ),
  ];

  static List<BoxShadow> get floating => [
    BoxShadow(
      color: NoveColors.terracotta.withValues(alpha: 0.3),
      offset: const Offset(0, 4),
      blurRadius: 12,
    ),
  ];
}
