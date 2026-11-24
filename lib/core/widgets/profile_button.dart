import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme/app_colors.dart';

class ProfileButton extends StatelessWidget {
  const ProfileButton({super.key});

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.peach,
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Icon(Icons.person_outline, color: AppColors.brown),
      ),
    ),
  );
}