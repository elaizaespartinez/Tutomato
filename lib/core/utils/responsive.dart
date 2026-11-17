import 'package:flutter/widgets.dart';

enum ScreenSize { phone, tablet, desktop }

class Responsive {
  static const double tabletMin = 600;
  static const double desktopMin = 1024;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= desktopMin) return ScreenSize.desktop;
    if (width >= tabletMin) return ScreenSize.tablet;
    return ScreenSize.phone;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktopMin;
}