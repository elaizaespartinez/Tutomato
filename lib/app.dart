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
      initialRoute: AppRoutes.shell, // later: welcome if not logged in
      routes: AppRoutes.table,
    );
  }
}