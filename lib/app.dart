import 'package:flutter/material.dart';

import 'core/routes.dart';
import 'core/theme/app_theme.dart';

class TutomatoApp extends StatelessWidget {
  const TutomatoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tutomato',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Start on the welcome screen. To skip it while testing, use AppRoutes.shell.
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.table,
    );
  }
}
