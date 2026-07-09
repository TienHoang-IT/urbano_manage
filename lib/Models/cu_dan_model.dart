class CuDan {
  final int id;
  final String hoTenDem;
  final String ten;
  final String hoTen;
  final String sdt;
  final String cccd;
  final String email;
  final DateTime? ngaySinh;
  final int? gioiTinh;
  final String gioiTinhText;
  final String tinh;
  final String xa;
  final String diaChi;
  final String diaChiDayDu;
  final int trangThai;
  final String trangThaiText;
  final DateTime createdAt;
  final DateTime updatedAt;

  CuDan({
    required this.id,
    required this.hoTenDem,
    required this.ten,
    required this.hoTen,
    required this.sdt,
    required this.cccd,
    required this.email,
    this.ngaySinh,
    this.gioiTinh,
    required this.gioiTinhText,
    required this.tinh,
    required this.xa,
    required this.diaChi,
    required this.diaChiDayDu,
    required this.trangThai,
    required this.trangThaiText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CuDan.fromJson(Map<String, dynamic> json) {
    return CuDan(
      id: json['id'] as int,
      hoTenDem: json['hoTenDem'] as String? ?? '',
      ten: json['ten'] as String? ?? '',
      hoTen: json['hoTen'] as String? ?? '',
      sdt: json['sdt'] as String? ?? '',
      cccd: json['cccd'] as String? ?? '',
      email: json['email'] as String? ?? '',
      ngaySinh: json['ngaySinh'] != null ? DateTime.parse(json['ngaySinh'] as String) : null,
      gioiTinh: json['gioiTinh'] as int?,
      gioiTinhText: json['gioiTinhText'] as String? ?? '',
      tinh: json['tinh'] as String? ?? '',
      xa: json['xa'] as String? ?? '',
      diaChi: json['diaChi'] as String? ?? '',
      diaChiDayDu: json['diaChiDayDu'] as String? ?? '',
      trangThai: json['trangThai'] as int? ?? 0,
      trangThaiText: json['trangThaiText'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hoTenDem': hoTenDem,
      'ten': ten,
      'hoTen': hoTen,
      'sdt': sdt,
      'cccd': cccd,
      'email': email,
      'ngaySinh': ngaySinh?.toIso8601String(),
      'gioiTinh': gioiTinh,
      'gioiTinhText': gioiTinhText,
      'tinh': tinh,
      'xa': xa,
      'diaChi': diaChi,
      'diaChiDayDu': diaChiDayDu,
      'trangThai': trangThai,
      'trangThaiText': trangThaiText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
