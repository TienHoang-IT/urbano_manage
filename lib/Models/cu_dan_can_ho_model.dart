class CuDanCanHo {
  final int id;
  final int cuDanId;
  final String tenCuDan;
  final String sdtCuDan;
  final String cccdCuDan;
  final String emailCuDan;
  final int canHoId;
  final String soCanHo;
  final String tenToaNha;
  final int vaiTroId;
  final String tenVaiTro;
  final DateTime? ngayChuyenDen;
  final DateTime? ngayChuyenDi;
  final int trangThai;
  final String trangThaiText;

  CuDanCanHo({
    required this.id,
    required this.cuDanId,
    required this.tenCuDan,
    required this.sdtCuDan,
    required this.cccdCuDan,
    required this.emailCuDan,
    required this.canHoId,
    required this.soCanHo,
    required this.tenToaNha,
    required this.vaiTroId,
    required this.tenVaiTro,
    this.ngayChuyenDen,
    this.ngayChuyenDi,
    required this.trangThai,
    required this.trangThaiText,
  });

  factory CuDanCanHo.fromJson(Map<String, dynamic> json) {
    return CuDanCanHo(
      id: json['id'] as int? ?? 0,
      cuDanId: json['cuDanId'] as int? ?? 0,
      tenCuDan: json['tenCuDan'] as String? ?? '',
      sdtCuDan: json['sdtCuDan'] as String? ?? '',
      cccdCuDan: json['cccdCuDan'] as String? ?? '',
      emailCuDan: json['emailCuDan'] as String? ?? '',
      canHoId: json['canHoId'] as int? ?? 0,
      soCanHo: json['soCanHo'] as String? ?? '',
      tenToaNha: json['tenToaNha'] as String? ?? '',
      vaiTroId: json['vaiTroId'] as int? ?? 0,
      tenVaiTro: json['tenVaiTro'] as String? ?? '',
      ngayChuyenDen: json['ngayChuyenDen'] != null ? DateTime.parse(json['ngayChuyenDen'] as String) : null,
      ngayChuyenDi: json['ngayChuyenDi'] != null ? DateTime.parse(json['ngayChuyenDi'] as String) : null,
      trangThai: json['trangThai'] as int? ?? 0,
      trangThaiText: json['trangThaiText'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cuDanId': cuDanId,
      'tenCuDan': tenCuDan,
      'sdtCuDan': sdtCuDan,
      'cccdCuDan': cccdCuDan,
      'emailCuDan': emailCuDan,
      'canHoId': canHoId,
      'soCanHo': soCanHo,
      'tenToaNha': tenToaNha,
      'vaiTroId': vaiTroId,
      'tenVaiTro': tenVaiTro,
      'ngayChuyenDen': ngayChuyenDen?.toIso8601String(),
      'ngayChuyenDi': ngayChuyenDi?.toIso8601String(),
      'trangThai': trangThai,
      'trangThaiText': trangThaiText,
    };
  }
}
