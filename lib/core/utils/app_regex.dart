class AppRegex {
  // Email validation regex
  static bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  // Name validation (Arabic/English letters and spaces only)
  static bool isNameValid(String name) {
    final value = name.trim();
    if (value.isEmpty) return false;
    return RegExp(r'^[a-zA-Z\u0600-\u06FF\u0750-\u077F\s]+$').hasMatch(value);
  }

  // Password validation - contains uppercase letter
  static bool hasUpperCase(String password) {
    return RegExp(r'[A-Z]').hasMatch(password);
  }

  // Password validation - contains lowercase letter
  static bool hasLowerCase(String password) {
    return RegExp(r'[a-z]').hasMatch(password);
  }

  // Password validation - contains number
  static bool hasNumber(String password) {
    return RegExp(r'[0-9]').hasMatch(password);
  }

  // Password validation - contains special character
  static bool hasSpecialCharacter(String password) {
    return RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  // Phone number validation (International format - accepts 7 to 15 digits)
  static bool isPhoneNumberValid(String phoneNumber) {
    // Remove any spaces, dashes, or parentheses
    String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    // Accept numbers with 7 to 15 digits (international standard)
    return RegExp(r'^[0-9]{7,15}$').hasMatch(cleanedNumber);
  }

  // Username validation (alphanumeric and underscore only)
  static bool isUsernameValid(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }
}
