import 'package:flutter/material.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';

class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = 'Hủy',
    this.confirmText = 'Xác nhận',
    this.confirmColor = AppColors.red,
  });

  /// Static helper to display the confirm dialog.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = 'Hủy',
    String confirmText = 'Xác nhận',
    Color confirmColor = AppColors.red,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppConfirmDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgMid,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderButton),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      content: Text(content, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: confirmColor,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ],
    );
  }
}
