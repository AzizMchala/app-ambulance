import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Thème global unique de l'application commune. Les modules E1 à E6 le partagent :
/// ils lisent [AppColors] via `context.colors` et n'en créent jamais un second.
ThemeData buildAppTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? AppColors.dark : AppColors.light;
  final text = buildAppTextTheme(ink: c.ink, muted: c.inkMuted);
  final scheme = ColorScheme.fromSeed(
    seedColor: c.action,
    brightness: brightness,
    primary: c.action,
    onPrimary: c.onAction,
    surface: c.surface,
    onSurface: c.ink,
    error: c.danger,
    onError: c.onDanger,
    outline: c.line,
  );

  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.md),
    borderSide: BorderSide(color: color, width: width),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: c.canvas,
    textTheme: text,
    fontFamily: text.bodyLarge!.fontFamily,
    extensions: [c],
    splashFactory: InkSparkle.splashFactory,
    dividerTheme: DividerThemeData(color: c.line, thickness: 1, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: c.canvas,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      foregroundColor: c.ink,
      titleTextStyle: text.titleLarge,
      systemOverlayStyle: brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: c.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x4),
      hintStyle: text.bodyLarge!.copyWith(color: c.inkMuted),
      labelStyle: text.bodyMedium,
      floatingLabelStyle: text.bodyMedium!.copyWith(color: c.action),
      errorStyle: text.bodySmall!.copyWith(color: c.onDangerTint),
      border: border(c.line),
      enabledBorder: border(c.line),
      focusedBorder: border(c.action, 1.5),
      errorBorder: border(c.danger),
      focusedErrorBorder: border(c.danger, 1.5),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
      titleTextStyle: text.headlineSmall,
      contentTextStyle: text.bodyMedium,
      barrierColor: c.scrim,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: c.scrim,
      showDragHandle: true,
      dragHandleColor: c.line,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.hero))),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: c.ink,
      contentTextStyle: text.bodyMedium!.copyWith(color: c.canvas),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      insetPadding: const EdgeInsets.all(AppSpace.x4),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: c.action, linearTrackColor: c.surfaceSunken),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: c.action,
      selectionColor: c.action.withValues(alpha: 0.2),
      selectionHandleColor: c.action,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
