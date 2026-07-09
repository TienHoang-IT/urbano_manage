import 'package:flutter/material.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';

class AppLoadingShimmer extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AppLoadingShimmer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  /// Helper to build a standard list item placeholder.
  static Widget listPlaceholder({int count = 5}) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.nenContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderButton),
            ),
            child: Row(
              children: [
                const AppLoadingShimmer(width: 44, height: 44, borderRadius: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppLoadingShimmer(width: double.infinity * 0.7, height: 16),
                      const SizedBox(height: 8),
                      const AppLoadingShimmer(width: 100, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  State<AppLoadingShimmer> createState() => _AppLoadingShimmerState();
}

class _AppLoadingShimmerState extends State<AppLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.15 + (_controller.value * 0.25),
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}
