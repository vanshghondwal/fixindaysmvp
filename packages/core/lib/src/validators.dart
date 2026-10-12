/// Pure-Dart input validators shared by all FixinDays apps.
library;

/// Returns an error message, or null when valid.
String? validatePhone(String? v) {
  final s = (v ?? '').replaceAll(RegExp(r'[\s-]'), '');
  if (s.isEmpty) return 'Phone number is required';
  if (!RegExp(r'^\+?[0-9]{10,13}$').hasMatch(s)) {
    return 'Enter a valid phone number';
  }
  return null;
}

String? validateEmail(String? v) {
  final s = (v ?? '').trim();
  if (s.isEmpty) return 'Email is required';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
    return 'Enter a valid email address';
  }
  return null;
}

String? validatePassword(String? v) {
  if ((v ?? '').length < 6) return 'Password must be at least 6 characters';
  return null;
}

String? validateRequired(String? v, [String field = 'This field']) {
  if ((v ?? '').trim().isEmpty) return '$field is required';
  return null;
}

String? validatePincode(String? v) {
  if (!RegExp(r'^[0-9]{6}$').hasMatch((v ?? '').trim())) {
    return 'Enter a 6-digit pincode';
  }
  return null;
}

String? validateOtp(String? v) {
  if (!RegExp(r'^[0-9]{6}$').hasMatch((v ?? '').trim())) {
    return 'Enter the 6-digit OTP';
  }
  return null;
}

String? validatePrice(String? v) {
  final n = int.tryParse((v ?? '').trim());
  if (n == null || n <= 0) return 'Enter a valid price';
  return null;
}

String? validateRating(int? v) {
  if (v == null || v < 1 || v > 5) return 'Rating must be 1–5';
  return null;
}
