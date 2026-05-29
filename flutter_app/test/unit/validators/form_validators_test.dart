import 'package:flutter_test/flutter_test.dart';
import 'package:wedding_planner/core/validators/form_validators.dart';

void main() {
  group('FormValidators.required', () {
    test('returns error for null value', () {
      expect(FormValidators.required(null, fieldName: 'Nama'), isNotNull);
    });

    test('returns error for empty string', () {
      expect(FormValidators.required('', fieldName: 'Nama'), isNotNull);
    });

    test('returns error for whitespace-only string', () {
      expect(FormValidators.required('   ', fieldName: 'Nama'), isNotNull);
    });

    test('returns null for valid non-empty string', () {
      expect(FormValidators.required('Hello', fieldName: 'Nama'), isNull);
    });

    test('includes field name in error message', () {
      expect(
        FormValidators.required('', fieldName: 'Kategori'),
        contains('Kategori'),
      );
    });
  });

  group('FormValidators.email', () {
    test('returns error for null value', () {
      expect(FormValidators.email(null), isNotNull);
    });

    test('returns error for empty string', () {
      expect(FormValidators.email(''), isNotNull);
    });

    test('returns error for invalid email format', () {
      expect(FormValidators.email('notanemail'), isNotNull);
      expect(FormValidators.email('missing@domain'), isNotNull);
      expect(FormValidators.email('@nodomain.com'), isNotNull);
    });

    test('returns error for email exceeding 255 characters', () {
      final longEmail = '${'a' * 250}@b.com';
      expect(FormValidators.email(longEmail), isNotNull);
    });

    test('returns null for valid email', () {
      expect(FormValidators.email('user@example.com'), isNull);
      expect(FormValidators.email('test.user+tag@domain.co.id'), isNull);
    });
  });

  group('FormValidators.maxLength', () {
    test('returns null for null value', () {
      expect(FormValidators.maxLength(null, 255), isNull);
    });

    test('returns null for empty value', () {
      expect(FormValidators.maxLength('', 255), isNull);
    });

    test('returns null for string within limit', () {
      expect(FormValidators.maxLength('Hello', 255), isNull);
    });

    test('returns error for string exceeding limit', () {
      expect(
        FormValidators.maxLength('a' * 256, 255, fieldName: 'Nama'),
        isNotNull,
      );
    });

    test('returns null for string at exact limit', () {
      expect(FormValidators.maxLength('a' * 255, 255), isNull);
    });
  });

  group('FormValidators.minLength', () {
    test('returns null for null value', () {
      expect(FormValidators.minLength(null, 8), isNull);
    });

    test('returns null for empty value', () {
      expect(FormValidators.minLength('', 8), isNull);
    });

    test('returns error for string below minimum', () {
      expect(
        FormValidators.minLength('short', 8, fieldName: 'Password'),
        isNotNull,
      );
    });

    test('returns null for string at exact minimum', () {
      expect(FormValidators.minLength('12345678', 8), isNull);
    });

    test('returns null for string above minimum', () {
      expect(FormValidators.minLength('longpassword', 8), isNull);
    });
  });

  group('FormValidators.numeric', () {
    test('returns null for null value', () {
      expect(FormValidators.numeric(null), isNull);
    });

    test('returns null for empty value', () {
      expect(FormValidators.numeric(''), isNull);
    });

    test('returns null for valid integer', () {
      expect(FormValidators.numeric('123'), isNull);
    });

    test('returns null for valid decimal', () {
      expect(FormValidators.numeric('123.45'), isNull);
    });

    test('returns null for negative number', () {
      expect(FormValidators.numeric('-10'), isNull);
    });

    test('returns error for non-numeric string', () {
      expect(FormValidators.numeric('abc'), isNotNull);
      expect(FormValidators.numeric('12abc'), isNotNull);
    });
  });

  group('FormValidators.nonNegative', () {
    test('returns null for null value', () {
      expect(FormValidators.nonNegative(null), isNull);
    });

    test('returns null for empty value', () {
      expect(FormValidators.nonNegative(''), isNull);
    });

    test('returns null for zero', () {
      expect(FormValidators.nonNegative('0'), isNull);
    });

    test('returns null for positive number', () {
      expect(FormValidators.nonNegative('100.5'), isNull);
    });

    test('returns error for negative number', () {
      expect(FormValidators.nonNegative('-1'), isNotNull);
    });

    test('returns error for non-numeric string', () {
      expect(FormValidators.nonNegative('abc'), isNotNull);
    });
  });

  group('FormValidators.maxValue', () {
    test('returns null for null value', () {
      expect(FormValidators.maxValue(null, 100), isNull);
    });

    test('returns null for value within limit', () {
      expect(FormValidators.maxValue('50', 100), isNull);
    });

    test('returns null for value at exact limit', () {
      expect(FormValidators.maxValue('100', 100), isNull);
    });

    test('returns error for value exceeding limit', () {
      expect(FormValidators.maxValue('101', 100), isNotNull);
    });

    test('returns error for non-numeric string', () {
      expect(FormValidators.maxValue('abc', 100), isNotNull);
    });
  });

  group('FormValidators.side', () {
    test('returns error for null value', () {
      expect(FormValidators.side(null), isNotNull);
    });

    test('returns error for empty value', () {
      expect(FormValidators.side(''), isNotNull);
    });

    test('returns null for "Pria"', () {
      expect(FormValidators.side('Pria'), isNull);
    });

    test('returns null for "Wanita"', () {
      expect(FormValidators.side('Wanita'), isNull);
    });

    test('returns null for "Keluarga"', () {
      expect(FormValidators.side('Keluarga'), isNull);
    });

    test('returns error for invalid side value', () {
      expect(FormValidators.side('Invalid'), isNotNull);
      expect(FormValidators.side('pria'), isNotNull); // case-sensitive
    });
  });

  group('FormValidators.type', () {
    test('returns error for null value', () {
      expect(FormValidators.type(null), isNotNull);
    });

    test('returns error for empty value', () {
      expect(FormValidators.type(''), isNotNull);
    });

    test('returns null for "input"', () {
      expect(FormValidators.type('input'), isNull);
    });

    test('returns null for "execution"', () {
      expect(FormValidators.type('execution'), isNull);
    });

    test('returns error for invalid type value', () {
      expect(FormValidators.type('other'), isNotNull);
      expect(FormValidators.type('Input'), isNotNull); // case-sensitive
    });
  });

  group('FormValidators.priority', () {
    test('returns error for null value', () {
      expect(FormValidators.priority(null), isNotNull);
    });

    test('returns error for empty value', () {
      expect(FormValidators.priority(''), isNotNull);
    });

    test('returns null for "rendah"', () {
      expect(FormValidators.priority('rendah'), isNull);
    });

    test('returns null for "sedang"', () {
      expect(FormValidators.priority('sedang'), isNull);
    });

    test('returns null for "tinggi"', () {
      expect(FormValidators.priority('tinggi'), isNull);
    });

    test('returns error for invalid priority value', () {
      expect(FormValidators.priority('high'), isNotNull);
      expect(FormValidators.priority('Rendah'), isNotNull); // case-sensitive
    });
  });

  group('FormValidators.budgetAmount', () {
    test('returns error for null value', () {
      expect(FormValidators.budgetAmount(null), isNotNull);
    });

    test('returns error for empty value', () {
      expect(FormValidators.budgetAmount(''), isNotNull);
    });

    test('returns error for non-numeric value', () {
      expect(FormValidators.budgetAmount('abc'), isNotNull);
    });

    test('returns error for negative value', () {
      expect(FormValidators.budgetAmount('-100'), isNotNull);
    });

    test('returns error for value exceeding max budget', () {
      expect(FormValidators.budgetAmount('10000000000000'), isNotNull);
    });

    test('returns null for valid budget amount', () {
      expect(FormValidators.budgetAmount('0'), isNull);
      expect(FormValidators.budgetAmount('1000000'), isNull);
      expect(FormValidators.budgetAmount('9999999999999.99'), isNull);
    });
  });

  group('FormValidators.requiredWithMaxLength', () {
    test('returns error for null value', () {
      expect(
        FormValidators.requiredWithMaxLength(null, fieldName: 'Nama'),
        isNotNull,
      );
    });

    test('returns error for empty value', () {
      expect(
        FormValidators.requiredWithMaxLength('', fieldName: 'Nama'),
        isNotNull,
      );
    });

    test('returns error for value exceeding max length', () {
      expect(
        FormValidators.requiredWithMaxLength('a' * 256, fieldName: 'Nama'),
        isNotNull,
      );
    });

    test('returns null for valid value within limits', () {
      expect(
        FormValidators.requiredWithMaxLength('Valid Name', fieldName: 'Nama'),
        isNull,
      );
    });
  });
}
