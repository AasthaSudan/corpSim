import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  static double getResponsivePadding(BuildContext context) {
    if (isMobile(context)) return 16.0;
    if (isTablet(context)) return 32.0;
    return 48.0;
  }

  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    if (isMobile(context)) return baseFontSize;
    if (isTablet(context)) return baseFontSize * 1.1;
    return baseFontSize * 1.2;
  }

  static double getCardWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width - 32;
    if (isTablet(context)) return width * 0.45;
    return 400;
  }

  static double getDialogWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) return width * 0.9;
    if (isTablet(context)) return 500;
    return 600;
  }

  static double getMaxContentWidth(BuildContext context) {
    return isDesktop(context) ? 1400 : double.infinity;
  }

  static EdgeInsets getResponsiveMargin(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32);
    } else {
      final width = MediaQuery.of(context).size.width;
      final margin = (width - getMaxContentWidth(context)) / 2;
      return EdgeInsets.symmetric(horizontal: margin.clamp(48, 200));
    }
  }

  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static double getSafeBottomPadding(BuildContext context) =>
      MediaQuery.of(context).padding.bottom;

  static double getSafeTopPadding(BuildContext context) =>
      MediaQuery.of(context).padding.top;
}

extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);

  double get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  int get gridColumns => ResponsiveHelper.getGridColumns(this);
  double get maxContentWidth => ResponsiveHelper.getMaxContentWidth(this);
  EdgeInsets get responsiveMargin => ResponsiveHelper.getResponsiveMargin(this);
}