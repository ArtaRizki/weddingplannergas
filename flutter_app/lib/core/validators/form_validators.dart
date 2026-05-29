/// Shared form validators for the Wedding Planner app.
///
/// All validators return `null` if valid, or an error message string if invalid.
/// Designed to be used with Flutter's [TextFormField] `validator` parameter.
class FormValidators {
  FormValidators._();

  // ─── Valid enum values ───────────────────────────────────────────────

  static const List<String> validSides = ['Pria', 'Wanita', 'Keluarga'];
  static const List<String> validTypes = ['input', 'execution'];
  static const List<String> validPriorities = ['rendah', 'sedang', 'tinggi'];

  // ─── Required field ─────────────────────────────────────────────────

  /// Validates that the value is not null, empty, or whitespace-only.
  ///
  /// [fieldName] is used in the error message (e.g. "Nama", "Kategori").
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    return null;
  }

  // ─── Email format ───────────────────────────────────────────────────

  /// Validates email format with a maximum of 255 characters.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email wajib diisi';
    }
    if (value.length > 255) {
      return 'Email maksimal 255 karakter';
    }
    // Basic email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Format email tidak valid';
    }
    return null;
  }

  // ─── Max length ─────────────────────────────────────────────────────

  /// Validates that the string does not exceed [maxLength] characters.
  ///
  /// Returns null if value is null or empty (use [required] for that check).
  static String? maxLength(String? value, int maxLength,
      {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length > maxLength) {
      return '$fieldName maksimal $maxLength karakter';
    }
    return null;
  }

  // ─── Min length ─────────────────────────────────────────────────────

  /// Validates that the string has at least [minLength] characters.
  ///
  /// Returns null if value is null or empty (use [required] for that check).
  static String? minLength(String? value, int minLength,
      {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < minLength) {
      return '$fieldName minimal $minLength karakter';
    }
    return null;
  }

  // ─── Numeric ────────────────────────────────────────────────────────

  /// Validates that the value is a valid number.
  ///
  /// Returns null if value is null or empty (use [required] for that check).
  static String? numeric(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (double.tryParse(value.trim()) == null) {
      return '$fieldName harus berupa angka';
    }
    return null;
  }

  // ─── Non-negative ───────────────────────────────────────────────────

  /// Validates that the numeric value is >= 0.
  ///
  /// Returns null if value is null or empty (use [required] for that check).
  /// Returns an error if the value is not numeric or is negative.
  static String? nonNegative(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName harus berupa angka';
    }
    if (number < 0) {
      return '$fieldName tidak boleh negatif';
    }
    return null;
  }

  // ─── Max value ──────────────────────────────────────────────────────

  /// Validates that the numeric value does not exceed [max].
  ///
  /// Returns null if value is null or empty (use [required] for that check).
  /// Returns an error if the value is not numeric or exceeds the max.
  static String? maxValue(String? value, double max,
      {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final number = double.tryParse(value.trim());
    if (number == null) {
      return '$fieldName harus berupa angka';
    }
    if (number > max) {
      return '$fieldName tidak boleh melebihi ${max.toStringAsFixed(max.truncateToDouble() == max ? 0 : 2)}';
    }
    return null;
  }

  // ─── Side enum ──────────────────────────────────────────────────────

  /// Validates that the value is one of "Pria", "Wanita", "Keluarga".
  static String? side(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Sisi wajib dipilih';
    }
    if (!validSides.contains(value.trim())) {
      return 'Sisi harus salah satu dari: ${validSides.join(", ")}';
    }
    return null;
  }

  // ─── Type enum ──────────────────────────────────────────────────────

  /// Validates that the value is one of "input", "execution".
  static String? type(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tipe wajib dipilih';
    }
    if (!validTypes.contains(value.trim())) {
      return 'Tipe harus salah satu dari: ${validTypes.join(", ")}';
    }
    return null;
  }

  // ─── Priority enum ──────────────────────────────────────────────────

  /// Validates that the value is one of "rendah", "sedang", "tinggi".
  static String? priority(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Prioritas wajib dipilih';
    }
    if (!validPriorities.contains(value.trim())) {
      return 'Prioritas harus salah satu dari: ${validPriorities.join(", ")}';
    }
    return null;
  }

  // ─── Compound validators (convenience) ──────────────────────────────

  /// Validates a budget amount: must be numeric, non-negative,
  /// and not exceed 9,999,999,999,999.99.
  static String? budgetAmount(String? value, {String fieldName = 'Jumlah'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName wajib diisi';
    }
    final numericError = numeric(value, fieldName: fieldName);
    if (numericError != null) return numericError;

    final nonNegError = nonNegative(value, fieldName: fieldName);
    if (nonNegError != null) return nonNegError;

    final maxError = maxValue(value, 9999999999999.99, fieldName: fieldName);
    if (maxError != null) return maxError;

    return null;
  }

  /// Validates a required field with max length (common pattern for names).
  static String? requiredWithMaxLength(String? value,
      {String fieldName = 'Field', int max = 255}) {
    final reqError = required(value, fieldName: fieldName);
    if (reqError != null) return reqError;

    final lenError = maxLength(value, max, fieldName: fieldName);
    if (lenError != null) return lenError;

    return null;
  }
}
