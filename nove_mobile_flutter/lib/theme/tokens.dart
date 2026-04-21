import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// NOVE Mobile Design Tokens
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

  // Base Dark Theme — fully active
  static const Color deepDark = Color(0xFF1A1714);
  static const Color cardDark = Color(0xFF242018);
  static const Color cardDarkLight = Color(0xFF2F2A22);
  static const Color darkBorder = Color(0xFF3D3630);

  // Sticky Note Colors
  static const Color stickyYellow = Color(0xFFF5C842);
  static const Color stickyPink = Color(0xFFF2C2D8);
  static const Color stickyGreen = Color(0xFFC5EDBE);
  static const Color stickyBlue = Color(0xFFB3E5FC);

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Helper: get background for dark vs light
  static Color bg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? deepDark : cream;

  static Color cardBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : warmWhite;

  static Color cardBorder(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorder : warmGray200;

  static Color primaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cream : warmGray900;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? warmGray500 : warmGray600;

  static Color mutedText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? warmGray700 : warmGray400;

  static Color inputBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? cardDark : warmGray200;

  static Color accent(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? terracottaLight : terracotta;
}

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

class NoveTypography {
  static TextStyle lora({TextStyle? style}) => GoogleFonts.lora(textStyle: style);
  static TextStyle dmsans({TextStyle? style}) => GoogleFonts.dmSans(textStyle: style);
  static TextStyle caveat({TextStyle? style}) => GoogleFonts.caveat(textStyle: style);

  static const double fontSizeXs = 11;
  static const double fontSizeSm = 13;
  static const double fontSizeMd = 15;
  static const double fontSizeLg = 18;
  static const double fontSizeXl = 22;
  static const double fontSizeXxl = 28;
  static const double fontSizeXxxl = 36;

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const double lineHeightNormal = 1.5;
  static const double lineHeightRelaxed = 1.75;

  static const double letterSpacingWide = 1;
  static const double letterSpacingWider = 2;
}

class NoveAnimation {
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration entrance = Duration(milliseconds: 600);
}

class NoveShadows {
  static List<BoxShadow> cardLight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? []
        : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ];
  }

  static List<BoxShadow> get floating => [
        BoxShadow(
          color: NoveColors.terracotta.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 12,
        ),
      ];
}