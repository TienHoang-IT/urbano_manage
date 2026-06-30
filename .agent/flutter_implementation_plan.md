# 📱 FLUTTER IMPLEMENTATION PLAN (urbano_manage)

Bản kế hoạch này dành cho AI phát triển dự án Flutter **urbano_manage** (MVVM + Provider + Dark Mode). Tập trung vào việc hoàn thiện giao diện CRUD cho quản lý của 8 module chính trên Drawer. KHÔNG thực hiện module Hợp đồng.

---

## 🎯 CẤU TRÚC KIẾN TRÚC HIỆN TẠI (CẦN TUÂN THỦ)
- **State Management**: Sử dụng `Provider` và `ChangeNotifier`.
- **Theme**: Dark mode đồng bộ với màu Teal làm chủ đạo (`AppColors` trong `lib/core/constants/app_colors.dart`).
- **Layout**: `MainShellView` với Drawer điều hướng tương ứng 8 tab trong `NavigationTabs`.
- **Pattern**: 
  - `Models/[entity]_model.dart`
  - `Services/[entity]_service.dart`
  - `features/[feature_name]/ViewModels/[entity]_viewmodel.dart`
  - `features/[feature_name]/Views/[entity]_list_view.dart`
  - `features/[feature_name]/Views/[entity]_detail_view.dart`
  - `features/[feature_name]/Views/[entity]_form_view.dart`

---

## 🛠️ CHI TIẾT CÁC NHIỆM VỤ PHẢI LÀM

### NHIỆM VỤ 1: HOÀN THIỆN CRUD CHO CÁC MODULE ĐÃ CÓ MỘT PHẦN

#### 1. Module Nhân Viên (NhanVien) - Thêm Create, Edit, Delete
- **Hiện trạng**: Mới chỉ có List + Detail (Read-only).
- **Cần làm**:
  1. Thêm các method `createNhanVien`, `updateNhanVien`, `deleteNhanVien` vào `NhanVienService`.
  2. Bổ sung hàm xử lý logic tương ứng trong `NhanVienViewModel`.
  3. Tạo mới `nhan_vien_form_view.dart`: Sử dụng form với các trường: *Họ tên, Chức vụ (Dropdown), SĐT, Email, Mật khẩu, Mã NV, CCCD, Ngày sinh, Ghi chú*.
  4. Thêm nút Edit/Delete vào `nhan_vien_detail_view.dart` và FAB "+" vào `nhan_vien_list_view.dart`.

#### 2. Module Hóa Đơn (HoaDon) - Thêm Create, Edit, Delete
- **Hiện trạng**: Mới chỉ có List + Detail (Read-only).
- **Cần làm**:
  1. Thêm các phương thức ghi/sửa/xóa hóa đơn vào `HoaDonService` và `HoaDonViewModel`.
  2. Tạo mới `hoa_don_form_view.dart`: Chọn căn hộ (Dropdown), nhập Tháng, Năm, Tổng tiền, Hạn thanh toán (DatePicker), Trạng thái thanh toán.
  3. Tích hợp quản lý thêm/sửa chi tiết hóa đơn (các mục phí con) và nút ghi nhận thanh toán trong giao diện chi tiết hóa đơn.

#### 3. Module Thông Báo (ThongBao) - Thêm CRUD Hoàn Chỉnh
- **Hiện trạng**: Chỉ hiển thị List và hiện chi tiết bằng Dialog.
- **Cần làm**:
  1. Viết các API call trong `ThongBaoService` để tạo, cập nhật và xóa thông báo.
  2. Tạo trang chi tiết riêng biệt `thong_bao_detail_view.dart` thay vì dùng Dialog để hiển thị đầy đủ nội dung, thời gian và có nút Edit/Delete.
  3. Tạo trang form `thong_bao_form_view.dart` để quản lý đăng tải/chỉnh sửa thông báo.

#### 4. Module Yêu Cầu Cư Dân (YeuCauCuDan) - Phân Công Xử Lý
- **Hiện trạng**: Mới chỉ cho phép đổi trạng thái.
- **Cần làm**:
  1. Cập nhật `YeuCauCuDanDetailView`: Thay thế việc lấy cứng ID nhân viên xử lý thành lấy ID của Nhân viên đang đăng nhập (lưu trong SharedPreferences).
  2. Thêm Dropdown cho phép quản lý chọn phân công một nhân viên kỹ thuật/lễ tân khác chịu trách nhiệm xử lý yêu cầu đó.

---

### NHIỆM VỤ 2: PHÁT TRIỂN MODULE MỚI THAY THẾ PLACEHOLDER

#### 1. Module Căn Hộ (CanHo) - Thay thế Placeholder Tab 2
- **Hiện trạng**: Đang hiển thị Widget placeholder trống.
- **Cần làm**: Phát triển trọn bộ cấu trúc MVVM cho Căn Hộ (kết nối tới API `/api/CanHo` đã có sẵn trên backend):
  - `can_ho_model.dart`: Định nghĩa model căn hộ.
  - `can_ho_service.dart`: Các hàm gọi API CRUD.
  - `can_ho_viewmodel.dart`: Quản lý state của danh sách và form.
  - `can_ho_list_view.dart`: Hiển thị danh sách, thanh tìm kiếm theo số căn hộ, lọc theo trạng thái và nút thêm mới.
  - `can_ho_detail_view.dart`: Chi tiết căn hộ, hiển thị thông tin tòa nhà, loại căn hộ, giá. Bổ sung nút Sửa/Xóa.
  - `can_ho_form_view.dart`: Form thêm/sửa thông tin căn hộ.
  - Thay thế Placeholder ở tab index 2 trong `MainShellView`.

#### 2. Module Phí Dịch Vụ (PhiDichVu) - Thay thế Placeholder Tab 4
- **Hiện trạng**: Đang hiển thị Widget placeholder trống.
- **Cần làm**: Phát triển trọn bộ cấu trúc MVVM cho Phí Dịch Vụ (kết nối tới API `/api/PhiDichVu` đã có sẵn):
  - Tạo model, service, viewmodel và 3 views (List, Detail, Form) tương tự như module Căn hộ.
  - Form fields: *Tên phí dịch vụ, Đơn giá, Loại phí (Dropdown), Đơn vị tính (Dropdown), Cách tính phí (Dropdown)*.
  - Thay thế Placeholder ở tab index 4 trong `MainShellView`.

---

### NHIỆM VỤ 3: NÂNG CẤP DASHBOARD & UX TIỆN ÍCH

#### 1. Tích Hợp API Thống Kê Dashboard
- **Cần làm**: Thay thế mock data trên `DashboardView` bằng cách gọi API thống kê `/api/Dashboard/statistics`. Hiển thị biểu đồ biểu diễn doanh thu hóa đơn hoặc tỉ lệ trạng thái yêu cầu của cư dân (sử dụng package `fl_chart`).

#### 2. Tự động xử lý hết hạn phiên đăng nhập (JWT Expiry)
- **Cần làm**: Sửa helper HTTP hoặc class mạng của bạn (ví dụ `auth_http.dart` hoặc wrapper HTTP request). 
  - Nếu API phản hồi mã lỗi `401 Unauthorized`, thực hiện xóa token và thông tin nhân viên khỏi `SharedPreferences`.
  - Tự động chuyển hướng người dùng về màn hình đăng nhập `LoginView` và hiển thị SnackBar cảnh báo.

#### 3. Xây Dựng Bộ Widgets Dùng Chung Đồng Bộ
- Thiết kế các widget tái sử dụng để code sạch hơn:
  - `AppDropdownField`: Dropdown styled tối đồng bộ.
  - `AppDatePicker`: Chọn ngày tháng có UI đồng bộ tông màu tối/teal.
  - `AppConfirmDialog`: Dialog xác nhận trước khi thực hiện thao tác Xóa.
  - `AppLoadingShimmer`: Skeleton loading thay thế cho vòng xoay tải tròn thông thường.
