class Validators {
  static String? validateEmail(String? value) {
    if (value == null || !value.contains('@')) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.length < 7) {
      return 'Password must be at least 7 characters';
    }
    return null;
  }
}
