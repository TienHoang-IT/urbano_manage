class BangTin {
  final int id;
  final String tieuDe;
  final String noiDung;
  final String hinhUrl;
  final int nguoiTaoId;
  final String tenNguoiTao;
  final int nguoiCapNhatId;
  final String tenNguoiCapNhat;
  final DateTime createdAt;
  final DateTime updatedAt;

  BangTin({
    required this.id,
    required this.tieuDe,
    required this.noiDung,
    required this.hinhUrl,
    required this.nguoiTaoId,
    required this.tenNguoiTao,
    required this.nguoiCapNhatId,
    required this.tenNguoiCapNhat,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BangTin.fromJson(Map<String, dynamic> json) {
    return BangTin(
      id: json['id'] as int? ?? 0,
      tieuDe: json['tieuDe'] as String? ?? '',
      noiDung: json['noiDung'] as String? ?? '',
      hinhUrl: json['hinhUrl'] as String? ?? '',
      nguoiTaoId: json['nguoiTaoId'] as int? ?? 0,
      tenNguoiTao: json['tenNguoiTao'] as String? ?? '',
      nguoiCapNhatId: json['nguoiCapNhatId'] as int? ?? 0,
      tenNguoiCapNhat: json['tenNguoiCapNhat'] as String? ?? '',
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
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'hinhUrl': hinhUrl,
      'nguoiTaoId': nguoiTaoId,
      'tenNguoiTao': tenNguoiTao,
      'nguoiCapNhatId': nguoiCapNhatId,
      'tenNguoiCapNhat': tenNguoiCapNhat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
