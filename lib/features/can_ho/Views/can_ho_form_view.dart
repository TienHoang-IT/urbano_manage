import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:urbano_manage/core/constants/app_colors.dart';
import 'package:urbano_manage/core/Widgets/app_button.dart';
import 'package:urbano_manage/core/Widgets/app_text_field.dart';
import 'package:urbano_manage/core/Widgets/app_dropdown_field.dart';
import 'package:urbano_manage/Models/can_ho_model.dart';
import 'package:urbano_manage/features/can_ho/ViewModels/can_ho_viewmodel.dart';
import 'package:urbano_manage/core/utils/app_validators.dart';

class CanHoFormView extends StatefulWidget {
  final CanHo? canHo;

  const CanHoFormView({super.key, this.canHo});

  @override
  State<CanHoFormView> createState() => _CanHoFormViewState();
}

class _CanHoFormViewState extends State<CanHoFormView> {
  final _formKey = GlobalKey<FormState>();
  final _soCanHoController = TextEditingController();
  final _tangController = TextEditingController();
  final _giaController = TextEditingController();
  final _soPhongController = TextEditingController();

  int? _selectedToaNhaId;
  int? _selectedLoaiCanHoId;
  int? _selectedTrangThaiId;
  final List<_SelectedFee> _selectedFees = [];

  @override
  void initState() {
    super.initState();
    
    _tangController.addListener(_updateSoCanHo);
    _soPhongController.addListener(_updateSoCanHo);

    if (widget.canHo == null) {
      _selectedFees.add(_SelectedFee(donGiaController: TextEditingController()));
    }

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
      } else if (widget.canHo != null && mounted) {
        vm.getFeesForCanHo(widget.canHo!.id).then((fees) {
          if (mounted) {
            setState(() {
              _selectedFees.clear();
              for (var fee in fees) {
                final ctrl = TextEditingController(text: fee['donGia'].toString());
                _selectedFees.add(_SelectedFee(feeId: fee['phiDichVuId'], donGiaController: ctrl));
              }
              if (_selectedFees.isEmpty) {
                _selectedFees.add(_SelectedFee(donGiaController: TextEditingController()));
              }
            });
          }
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
    for (var fee in _selectedFees) {
      fee.donGiaController.dispose();
    }
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
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng kiểm tra và điền đúng thông tin theo yêu cầu')),
      );
      return;
    }

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
    }
    
    List<Map<String, dynamic>> canHoPhiDichVus = [];
    for (var item in _selectedFees) {
      if (item.feeId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn phí dịch vụ cho tất cả các mục')));
        return;
      }
      final donGia = double.tryParse(item.donGiaController.text.trim());
      if (donGia == null || donGia < 0) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đơn giá hợp lệ (>= 0) cho tất cả phí dịch vụ')));
        return;
      }
      canHoPhiDichVus.add({
        'phiDichVuId': item.feeId,
        'donGia': donGia,
      });
    }
    data['canHoPhiDichVus'] = canHoPhiDichVus;

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
                        AppTextField(
                          label: 'TẦNG *',
                          hint: 'Nhập số tầng',
                          controller: _tangController,
                          prefixIcon: Icons.layers_rounded,
                          keyboardType: TextInputType.number,
                          validator: (v) => AppValidators.validatePositiveInteger(v, fieldName: 'Số tầng'),
                        ),
                        const SizedBox(height: 16),
                        if (!isEdit) ...[
                          AppTextField(
                            label: 'SỐ PHÒNG *',
                            hint: 'Nhập số phòng (ví dụ: 1, 2, 10...)',
                            controller: _soPhongController,
                            prefixIcon: Icons.meeting_room_rounded,
                            keyboardType: TextInputType.number,
                            validator: (v) => AppValidators.validatePositiveInteger(v, fieldName: 'Số phòng'),
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
                        label: 'GIÁ CĂN HỘ (VND)',
                        hint: 'Nhập giá căn hộ',
                        controller: _giaController,
                        prefixIcon: Icons.attach_money_rounded,
                        keyboardType: TextInputType.number,
                        validator: (v) => AppValidators.validateNonNegativeNumber(v, fieldName: 'Giá căn hộ', required: false),
                      ),
                      const SizedBox(height: 16),
                        Text(
                          'DANH SÁCH PHÍ DỊCH VỤ',
                          style: TextStyle(color: AppColors.textPrimary70, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ..._selectedFees.asMap().entries.map((entry) {
                          final index = entry.key;
                          final feeItem = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.inputFill,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.borderButton),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Phí dịch vụ #${index + 1}', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                      if (_selectedFees.length > 1)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              feeItem.donGiaController.dispose();
                                              _selectedFees.removeAt(index);
                                            });
                                          },
                                          child: Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  AppDropdownField<int>(
                                    label: 'CHỌN PHÍ *',
                                    value: feeItem.feeId,
                                    hint: 'Chọn phí dịch vụ',
                                    prefixIcon: Icons.monetization_on_rounded,
                                    onChanged: (val) {
                                      setState(() {
                                        feeItem.feeId = val;
                                        if (val != null) {
                                          final fee = viewModel.serviceFees.firstWhere((f) => f.id == val);
                                          feeItem.donGiaController.text = fee.donGia.toInt().toString();
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
                                  const SizedBox(height: 12),
                                  AppTextField(
                                    label: 'ĐƠN GIÁ (VND) *',
                                    hint: 'Nhập đơn giá',
                                    controller: feeItem.donGiaController,
                                    prefixIcon: Icons.price_change_rounded,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedFees.add(_SelectedFee(donGiaController: TextEditingController()));
                              });
                            },
                            icon: Icon(Icons.add_circle_outline, color: AppColors.tealPrimary),
                            label: Text('Thêm phí dịch vụ', style: TextStyle(color: AppColors.tealPrimary)),
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppButton(
                          label: isEdit ? 'LƯU THAY ĐỔI' : 'TẠO CĂN HỘ MỚI',
                          isLoading: viewModel.isLoading,
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
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              isEdit ? 'Sửa thông tin Căn hộ' : 'Thêm Căn hộ mới',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedFee {
  int? feeId;
  final TextEditingController donGiaController;
  _SelectedFee({this.feeId, required this.donGiaController});
}
