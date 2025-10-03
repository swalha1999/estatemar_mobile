import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';

  static User? _currentUser;
  static bool _isLoggedIn = false;
  static String? _authToken;

  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;
  static String? get authToken => _authToken;

  /// Initialize the auth service and load user data from storage
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      _authToken = prefs.getString(_tokenKey);
      
      if (_isLoggedIn && _authToken != null) {
        final userJson = prefs.getString(_userKey);
        if (userJson != null) {
          try {
            final userData = json.decode(userJson);
            _currentUser = User.fromJson(userData);
          } catch (e) {
            // If there's an error parsing user data, log out
            await logout();
          }
        } else {
          // No user data found, log out
          await logout();
        }
      }
    } catch (e) {
      // If there's any error during initialization, ensure clean state
      _currentUser = null;
      _isLoggedIn = false;
      _authToken = null;
    }
  }

  /// Sign in with email and password
  static Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('📤 Sign In Request:');
      print('   URL: ${AppConfig.apiBaseUrl}/auth/sign-in/email');
      print('   Email: $email');
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/sign-in/email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.networkTimeout);

      print('📥 Sign In Response:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Better Auth returns token and user directly
        if (responseData['token'] != null && responseData['user'] != null) {
          final userData = responseData['user'];
          // Add token to user data for our User model
          userData['token'] = responseData['token'];
          
          final user = User.fromJson(userData);
          
          _currentUser = user;
          _authToken = responseData['token'];
          _isLoggedIn = true;
          
          await _saveUserData();
          
          // Check if profile is complete (has phone number)
          final isNewUser = !user.isProfileComplete;
          
          print('✅ Sign In Success: User ${user.email} logged in');
          return AuthResult.success(user, isNewUser: isNewUser);
        }
      }
      
      // Handle error response
      final message = responseData['message'] ?? 
                     responseData['error'] ?? 
                     'Sign in failed (${response.statusCode})';
      print('❌ Sign In Error: $message');
      return AuthResult.failure(message);
    } catch (e) {
      print('❌ Sign In Exception: $e');
      return AuthResult.failure('Sign in failed: ${e.toString()}');
    }
  }

  /// Sign up with email, password, and full name
  static Future<AuthResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      print('📤 Sign Up Request:');
      print('   URL: ${AppConfig.apiBaseUrl}/auth/sign-up/email');
      print('   Email: $email');
      print('   Full Name: $fullName');
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/sign-up/email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': fullName,  // Better Auth expects 'name' not 'full_name'
          'email': email,
          'password': password,
        }),
      ).timeout(AppConfig.networkTimeout);

      print('📥 Sign Up Response:');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Better Auth returns token and user directly (not nested in 'data')
        if (responseData['token'] != null && responseData['user'] != null) {
          final userData = responseData['user'];
          // Add token to user data for our User model
          userData['token'] = responseData['token'];
          
          final user = User.fromJson(userData);
          
          _currentUser = user;
          _authToken = responseData['token'];
          _isLoggedIn = true;
          
          await _saveUserData();
          
          print('✅ Sign Up Success: User ${user.email} created');
          // New users need to complete profile (add phone)
          return AuthResult.success(user, isNewUser: true);
        }
      }
      
      // Handle error response
      final message = responseData['message'] ?? 
                     responseData['error'] ?? 
                     'Sign up failed (${response.statusCode})';
      print('❌ Sign Up Error: $message');
      return AuthResult.failure(message);
    } catch (e) {
      print('❌ Sign Up Exception: $e');
      return AuthResult.failure('Sign up failed: ${e.toString()}');
    }
  }

  /// Complete signup by adding phone number (uses Better Auth's update-user endpoint)
  static Future<AuthResult> completeSignup({
    required String fullName,
    required String phoneNumber,
    required String phoneCountryCode,
    required String phoneDialCode,
  }) async {
    try {
      if (_authToken == null) {
        return AuthResult.failure('No authentication token');
      }

      print('📤 Complete Signup Request:');
      print('   URL: ${AppConfig.apiBaseUrl}/auth/update-user');
      print('   Phone: $phoneDialCode$phoneNumber');

      // Better Auth's update-user endpoint requires cookie authentication
      // Since we can't easily set cookies in Flutter, we'll store phone locally
      // The user already has their name from signup, so we just save phone locally
      
      print('📝 Storing phone number locally (Better Auth limitation)');
      
      // Update current user with phone number locally
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          phoneNumber: phoneNumber,
          phoneCountryCode: phoneCountryCode,
          phoneDialCode: phoneDialCode,
        );
        await _saveUserData();
        
        print('✅ Profile completed with phone number (stored locally)');
        return AuthResult.success(_currentUser!);
      }
      
      return AuthResult.failure('Failed to update profile: User not found');
    } catch (e) {
      print('❌ Complete Signup Exception: $e');
      return AuthResult.failure('Complete signup failed: ${e.toString()}');
    }
  }

  /// Update user profile information
  static Future<AuthResult> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? phoneCountryCode,
    String? phoneDialCode,
  }) async {
    try {
      if (_currentUser == null || _authToken == null) {
        return AuthResult.failure('No user logged in');
      }

      final Map<String, dynamic> body = {};
      if (fullName != null) body['full_name'] = fullName;
      if (phoneNumber != null && phoneDialCode != null) {
        body['phone_number'] = '$phoneDialCode$phoneNumber';
        body['phone_country_code'] = phoneCountryCode;
        body['phone_dial_code'] = phoneDialCode;
      }

      final response = await http.put(
        Uri.parse('${AppConfig.apiBaseUrl}/auth/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_authToken',
        },
        body: json.encode(body),
      ).timeout(AppConfig.networkTimeout);

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final userData = responseData['data'];
        final user = User.fromJson(userData);
        
        _currentUser = user;
        await _saveUserData();
        
        return AuthResult.success(user);
      } else {
        final message = responseData['message'] ?? 'Profile update failed';
        return AuthResult.failure(message);
      }
    } catch (e) {
      return AuthResult.failure('Profile update failed: ${e.toString()}');
    }
  }

  /// Logout the current user
  static Future<void> logout() async {
    try {
      _currentUser = null;
      _isLoggedIn = false;
      _authToken = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      // Even if there's an error, ensure the in-memory state is clean
      _currentUser = null;
      _isLoggedIn = false;
      _authToken = null;
    }
  }

  /// Save current user data to storage
  static Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_currentUser != null) {
      await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
      
      if (_authToken != null) {
        await prefs.setString(_tokenKey, _authToken!);
      }
    }
  }
}

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final User? user;
  final bool isNewUser;

  const AuthResult._({
    required this.isSuccess,
    this.errorMessage,
    this.user,
    this.isNewUser = false,
  });

  factory AuthResult.success(User user, {bool isNewUser = false}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      isNewUser: isNewUser,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
