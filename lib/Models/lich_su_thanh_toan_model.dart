class LichSuThanhToan {
  final int id;
  final int hoaDonId;
  final String maThanhToan;
  final int thang;
  final int nam;
  final DateTime? ngayThanhToan;
  final double soTien;
  final String phuongThucThanhToan;
  final String maGiaoDich;
  final String ghiChu;

  LichSuThanhToan({
    required this.id,
    required this.hoaDonId,
    required this.maThanhToan,
    required this.thang,
    required this.nam,
    this.ngayThanhToan,
    required this.soTien,
    required this.phuongThucThanhToan,
    required this.maGiaoDich,
    required this.ghiChu,
  });

  factory LichSuThanhToan.fromJson(Map<String, dynamic> json) {
    return LichSuThanhToan(
      id: json['id'] ?? 0,
      hoaDonId: json['hoaDonId'] ?? 0,
      maThanhToan: json['maThanhToan'] ?? '',
      thang: json['thang'] ?? 0,
      nam: json['nam'] ?? 0,
      ngayThanhToan: json['ngayThanhToan'] != null ? DateTime.tryParse(json['ngayThanhToan'].toString()) : null,
      soTien: (json['soTien'] ?? 0).toDouble(),
      phuongThucThanhToan: json['phuongThucThanhToan'] ?? '',
      maGiaoDich: json['maGiaoDich'] ?? '',
      ghiChu: json['ghiChu'] ?? '',
    );
  }
}
