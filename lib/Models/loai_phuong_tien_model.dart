class LoaiPhuongTien {
  final int id;
  final String tenLoaiPhuongTien;

  LoaiPhuongTien({
    required this.id,
    required this.tenLoaiPhuongTien,
  });

  factory LoaiPhuongTien.fromJson(Map<String, dynamic> json) {
    return LoaiPhuongTien(
      id: json['id'] as int? ?? 0,
      tenLoaiPhuongTien: json['tenLoaiPhuongTien'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenLoaiPhuongTien': tenLoaiPhuongTien,
    };
  }
}
