import 'package:flutter/material.dart';

import '../theme/app_text.dart';
import '../utils/responsive.dart';
import 'profile_button.dart';

/// The layout used by the Pomodori, Records and Friends tabs.
///
/// On phones and tablets everything is one column: [children] first, then
/// [sideChildren]. On a wide laptop window they sit side by side.
class TabPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children; // main (left) column
  final List<Widget> sideChildren; // right column on wide screens

  const TabPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.sideChildren = const [],
  });

  @override
  Widget build(BuildContext context) {
    final desktop = Responsive.isDesktop(context);
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            desktop ? 40 : 20,
            desktop ? 36 : 16,
            desktop ? 40 : 20,
            28,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppText.h1.copyWith(fontSize: desktop ? 40 : 32),
                  ),
                ),
                if (!desktop) const ProfileButton(),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, style: AppText.body.copyWith(fontSize: 17)),
            ],
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, c) {
                final twoColumns = sideChildren.isNotEmpty && c.maxWidth >= 720;
                if (!twoColumns) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [...children, ...sideChildren],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: children,
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: sideChildren,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
