class DatLichTienIch {
  final int id;
  final String maDatLich;
  final int cuDanId;
  final String tenCuDan;
  final int? canHoId;
  final String soCanHo;
  final int tienIchId;
  final String tenTienIch;
  final DateTime thoiGianBatDau;
  final DateTime thoiGianKetThuc;
  final int soNguoi;
  final double phiSuDung;
  final String ghiChu;
  final int trangThai;
  final String trangThaiText;
  final int? nhanVienDuyet;
  final String tenNhanVienDuyet;
  final DateTime? ngayDuyet;
  final DateTime? ngayHuy;
  final String lyDoHuy;
  final int? nguoiCapNhat;
  final DateTime createdAt;
  final DateTime updatedAt;

  DatLichTienIch({
    required this.id,
    required this.maDatLich,
    required this.cuDanId,
    required this.tenCuDan,
    this.canHoId,
    required this.soCanHo,
    required this.tienIchId,
    required this.tenTienIch,
    required this.thoiGianBatDau,
    required this.thoiGianKetThuc,
    required this.soNguoi,
    required this.phiSuDung,
    required this.ghiChu,
    required this.trangThai,
    required this.trangThaiText,
    this.nhanVienDuyet,
    required this.tenNhanVienDuyet,
    this.ngayDuyet,
    this.ngayHuy,
    required this.lyDoHuy,
    this.nguoiCapNhat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DatLichTienIch.fromJson(Map<String, dynamic> json) {
    return DatLichTienIch(
      id: json['id'] as int? ?? 0,
      maDatLich: json['maDatLich'] as String? ?? '',
      cuDanId: (json['cuDan'] ?? json['cuDanId']) as int? ?? 0,
      tenCuDan: json['tenCuDan'] as String? ?? '',
      canHoId: (json['canHo'] ?? json['canHoId']) as int?,
      soCanHo: json['soCanHo'] as String? ?? '',
      tienIchId: (json['tienIch'] ?? json['tienIchId']) as int? ?? 0,
      tenTienIch: json['tenTienIch'] as String? ?? '',
      thoiGianBatDau: json['thoiGianBatDau'] != null
          ? DateTime.parse(json['thoiGianBatDau'] as String)
          : DateTime.now(),
      thoiGianKetThuc: json['thoiGianKetThuc'] != null
          ? DateTime.parse(json['thoiGianKetThuc'] as String)
          : DateTime.now(),
      soNguoi: json['soNguoi'] as int? ?? 0,
      phiSuDung: (json['phiSuDung'] as num? ?? 0).toDouble(),
      ghiChu: json['ghiChu'] as String? ?? '',
      trangThai: json['trangThai'] as int? ?? 1,
      trangThaiText: json['trangThaiText'] as String? ?? '',
      nhanVienDuyet: json['nhanVienDuyet'] as int?,
      tenNhanVienDuyet: json['tenNhanVienDuyet'] as String? ?? '',
      ngayDuyet: json['ngayDuyet'] != null
          ? DateTime.parse(json['ngayDuyet'] as String)
          : null,
      ngayHuy: json['ngayHuy'] != null
          ? DateTime.parse(json['ngayHuy'] as String)
          : null,
      lyDoHuy: json['lyDoHuy'] as String? ?? '',
      nguoiCapNhat: json['nguoiCapNhat'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maDatLich': maDatLich,
      'cuDanId': cuDanId,
      'canHoId': canHoId,
      'tienIchId': tienIchId,
      'thoiGianBatDau': thoiGianBatDau.toIso8601String(),
      'thoiGianKetThuc': thoiGianKetThuc.toIso8601String(),
      'soNguoi': soNguoi,
      'phiSuDung': phiSuDung,
      'ghiChu': ghiChu,
      'trangThai': trangThai,
    };
  }
}
