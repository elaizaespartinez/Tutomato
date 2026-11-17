import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

OutlineInputBorder _border(Color color, [double width = 1]) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(28),
      borderSide: BorderSide(color: color, width: width),
    );

Widget _label(String? label, bool bold) {
  if (label == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: bold ? AppText.title : AppText.body),
  );
}

/// A rounded text field with an optional icon, label, and show/hide password.
class AppTextField extends StatefulWidget {
  final String? label;
  final String hint;
  final IconData? icon;
  final bool password;
  final bool boldLabel;
  final TextEditingController? controller;
  final String? helper;
  final String? error;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    this.label,
    required this.hint,
    this.icon,
    this.password = false,
    this.boldLabel = true,
    this.controller,
    this.helper,
    this.error,
    this.keyboardType,
    this.onChanged,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(widget.label, widget.boldLabel),
        TextField(
          controller: widget.controller,
          obscureText: widget.password && _hidden,
          keyboardType: widget.keyboardType,
          onChanged: widget.onChanged,
          style: const TextStyle(fontSize: 17, color: AppColors.brown),
          cursorColor: AppColors.tomato,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AppColors.brownSoft.withValues(alpha: 0.7),
            ),
            errorText: widget.error,
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            prefixIcon: widget.icon == null
                ? null
                : Icon(widget.icon, color: AppColors.brownSoft),
            suffixIcon: widget.password
                ? IconButton(
              icon: Icon(
                _hidden
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.brownSoft,
              ),
              onPressed: () => setState(() => _hidden = !_hidden),
            )
                : null,
            border: _border(AppColors.border),
            enabledBorder: _border(AppColors.border),
            focusedBorder: _border(AppColors.tomato, 2),
            errorBorder: _border(AppColors.tomato),
            focusedErrorBorder: _border(AppColors.tomato, 2),
          ),
        ),
        if (widget.helper != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(widget.helper!, style: AppText.small),
          ),
      ],
    );
  }
}

/// A rounded dropdown that matches the text fields.
class AppDropdown<T> extends StatelessWidget {
  final String? label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final bool boldLabel;

  const AppDropdown({
    super.key,
    this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.boldLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, boldLabel),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              items: items,
              onChanged: onChanged,
              isExpanded: true,
              borderRadius: BorderRadius.circular(20),
              dropdownColor: AppColors.card,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.brown,
              ),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.brown,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Looks like a dropdown but runs your own code when tapped (e.g. a date picker).
class AppPickerField extends StatelessWidget {
  final String? label;
  final String text;
  final VoidCallback onTap;

  const AppPickerField({
    super.key,
    this.label,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
      side: const BorderSide(color: AppColors.border),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, false),
        Material(
          color: AppColors.card,
          shape: shape,
          child: InkWell(
            customBorder: shape,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.brown,
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down, color: AppColors.brown),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
