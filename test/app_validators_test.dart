import 'package:flutter_test/flutter_test.dart';
import 'package:urbano_manage/core/utils/app_validators.dart';

void main() {
  group('AppValidators Tests', () {
    test('validatePhone tests', () {
      // Valid Vietnamese phone numbers
      expect(AppValidators.validatePhone('0912345678'), isNull);
      expect(AppValidators.validatePhone('0389998888'), isNull);
      expect(AppValidators.validatePhone('+84901234567'), isNull);

      // Invalid phone numbers
      expect(AppValidators.validatePhone('0123456789'), isNotNull); // 01 is not a valid modern prefix
      expect(AppValidators.validatePhone('0912345'), isNotNull); // too short
      expect(AppValidators.validatePhone('091234567890'), isNotNull); // too long
      expect(AppValidators.validatePhone('abc09123456'), isNotNull); // contains letters
    });

    test('validateEmail tests', () {
      // Valid email addresses
      expect(AppValidators.validateEmail('user@domain.com'), isNull);
      expect(AppValidators.validateEmail('john.doe@company.org.vn'), isNull);

      // Invalid email addresses
      expect(AppValidators.validateEmail('userdomain.com'), isNotNull);
      expect(AppValidators.validateEmail('user@'), isNotNull);
      expect(AppValidators.validateEmail('@domain.com'), isNotNull);
    });

    test('validateCccd tests', () {
      // Valid 9 or 12 digit CCCD/CMND
      expect(AppValidators.validateCccd('123456789'), isNull);
      expect(AppValidators.validateCccd('001200123456'), isNull);

      // Invalid CCCD
      expect(AppValidators.validateCccd('12345678'), isNotNull); // 8 digits
      expect(AppValidators.validateCccd('1234567890'), isNotNull); // 10 digits
      expect(AppValidators.validateCccd('123456789A'), isNotNull); // contains letter
    });

    test('validateLicensePlate tests', () {
      // Valid license plates
      expect(AppValidators.validateLicensePlate('30A-123.45'), isNull);
      expect(AppValidators.validateLicensePlate('29H12345'), isNull);
      expect(AppValidators.validateLicensePlate('51F-99999'), isNull);

      // Invalid license plates
      expect(AppValidators.validateLicensePlate('ABC-12345'), isNotNull);
      expect(AppValidators.validateLicensePlate('1'), isNotNull);
    });

    test('validateName tests', () {
      // Valid Vietnamese names
      expect(AppValidators.validateName('Nguyễn Văn A', fieldName: 'Tên'), isNull);
      expect(AppValidators.validateName('Phạm Thị Hồng Mơ', fieldName: 'Tên'), isNull);

      // Invalid names
      expect(AppValidators.validateName('A', fieldName: 'Tên'), isNotNull); // too short
      expect(AppValidators.validateName('Nguyễn Văn A 123', fieldName: 'Tên'), isNotNull); // contains digits
      expect(AppValidators.validateName('John@Doe', fieldName: 'Tên'), isNotNull); // contains special char
    });

    test('validateApartmentNumber tests', () {
      // Valid apartment codes
      expect(AppValidators.validateApartmentNumber('A-12.04'), isNull);
      expect(AppValidators.validateApartmentNumber('101'), isNull);
      expect(AppValidators.validateApartmentNumber('B2/05'), isNull);

      // Invalid apartment code
      expect(AppValidators.validateApartmentNumber(''), isNotNull);
    });

    test('validatePositiveNumber & PositiveInteger tests', () {
      // Valid positive numbers
      expect(AppValidators.validatePositiveNumber('100000', fieldName: 'Số tiền'), isNull);
      expect(AppValidators.validatePositiveNumber('50.5', fieldName: 'Số tiền'), isNull);

      // Invalid numbers
      expect(AppValidators.validatePositiveNumber('0', fieldName: 'Số tiền'), isNotNull);
      expect(AppValidators.validatePositiveNumber('-100', fieldName: 'Số tiền'), isNotNull);
      expect(AppValidators.validatePositiveNumber('abc', fieldName: 'Số tiền'), isNotNull);

      // Valid positive integers
      expect(AppValidators.validatePositiveInteger('5', fieldName: 'Số lượng'), isNull);
      expect(AppValidators.validatePositiveInteger('0', fieldName: 'Số lượng'), isNotNull);
      expect(AppValidators.validatePositiveInteger('2.5', fieldName: 'Số lượng'), isNotNull);
    });

    test('validatePassword tests', () {
      expect(AppValidators.validatePassword('123456'), isNull);
      expect(AppValidators.validatePassword('password123'), isNull);
      expect(AppValidators.validatePassword('12345'), isNotNull); // too short
    });
  });
}
