import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppDesignSystem {
  AppDesignSystem._();

  static const double maxContentWidth = 420;

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;
  static const double huge = 32;
  // ─────────────────────────────────────────────
// APP SCREEN DESIGN
// ─────────────────────────────────────────────

static const EdgeInsets appPagePadding = EdgeInsets.symmetric(
  horizontal: 15,
  vertical: 16,
);

static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
  horizontal: 15,
);

static const double bottomNavHeight = 62;

static const BorderRadius appCardRadius = BorderRadius.all(
  Radius.circular(18),
);

static const BorderRadius searchRadius = BorderRadius.all(
  Radius.circular(14),
);

static const BorderRadius actionRadius = BorderRadius.all(
  Radius.circular(20),
);

// Avatar sizes
static const double avatarSmall = 38;
static const double avatarMedium = 42;
static const double avatarLarge = 92;

// Common icon containers
static const double iconButtonSize = 34;
static const double callButtonSize = 48;

// List item heights
static const double contactItemHeight = 68;
static const double historyItemHeight = 74;

// Bottom navigation
static const double bottomNavIconSize = 22;
static const double bottomNavLabelSize = 9;

// Search field
static const EdgeInsets searchPadding = EdgeInsets.symmetric(
  horizontal: 18,
  vertical: 14,
);

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: 22,
    vertical: 18,
  );

  static const EdgeInsets panelPadding = EdgeInsets.all(22);
  static const EdgeInsets fieldPadding = EdgeInsets.symmetric(
    horizontal: 18,
    vertical: 18,
  );

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(30));
  static const BorderRadius mediumRadius = BorderRadius.all(
    Radius.circular(18),
  );
  static const BorderRadius smallRadius = BorderRadius.all(Radius.circular(12));

  static const BoxShadow cardShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 24,
    offset: Offset(0, 18),
  );

  static const BoxShadow softShadow = BoxShadow(
    color: AppColors.shadow,
    blurRadius: 18,
    offset: Offset(0, 10),
  );

  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.background, Color(0xFFF8FBFF)],
  );

  static final BoxDecoration authCardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: cardRadius,
    border: Border.all(color: AppColors.cardBorder, width: 1),
    boxShadow: const [cardShadow],
  );

  static final BoxDecoration inputDecoration = BoxDecoration(
    color: AppColors.fieldBackground,
    borderRadius: mediumRadius,
    border: Border.all(color: AppColors.fieldBorder, width: 1.2),
  );

  static OutlineInputBorder inputBorder({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: mediumRadius,
      borderSide: BorderSide(
        color: focused ? AppColors.primary : AppColors.fieldBorder,
        width: focused ? 1.6 : 1.2,
      ),
    );
  }

  static BoxDecoration createScreenBackground() {
    return const BoxDecoration(gradient: appGradient);
  }

  static Widget buildCenteredCard({
    required Widget child,
    EdgeInsetsGeometry padding = panelPadding,
    double maxWidth = maxContentWidth,
  }) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: padding,
          decoration: authCardDecoration,
          child: child,
        ),
      ),
    );
  }
}
