---
name: urbano-manage-flutter
description: >
  Quy tắc và công thức bắt buộc khi làm việc trên app Flutter Urbano Manage (bản
  quản lý). Kích hoạt skill này cho MỌI yêu cầu liên quan tới: thêm/sửa màn hình,
  tạo Model, Service gọi API, ViewModel (Provider/ChangeNotifier), View, gọi REST
  bằng package http, đăng nhập nhân viên, danh sách/lọc theo tab, cập nhật trạng
  thái, dùng theme/màu AppColors, widget dùng chung (AppButton, AppTextField),
  hoặc viết test cho ViewModel/Widget. Luôn đọc skill này TRƯỚC khi sinh code Dart
  trong dự án urbano_manage.
---

# Skill: App Flutter Urbano Manage (bản quản lý)

Nguyên tắc số 1: **bắt chước feature đã có** (`features/yeu_cau_cu_dan` và
`features/auth`) — đây là khuôn mẫu chuẩn cho MVVM + Provider. Không tự đổi
kiến trúc, không thêm package state-management khác (giữ `provider`).

## 1. Stack & package (giữ nguyên)
- Flutter, Material 3, theme **tối** (dark). SDK Dart `^3.12.2`.
- State: `provider` (ChangeNotifier) — pattern MVVM.
- Gọi API: `http`. Lưu local: `shared_preferences`. Định dạng ngày/số: `intl`.
- KHÔNG thêm dio/bloc/riverpod/get nếu chưa được duyệt.

## 2. Cấu trúc thư mục (đặt file đúng chỗ)
```
lib/
├── main.dart                 # MultiProvider + MaterialApp + theme
├── Models/                   # model có fromJson/toJson
├── Services/                 # lớp gọi HTTP tới API
├── core/
│   ├── constants/app_colors.dart   # bảng màu dùng chung
│   └── Widgets/                     # AppButton, AppTextField...
└── features/<ten_feature>/
    ├── ViewModels/<ten>_viewmodel.dart
    └── Views/<ten>_view.dart
```
Quy ước đặt tên file: `snake_case.dart`. Class: `PascalCase`. Mỗi feature một thư
mục riêng trong `features/`.

## 3. baseUrl & gọi API
- Backend hiện trỏ tới `http://103.116.39.175/api`. Service đặt URL dạng
  `static const String apiUrl = 'http://103.116.39.175/api/<TenController>';`
  khớp route `api/[controller]` của ASP.NET (vd `YeuCauCuDan`, `NhanVien`, `CanHo`).
- **Luôn decode UTF-8**: `jsonDecode(utf8.decode(response.bodyBytes))` để không lỗi
  tiếng Việt (đừng dùng `response.body` cho dữ liệu có dấu).
- Response list có thể là **mảng trần** hoặc `{ "value": [...] }` — xử lý cả hai
  (xem `YeuCauCuDanService.fetchYeuCaus`).
- Thành công đọc: `statusCode == 200`. Thành công ghi (PUT/DELETE): chấp nhận
  `200 || 204`. Thất bại: `throw Exception('Thông báo tiếng Việt (${response.statusCode})')`.

## 4. Công thức thêm một feature `X` (vd: quản lý Căn hộ)

### Bước 1 — Model (`lib/Models/can_ho_model.dart`)
Theo khuôn `Models/yeu_cau_cu_dan_model.dart`:
- Field `final`, có constructor `required`/nullable hợp lý.
- `factory X.fromJson(Map<String, dynamic> json)` parse **null-safe**:
  - chuỗi: `json['ten'] as String? ?? ''`
  - số nullable: `json['nhanVienXuLy'] as int?`
  - ngày: `json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()`
- `Map<String, dynamic> toJson()` đối xứng, ngày dùng `.toIso8601String()`.
- Tên field JSON phải khớp DTO C# (camelCase: `id`, `tenCuDan`, `trangThai`...).

### Bước 2 — Service (`lib/Services/can_ho_service.dart`)
Class thường, dùng `http`. Mỗi thao tác một method `Future`:
```dart
class CanHoService {
  static const String apiUrl = 'http://103.116.39.175/api/CanHo';

  Future<List<CanHo>> fetchAll() async {
    final res = await http.get(Uri.parse(apiUrl));
    if (res.statusCode == 200) {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      final list = decoded is List ? decoded
          : (decoded is Map && decoded['value'] != null ? decoded['value'] : []);
      return (list as List).map((e) => CanHo.fromJson(e)).toList();
    }
    throw Exception('Không thể tải danh sách căn hộ (${res.statusCode})');
  }

  Future<bool> update(int id, Map<String, dynamic> body) async {
    final res = await http.put(Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
    return res.statusCode == 200 || res.statusCode == 204;
  }
}
```

### Bước 3 — ViewModel (`features/can_ho/ViewModels/can_ho_viewmodel.dart`)
`extends ChangeNotifier`, theo khuôn `YeuCauCuDanViewModel`:
- State công khai: `bool isLoading`, `String? error`, `List<X> items` (+ tab nếu cần).
- Mẫu mỗi tác vụ async: bật `isLoading=true; error=null; notifyListeners();` →
  `try { gọi service } catch (e) { error = 'Thông báo tiếng Việt'; } finally { isLoading=false; notifyListeners(); }`.
- KHÔNG gọi `http` trực tiếp trong ViewModel — luôn qua Service.
- KHÔNG đụng `BuildContext` trong ViewModel.

### Bước 4 — View (`features/can_ho/Views/can_ho_view.dart`)
Theo khuôn `login_view.dart` / `yeu_cau_cu_dan_view.dart`:
- Bọc bằng `ChangeNotifierProvider(create: (_) => XViewModel(), child: _Inner())`
  rồi đọc state qua `context.watch<XViewModel>()` / `Consumer` / `context.read` cho
  hành động. (Hoặc đăng ký provider ở `main.dart` nếu cần dùng toàn cục.)
- Dùng **màu từ `AppColors`** (vd `AppColors.bgDark`, `AppColors.tealPrimary`),
  không hardcode mã màu mới.
- Tái sử dụng widget trong `core/Widgets/` (`AppButton`, `AppTextField`) thay vì
  tự dựng lại button/textfield.
- Hiển thị `isLoading` bằng `CircularProgressIndicator`; hiển thị `error` khi có.
- `StatefulWidget` nào tạo `TextEditingController` thì phải `dispose()` chúng.

### Bước 5 — Đăng ký provider (nếu dùng toàn cục)
Trong `main.dart`, thêm vào `MultiProvider.providers`:
```dart
ChangeNotifierProvider(create: (_) => CanHoViewModel()),
```

## 5. Giao diện theo mẫu
- App theo theme tối, màu chủ đạo teal (`0xFF41B996`). Khi tạo màn mới, **bám
  layout/spacing/màu của các View đã có** làm template; không tự đổi phong cách.
- Trạng thái dùng màu trong `AppColors` (`blue/amber/pink/red`) cho badge/nhãn.

## 6. Quy ước trạng thái (đồng bộ với API)
`yeu_cau_cu_dan.trang_thai`: 1=Chờ xử lý, 2=Đang xử lý, 3=Hoàn thành, 4=Từ chối.
ViewModel có thể gom tab (vd tab "Đã xong" lọc `trangThai == 3 || == 4`) — xem
`YeuCauCuDanViewModel`. Ưu tiên dùng field `*Text` server trả về để hiển thị.

## 7. Test (tránh lỗi cơ bản)
Đặt trong `test/`, dùng `flutter_test` (đã có sẵn).
- **Unit test ViewModel**: tạo ViewModel với một Service giả (tách interface hoặc
  truyền service vào constructor để mock được), gọi method, kiểm tra `isLoading`,
  `error`, `items` đổi đúng. Có thể dùng `package:mockito` hoặc fake class thủ công.
- **Widget test**: bơm View qua `ChangeNotifierProvider` với ViewModel/Service giả,
  `tester.pumpWidget(...)`, kiểm tra hiển thị loading/empty/danh sách.
- Gợi ý: để test được, **cho Service vào ViewModel qua constructor** (mặc định tạo
  thật) thay vì khởi tạo cứng bên trong — vẫn giữ tương thích code hiện có.
- Chạy `flutter analyze` (không lỗi) và `flutter test` (pass) trước khi báo xong.

## 8. Checklist trước khi báo "đã xong"
- [ ] Model có `fromJson`/`toJson` null-safe, tên field khớp DTO C# (camelCase).
- [ ] Service decode UTF-8, xử lý cả list trần lẫn `{value:[]}`, ném Exception tiếng Việt.
- [ ] ViewModel theo mẫu isLoading/error/try-catch-finally, không chạm http/context.
- [ ] View dùng AppColors + core/Widgets, dispose controller, hiện loading/error.
- [ ] Provider đăng ký đúng chỗ.
- [ ] `flutter analyze` sạch, `flutter test` pass.
