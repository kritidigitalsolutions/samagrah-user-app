class AppValidator {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return "This field is required";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter email";
    }
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
      return "Invalid email";
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.length < 10) {
      return "Enter valid phone number";
    }
    return null;
  }
}
