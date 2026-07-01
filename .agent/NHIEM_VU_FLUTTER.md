# NHIỆM VỤ FLUTTER — Urbano Manage (phân tích từ code thật, cập nhật)

## HIỆN TRẠNG SAU PHÂN TÍCH

### ĐÃ CÓ — 8 tab trong MainShell (IndexedStack)

| Tab | Màn | Model | Service | ViewModel | Views | Mức hoàn thiện |
|---|---|---|---|---|---|---|
| 0 | Dashboard | — | (gọi nhiều service) | ✅ | ✅ | ⚠️ Đếm client-side, chậm |
| 1 | Cư dân | ✅ | ✅ (full CRUD) | ✅ | List + Detail + Form | ✅ **ĐẦY ĐỦ** |
| 2 | Căn hộ | ❌ | ❌ | ❌ | **Placeholder** | ❌ Chưa làm |
| 3 | Hóa đơn | ✅ | ⚠️ (chỉ GET) | ✅ | List + Detail | ⚠️ Chỉ xem |
| 4 | Phí dịch vụ | ❌ | ❌ | ❌ | **Placeholder** | ❌ Chưa làm |
| 5 | Yêu cầu cư dân | ✅ | ✅ (list + status) | ✅ | List + Detail | ⚠️ Xem + đổi trạng thái |
| 6 | Thông báo | ✅ | ⚠️ (chỉ GET) | ✅ | List (xem) | ⚠️ **Chỉ xem, không tạo** |
| 7 | Nhân viên | ✅ | ⚠️ (chỉ GET) | ✅ | List + Detail | ⚠️ Chỉ xem |

**Không có trong Shell:** Bảng tin, Phương tiện, Hồ sơ/Đổi MK, Gán cư dân↔căn hộ.

### VẤN ĐỀ CỐT LÕI
App hiện tại gần như **chỉ đọc** — quản trị viên nhìn được nhưng **không quản lý được**.
Chỉ CuDan có form tạo/sửa/xóa. Các màn khác thiếu nút Thêm/Sửa/Xóa.

---

## NHIỆM VỤ THEO THỨ TỰ ƯU TIÊN

### ƯU TIÊN 1 — Nâng cấp màn hiện có từ "chỉ xem" lên "quản lý được"

#### 1.1 Thông báo — thêm TẠO + SỬA + XÓA
**API cần trước:** ThongBao thêm PUT (nhiệm vụ API 1.1)
```
Prompt: Đọc skill + mở Swagger http://localhost:5080/swagger/index.html xem schema
ThongBao. Nâng cấp màn Thông báo:
1. Service: thêm createThongBao(body), updateThongBao(id, body), deleteThongBao(id).
2. ViewModel: thêm method tạo/sửa/xóa, cập nhật list.
3. View: thêm FAB "Tạo thông báo" mở form (tiêu đề + nội dung). List item có nút
   Sửa/Xóa (slide-to-delete hoặc menu). Form dùng cho cả tạo và sửa.
4. heroTag duy nhất cho FAB. Gắn vào MainShell đúng skill 3b.
flutter analyze sạch + test. Lập plan trước.
```
- Nhánh: `feature/thongbao-crud-ui`

#### 1.2 Hóa đơn — thêm TẠO + SỬA + XÓA + LỌC
**API cần trước:** HoaDon filter (nhiệm vụ API 1.4)
```
Prompt: Nâng cấp màn Hóa đơn:
1. Service: thêm createHoaDon, updateHoaDon, deleteHoaDon, fetchHoaDons có filter
   (trangThai, thang, nam).
2. ViewModel: method CRUD + lọc, lưu trạng thái filter hiện tại.
3. View: FAB tạo hóa đơn, form tạo/sửa (chọn căn hộ, phí dịch vụ, số tiền, hạn).
   Thanh lọc (chip/tab trạng thái + chọn tháng/năm). Detail view có nút Sửa/Xóa.
4. Gắn vào MainShell đúng skill 3b.
flutter analyze + test. Lập plan trước.
```
- Nhánh: `feature/hoadon-crud-ui`

#### 1.3 Nhân viên — thêm TẠO + SỬA + XÓA
**API đã đủ CRUD.**
```
Prompt: Nâng cấp màn Nhân viên:
1. Service: thêm createNhanVien, updateNhanVien, deleteNhanVien.
2. ViewModel: method CRUD.
3. View: FAB tạo nhân viên, form (họ tên, email, mã NV, chức vụ, mật khẩu).
   Detail view có nút Sửa/Xóa. Xác nhận trước khi xóa.
4. Gắn vào MainShell đúng skill 3b.
flutter analyze + test. Lập plan trước.
```
- Nhánh: `feature/nhanvien-crud-ui`

#### 1.4 Yêu cầu cư dân — thêm TẠO (từ phía quản lý) + XÓA
**API đã đủ.**
```
Prompt: Nâng cấp:
1. Service: thêm createYeuCau, deleteYeuCau.
2. View: FAB tạo yêu cầu, form (loại yêu cầu, tiêu đề, nội dung, chọn cư dân).
   Detail view có nút Xóa (dành cho yêu cầu spam/sai).
flutter analyze + test. Lập plan trước.
```
- Nhánh: `feature/yeucau-crud-ui`

### ƯU TIÊN 2 — Xây màn mới (thay placeholder)

#### 2.1 Căn hộ — full CRUD (thay placeholder tab 2)
**API đã đủ CRUD.**
```
Prompt: Đọc skill + Swagger. Tạo feature **Căn hộ** hoàn chỉnh thay thế placeholder:
1. Model: can_ho_model.dart (fromJson đúng field Swagger: id, toaNhaId, tenToaNha,
   soCanHo, tang, trangThaiId, tenTrangThai, gia, loaiCanHoId, tenLoaiCanHo...).
2. Service: fetchAll, getById, create, update, delete.
3. ViewModel: isLoading/error, CRUD methods, tìm kiếm.
4. Views: list (search + filter theo tòa nhà), detail, form (chọn tòa nhà dropdown,
   loại căn hộ dropdown, trạng thái dropdown, nhập số căn hộ/tầng/giá).
   Dropdown lấy data từ API ToaNha, LoaiCanHo, TrangThaiCanHo.
5. Thay _PlaceholderPage('Căn hộ') bằng CanHoListView trong MainShell IndexedStack.
flutter analyze + test. Lập plan trước.
```
- Nhánh: `feature/canho-screen`

#### 2.2 Phí dịch vụ — full CRUD (thay placeholder tab 4)
**API đã đủ CRUD.**
```
Prompt: Tương tự Căn hộ. Tạo feature Phí dịch vụ thay placeholder:
1. Model: phi_dich_vu_model.dart (field: id, tenPhiDichVu, donGia, loaiPhiDichVuId,
   tenLoaiPhiDichVu, donViTinhId, tenDonViTinh, loaiTinhPhiId, tenLoaiTinhPhi...).
2. Service: CRUD.
3. ViewModel: CRUD + tìm kiếm.
4. Views: list, detail, form (dropdown loại phí, đơn vị tính, loại tính phí).
5. Thay placeholder trong MainShell.
flutter analyze + test. Lập plan trước.
```
- Nhánh: `feature/phidichvu-screen`

### ƯU TIÊN 3 — Tính năng mới (thêm vào Shell)

#### 3.1 Bảng tin — thêm tab mới vào Shell
**API đã đủ CRUD.**
```
Prompt: Tạo feature Bảng tin (tin tức/thông cáo nội bộ):
Model, Service, ViewModel, Views (list + detail + form: tiêu đề, nội dung, hình URL).
Thêm mục "Bảng tin" vào Drawer + IndexedStack trong MainShell. Bấm Dashboard card
(nếu thêm) dùng onNavigate(index).
flutter analyze + test. Lập plan trước.
```
- Nhánh: `feature/bangtin-screen`

#### 3.2 Phương tiện — thêm tab mới vào Shell
**API đã đủ CRUD.**
```
Prompt: Tạo feature Phương tiện (xe máy/ô tô cư dân):
Model, Service, ViewModel, Views (list + detail + form: biển số, loại, chủ sở hữu).
Dropdown loại phương tiện từ API LoaiPhuongTien.
Thêm vào Shell. flutter analyze + test. Lập plan trước.
```
- Nhánh: `feature/phuongtien-screen`

#### 3.3 Gán cư dân ↔ căn hộ
**API cần trước:** CuDanCanHo (nhiệm vụ API 2.1)
```
Prompt: Trong màn chi tiết Căn hộ, thêm tab/section "Cư dân trong căn hộ":
- Hiển thị danh sách cư dân đang ở (từ API CuDanCanHo).
- Nút Thêm cư dân (chọn từ danh sách cư dân chưa có căn hộ).
- Nút Gỡ (xóa liên kết).
Tương tự, trong chi tiết Cư dân thêm section "Căn hộ đang ở".
flutter analyze + test. Lập plan trước.
```
- Nhánh: `feature/cudan-canho-assign`

#### 3.4 Dashboard nâng cấp — dùng API thống kê
**API cần trước:** DashboardController (nhiệm vụ API 1.3)
```
Prompt: Sửa DashboardService + ViewModel: gọi GET /api/Dashboard/stats thay vì
đếm client-side. Hiện thêm thẻ: thông báo tháng này, cư dân mới 30 ngày.
flutter analyze + test. Lập plan trước.
```
- Nhánh: `feature/dashboard-upgrade`

### ƯU TIÊN 4 — Hoàn thiện

#### 4.1 Hồ sơ cá nhân + đổi mật khẩu
**API cần trước:** NhanVien change-password (nhiệm vụ API 1.2)
```
Prompt: Tạo màn Hồ sơ (mở từ avatar/tên trong Drawer, không phải tab):
- Hiện thông tin nhân viên đang đăng nhập.
- Form đổi mật khẩu (mật khẩu cũ + mật khẩu mới + xác nhận).
- Gọi PUT /api/NhanVien/{id}/change-password.
Navigator.push (không phải tab trong Shell). flutter analyze + test.
```
- Nhánh: `feature/profile-screen`

#### 4.2 UI Polish
```
Prompt: Rà soát toàn bộ app:
- Pull-to-refresh cho mọi list.
- Trạng thái rỗng (empty state) khi list = 0 (icon + text "Chưa có dữ liệu").
- Xác nhận trước khi xóa ở mọi màn (dialog).
- SnackBar thống nhất: xanh = thành công, đỏ = lỗi.
- Loading skeleton thay CircularProgressIndicator nếu muốn.
flutter analyze + test.
```
- Nhánh: `feature/ui-polish`

---

## PIPELINE SONG SONG (API ↔ Flutter)

```
Nhịp 1: API 1.1 (ThongBao PUT)     → Flutter 1.3 (NhanVien CRUD, API đã đủ)
Nhịp 2: API 1.2 (NV change-pw)     → Flutter 1.1 (ThongBao CRUD, API 1.1 xong)
Nhịp 3: API 1.3 (Dashboard stats)  → Flutter 1.2 (HoaDon CRUD, API 1.4 xong)
Nhịp 4: API 1.4 (HoaDon filter)    → Flutter 1.4 (YeuCau tạo/xóa, API đã đủ)
Nhịp 5: API 2.1 (CuDanCanHo)       → Flutter 2.1 (Căn hộ screen, API đã đủ)
Nhịp 6: API 2.2 (CanHoPhiDichVu)   → Flutter 2.2 (Phí dịch vụ screen, API đã đủ)
Nhịp 7: API 2.3 (ThongBaoDaDoc)    → Flutter 3.1 (Bảng tin, API đã đủ)
Nhịp 8: API 3.1 (LichSuThanhToan)  → Flutter 3.2 (Phương tiện, API đã đủ)
         ...                        → Flutter 3.3, 3.4, 4.1, 4.2
```

Nguyên tắc: Flutter **chỉ làm màn khi API endpoint tương ứng đã tồn tại trên Swagger**.
Những màn mà API đã đủ (NhanVien CRUD, Căn hộ, Phí dịch vụ, Bảng tin, Phương tiện,
YeuCauCuDan tạo/xóa) → **Flutter làm được ngay** không cần chờ.

---

## PROMPT TÀI XẾ FLUTTER (chạy tất cả — Agent-driven)

> Đọc skill **urbano-manage-flutter**. Làm lần lượt:
>
> 1. NhanVien: nâng cấp lên CRUD (FAB tạo, form, detail có Sửa/Xóa)
> 2. YeuCauCuDan: thêm FAB tạo yêu cầu + nút Xóa ở detail
> 3. Căn hộ: tạo feature thay placeholder (Model+Service+VM+Views, dropdown ToaNha/LoaiCanHo/TrangThai)
> 4. Phí dịch vụ: tạo feature thay placeholder (dropdown LoaiPhi/DonViTinh/LoaiTinhPhi)
> 5. ThongBao: thêm tạo/sửa/xóa (sau khi API có PUT — kiểm Swagger trước)
> 6. HoaDon: thêm CRUD + filter (sau khi API có filter — kiểm Swagger trước)
> 7. Bảng tin: tạo feature mới, thêm vào Shell
> 8. Phương tiện: tạo feature mới, thêm vào Shell
> 9. Dashboard: đổi sang gọi API stats (nếu endpoint đã có)
>
> Mỗi feature: mở Swagger lấy đúng field, theo skill 3b (body trong MainShell),
> heroTag cho FAB. `flutter analyze` sạch + `flutter test` pass → commit.
> Nếu API endpoint chưa có trên Swagger → bỏ qua, ghi lại, làm feature khác.
> Cuối cùng in báo cáo.
