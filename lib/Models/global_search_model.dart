class SearchCanHo {
  final int id;
  final String soCanHo;
  final String tenToaNha;

  SearchCanHo({
    required this.id,
    required this.soCanHo,
    required this.tenToaNha,
  });

  factory SearchCanHo.fromJson(Map<String, dynamic> json) {
    return SearchCanHo(
      id: json['id'] as int? ?? 0,
      soCanHo: json['soCanHo'] as String? ?? '',
      tenToaNha: json['tenToaNha'] as String? ?? '',
    );
  }
}

class SearchCuDan {
  final int id;
  final String hoTen;
  final String soCanHo;

  SearchCuDan({
    required this.id,
    required this.hoTen,
    required this.soCanHo,
  });

  factory SearchCuDan.fromJson(Map<String, dynamic> json) {
    return SearchCuDan(
      id: json['id'] as int? ?? 0,
      hoTen: json['hoTen'] as String? ?? '',
      soCanHo: json['soCanHo'] as String? ?? '',
    );
  }
}

class SearchHoaDon {
  final int id;
  final String maThanhToan;
  final String soCanHo;

  SearchHoaDon({
    required this.id,
    required this.maThanhToan,
    required this.soCanHo,
  });

  factory SearchHoaDon.fromJson(Map<String, dynamic> json) {
    return SearchHoaDon(
      id: json['id'] as int? ?? 0,
      maThanhToan: json['maThanhToan'] as String? ?? '',
      soCanHo: json['soCanHo'] as String? ?? '',
    );
  }
}

class SearchPhuongTien {
  final int id;
  final String bienSo;
  final String soCanHo;

  SearchPhuongTien({
    required this.id,
    required this.bienSo,
    required this.soCanHo,
  });

  factory SearchPhuongTien.fromJson(Map<String, dynamic> json) {
    return SearchPhuongTien(
      id: json['id'] as int? ?? 0,
      bienSo: json['bienSo'] as String? ?? '',
      soCanHo: json['soCanHo'] as String? ?? '',
    );
  }
}

class GlobalSearchData {
  final List<SearchCanHo> canHo;
  final List<SearchCuDan> cuDan;
  final List<SearchHoaDon> hoaDon;
  final List<SearchPhuongTien> phuongTien;

  GlobalSearchData({
    required this.canHo,
    required this.cuDan,
    required this.hoaDon,
    required this.phuongTien,
  });

  factory GlobalSearchData.fromJson(Map<String, dynamic> json) {
    final chList = json['canHo'] as List? ?? [];
    final cdList = json['cuDan'] as List? ?? [];
    final hdList = json['hoaDon'] as List? ?? [];
    final ptList = json['phuongTien'] as List? ?? [];

    return GlobalSearchData(
      canHo: chList.map((e) => SearchCanHo.fromJson(e as Map<String, dynamic>)).toList(),
      cuDan: cdList.map((e) => SearchCuDan.fromJson(e as Map<String, dynamic>)).toList(),
      hoaDon: hdList.map((e) => SearchHoaDon.fromJson(e as Map<String, dynamic>)).toList(),
      phuongTien: ptList.map((e) => SearchPhuongTien.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
