class RegisterFunctions {
  // Email validation function
  String? validateEmail(String? value) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  // Password validation function
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    } else if (!RegExp(r'^[a-z0-9]{6}$').hasMatch(value)) {
      return 'Special Characters are not allowed with UpperCase and it must be six characters';
    }
    return null;
  }

  String calculateAge(DateTime birthday) {
    final DateTime today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age.toString();
  }

  DateTime? parseDob(String dob) {
    try {
      final parts = dob.split('/');
      if (parts.length == 3) {
        int day = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int year = int.parse(parts[2]);

        // Handle two-digit years
        if (year < 100) {
          final currentYear = DateTime.now().year % 100;
          year += (year > currentYear ? 1900 : 2000);
        }

        return DateTime(year, month, day);
      }
    } catch (e) {
      // Handle invalid date parsing
      return null;
    }
    return null;
  }
}
