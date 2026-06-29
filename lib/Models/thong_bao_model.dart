class ThongBao {
  final int id;
  final String tieuDe;
  final String noiDung;
  final int nguoiTao;
  final String tenNguoiTao;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ThongBao({
    required this.id,
    required this.tieuDe,
    required this.noiDung,
    required this.nguoiTao,
    required this.tenNguoiTao,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory ThongBao.fromJson(Map<String, dynamic> json) {
    return ThongBao(
      id: json['id'] as int,
      tieuDe: json['tieuDe'] as String? ?? '',
      noiDung: json['noiDung'] as String? ?? '',
      nguoiTao: json['nguoiTao'] as int? ?? 0,
      tenNguoiTao: json['tenNguoiTao'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'nguoiTao': nguoiTao,
      'tenNguoiTao': tenNguoiTao,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }
}
