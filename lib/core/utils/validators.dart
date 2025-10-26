/// Input validation utilities
class Validators {
  Validators._();

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }
    
    // Check for strong password requirements
    final hasUpperCase = value.contains(RegExp(r'[A-Z]'));
    final hasLowerCase = value.contains(RegExp(r'[a-z]'));
    final hasDigits = value.contains(RegExp(r'[0-9]'));
    final hasSpecialCharacters = value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    if (!hasUpperCase) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (!hasLowerCase) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (!hasDigits) {
      return 'Password must contain at least one number';
    }
    
    if (!hasSpecialCharacters) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validate task name
  static String? validateTaskName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Task name is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return 'Task name cannot be empty';
    }
    
    if (trimmedValue.length > 100) {
      return 'Task name must be less than 100 characters';
    }
    
    // Check for potentially malicious content
    if (_containsMaliciousContent(trimmedValue)) {
      return 'Task name contains invalid characters';
    }
    
    return null;
  }

  /// Validate project name
  static String? validateProjectName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Project name is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) {
      return 'Project name cannot be empty';
    }
    
    if (trimmedValue.length > 50) {
      return 'Project name must be less than 50 characters';
    }
    
    // Check for potentially malicious content
    if (_containsMaliciousContent(trimmedValue)) {
      return 'Project name contains invalid characters';
    }
    
    return null;
  }

  /// Validate description
  static String? validateDescription(String? value) {
    if (value == null) return null;
    
    if (value.length > 500) {
      return 'Description must be less than 500 characters';
    }
    
    // Check for potentially malicious content
    if (_containsMaliciousContent(value)) {
      return 'Description contains invalid characters';
    }
    
    return null;
  }

  /// Validate duration in minutes
  static String? validateDuration(int? value) {
    if (value == null) {
      return 'Duration is required';
    }
    
    if (value < 1) {
      return 'Duration must be at least 1 minute';
    }
    
    if (value > 60) {
      return 'Duration must be less than 60 minutes';
    }
    
    return null;
  }

  /// Validate Pomodoro count
  static String? validatePomodoroCount(int? value) {
    if (value == null) {
      return 'Pomodoro count is required';
    }
    
    if (value < 1) {
      return 'Must be at least 1 Pomodoro';
    }
    
    if (value > 10) {
      return 'Must be less than 10 Pomodoros';
    }
    
    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  /// Validate minimum length
  static String? validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }
    
    return null;
  }

  /// Validate maximum length
  static String? validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }

  /// Validate numeric value
  static String? validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    final numericValue = int.tryParse(value);
    if (numericValue == null) {
      return '$fieldName must be a valid number';
    }
    
    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value, String fieldName) {
    final numericError = validateNumeric(value, fieldName);
    if (numericError != null) return numericError;
    
    final numericValue = int.parse(value!);
    if (numericValue <= 0) {
      return '$fieldName must be greater than 0';
    }
    
    return null;
  }

  /// Validate URL format
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validate phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number is optional
    }
    
    final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[\s\-\(\)]'), ''))) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validate date
  static String? validateDate(DateTime? value, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return '$fieldName cannot be in the future';
    }
    
    return null;
  }

  /// Validate date range
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Both start and end dates are required';
    }
    
    if (startDate.isAfter(endDate)) {
      return 'Start date cannot be after end date';
    }
    
    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (trimmedValue.length > 20) {
      return 'Username must be less than 20 characters';
    }
    
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(trimmedValue)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  /// Validate search query
  static String? validateSearchQuery(String? value) {
    if (value == null || value.isEmpty) {
      return 'Search query is required';
    }
    
    final trimmedValue = value.trim();
    if (trimmedValue.length < 2) {
      return 'Search query must be at least 2 characters';
    }
    
    if (trimmedValue.length > 100) {
      return 'Search query must be less than 100 characters';
    }
    
    return null;
  }

  /// Check for potentially malicious content
  static bool _containsMaliciousContent(String input) {
    final maliciousPatterns = [
      r'<script[^>]*>.*?</script>',
      r'javascript:',
      r'on\w+\s*=',
      r'<iframe[^>]*>.*?</iframe>',
      r'<object[^>]*>.*?</object>',
      r'<embed[^>]*>.*?</embed>',
      r'<link[^>]*>',
      r'<meta[^>]*>',
      r'<style[^>]*>.*?</style>',
      r'<form[^>]*>',
      r'<input[^>]*>',
      r'<button[^>]*>',
      r'<select[^>]*>',
      r'<textarea[^>]*>',
    ];
    
    for (final pattern in maliciousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(input)) {
        return true;
      }
    }
    
    return false;
  }

  /// Combine multiple validators
  static String? combineValidators(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Validate with custom function
  static String? validateWithCustom<T>(
    T? value,
    String fieldName,
    bool Function(T) validator,
    String errorMessage,
  ) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (!validator(value)) {
      return errorMessage;
    }
    
    return null;
  }
}
