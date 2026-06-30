class PhiDichVu {
  final int id;
  final int loaiPhiDichVuId;
  final String tenLoaiPhiDichVu;
  final String tenPhiDichVu;
  final double donGia;
  final int donViTinhId;
  final String tenDonViTinh;
  final int loaiTinhPhiId;
  final String tenLoaiTinhPhi;
  final int? nguoiCapNhatId;
  final String tenNguoiCapNhat;
  final DateTime createdAt;
  final DateTime updatedAt;

  PhiDichVu({
    required this.id,
    required this.loaiPhiDichVuId,
    required this.tenLoaiPhiDichVu,
    required this.tenPhiDichVu,
    required this.donGia,
    required this.donViTinhId,
    required this.tenDonViTinh,
    required this.loaiTinhPhiId,
    required this.tenLoaiTinhPhi,
    this.nguoiCapNhatId,
    required this.tenNguoiCapNhat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PhiDichVu.fromJson(Map<String, dynamic> json) {
    return PhiDichVu(
      id: json['id'] as int,
      loaiPhiDichVuId: json['loaiPhiDichVuId'] as int? ?? 0,
      tenLoaiPhiDichVu: json['tenLoaiPhiDichVu'] as String? ?? '',
      tenPhiDichVu: json['tenPhiDichVu'] as String? ?? '',
      donGia: (json['donGia'] as num? ?? 0.0).toDouble(),
      donViTinhId: json['donViTinhId'] as int? ?? 0,
      tenDonViTinh: json['tenDonViTinh'] as String? ?? '',
      loaiTinhPhiId: json['loaiTinhPhiId'] as int? ?? 0,
      tenLoaiTinhPhi: json['tenLoaiTinhPhi'] as String? ?? '',
      nguoiCapNhatId: json['nguoiCapNhatId'] as int?,
      tenNguoiCapNhat: json['tenNguoiCapNhat'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loaiPhiDichVuId': loaiPhiDichVuId,
      'tenLoaiPhiDichVu': tenLoaiPhiDichVu,
      'tenPhiDichVu': tenPhiDichVu,
      'donGia': donGia,
      'donViTinhId': donViTinhId,
      'tenDonViTinh': tenDonViTinh,
      'loaiTinhPhiId': loaiTinhPhiId,
      'tenLoaiTinhPhi': tenLoaiTinhPhi,
      'nguoiCapNhatId': nguoiCapNhatId,
      'tenNguoiCapNhat': tenNguoiCapNhat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
