class LoaiYeuCau {
  final int id;
  final String name;

  LoaiYeuCau({
    required this.id,
    required this.name,
  });

  factory LoaiYeuCau.fromJson(Map<String, dynamic> json) {
    return LoaiYeuCau(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
