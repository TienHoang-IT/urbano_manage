import 'package:flutter/material.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';

class AppDropdownField<T> extends StatelessWidget {
  final String? label;
  final T? value;
  final String hint;
  final IconData? prefixIcon;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const AppDropdownField({
    super.key,
    this.label,
    required this.value,
    required this.hint,
    this.prefixIcon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.inputFill,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSide, width: 1.5),
          ),
          child: Row(
            children: [
              if (prefixIcon != null) ...[
                Icon(prefixIcon, size: 18, color: AppColors.iconMuted),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<T>(
                    value: value,
                    hint: Text(
                      hint,
                      style: const TextStyle(color: AppColors.textHint, fontSize: 13),
                    ),
                    dropdownColor: AppColors.bgMid,
                    icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.iconMuted),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    isExpanded: true,
                    onChanged: onChanged,
                    items: items,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
