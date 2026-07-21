import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String hint;
  final IconData prefixIcon;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines;
  final bool readOnly;
  final void Function(String)? onChanged;
  final FormFieldValidator<String>? validator;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode? autovalidateMode;

  const AppTextField({
    super.key,
    this.label,
    required this.hint,
    required this.controller,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
    this.readOnly = false,
    this.onChanged,
    this.validator,
    this.errorText,
    this.inputFormatters,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          readOnly: readOnly,
          onChanged: onChanged,
          validator: validator,
          inputFormatters: inputFormatters,
          autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: AppColors.textHint),
            prefixIcon: Icon(prefixIcon, size: 18, color: AppColors.iconMuted),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: AppColors.inputFill,
            errorText: errorText,
            errorStyle: const TextStyle(fontSize: 11, color: AppColors.red, height: 1.2),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderSide, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.tealPrimary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
