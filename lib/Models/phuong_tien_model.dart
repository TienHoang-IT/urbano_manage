class PhuongTien {
  final int id;
  final String tenPhuongTien;
  final String bienSo;
  final int loaiPhuongTienId;
  final String tenLoaiPhuongTien;
  final int canHoId;
  final String soCanHo;
  final DateTime? ngayDangKy;
  final DateTime? ngayHuy;
  final int trangThai;
  final int? nguoiCapNhatId;
  final String tenNguoiCapNhat;

  PhuongTien({
    required this.id,
    required this.tenPhuongTien,
    required this.bienSo,
    required this.loaiPhuongTienId,
    required this.tenLoaiPhuongTien,
    required this.canHoId,
    required this.soCanHo,
    this.ngayDangKy,
    this.ngayHuy,
    required this.trangThai,
    this.nguoiCapNhatId,
    required this.tenNguoiCapNhat,
  });

  factory PhuongTien.fromJson(Map<String, dynamic> json) {
    return PhuongTien(
      id: json['id'] as int? ?? 0,
      tenPhuongTien: json['tenPhuongTien'] as String? ?? '',
      bienSo: json['bienSo'] as String? ?? '',
      loaiPhuongTienId: json['loaiPhuongTienId'] as int? ?? 0,
      tenLoaiPhuongTien: json['tenLoaiPhuongTien'] as String? ?? '',
      canHoId: json['canHoId'] as int? ?? 0,
      soCanHo: json['soCanHo'] as String? ?? '',
      ngayDangKy: json['ngayDangKy'] != null
          ? DateTime.parse(json['ngayDangKy'] as String)
          : null,
      ngayHuy: json['ngayHuy'] != null
          ? DateTime.parse(json['ngayHuy'] as String)
          : null,
      trangThai: json['trangThai'] as int? ?? 0,
      nguoiCapNhatId: json['nguoiCapNhatId'] as int?,
      tenNguoiCapNhat: json['tenNguoiCapNhat'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenPhuongTien': tenPhuongTien,
      'bienSo': bienSo,
      'loaiPhuongTienId': loaiPhuongTienId,
      'tenLoaiPhuongTien': tenLoaiPhuongTien,
      'canHoId': canHoId,
      'soCanHo': soCanHo,
      'ngayDangKy': ngayDangKy?.toIso8601String(),
      'ngayHuy': ngayHuy?.toIso8601String(),
      'trangThai': trangThai,
      'nguoiCapNhatId': nguoiCapNhatId,
      'tenNguoiCapNhat': tenNguoiCapNhat,
    };
  }
}
