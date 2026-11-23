import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'page_width.dart';

/// A full screen with a back (or close) button, a title, and a scrolling body.
class AppPage extends StatelessWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBack;
  final bool close; // show an X instead of the back arrow
  final VoidCallback? onBack;
  final double maxWidth;
  final List<Widget> children;

  const AppPage({
    super.key,
    this.title,
    this.titleWidget,
    this.showBack = true,
    this.close = false,
    this.onBack,
    this.maxWidth = 600,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final hasHeader = title != null || titleWidget != null || showBack;
    return PageWidth(
      maxWidth: maxWidth,
      child: Scaffold(
        backgroundColor: AppColors.cream,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              if (hasHeader)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      if (showBack)
                        IconButton(
                          onPressed:
                          onBack ?? () => Navigator.maybePop(context),
                          icon: Icon(close ? Icons.close : Icons.arrow_back),
                          color: AppColors.brown,
                          iconSize: 28,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child:
                        titleWidget ??
                            Text(
                              title ?? '',
                              style: AppText.h2.copyWith(fontSize: 28),
                            ),
                      ),
                    ],
                  ),
                ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

/// The small centred line at the bottom of many screens.
class FooterNote extends StatelessWidget {
  final String text;
  const FooterNote(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28, bottom: 4),
    child: Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.brownSoft,
        ),
      ),
    ),
  );
}

/// The centred "Tutomato" wordmark used in the login and sign-up header.
class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(
        child: Center(
          child: Text(
            'Tutomato',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.tomato,
            ),
          ),
        ),
      ),
      SizedBox(width: 48),
    ],
  );
}
