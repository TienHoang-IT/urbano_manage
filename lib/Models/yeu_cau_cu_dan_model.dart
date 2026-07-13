class YeuCauCuDan {
  final int id;
  final int cuDan;
  final String tenCuDan;
  final int loaiYeuCau;
  final String tenLoaiYeuCau;
  final String tieuDe;
  final String noiDung;
  final DateTime ngayGui;
  final int mucDoUuTien;
  final String mucDoUuTienText;
  final int trangThai;
  final String trangThaiText;
  final int? nhanVienXuLy;
  final String tenNhanVienXuLy;
  final DateTime? ngayHoanThanh;
  final int? nguoiCapNhat;
  final String tenNguoiCapNhat;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? sao;
  final String? nhanXet;

  YeuCauCuDan({
    required this.id,
    required this.cuDan,
    required this.tenCuDan,
    required this.loaiYeuCau,
    required this.tenLoaiYeuCau,
    required this.tieuDe,
    required this.noiDung,
    required this.ngayGui,
    required this.mucDoUuTien,
    required this.mucDoUuTienText,
    required this.trangThai,
    required this.trangThaiText,
    this.nhanVienXuLy,
    required this.tenNhanVienXuLy,
    this.ngayHoanThanh,
    this.nguoiCapNhat,
    required this.tenNguoiCapNhat,
    required this.createdAt,
    required this.updatedAt,
    this.sao,
    this.nhanXet,
  });

  factory YeuCauCuDan.fromJson(Map<String, dynamic> json) {
    return YeuCauCuDan(
      id: json['id'] as int,
      cuDan: json['cuDan'] as int,
      tenCuDan: json['tenCuDan'] as String? ?? '',
      loaiYeuCau: json['loaiYeuCau'] as int,
      tenLoaiYeuCau: json['tenLoaiYeuCau'] as String? ?? '',
      tieuDe: json['tieuDe'] as String? ?? '',
      noiDung: json['noiDung'] as String? ?? '',
      ngayGui: json['ngayGui'] != null ? DateTime.parse(json['ngayGui'] as String) : DateTime.now(),
      mucDoUuTien: json['mucDoUuTien'] as int,
      mucDoUuTienText: json['mucDoUuTienText'] as String? ?? '',
      trangThai: json['trangThai'] as int,
      trangThaiText: json['trangThaiText'] as String? ?? '',
      nhanVienXuLy: json['nhanVienXuLy'] as int?,
      tenNhanVienXuLy: json['tenNhanVienXuLy'] as String? ?? '',
      ngayHoanThanh: json['ngayHoanThanh'] != null ? DateTime.parse(json['ngayHoanThanh'] as String) : null,
      nguoiCapNhat: json['nguoiCapNhat'] as int?,
      tenNguoiCapNhat: json['tenNguoiCapNhat'] as String? ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : DateTime.now(),
      sao: json['sao'] as int?,
      nhanXet: json['nhanXet'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cuDan': cuDan,
      'tenCuDan': tenCuDan,
      'loaiYeuCau': loaiYeuCau,
      'tenLoaiYeuCau': tenLoaiYeuCau,
      'tieuDe': tieuDe,
      'noiDung': noiDung,
      'ngayGui': ngayGui.toIso8601String(),
      'mucDoUuTien': mucDoUuTien,
      'mucDoUuTienText': mucDoUuTienText,
      'trangThai': trangThai,
      'trangThaiText': trangThaiText,
      'nhanVienXuLy': nhanVienXuLy,
      'tenNhanVienXuLy': tenNhanVienXuLy,
      'ngayHoanThanh': ngayHoanThanh?.toIso8601String(),
      'nguoiCapNhat': nguoiCapNhat,
      'tenNguoiCapNhat': tenNguoiCapNhat,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
