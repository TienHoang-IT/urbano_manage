# SKILL BỔ SUNG — 7 Tính năng nâng cao Flutter Manage

Đọc file này KẾT HỢP với skill chính `urbano-manage-flutter`. Các quy tắc gốc
(MVVM/Provider, AppColors, MainShell 3b, Swagger, ApiConfig) vẫn áp dụng.

---

## F1. TỰ ĐỘNG TẠO HÓA ĐƠN (Auto-Billing) — UI

**Vị trí:** trong màn Hóa đơn (tab HoaDon), thêm nút/FAB phụ "Tạo hóa đơn tháng".

**Luồng:**
1. Bấm nút → hiện dialog chọn tháng/năm (DatePicker hoặc 2 dropdown).
2. Gọi `POST /api/HoaDon/auto-billing` với `{ thang, nam, nguoiTao }`.
   `nguoiTao` = id nhân viên đang đăng nhập (đọc từ SharedPreferences).
3. Hiện kết quả: "Đã tạo X hóa đơn, bỏ qua Y (đã tồn tại)".
4. Refresh danh sách hóa đơn.

**Service:** thêm `autoBilling(int thang, int nam, int nguoiTao)` trong `HoaDonService`.

---

## F2. DASHBOARD PHÂN TÍCH TRỰC QUAN — UI

**Package:** `fl_chart` (hoặc `syncfusion_flutter_charts` nếu đã có).

**Thay đổi DashboardView:**
1. **4 thẻ tổng quan** (giữ nguyên layout hiện có) — data từ `GET /api/Dashboard/statistics`
   field `tongQuan`.
2. **Biểu đồ cột doanh thu 6 tháng** — data từ `doanhThu6Thang`. Cột xanh = đã thu,
   cột xám = tổng tiền. Trục X = tháng, trục Y = triệu đồng.
3. **Biểu đồ tròn yêu cầu theo loại** — data từ `yeuCauTheoLoai`.
4. **Thẻ cảnh báo** (nền đỏ/vàng) — data từ `canhBao`:
   - "X hóa đơn quá hạn" (đỏ, bấm → lọc hóa đơn quá hạn)
   - "Y yêu cầu chờ xử lý > 7 ngày" (vàng)
   - "Z căn hộ trống" (xanh dương)

**ViewModel:** `DashboardViewModel` gọi `GET /api/Dashboard/statistics`, parse toàn bộ
response vào các field cho UI bind. Có `isLoading`/`error` như chuẩn.

**Lưu ý:** biểu đồ đặt trong `SingleChildScrollView` (Dashboard đã scroll được).
Dùng `AppColors` cho màu cột/tròn. Responsive cho cả tablet.

---

## F3. XUẤT BÁO CÁO PDF/EXCEL — UI

**Vị trí:** AppBar của màn Hóa đơn, thêm icon button "Xuất" (biểu tượng download).

**Luồng:**
1. Bấm icon → hiện BottomSheet chọn: "Xuất Excel tháng" / "Xuất biên lai PDF".
2. **Excel:** chọn tháng/năm → gọi `GET /api/BaoCao/hoa-don/excel?thang=X&nam=Y`
   → nhận `bytes` → lưu file bằng `path_provider` + `dart:io` → mở bằng
   `open_file` hoặc `share_plus`.
3. **PDF biên lai:** từ chi tiết 1 hóa đơn → gọi `GET /api/BaoCao/hoa-don/pdf?hoaDonId=X`
   → tương tự lưu + mở.

**Service:** `BaoCaoService` với 2 method nhận `http.Response` dạng bytes
(`response.bodyBytes`), trả `Uint8List`. KHÔNG parse JSON.

**Package cần thêm:** `path_provider`, `open_file` (hoặc `share_plus`).

---

## F4. LỊCH SỬ HOẠT ĐỘNG (Audit Trail) — UI

**Vị trí:** thêm mục "Lịch sử hoạt động" vào Drawer (dưới cùng, trên Đăng xuất).
Chỉ hiện cho vai trò "Quản lý" (xem F7).

**Màn `NhatKyHeThongListView`:**
- Danh sách timeline: icon theo hành động (Tạo=xanh, Sửa=vàng, Xóa=đỏ),
  text "[Tên NV] đã [Hành động] [Bảng tác động] #[Id bản ghi]", thời gian relative
  ("2 giờ trước", "hôm qua").
- Thanh lọc: chọn bảng (dropdown), khoảng thời gian (DateRangePicker).
- Phân trang (infinite scroll hoặc nút "Xem thêm").

**Model:** `NhatKyHeThong` với `fromJson`.
**Service:** `NhatKyHeThongService` gọi `GET /api/NhatKyHeThong?...`.

---

## F5. TÌM KIẾM THÔNG MINH TOÀN CỤC — UI

**Vị trí:** thanh tìm kiếm ở AppBar của MainShell (hoặc Dashboard). Bấm icon search
→ mở `SearchDelegate` hoặc trang tìm kiếm riêng.

**Luồng:**
1. Nhập keyword → debounce 500ms → gọi `GET /api/TimKiem?q=<keyword>`.
2. Hiển thị kết quả phân nhóm: "Căn hộ (2)", "Cư dân (3)", "Hóa đơn (1)", "Phương tiện (1)".
3. Mỗi kết quả bấm vào → điều hướng tới trang chi tiết tương ứng (`Navigator.push`
   vì đây là sub-page, không phải tab).

**Model:** `KetQuaTimKiem` chứa 4 list (canHo, cuDan, hoaDon, phuongTien).
**Service:** `TimKiemService` với `search(String keyword)`.

---

## F6. GÁN CƯ DÂN ↔ CĂN HỘ VỚI TIMELINE — UI

**Vị trí:** trong màn chi tiết Căn hộ (`CanHoDetailView`), thêm tab/section
"Cư dân trong căn hộ".

**Hiển thị:**
- **Đang ở** (NgayChuyenDi == null): thẻ xanh, hiện tên cư dân + vai trò + ngày chuyển đến.
- **Đã chuyển đi**: thẻ xám, hiện tên + khoảng thời gian ở (từ X → đến Y).
- Timeline sắp theo `NgayChuyenDen DESC`.

**Hành động:**
- Nút "Thêm cư dân" → dialog chọn cư dân (dropdown/search) + vai trò + ngày chuyển đến
  → `POST /api/CuDanCanHo`.
- Nút "Chuyển đi" trên thẻ đang ở → `PUT /api/CuDanCanHo/{id}/chuyen-di`.
- Nút "Xóa" (admin) → `DELETE /api/CuDanCanHo/{id}`.

**Tương tự**, trong `CuDanDetailView` thêm section "Lịch sử căn hộ" hiện các căn hộ
cư dân đang/đã ở → `GET /api/CuDanCanHo/cudan/{cuDanId}`.

**Service:** `CuDanCanHoService`.
**Model:** `CuDanCanHoModel` với `fromJson`.

---

## F7. PHÂN QUYỀN THEO VAI TRÒ — UI

**Cơ chế client-side:** sau khi login, lưu thêm `role` (tên chức vụ) vào
SharedPreferences. Drawer ẩn/hiện mục theo vai trò.

**Khi login:** API response giờ có thêm claim `role` trong token (hoặc trả trong
`user.tenChucVu`). Lưu:
```dart
prefs.setString('role', loginResult.user.tenChucVu);
```

**MainShell — ẩn/hiện mục Drawer:**
```dart
final role = prefs.getString('role') ?? '';
final isQuanLy = role == 'Quản lý';
final isKeToan = role == 'Kế toán' || isQuanLy;
final isBaoVe = role == 'Bảo vệ' || isQuanLy;
```

Dùng biến này để `if (isKeToan)` mới hiện mục Hóa đơn/Báo cáo/Auto-billing;
`if (isBaoVe)` hiện Phương tiện; `if (isQuanLy)` hiện Nhân viên/Audit log.

**Mục luôn hiện cho mọi vai trò:** Dashboard, Yêu cầu cư dân, Thông báo, Hồ sơ.

**LƯU Ý:** đây là **ẩn UI** ở client, không phải bảo mật thật (bảo mật nằm ở API
với `[Authorize(Roles=...)]`). Client ẩn menu để UX gọn gàng, không phải để chặn
truy cập — API là tường thành cuối.
