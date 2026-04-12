class AppConstants {
  // For Android emulator, use 10.0.2.2; for iOS simulator use localhost
  // Change this based on your environment
  static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator
  // static const String baseUrl = 'http://localhost:5000'; // iOS simulator
  
  static const String accessTokenKey = 'jwt_token';
  static const String userKey = 'user_data';
  
  static const List<String> expenseCategories = [
    'food',
    'transport',
    'shopping',
    'bills',
    'entertainment',
    'health',
    'other'
  ];
}