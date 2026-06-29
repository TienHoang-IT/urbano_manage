# Backlog App Flutter — Urbano Manage (cập nhật: Dashboard + Điều hướng)

Workspace `urbano_manage`. Mỗi màn theo "Công thức thêm feature" trong skill
`urbano-manage-flutter`: Model → Service → ViewModel → View → Provider.

> ⚠️ LUẬT SỐ 1: **API chốt tên field JSON (xem Swagger) TRƯỚC** khi dựng màn dùng nó.
> Model Dart dùng đúng tên camelCase đó, đừng đoán.

**Hiện trạng:** đăng nhập xong → vào **thẳng** màn Yêu cầu cư dân. Chưa có Home,
chưa có điều hướng. `ApiConfig` đã tách xong. Mục tiêu trước mắt: **Dashboard +
khung điều hướng** để đi tới các chức năng khác.

---

## 🎯 VIỆC TIẾP THEO (ưu tiên ngay) — Khung điều hướng + Dashboard

Làm theo thứ tự 3 bước nhỏ:

### B1. AuthGate + Logout — `feature/auth-session`
- `AuthGate`: mở app đọc SharedPreferences, có `token` → vào **MainShell**, không →
  `LoginView`. Login thành công cũng điều hướng tới **MainShell** (thay vì
  `YeuCauCuDanView` như hiện tại).
- Logout: xóa `token` + `nhanVien`, về `LoginView`.

### B2. MainShell — khung điều hướng — `feature/app-shell`
- Một `Scaffold` có **Drawer** (hoặc `NavigationRail`/`BottomNav`) liệt kê các mục:
  **Tổng quan (Dashboard)**, Cư dân, Căn hộ, Hóa đơn, Phí dịch vụ, Yêu cầu cư dân,
  Thông báo, Nhân viên, và **Đăng xuất**.
- Body đổi theo mục đang chọn. Mục chưa làm thì hiện placeholder "Đang phát triển".
- Hiện tên nhân viên đang đăng nhập (đọc từ prefs) ở header Drawer.

### B3. Dashboard (màn Tổng quan) — `feature/dashboard`
- Lưới **thẻ thống kê**: ví dụ Số cư dân, Số căn hộ, Hóa đơn chưa thanh toán,
  Yêu cầu chờ xử lý. Ban đầu lấy số đếm từ API list sẵn có (vd đếm `yeu_cau_cu_dan`
  có `trangThai == 1`). Sau này thay bằng API thống kê riêng nếu cần.
- Mỗi thẻ bấm vào → điều hướng sang màn tương ứng trong MainShell.
- Dùng `AppColors` + `core/Widgets`; có loading/error; trạng thái rỗng gọn gàng.

**Prompt cho B2 + B3** (Plan mode):

> Đọc skill **urbano-manage-flutter**. Tạo **khung điều hướng + Dashboard** cho app quản lý:
> 1. `MainShell` (Scaffold + Drawer) với các mục: Tổng quan, Cư dân, Căn hộ, Hóa đơn,
>    Phí dịch vụ, Yêu cầu cư dân, Thông báo, Nhân viên, Đăng xuất. Body đổi theo mục;
>    mục chưa có màn thì hiện placeholder "Đang phát triển". Header Drawer hiện tên
>    nhân viên đang đăng nhập (đọc `nhanVien` từ SharedPreferences).
> 2. Màn **Dashboard** (Tổng quan): lưới thẻ thống kê (Số cư dân, Số căn hộ, Hóa đơn
>    chưa thanh toán, Yêu cầu chờ xử lý). Lấy số đếm từ các API list hiện có; thẻ nào
>    chưa có API thì hiện "—". Bấm thẻ điều hướng sang màn tương ứng.
> 3. Sau đăng nhập điều hướng tới `MainShell` (không vào thẳng Yêu cầu cư dân nữa);
>    màn Yêu cầu cư dân hiện tại trở thành một mục trong Shell.
> 4. Dùng `AppColors` + `core/Widgets`, MVVM/Provider theo mẫu, `ApiConfig.baseUrl`.
>    Viết test ViewModel của Dashboard. `flutter analyze` sạch. Lập plan trước, chưa code.

---

## WAVE 1 — Màn nghiệp vụ (gắn vào MainShell, cần API tương ứng đã xong)

| Mục trong Shell | API phụ thuộc | Tình trạng API | Nhánh |
|---|---|---|---|
| **Cư dân** (list/chi tiết/CRUD) | CuDan | ✅ đủ CRUD | `feature/cudan-screen` |
| **Yêu cầu cư dân** | YeuCauCuDan | ⚠️ xác nhận trên Swagger | (đã có UI, ghép vào Shell) |
| **Hóa đơn** (xem/lọc) | HoaDon | ✅ GET | `feature/hoadon-screen` |
| **Thông báo** (xem) | ThongBao | ✅ GET | `feature/thongbao-screen` |
| **Nhân viên** (list/chi tiết) | NhanVien | ✅ GET (login + đọc) | `feature/nhanvien-screen` |

## WAVE 2 — Mở rộng (cần API trước)

| Mục | API | Nhánh |
|---|---|---|
| Căn hộ | CanHo | `feature/canho-screen` |
| Phí dịch vụ | PhiDichVu | `feature/phidichvu-screen` |
| Phương tiện | PhuongTien | `feature/phuongtien-screen` |
| Bảng tin | BangTin | `feature/bangtin-screen` |
| Gán cư dân ↔ căn hộ | CuDanCanHo | `feature/gan-cudan-canho` |

## WAVE 3 — Hoàn thiện

Hồ sơ cá nhân + đổi mật khẩu (`feature/profile`); thẻ thống kê Dashboard nâng cấp
dùng API tổng hợp (`feature/dashboard-stats`); polish UI, pull-to-refresh, trạng thái
rỗng (`feature/ui-polish`); xử lý `401` (token hết hạn) tự đẩy về Login.

---

## PROMPT MẪU dựng một màn (thay `<TÊN>`) — Plan mode

> Đọc skill **urbano-manage-flutter**. Tạo màn **`<TÊN>`** theo "Công thức thêm
> feature", bám style `features/yeu_cau_cu_dan`, và **gắn vào MainShell** như một mục.
> Model dùng đúng field JSON từ `/api/<TÊN>` (đã xem Swagger). Service lấy URL từ
> `ApiConfig.baseUrl`. ViewModel theo mẫu isLoading/error/try-catch-finally. View dùng
> `AppColors` + `core/Widgets`, có loading/error, dispose controller. Viết test
> ViewModel. `flutter analyze` + `flutter test` xanh. Lập plan trước, chưa code.

---

## TRÌNH TỰ ĐỀ XUẤT

1. **B1 → B2 → B3** (session + shell + dashboard) — làm ngay, gần như không phụ thuộc API.
2. Ghép **Yêu cầu cư dân** (đã có) vào Shell; xác nhận API YeuCauCuDan trên Swagger.
3. **Cư dân** — làm trước vì API CuDan đã đủ; test luôn khung điều hướng.
4. Các màn còn lại theo tiến độ API (pipeline song song: API làm feature N+1 trong khi
   manage dựng màn N đã chốt JSON). Hai repo, hai nhánh `develop` riêng.
