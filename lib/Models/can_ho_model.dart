class CanHo {
  final int id;
  final int toaNhaId;
  final String tenToaNha;
  final String soCanHo;
  final int tang;
  final int trangThaiId;
  final String tenTrangThai;
  final double? gia;
  final int loaiCanHoId;
  final String tenLoaiCanHo;
  final int? nguoiCapNhatId;
  final String tenNguoiCapNhat;
  final DateTime createdAt;
  final DateTime updatedAt;

  CanHo({
    required this.id,
    required this.toaNhaId,
    required this.tenToaNha,
    required this.soCanHo,
    required this.tang,
    required this.trangThaiId,
    required this.tenTrangThai,
    this.gia,
    required this.loaiCanHoId,
    required this.tenLoaiCanHo,
    this.nguoiCapNhatId,
    required this.tenNguoiCapNhat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CanHo.fromJson(Map<String, dynamic> json) {
    return CanHo(
      id: json['id'] as int,
      toaNhaId: json['toaNhaId'] as int? ?? 0,
      tenToaNha: json['tenToaNha'] as String? ?? '',
      soCanHo: json['soCanHo'] as String? ?? '',
      tang: json['tang'] as int? ?? 0,
      trangThaiId: json['trangThaiId'] as int? ?? 0,
      tenTrangThai: json['tenTrangThai'] as String? ?? '',
      gia: json['gia'] != null ? (json['gia'] as num).toDouble() : null,
      loaiCanHoId: json['loaiCanHoId'] as int? ?? 0,
      tenLoaiCanHo: json['tenLoaiCanHo'] as String? ?? '',
      nguoiCapNhatId: json['nguoiCapNhatId'] as int?,
      tenNguoiCapNhat: json['tenNguoiCapNhat'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toaNhaId': toaNhaId,
      'tenToaNha': tenToaNha,
      'soCanHo': soCanHo,
      'tang': tang,
      'trangThaiId': trangThaiId,
      'tenTrangThai': tenTrangThai,
      'gia': gia,
      'loaiCanHoId': loaiCanHoId,
      'tenLoaiCanHo': tenLoaiCanHo,
      'nguoiCapNhatId': nguoiCapNhatId,
      'tenNguoiCapNhat': tenNguoiCapNhat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
