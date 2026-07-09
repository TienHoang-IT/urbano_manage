class NhatKyHeThong {
  final int id;
  final int? nguoiThucHien;
  final String tenNguoiThucHien;
  final DateTime thoiGian;
  final String hanhDong;
  final String bangTacDong;
  final int? idBanGhi;
  final String? giaTriCu;
  final String? giaTriMoi;

  NhatKyHeThong({
    required this.id,
    this.nguoiThucHien,
    required this.tenNguoiThucHien,
    required this.thoiGian,
    required this.hanhDong,
    required this.bangTacDong,
    this.idBanGhi,
    this.giaTriCu,
    this.giaTriMoi,
  });

  factory NhatKyHeThong.fromJson(Map<String, dynamic> json) {
    return NhatKyHeThong(
      id: json['id'] as int? ?? 0,
      nguoiThucHien: json['nguoiThucHien'] as int?,
      tenNguoiThucHien: json['tenNguoiThucHien'] as String? ?? '',
      thoiGian: json['thoiGian'] != null ? DateTime.parse(json['thoiGian'] as String) : DateTime.now(),
      hanhDong: json['hanhDong'] as String? ?? '',
      bangTacDong: json['bangTacDong'] as String? ?? '',
      idBanGhi: json['idBanGhi'] as int?,
      giaTriCu: json['giaTriCu'] as String?,
      giaTriMoi: json['giaTriMoi'] as String?,
    );
  }
}

class PagedLogs {
  final List<NhatKyHeThong> items;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final int totalRecords;

  PagedLogs({
    required this.items,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    required this.totalRecords,
  });

  factory PagedLogs.fromJson(Map<String, dynamic> json) {
    final list = json['value'] as List? ?? [];
    return PagedLogs(
      items: list.map((e) => NhatKyHeThong.fromJson(e as Map<String, dynamic>)).toList(),
      pageNumber: json['pageNumber'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 0,
      totalRecords: json['totalRecords'] as int? ?? 0,
    );
  }
}
