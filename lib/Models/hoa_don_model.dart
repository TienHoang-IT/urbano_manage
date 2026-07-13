class HoaDon {
  final int id;
  final String maThanhToan;
  final int canHo;
  final String soCanHo;
  final int thang;
  final int nam;
  final double tongTien;
  final double soTienDaThanhToan;
  final double chiPhi;
  final DateTime? hanThanhToan;
  final int trangThai;
  final int? nguoiCapNhat;
  final String tenNguoiCapNhat;
  final DateTime createdAt;
  final DateTime updatedAt;

  HoaDon({
    required this.id,
    required this.maThanhToan,
    required this.canHo,
    required this.soCanHo,
    required this.thang,
    required this.nam,
    required this.tongTien,
    required this.soTienDaThanhToan,
    required this.chiPhi,
    this.hanThanhToan,
    required this.trangThai,
    this.nguoiCapNhat,
    required this.tenNguoiCapNhat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HoaDon.fromJson(Map<String, dynamic> json) {
    return HoaDon(
      id: json['id'] as int,
      maThanhToan: json['maThanhToan'] as String? ?? '',
      canHo: json['canHo'] as int? ?? 0,
      soCanHo: json['soCanHo'] as String? ?? '',
      thang: json['thang'] as int? ?? 0,
      nam: json['nam'] as int? ?? 0,
      tongTien: (json['tongTien'] as num? ?? 0.0).toDouble(),
      soTienDaThanhToan: (json['soTienDaThanhToan'] as num? ?? 0.0).toDouble(),
      chiPhi: (json['chiPhi'] as num? ?? 0.0).toDouble(),
      hanThanhToan: json['hanThanhToan'] != null ? DateTime.parse(json['hanThanhToan'] as String) : null,
      trangThai: json['trangThai'] as int? ?? 1,
      nguoiCapNhat: json['nguoiCapNhat'] as int?,
      tenNguoiCapNhat: json['tenNguoiCapNhat'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'maThanhToan': maThanhToan,
      'canHo': canHo,
      'soCanHo': soCanHo,
      'thang': thang,
      'nam': nam,
      'tongTien': tongTien,
      'soTienDaThanhToan': soTienDaThanhToan,
      'chiPhi': chiPhi,
      'hanThanhToan': hanThanhToan?.toIso8601String(),
      'trangThai': trangThai,
      'nguoiCapNhat': nguoiCapNhat,
      'tenNguoiCapNhat': tenNguoiCapNhat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  int get displayTrangThai {
    if (trangThai != 2 && hanThanhToan != null && DateTime.now().isAfter(hanThanhToan!)) {
      return 3; // Quá hạn
    }
    return trangThai;
  }

  String get trangThaiText {
    switch (displayTrangThai) {
      case 1:
        return 'Chưa thanh toán';
      case 2:
        return 'Đã thanh toán';
      case 3:
        return 'Quá hạn';
      case 4:
        return '1 phần';
      default:
        return 'Chưa thanh toán';
    }
  }
}
