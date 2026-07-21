import 'package:flutter/services.dart';

class AppValidators {
  // Regex patterns
  static final RegExp _phoneRegex = RegExp(r'^(?:0|\+84)[35789][0-9]{8}$');
  static final RegExp _emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp _cccdRegex = RegExp(r'^(?:[0-9]{9}|[0-9]{12})$');
  static final RegExp _licensePlateRegex = RegExp(r'^[0-9]{2}[A-Z0-9]{1,2}[-.\s]?[0-9]{3,5}(?:[-.\s]?[0-9]{2,3})?$');
  static final RegExp _vietnameseNameRegex = RegExp(
    r"^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầnẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ\s\.'-]{2,50}$",
  );
  static final RegExp _apartmentCodeRegex = RegExp(r'^[a-zA-Z0-9\-\.\/]{1,20}$');
  static final RegExp _codeRegex = RegExp(r'^[a-zA-Z0-9\-\_]{2,20}$');
  static final RegExp _positiveIntegerRegex = RegExp(r'^[1-9][0-9]*$');

  /// Validates phone number (10 digits starting with 03, 05, 07, 08, 09 or +84)
  static String? validatePhone(String? value, {bool required = false}) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập số điện thoại';
      return null;
    }
    if (!_phoneRegex.hasMatch(str)) {
      return 'Số điện thoại không hợp lệ (gồm 10 chữ số bắt đầu bằng 03, 05, 07, 08, 09)';
    }
    return null;
  }

  /// Validates email address
  static String? validateEmail(String? value, {bool required = false}) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập địa chỉ email';
      return null;
    }
    if (!_emailRegex.hasMatch(str)) {
      return 'Email không đúng định dạng (Ví dụ: example@domain.com)';
    }
    return null;
  }

  /// Validates CCCD / CMND (9 or 12 digits)
  static String? validateCccd(String? value, {bool required = false}) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập số CCCD/CMND';
      return null;
    }
    if (!_cccdRegex.hasMatch(str)) {
      return 'Số CCCD/CMND phải gồm 9 hoặc 12 chữ số';
    }
    return null;
  }

  /// Validates vehicle license plate
  static String? validateLicensePlate(String? value, {bool required = true}) {
    final str = value?.trim().toUpperCase() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập biển số xe';
      return null;
    }
    if (!_licensePlateRegex.hasMatch(str)) {
      return 'Biển số xe không đúng định dạng (Ví dụ: 30A-123.45 hoặc 29H12345)';
    }
    return null;
  }

  /// Validates name (letters, Vietnamese diacritics, spaces, 2-50 chars)
  static String? validateName(String? value, {String fieldName = 'Họ và tên', bool required = true}) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập $fieldName';
      return null;
    }
    if (str.length < 2) {
      return '$fieldName phải từ 2 ký tự trở lên';
    }
    if (!_vietnameseNameRegex.hasMatch(str)) {
      return '$fieldName chỉ được chứa chữ cái và không bao gồm ký tự đặc biệt hay số';
    }
    return null;
  }

  /// Validates apartment number / code
  static String? validateApartmentNumber(String? value, {bool required = true}) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập số căn hộ';
      return null;
    }
    if (!_apartmentCodeRegex.hasMatch(str)) {
      return 'Số căn hộ không hợp lệ (Ví dụ: A-12.04, 101, B2/05)';
    }
    return null;
  }

  /// Validates code / staff ID / bill code
  static String? validateCode(String? value, {String fieldName = 'Mã', bool required = true}) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập $fieldName';
      return null;
    }
    if (!_codeRegex.hasMatch(str)) {
      return '$fieldName chỉ gồm chữ cái, số và dấu - hoặc _ (2-20 ký tự)';
    }
    return null;
  }

  /// Validates positive numeric value (> 0)
  static String? validatePositiveNumber(String? value, {String fieldName = 'Số tiền', bool required = true}) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập $fieldName';
      return null;
    }
    final numVal = double.tryParse(str);
    if (numVal == null || numVal <= 0) {
      return '$fieldName phải là số dương lớn hơn 0';
    }
    return null;
  }

  /// Validates non-negative numeric value (>= 0)
  static String? validateNonNegativeNumber(String? value, {String fieldName = 'Giá trị', bool required = true}) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập $fieldName';
      return null;
    }
    final numVal = double.tryParse(str);
    if (numVal == null || numVal < 0) {
      return '$fieldName phải là số lớn hơn hoặc bằng 0';
    }
    return null;
  }

  /// Validates positive integer (>= 1)
  static String? validatePositiveInteger(String? value, {String fieldName = 'Số lượng', bool required = true}) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập $fieldName';
      return null;
    }
    if (!_positiveIntegerRegex.hasMatch(str)) {
      return '$fieldName phải là số nguyên dương lớn hơn 0';
    }
    return null;
  }

  /// Validates password (min 6 characters)
  static String? validatePassword(String? value, {bool required = true}) {
    final str = value ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập mật khẩu';
      return null;
    }
    if (str.length < 6) {
      return 'Mật khẩu phải chứa ít nhất 6 ký tự';
    }
    return null;
  }

  /// Validates general required text
  static String? validateRequiredText(
    String? value, {
    String fieldName = 'Thông tin',
    int minLength = 1,
    int maxLength = 500,
    bool required = true,
  }) {
    final str = value?.trim() ?? '';
    if (str.isEmpty) {
      if (required) return 'Vui lòng nhập $fieldName';
      return null;
    }
    if (str.length < minLength) {
      return '$fieldName phải chứa ít nhất $minLength ký tự';
    }
    if (str.length > maxLength) {
      return '$fieldName không được vượt quá $maxLength ký tự';
    }
    return null;
  }
}
