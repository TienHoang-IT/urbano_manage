class TongQuan {
  final int totalCuDan;
  final int totalCanHo;
  final int hoaDonChuaThanhToan;
  final int yeuCauChoXuLy;

  TongQuan({
    required this.totalCuDan,
    required this.totalCanHo,
    required this.hoaDonChuaThanhToan,
    required this.yeuCauChoXuLy,
  });

  factory TongQuan.fromJson(Map<String, dynamic> json) {
    return TongQuan(
      totalCuDan: json['totalCuDan'] as int? ?? 0,
      totalCanHo: json['totalCanHo'] as int? ?? 0,
      hoaDonChuaThanhToan: json['hoaDonChuaThanhToan'] as int? ?? 0,
      yeuCauChoXuLy: json['yeuCauChoXuLy'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCuDan': totalCuDan,
      'totalCanHo': totalCanHo,
      'hoaDonChuaThanhToan': hoaDonChuaThanhToan,
      'yeuCauChoXuLy': yeuCauChoXuLy,
    };
  }
}

class DoanhThuThang {
  final int thang;
  final int nam;
  final double tongTien;
  final double daThu;

  DoanhThuThang({
    required this.thang,
    required this.nam,
    required this.tongTien,
    required this.daThu,
  });

  factory DoanhThuThang.fromJson(Map<String, dynamic> json) {
    return DoanhThuThang(
      thang: json['thang'] as int? ?? 0,
      nam: json['nam'] as int? ?? 0,
      tongTien: (json['tongTien'] as num? ?? 0.0).toDouble(),
      daThu: (json['daThu'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'thang': thang,
      'nam': nam,
      'tongTien': tongTien,
      'daThu': daThu,
    };
  }
}

class YeuCauTheoLoai {
  final String tenLoai;
  final int soLuong;

  YeuCauTheoLoai({
    required this.tenLoai,
    required this.soLuong,
  });

  factory YeuCauTheoLoai.fromJson(Map<String, dynamic> json) {
    return YeuCauTheoLoai(
      tenLoai: json['tenLoai'] as String? ?? 'Khác',
      soLuong: json['soLuong'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenLoai': tenLoai,
      'soLuong': soLuong,
    };
  }
}

class CanhBao {
  final int hoaDonQuaHan;
  final int yeuCauQuaHan7Ngay;
  final int canHoTrong;

  CanhBao({
    required this.hoaDonQuaHan,
    required this.yeuCauQuaHan7Ngay,
    required this.canHoTrong,
  });

  factory CanhBao.fromJson(Map<String, dynamic> json) {
    return CanhBao(
      hoaDonQuaHan: json['hoaDonQuaHan'] as int? ?? 0,
      yeuCauQuaHan7Ngay: json['yeuCauQuaHan7Ngay'] as int? ?? 0,
      canHoTrong: json['canHoTrong'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hoaDonQuaHan': hoaDonQuaHan,
      'yeuCauQuaHan7Ngay': yeuCauQuaHan7Ngay,
      'canHoTrong': canHoTrong,
    };
  }
}

class DashboardStatistics {
  final TongQuan tongQuan;
  final List<DoanhThuThang> doanhThu6Thang;
  final List<YeuCauTheoLoai> yeuCauTheoLoai;
  final CanhBao canhBao;

  DashboardStatistics({
    required this.tongQuan,
    required this.doanhThu6Thang,
    required this.yeuCauTheoLoai,
    required this.canhBao,
  });

  factory DashboardStatistics.fromJson(Map<String, dynamic> json) {
    final tqJson = json['tongQuan'] as Map<String, dynamic>? ?? {};
    final cbJson = json['canhBao'] as Map<String, dynamic>? ?? {};
    
    final dtList = json['doanhThu6Thang'] as List? ?? [];
    final ycList = json['yeuCauTheoLoai'] as List? ?? [];

    return DashboardStatistics(
      tongQuan: TongQuan.fromJson(tqJson),
      doanhThu6Thang: dtList.map((e) => DoanhThuThang.fromJson(e as Map<String, dynamic>)).toList(),
      yeuCauTheoLoai: ycList.map((e) => YeuCauTheoLoai.fromJson(e as Map<String, dynamic>)).toList(),
      canhBao: CanhBao.fromJson(cbJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tongQuan': tongQuan.toJson(),
      'doanhThu6Thang': doanhThu6Thang.map((e) => e.toJson()).toList(),
      'yeuCauTheoLoai': yeuCauTheoLoai.map((e) => e.toJson()).toList(),
      'canhBao': canhBao.toJson(),
    };
  }
}
