import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/Models/tien_ich_model.dart';
import 'package:urbano_manage/features/tien_ich/ViewModels/tien_ich_viewmodel.dart';
import 'package:urbano_manage/core/utils/app_validators.dart';

class TienIchFormView extends StatefulWidget {
  final TienIch? tienIch;

  const TienIchFormView({super.key, this.tienIch});

  @override
  State<TienIchFormView> createState() => _TienIchFormViewState();
}

class _TienIchFormViewState extends State<TienIchFormView> {
  final _formKey = GlobalKey<FormState>();
  final _tenController = TextEditingController();
  final _moTaController = TextEditingController();
  final _viTriController = TextEditingController();
  final _sucChuaController = TextEditingController();
  final _phiController = TextEditingController();
  final _hinhUrlController = TextEditingController();

  int? _selectedLoaiId;
  int? _selectedToaNhaId;
  int _selectedTrangThai = 1; // 1: Hoạt động, 2: Bảo trì, 3: Ngừng hoạt động
  bool _canDatTruoc = false;
  TimeOfDay? _selectedGioMoCua;
  TimeOfDay? _selectedGioDongCua;

  @override
  void initState() {
    super.initState();
    final vm = context.read<TienIchViewModel>();

    if (widget.tienIch == null) {
      if (vm.loaiTienIchs.isNotEmpty) _selectedLoaiId = vm.loaiTienIchs.first['id'] as int;
      if (vm.toaNhas.isNotEmpty) _selectedToaNhaId = vm.toaNhas.first['id'] as int;
      _selectedGioMoCua = const TimeOfDay(hour: 8, minute: 0);
      _selectedGioDongCua = const TimeOfDay(hour: 22, minute: 0);
    } else {
      final t = widget.tienIch!;
      _tenController.text = t.tenTienIch;
      _moTaController.text = t.moTa;
      _viTriController.text = t.viTri;
      _sucChuaController.text = t.sucChua?.toString() ?? '';
      _phiController.text = t.phiSuDung.toStringAsFixed(0);
      _hinhUrlController.text = t.hinhUrl;
      _selectedLoaiId = t.loaiTienIchId;
      _selectedToaNhaId = t.toaNhaId;
      _selectedTrangThai = t.trangThai;
      _canDatTruoc = t.canDatTruoc;

      if (t.gioMoCua != null && t.gioMoCua!.isNotEmpty) {
        final parts = t.gioMoCua!.split(':');
        if (parts.length >= 2) {
          _selectedGioMoCua = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
      if (t.gioDongCua != null && t.gioDongCua!.isNotEmpty) {
        final parts = t.gioDongCua!.split(':');
        if (parts.length >= 2) {
          _selectedGioDongCua = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        }
      }
    }
  }

  @override
  void dispose() {
    _tenController.dispose();
    _moTaController.dispose();
    _viTriController.dispose();
    _sucChuaController.dispose();
    _phiController.dispose();
    _hinhUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, bool isOpeningTime) async {
    final initialTime = isOpeningTime
        ? _selectedGioMoCua ?? const TimeOfDay(hour: 8, minute: 0)
        : _selectedGioDongCua ?? const TimeOfDay(hour: 22, minute: 0);

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.tealPrimary,
              onPrimary: AppColors.textPrimary,
              surface: AppColors.bgDark,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isOpeningTime) {
          _selectedGioMoCua = picked;
        } else {
          _selectedGioDongCua = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra và điền đúng thông tin theo yêu cầu')),
      );
      return;
    }

    final name = _tenController.text.trim();
    final desc = _moTaController.text.trim();
    final location = _viTriController.text.trim();
    final capacity = int.tryParse(_sucChuaController.text.trim());
    final fee = double.tryParse(_phiController.text.trim()) ?? 0;
    final imageUrl = _hinhUrlController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tên tiện ích')));
      return;
    }
    if (_selectedLoaiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn loại tiện ích')));
      return;
    }
    if (location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập vị trí tiện ích')));
      return;
    }

    final gioMo = _selectedGioMoCua != null
        ? '${_selectedGioMoCua!.hour.toString().padLeft(2, '0')}:${_selectedGioMoCua!.minute.toString().padLeft(2, '0')}:00'
        : null;
    final gioDong = _selectedGioDongCua != null
        ? '${_selectedGioDongCua!.hour.toString().padLeft(2, '0')}:${_selectedGioDongCua!.minute.toString().padLeft(2, '0')}:00'
        : null;

    final data = {
      'tenTienIch': name,
      'loaiTienIch': _selectedLoaiId,
      'toaNha': _selectedToaNhaId,
      'moTa': desc,
      'viTri': location,
      'sucChua': capacity,
      'gioMoCua': gioMo,
      'gioDongCua': gioDong,
      'phiSuDung': fee,
      'canDatTruoc': _canDatTruoc,
      'hinhUrl': imageUrl,
      'trangThai': _selectedTrangThai,
    };

    final viewModel = context.read<TienIchViewModel>();
    bool success;
    if (widget.tienIch != null) {
      success = await viewModel.update(widget.tienIch!.id, data);
    } else {
      success = await viewModel.create(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.tienIch != null ? 'Cập nhật tiện ích thành công' : 'Thêm tiện ích thành công'),
            backgroundColor: AppColors.tealPrimary,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.error ?? 'Đã xảy ra lỗi'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TienIchViewModel>();
    final isEdit = widget.tienIch != null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgMid, AppColors.bgDarkest],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppbar(context, isEdit),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'TÊN TIỆN ÍCH *',
                          hint: 'Ví dụ: Sân Tennis A, Hồ Bơi Vô Cực',
                          controller: _tenController,
                          prefixIcon: Icons.pool_rounded,
                          validator: (v) => AppValidators.validateRequiredText(v, fieldName: 'Tên tiện ích'),
                        ),
                        const SizedBox(height: 16),
                        AppDropdownField<int>(
                          label: 'LOẠI TIỆN ÍCH *',
                          value: _selectedLoaiId,
                          hint: 'Chọn loại tiện ích',
                          prefixIcon: Icons.category_rounded,
                          items: vm.loaiTienIchs.map((loai) {
                            return DropdownMenuItem<int>(
                              value: loai['id'] as int,
                              child: Text(loai['tenLoaiTienIch'] as String),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedLoaiId = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        AppDropdownField<int>(
                          label: 'TÒA NHÀ',
                          value: _selectedToaNhaId,
                          hint: 'Chọn tòa nhà (nếu có)',
                          prefixIcon: Icons.apartment_rounded,
                          items: vm.toaNhas.map((toaNha) {
                            return DropdownMenuItem<int>(
                              value: toaNha['id'] as int,
                              child: Text(toaNha['tenToaNha'] as String),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _selectedToaNhaId = val;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'VỊ TRÍ *',
                          hint: 'Ví dụ: Tầng thượng Tòa A, Khu công viên trung tâm',
                          controller: _viTriController,
                          prefixIcon: Icons.location_on_rounded,
                          validator: (v) => AppValidators.validateRequiredText(v, fieldName: 'Vị trí'),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppTextField(
                                label: 'SỨC CHỨA',
                                hint: 'Số người',
                                controller: _sucChuaController,
                                prefixIcon: Icons.people_rounded,
                                keyboardType: TextInputType.number,
                                validator: (v) => AppValidators.validatePositiveInteger(v, fieldName: 'Sức chứa', required: false),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: AppTextField(
                                label: 'PHÍ SỬ DỤNG (VNĐ/LƯỢT)',
                                hint: 'Ví dụ: 50000',
                                controller: _phiController,
                                prefixIcon: Icons.monetization_on_rounded,
                                keyboardType: TextInputType.number,
                                validator: (v) => AppValidators.validateNonNegativeNumber(v, fieldName: 'Phí sử dụng', required: false),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTime(context, true),
                              child: AbsorbPointer(
                                child: AppTextField(
                                  label: 'GIỜ MỞ CỬA',
                                  hint: 'Chọn giờ',
                                  controller: TextEditingController(
                                    text: _formatTimeOfDay(_selectedGioMoCua),
                                  ),
                                  prefixIcon: Icons.access_time_rounded,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectTime(context, false),
                              child: AbsorbPointer(
                                child: AppTextField(
                                  label: 'GIỜ ĐÓNG CỬA',
                                  hint: 'Chọn giờ',
                                  controller: TextEditingController(
                                    text: _formatTimeOfDay(_selectedGioDongCua),
                                  ),
                                  prefixIcon: Icons.access_time_filled_rounded,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'ĐƯỜNG DẪN HÌNH ẢNH',
                        hint: 'Ví dụ: https://images.com/pool.jpg',
                        controller: _hinhUrlController,
                        prefixIcon: Icons.image_rounded,
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'TRẠNG THÁI *',
                        value: _selectedTrangThai,
                        hint: 'Chọn trạng thái',
                        prefixIcon: Icons.toggle_on_rounded,
                        items: const [
                          DropdownMenuItem<int>(value: 1, child: Text('Hoạt động')),
                          DropdownMenuItem<int>(value: 2, child: Text('Bảo trì')),
                          DropdownMenuItem<int>(value: 3, child: Text('Ngừng hoạt động')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedTrangThai = val;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.nenContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderButton),
                        ),
                        child: SwitchListTile(
                          activeThumbColor: AppColors.tealPrimary,
                          title: Text(
                            'Cần đặt trước lịch sử dụng',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Cư dân cần gửi đăng ký thuê/đặt trước khi sử dụng tiện ích này',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                          ),
                          value: _canDatTruoc,
                          onChanged: (bool value) {
                            setState(() {
                              _canDatTruoc = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      AppButton(
                        label: isEdit ? 'LƯU THAY ĐỔI' : 'TẠO TIỆN ÍCH MỚI',
                        isLoading: vm.isLoading,
                        onPressed: _saveForm,
                      ),
                      const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppbar(BuildContext context, bool isEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.tealPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            isEdit ? 'Chỉnh sửa Tiện ích' : 'Thêm Tiện ích Mới',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
