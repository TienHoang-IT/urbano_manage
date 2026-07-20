import 'package:flutter/material.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';

class AppSearchablePicker<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final String Function(T) itemAsString;
  final bool Function(T, String)? searchFn;
  final void Function(T) onChanged;
  final bool isLoading;

  const AppSearchablePicker({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    required this.itemAsString,
    this.searchFn,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  State<AppSearchablePicker<T>> createState() => _AppSearchablePickerState<T>();
}

class _AppSearchablePickerState<T> extends State<AppSearchablePicker<T>> {
  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _SearchDialog<T>(
          items: widget.items,
          itemAsString: widget.itemAsString,
          searchFn: widget.searchFn,
          isLoading: widget.isLoading,
        );
      },
    ).then((selectedValue) {
      if (selectedValue != null) {
        widget.onChanged(selectedValue as T);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String displayString = widget.value != null ? widget.itemAsString(widget.value as T) : '';

    return GestureDetector(
      onTap: () => _showSearchDialog(context),
      child: AbsorbPointer(
        child: AppTextField(
          label: widget.label,
          hint: widget.hint,
          controller: TextEditingController(text: displayString),
          prefixIcon: widget.prefixIcon,
        ),
      ),
    );
  }
}

class _SearchDialog<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemAsString;
  final bool Function(T, String)? searchFn;
  final bool isLoading;

  const _SearchDialog({
    required this.items,
    required this.itemAsString,
    this.searchFn,
    this.isLoading = false,
  });

  @override
  State<_SearchDialog<T>> createState() => _SearchDialogState<T>();
}

class _SearchDialogState<T> extends State<_SearchDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredItems = widget.items;
      });
      return;
    }

    setState(() {
      _filteredItems = widget.items.where((item) {
        if (widget.searchFn != null) {
          return widget.searchFn!(item, query);
        }
        return widget.itemAsString(item).toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.borderButton),
      ),
      contentPadding: const EdgeInsets.all(16),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'TÌM KIẾM',
              hint: 'Nhập từ khóa tìm kiếm...',
              controller: _searchController,
              prefixIcon: Icons.search_rounded,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: widget.isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: AppColors.tealPrimary),
                    )
                  : _filteredItems.isEmpty
                      ? Center(
                          child: Text(
                            'Không tìm thấy dữ liệu phù hợp',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                          ),
                        )
                      : ListView.builder(
                      shrinkWrap: false,
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          title: Text(
                            widget.itemAsString(item),
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                          ),
                          onTap: () {
                            Navigator.of(context).pop(item);
                          },
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          hoverColor: AppColors.tealPrimary.withValues(alpha: 0.1),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
