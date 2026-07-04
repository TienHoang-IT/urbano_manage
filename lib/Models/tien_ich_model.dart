class TienIch {
  final int id;
  final String tenTienIch;
  final int loaiTienIchId;
  final String tenLoaiTienIch;
  final int? toaNhaId;
  final String tenToaNha;
  final String moTa;
  final String viTri;
  final int? sucChua;
  final String? gioMoCua;
  final String? gioDongCua;
  final double phiSuDung;
  final bool canDatTruoc;
  final String hinhUrl;
  final int trangThai;
  final String trangThaiText;
  final DateTime createdAt;
  final DateTime updatedAt;

  TienIch({
    required this.id,
    required this.tenTienIch,
    required this.loaiTienIchId,
    required this.tenLoaiTienIch,
    this.toaNhaId,
    required this.tenToaNha,
    required this.moTa,
    required this.viTri,
    this.sucChua,
    this.gioMoCua,
    this.gioDongCua,
    required this.phiSuDung,
    required this.canDatTruoc,
    required this.hinhUrl,
    required this.trangThai,
    required this.trangThaiText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TienIch.fromJson(Map<String, dynamic> json) {
    return TienIch(
      id: json['id'] as int? ?? 0,
      tenTienIch: json['tenTienIch'] as String? ?? '',
      loaiTienIchId: (json['loaiTienIch'] ?? json['loaiTienIchId']) as int? ?? 0,
      tenLoaiTienIch: json['tenLoaiTienIch'] as String? ?? '',
      toaNhaId: (json['toaNha'] ?? json['toaNhaId']) as int?,
      tenToaNha: json['tenToaNha'] as String? ?? '',
      moTa: json['moTa'] as String? ?? '',
      viTri: json['viTri'] as String? ?? '',
      sucChua: json['sucChua'] as int?,
      gioMoCua: json['gioMoCua'] as String?,
      gioDongCua: json['gioDongCua'] as String?,
      phiSuDung: (json['phiSuDung'] as num? ?? 0).toDouble(),
      canDatTruoc: json['canDatTruoc'] as bool? ?? false,
      hinhUrl: json['hinhUrl'] as String? ?? '',
      trangThai: json['trangThai'] as int? ?? 1,
      trangThaiText: json['trangThaiText'] as String? ?? '',
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
      'tenTienIch': tenTienIch,
      'loaiTienIch': loaiTienIchId,
      'toaNha': toaNhaId,
      'moTa': moTa,
      'viTri': viTri,
      'sucChua': sucChua,
      'gioMoCua': gioMoCua,
      'gioDongCua': gioDongCua,
      'phiSuDung': phiSuDung,
      'canDatTruoc': canDatTruoc,
      'hinhUrl': hinhUrl,
      'trangThai': trangThai,
    };
  }
}
