import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

// Styles typographiques de docs/DESIGN.md. Les polices embarquées sont
// variables : la graisse et la taille optique passent par FontVariation, en
// plus de fontWeight pour l’accessibilité (texte en gras iOS).

const _serif = 'Newsreader';
const _sans = 'Inter Tight';

/// Opacité des textes atténués lorsqu’un contraste de 3:1 suffit (grand texte,
/// contour de contrôle). Les opacités source (45 %, 40 %) étaient trop faibles.
const quietAlpha = .8;

TextStyle _serifStyle(
  double size, {
  double? height,
  double letterSpacing = 0,
  Color color = foreground,
  bool italic = false,
}) => TextStyle(
  fontFamily: _serif,
  fontSize: size,
  height: height,
  letterSpacing: letterSpacing,
  color: color,
  fontWeight: FontWeight.w400,
  fontStyle: italic ? FontStyle.italic : FontStyle.normal,
  fontVariations: [
    const FontVariation('wght', 400),
    FontVariation('opsz', size.clamp(6, 72).toDouble()),
  ],
);

TextStyle _sansStyle(
  double size, {
  int weight = 400,
  double? height,
  double letterSpacing = 0,
  Color color = foreground,
  bool tabular = false,
}) => TextStyle(
  fontFamily: _sans,
  fontSize: size,
  height: height,
  letterSpacing: letterSpacing,
  color: color,
  fontWeight: FontWeight.values[weight ~/ 100 - 1],
  fontVariations: [FontVariation('wght', weight.toDouble())],
  fontFeatures: tabular ? const [FontFeature.tabularFigures()] : null,
);

abstract final class AppText {
  static final logotype = _serifStyle(
    18,
    height: 28 / 18,
    color: mutedForeground,
    italic: true,
  );
  static final badge = _sansStyle(
    11,
    weight: 600,
    height: 1,
    color: primaryForeground,
    tabular: true,
  );
  static final eyebrow = _sansStyle(
    13,
    weight: 500,
    height: 18 / 13,
    letterSpacing: 13 * .025,
    color: mutedForeground,
  );
  static final captureInput = _serifStyle(30, height: 1.2, letterSpacing: -.3);
  static final capturePlaceholder = captureInput.copyWith(
    color: mutedForeground.withValues(alpha: quietAlpha),
  );
  static final help = _sansStyle(14, height: 20 / 14, color: mutedForeground);
  static final button = _sansStyle(15, weight: 600);
  static final footer = _sansStyle(12, height: 16 / 12, color: mutedForeground);
  static final back = _sansStyle(16, weight: 500, color: primary);
  static final inboxTitle = _serifStyle(38, height: 1, letterSpacing: -.76);
  static final pendingCount = _sansStyle(
    14,
    height: 20 / 14,
    color: mutedForeground,
    tabular: true,
  );
  static final thought = _serifStyle(18, height: 1.375);
  static final date = _sansStyle(12, height: 16 / 12, color: mutedForeground);
  static final emptyTitle = _serifStyle(26, height: 1.25);
  static final emptyBody = _sansStyle(
    15,
    height: 20 / 15,
    color: mutedForeground,
  );
  static final emptyButton = _sansStyle(
    15,
    weight: 500,
    color: secondaryForeground,
  );
  static final toast = _sansStyle(15, height: 20 / 15, color: background);
  static final toastAction = _sansStyle(15, weight: 600, color: primarySoft);
  static final sheetPreview = _serifStyle(15, color: mutedForeground);
  static final sheetAction = _sansStyle(17);
  static final sheetClose = _sansStyle(17, weight: 600);
}

/// Thème unique, clair, appliqué même lorsque l’iPhone est en mode sombre.
ThemeData buildAppTheme() {
  final colorScheme = const ColorScheme.light(
    primary: primary,
    onPrimary: primaryForeground,
    secondary: secondary,
    onSecondary: secondaryForeground,
    surface: card,
    onSurface: foreground,
    onSurfaceVariant: mutedForeground,
    outline: border,
    outlineVariant: border,
    error: destructive,
    onError: primaryForeground,
  );
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: background,
    fontFamily: _sans,
    splashFactory: NoSplash.splashFactory,
    highlightColor: secondary,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary.withValues(alpha: .25),
      selectionHandleColor: primary,
    ),
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: primary,
    ),
    inputDecorationTheme: const InputDecorationTheme(border: InputBorder.none),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: foreground,
      contentTextStyle: AppText.toast,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}

/// Ombre légère des cartes (intention de la source CSS, approximée).
const cardShadow = [
  BoxShadow(color: Color(0x0A1A1511), offset: Offset(0, 1), blurRadius: 2),
  BoxShadow(
    color: Color(0x1A1A1511),
    offset: Offset(0, 8),
    blurRadius: 24,
    spreadRadius: -12,
  ),
];
