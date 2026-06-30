import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';

class AppDatePicker extends StatelessWidget {
  final String? label;
  final String hint;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final IconData prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDatePicker({
    super.key,
    this.label,
    required this.hint,
    required this.selectedDate,
    required this.onDateSelected,
    this.prefixIcon = Icons.calendar_today_rounded,
    this.firstDate,
    this.lastDate,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.tealPrimary,
              onPrimary: Colors.white,
              surface: AppColors.bgDark,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(
      text: selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!.toLocal()) : '',
    );

    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: AppTextField(
          label: label,
          hint: hint,
          controller: controller,
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }
}
