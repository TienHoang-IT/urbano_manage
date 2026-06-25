class NhanVien {
  final int id;
  final String hoTen;
  final int chucVu;
  final String sdt;
  final String email;
  final int trangThai;
  final String maNhanVien;
  final String cccd;
  final DateTime? ngaySinh;
  final DateTime? ngayVaoLam;
  final DateTime? ngayNghiLam;
  final String ghiChu;
  final int? nguoiCapNhat;

  NhanVien({
    required this.id,
    required this.hoTen,
    required this.chucVu,
    required this.sdt,
    required this.email,
    required this.trangThai,
    required this.maNhanVien,
    required this.cccd,
    this.ngaySinh,
    this.ngayVaoLam,
    this.ngayNghiLam,
    required this.ghiChu,
    this.nguoiCapNhat,
  });

  factory NhanVien.fromJson(Map<String, dynamic> json) {
    return NhanVien(
      id: json['id'] as int,
      hoTen: json['hoTen'] as String? ?? '',
      chucVu: json['chucVu'] as int? ?? 0,
      sdt: json['sdt'] as String? ?? '',
      email: json['email'] as String? ?? '',
      trangThai: json['trangThai'] as int? ?? 0,
      maNhanVien: json['maNhanVien'] as String? ?? '',
      cccd: json['cccd'] as String? ?? '',
      ngaySinh: json['ngaySinh'] != null ? DateTime.parse(json['ngaySinh'] as String) : null,
      ngayVaoLam: json['ngayVaoLam'] != null ? DateTime.parse(json['ngayVaoLam'] as String) : null,
      ngayNghiLam: json['ngayNghiLam'] != null ? DateTime.parse(json['ngayNghiLam'] as String) : null,
      ghiChu: json['ghiChu'] as String? ?? '',
      nguoiCapNhat: json['nguoiCapNhat'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hoTen': hoTen,
      'chucVu': chucVu,
      'sdt': sdt,
      'email': email,
      'trangThai': trangThai,
      'maNhanVien': maNhanVien,
      'cccd': cccd,
      'ngaySinh': ngaySinh?.toIso8601String(),
      'ngayVaoLam': ngayVaoLam?.toIso8601String(),
      'ngayNghiLam': ngayNghiLam?.toIso8601String(),
      'ghiChu': ghiChu,
      'nguoiCapNhat': nguoiCapNhat,
    };
  }
}
