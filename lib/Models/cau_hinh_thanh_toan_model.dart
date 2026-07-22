class CauHinhThanhToan {
  final int id;
  final String loaiPhuongThuc;
  final String tenNhaCungCap;
  final String dinhDanhThuHuong;
  final String maNhanDien;
  final String tenChuTaiKhoan;

  CauHinhThanhToan({
    required this.id,
    required this.loaiPhuongThuc,
    required this.tenNhaCungCap,
    required this.dinhDanhThuHuong,
    required this.maNhanDien,
    required this.tenChuTaiKhoan,
  });

  factory CauHinhThanhToan.fromJson(Map<String, dynamic> json) {
    return CauHinhThanhToan(
      id: json['id'] as int? ?? 0,
      loaiPhuongThuc: json['loaiPhuongThuc'] as String? ?? 'ChuyenKhoan',
      tenNhaCungCap: json['tenNhaCungCap'] as String? ?? 'MBBank',
      dinhDanhThuHuong: json['dinhDanhThuHuong'] as String? ?? '0987654321',
      maNhanDien: json['maNhanDien'] as String? ?? 'MB',
      tenChuTaiKhoan: json['tenChuTaiKhoan'] as String? ?? 'BQL CHUNG CU URBANO',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'loaiPhuongThuc': loaiPhuongThuc,
      'tenNhaCungCap': tenNhaCungCap,
      'dinhDanhThuHuong': dinhDanhThuHuong,
      'maNhanDien': maNhanDien,
      'tenChuTaiKhoan': tenChuTaiKhoan,
    };
  }
}
