import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/features/can_ho/ViewModels/can_ho_viewmodel.dart';

class CanHoFormView extends StatefulWidget {
  final CanHo? canHo;

  const CanHoFormView({super.key, this.canHo});

  @override
  State<CanHoFormView> createState() => _CanHoFormViewState();
}

class _CanHoFormViewState extends State<CanHoFormView> {
  final _soCanHoController = TextEditingController();
  final _tangController = TextEditingController();
  final _giaController = TextEditingController();
  final _soPhongController = TextEditingController();
  final _donGiaController = TextEditingController();

  int? _selectedToaNhaId;
  int? _selectedLoaiCanHoId;
  int? _selectedTrangThaiId;
  int? _selectedFeeId;

  @override
  void initState() {
    super.initState();
    
    _tangController.addListener(_updateSoCanHo);
    _soPhongController.addListener(_updateSoCanHo);

    final vm = context.read<CanHoViewModel>();
    vm.fetchLookups().then((_) {
      if (widget.canHo == null && mounted) {
        setState(() {
          if (vm.buildings.isNotEmpty) {
            _selectedToaNhaId = vm.buildings.first['id'];
            _updateSoCanHo();
          }
          if (vm.roomTypes.isNotEmpty) _selectedLoaiCanHoId = vm.roomTypes.first['id'];
          if (vm.roomStatuses.isNotEmpty) _selectedTrangThaiId = vm.roomStatuses.first['id'];
        });
      }
    });

    if (widget.canHo != null) {
      final c = widget.canHo!;
      _soCanHoController.text = c.soCanHo;
      _tangController.text = c.tang.toString();
      _giaController.text = c.gia != null ? c.gia!.toInt().toString() : '';
      _selectedToaNhaId = c.toaNhaId;
      _selectedLoaiCanHoId = c.loaiCanHoId;
      _selectedTrangThaiId = c.trangThaiId;
    }
  }

  @override
  void dispose() {
    _soCanHoController.dispose();
    _tangController.dispose();
    _giaController.dispose();
    _soPhongController.dispose();
    _donGiaController.dispose();
    super.dispose();
  }

  void _updateSoCanHo() {
    if (widget.canHo != null) return;

    final vm = context.read<CanHoViewModel>();
    if (_selectedToaNhaId == null || vm.buildings.isEmpty) return;

    final building = vm.buildings.firstWhere(
      (b) => b['id'] == _selectedToaNhaId,
      orElse: () => <String, dynamic>{},
    );
    final prefix = building['tienTo'] as String? ?? '';

    final floorStr = _tangController.text.trim();
    final roomStr = _soPhongController.text.trim();

    if (floorStr.isEmpty || roomStr.isEmpty) {
      _soCanHoController.text = '';
      return;
    }

    final floorNum = int.tryParse(floorStr);
    final roomNum = int.tryParse(roomStr);

    if (floorNum == null || roomNum == null) {
      _soCanHoController.text = '';
      return;
    }

    final formattedFloor = floorNum.toString().padLeft(2, '0');
    final formattedRoom = roomNum.toString().padLeft(3, '0');

    _soCanHoController.text = '$prefix$formattedFloor$formattedRoom';
  }

  Future<void> _saveForm() async {
    final soCanHo = _soCanHoController.text.trim();
    final tang = int.tryParse(_tangController.text.trim()) ?? 0;
    final gia = double.tryParse(_giaController.text.trim());

    if (soCanHo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số căn hộ')));
      return;
    }
    if (_selectedToaNhaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn tòa nhà')));
      return;
    }
    if (tang <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập tầng hợp lệ (>0)')));
      return;
    }
    if (_selectedLoaiCanHoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn loại căn hộ')));
      return;
    }
    if (_selectedTrangThaiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn trạng thái')));
      return;
    }

    final data = {
      'toaNhaId': _selectedToaNhaId,
      'soCanHo': soCanHo,
      'tang': tang,
      'trangThaiId': _selectedTrangThaiId,
      'gia': gia,
      'loaiCanHoId': _selectedLoaiCanHoId,
    };

    if (widget.canHo == null) {
      final soPhong = _soPhongController.text.trim();
      if (soPhong.isEmpty || int.tryParse(soPhong) == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập số phòng hợp lệ')));
        return;
      }
      if (_selectedFeeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn phí dịch vụ')));
        return;
      }
      final donGia = double.tryParse(_donGiaController.text.trim());
      if (donGia == null || donGia <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đơn giá dịch vụ hợp lệ')));
        return;
      }
      data['phiDichVuId'] = _selectedFeeId;
      data['donGia'] = donGia;
    }

    final viewModel = context.read<CanHoViewModel>();
    bool success;
    if (widget.canHo != null) {
      success = await viewModel.editCanHo(widget.canHo!.id, data);
    } else {
      success = await viewModel.addCanHo(data);
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.canHo != null ? 'Cập nhật căn hộ thành công' : 'Thêm căn hộ thành công'),
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
    final viewModel = context.watch<CanHoViewModel>();
    final isEdit = widget.canHo != null;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppDropdownField<int>(
                        label: 'TÒA NHÀ *',
                        value: _selectedToaNhaId,
                        hint: 'Chọn tòa nhà',
                        prefixIcon: Icons.business_rounded,
                        onChanged: (val) {
                          setState(() {
                            _selectedToaNhaId = val;
                            _updateSoCanHo();
                          });
                        },
                        items: viewModel.buildings
                            .map((e) => DropdownMenuItem<int>(
                                  value: e['id'] as int,
                                  child: Text(e['tenToaNha'] as String? ?? ''),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      if (!isEdit) ...[
                        AppTextField(
                          label: 'SỐ PHÒNG *',
                          hint: 'Nhập số phòng (ví dụ: 1, 2, 10...)',
                          controller: _soPhongController,
                          prefixIcon: Icons.meeting_room_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                      ],
                      AppTextField(
                        label: 'SỐ CĂN HỘ *',
                        hint: 'Số căn hộ tự động sinh',
                        controller: _soCanHoController,
                        prefixIcon: Icons.tag_rounded,
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'TẦNG *',
                        hint: 'Nhập số tầng',
                        controller: _tangController,
                        prefixIcon: Icons.layers_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'LOẠI CĂN HỘ *',
                        value: _selectedLoaiCanHoId,
                        hint: 'Chọn loại căn hộ',
                        prefixIcon: Icons.category_rounded,
                        onChanged: (val) => setState(() => _selectedLoaiCanHoId = val),
                        items: viewModel.roomTypes
                            .map((e) => DropdownMenuItem<int>(
                                  value: e['id'] as int,
                                  child: Text(e['tenLoaiCanHo'] as String? ?? ''),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      AppDropdownField<int>(
                        label: 'TRẠNG THÁI *',
                        value: _selectedTrangThaiId,
                        hint: 'Chọn trạng thái',
                        prefixIcon: Icons.info_outline_rounded,
                        onChanged: (val) => setState(() => _selectedTrangThaiId = val),
                        items: viewModel.roomStatuses
                            .map((e) => DropdownMenuItem<int>(
                                  value: e['id'] as int,
                                  child: Text(e['tenTrangThai'] as String? ?? ''),
                                ))
                            .toList(),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'GIÁ BÁN/THUÊ (VND)',
                        hint: 'Nhập giá trị',
                        controller: _giaController,
                        prefixIcon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      if (!isEdit) ...[
                        AppDropdownField<int>(
                          label: 'PHÍ DỊCH VỤ *',
                          value: _selectedFeeId,
                          hint: 'Chọn phí dịch vụ',
                          prefixIcon: Icons.monetization_on_rounded,
                          onChanged: (val) {
                            setState(() {
                              _selectedFeeId = val;
                              if (val != null) {
                                final fee = viewModel.serviceFees.firstWhere((f) => f.id == val);
                                _donGiaController.text = fee.donGia.toInt().toString();
                              }
                            });
                          },
                          items: viewModel.serviceFees
                              .map((e) => DropdownMenuItem<int>(
                                    value: e.id,
                                    child: Text('${e.tenPhiDichVu} (${e.tenLoaiPhiDichVu})'),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'ĐƠN GIÁ DỊCH VỤ *',
                          hint: 'Nhập đơn giá dịch vụ',
                          controller: _donGiaController,
                          prefixIcon: Icons.price_change_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 16),
                      ],
                      const SizedBox(height: 32),
                      AppButton(
                        label: viewModel.isLoading ? 'Đang xử lý...' : (isEdit ? 'Cập Nhật' : 'Thêm Mới'),
                        onPressed: viewModel.isLoading ? null : _saveForm,
                        isLoading: viewModel.isLoading,
                      ),
                      const SizedBox(height: 24),
                    ],
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.inputFill,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderButton),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit ? 'Sửa thông tin Căn hộ' : 'Thêm Căn hộ mới',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
