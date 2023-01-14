import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart'
    hide ThemeData, Typography, Colors, ButtonThemeData, ButtonStyle;

enum InterfaceBrightness {
  light,
  dark,
  auto,
}

extension InterfaceBrightnessExtension on InterfaceBrightness {
  bool getIsDark(BuildContext? context) {
    if (this == InterfaceBrightness.light) return false;
    if (this == InterfaceBrightness.auto) {
      if (context == null) return true;
      return MediaQuery.of(context).platformBrightness == Brightness.dark;
    }

    return true;
  }

  Color getForegroundColor(BuildContext? context) {
    return getIsDark(context) ? Colors.white : Colors.black;
  }
}

ThemeData colorSchemeToThemeData({required ColorScheme colorScheme}) {
  return ThemeData(
    accentColor: convertColorSchemeToAccentColor(colorScheme),
    activeColor: colorScheme.secondary,
    acrylicBackgroundColor: colorScheme.surface,
    borderInputColor: colorScheme.onSurface,
    brightness: colorScheme.brightness,
    buttonTheme: ButtonThemeData(defaultButtonStyle: ButtonStyle(
      backgroundColor: ButtonState.resolveWith((states) {
        if (states.isDisabled) {
          return colorScheme.background;
        }

        // return colorScheme.background;
      }),
    )),
    checkedColor: colorScheme.primary.withOpacity(.1),
    disabledColor: colorScheme.onSurface.withOpacity(0.38),
    iconTheme: IconThemeData(
      color: colorScheme.onSurface,
    ),
    inactiveColor: colorScheme.onSurface.withOpacity(0.54),
    inactiveBackgroundColor: colorScheme.background,
    scaffoldBackgroundColor: colorScheme.background,
    shadowColor: colorScheme.shadow,
    typography: Typography.fromBrightness(
      brightness: colorScheme.brightness,
      color: colorScheme.onBackground,
    ),
    uncheckedColor: colorScheme.onSurface.withOpacity(0.54),
    focusTheme: FocusThemeData(
      glowFactor: is10footScreen() ? 2.0 : 0.0,
      glowColor: colorScheme.primary,
    ),
    // resources: colorSchemeToResourceDictionary(colorScheme),
  );
}

AccentColor convertColorSchemeToAccentColor(ColorScheme colorScheme) {
  return AccentColor.swatch({
    'normal': colorScheme.primary,
    'dark': colorScheme.primary.withOpacity(0.9),
    'darker': colorScheme.primary.withOpacity(0.8),
    'darkest': colorScheme.primary.withOpacity(0.7),
    'light': colorScheme.primary.withOpacity(0.9),
    'lighter': colorScheme.primary.withOpacity(0.8),
    'lightest': colorScheme.primary.withOpacity(0.7),
  });
}

ResourceDictionary colorSchemeToResourceDictionary(ColorScheme colorScheme) {
  
  return ResourceDictionary.raw(
    textFillColorPrimary: colorScheme.primary,
    textFillColorSecondary: colorScheme.secondary,
    textFillColorTertiary: colorScheme.tertiary,
    textFillColorDisabled: colorScheme.onSurface.withOpacity(0.38),
    textFillColorInverse: colorScheme.onBackground,
    accentTextFillColorDisabled: colorScheme.onPrimary.withOpacity(0.38),
    textOnAccentFillColorSelectedText: colorScheme.onPrimary,
    textOnAccentFillColorPrimary: colorScheme.onPrimary,
    textOnAccentFillColorSecondary: colorScheme.onPrimary.withOpacity(0.7),
    textOnAccentFillColorDisabled: colorScheme.onPrimary.withOpacity(0.38),
    controlFillColorDefault: colorScheme.surface,
    controlFillColorSecondary: colorScheme.onSurface.withOpacity(0.7),
    controlFillColorTertiary: colorScheme.onSurface.withOpacity(0.5),
    controlFillColorDisabled: colorScheme.onSurface.withOpacity(0.38),
    controlFillColorTransparent: Colors.transparent,
    controlFillColorInputActive: colorScheme.primary.withOpacity(0.3),
    controlStrongFillColorDefault: colorScheme.primary,
    controlStrongFillColorDisabled: colorScheme.onPrimary.withOpacity(0.38),
    controlSolidFillColorDefault: colorScheme.surface,
    subtleFillColorTransparent: Colors.transparent,
    subtleFillColorSecondary: colorScheme.onSurface.withOpacity(0.7),
    subtleFillColorTertiary: colorScheme.onSurface.withOpacity(0.5),
    subtleFillColorDisabled: colorScheme.onSurface.withOpacity(0.38),
    controlAltFillColorTransparent: Colors.transparent,
    controlAltFillColorSecondary: colorScheme.onSurface.withOpacity(0.7),
    controlAltFillColorTertiary: colorScheme.onSurface.withOpacity(0.5),
    controlAltFillColorQuarternary: colorScheme.onSurface.withOpacity(0.3),
    controlAltFillColorDisabled: colorScheme.onSurface.withOpacity(0.38),
    controlOnImageFillColorDefault: colorScheme.surface,
    controlOnImageFillColorSecondary: colorScheme.onSurface.withOpacity(0.7),
    controlOnImageFillColorTertiary: colorScheme.onSurface.withOpacity(0.5),
    controlOnImageFillColorDisabled: colorScheme.onSurface.withOpacity(0.38),
    accentFillColorDisabled: colorScheme.background,
    controlStrokeColorDefault: colorScheme.onSurface.withOpacity(0.12),
    controlStrokeColorSecondary: colorScheme.onSurface.withOpacity(0.12),
    controlStrokeColorOnAccentDefault: colorScheme.onPrimary.withOpacity(0.12),
    controlStrokeColorOnAccentSecondary:
        colorScheme.onPrimary.withOpacity(0.12),
    controlStrokeColorOnAccentTertiary: colorScheme.onPrimary.withOpacity(0.12),
    controlStrokeColorOnAccentDisabled: colorScheme.onPrimary.withOpacity(0.38),
    controlStrokeColorForStrongFillWhenOnImage:
        colorScheme.onPrimary.withOpacity(0.12),
    cardStrokeColorDefault: colorScheme.onSurface.withOpacity(0.12),
    cardStrokeColorDefaultSolid: colorScheme.onSurface,
    controlStrongStrokeColorDefault: colorScheme.primary.withOpacity(0.12),
    controlStrongStrokeColorDisabled: colorScheme.onPrimary.withOpacity(0.38),
    surfaceStrokeColorDefault: colorScheme.onSurface.withOpacity(0.12),
    surfaceStrokeColorFlyout: colorScheme.onSurface.withOpacity(0.12),
    surfaceStrokeColorInverse: colorScheme.onBackground.withOpacity(0.12),
    dividerStrokeColorDefault: colorScheme.onSurface.withOpacity(0.12),
    focusStrokeColorOuter: colorScheme.primary.withOpacity(0.12),
    focusStrokeColorInner: colorScheme.primary.withOpacity(0.12),
    cardBackgroundFillColorDefault: colorScheme.surface,
    cardBackgroundFillColorSecondary: colorScheme.onSurface.withOpacity(0.7),
    smokeFillColorDefault: colorScheme.onSurface.withOpacity(0.04),
    layerFillColorDefault: colorScheme.surface,
    layerFillColorAlt: colorScheme.surface.withOpacity(0.7),
    layerOnAcrylicFillColorDefault: colorScheme.surface,
    layerOnAccentAcrylicFillColorDefault: colorScheme.surface,
    layerOnMicaBaseAltFillColorDefault: colorScheme.surface,
    layerOnMicaBaseAltFillColorSecondary:
        colorScheme.onSurface.withOpacity(0.7),
    layerOnMicaBaseAltFillColorTertiary: colorScheme.onSurface.withOpacity(0.5),
    layerOnMicaBaseAltFillColorTransparent: Colors.transparent,
    solidBackgroundFillColorBase: colorScheme.surface,
    solidBackgroundFillColorSecondary: colorScheme.onSurface.withOpacity(0.7),
    solidBackgroundFillColorTertiary: colorScheme.onSurface.withOpacity(0.5),
    solidBackgroundFillColorQuarternary: colorScheme.onSurface.withOpacity(0.3),
    solidBackgroundFillColorTransparent: Colors.transparent,
    solidBackgroundFillColorBaseAlt: colorScheme.surface,
    systemFillColorSuccess: colorScheme.primary,
    systemFillColorCaution: colorScheme.secondary,
    systemFillColorCritical: colorScheme.error,
    systemFillColorNeutral: colorScheme.onSurface.withOpacity(0.7),
    systemFillColorSolidNeutral: colorScheme.onSurface,
    systemFillColorAttentionBackground: colorScheme.onSurface.withOpacity(0.04),
    systemFillColorSuccessBackground: colorScheme.onPrimary.withOpacity(0.04),
    systemFillColorCautionBackground: colorScheme.onSecondary.withOpacity(0.04),
    systemFillColorCriticalBackground: colorScheme.onError.withOpacity(0.04),
    systemFillColorNeutralBackground: colorScheme.onSurface.withOpacity(0.04),
    systemFillColorSolidAttentionBackground: colorScheme.onSurface,
    systemFillColorSolidNeutralBackground: colorScheme.onSurface,
  );
}
