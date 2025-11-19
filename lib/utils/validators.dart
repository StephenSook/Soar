class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Display name validation
  static String? validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Age is optional
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid age';
    }

    if (age < 13) {
      return 'You must be at least 13 years old to use this app';
    }

    if (age > 120) {
      return 'Please enter a valid age';
    }

    return null;
  }

  // Community alias validation
  static String? validateCommunityAlias(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Alias is optional, defaults to "Anonymous"
    }

    if (value.length < 2) {
      return 'Alias must be at least 2 characters';
    }

    if (value.length > 20) {
      return 'Alias must be less than 20 characters';
    }

    // Only allow letters, numbers, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Alias can only contain letters, numbers, and underscores';
    }

    return null;
  }

  // Message validation
  static String? validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message cannot be empty';
    }

    if (value.length > 500) {
      return 'Message must be less than 500 characters';
    }

    return null;
  }

  // Check for potentially harmful content
  static bool containsHarmfulContent(String text) {
    final lowerText = text.toLowerCase();
    
    // Basic keyword check for crisis situations
    final crisisKeywords = [
      'suicide',
      'kill myself',
      'end my life',
      'want to die',
      'harm myself',
    ];

    for (var keyword in crisisKeywords) {
      if (lowerText.contains(keyword)) {
        return true;
      }
    }

    return false;
  }
}

