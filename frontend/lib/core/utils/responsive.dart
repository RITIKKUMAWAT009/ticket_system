import 'package:flutter/material.dart';

class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isDesktop(context)) return 800;
    if (isTablet(context)) return 600;
    return width;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
    return const EdgeInsets.all(16);
  }
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: Responsive.contentWidth(context)),
        child: child,
      ),
    );
  }
}
