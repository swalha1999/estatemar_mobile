import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  static User? _currentUser;
  static bool _isLoggedIn = false;

  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;

  /// Initialize the auth service and load user data from storage
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      
      if (_isLoggedIn) {
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
    }
  }

  /// Login with email (simplified for demo purposes)
  static Future<AuthResult> loginWithEmail(String email) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      // For demo purposes, accept any valid email format
      if (!_isValidEmail(email)) {
        return AuthResult.failure('Please enter a valid email address');
      }

      // Check if this is a new user (simplified check)
      final prefs = await SharedPreferences.getInstance();
      final isNewUser = !prefs.containsKey('user_$email');
      
      if (isNewUser) {
        // Create new user
        final user = User(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          email: email,
          firstName: '', // Will be set in profile setup
          lastName: '', // Will be set in profile setup
          createdAt: DateTime.now(),
        );
        
        _currentUser = user;
        _isLoggedIn = true;
        
        await _saveUserData();
        
        return AuthResult.success(user, isNewUser: true);
      } else {
        // Load existing user
        final userJson = prefs.getString('user_$email');
        if (userJson != null) {
          final userData = json.decode(userJson);
          _currentUser = User.fromJson(userData);
          _isLoggedIn = true;
          
          await _saveUserData();
          
          return AuthResult.success(_currentUser!, isNewUser: false);
        } else {
          return AuthResult.failure('User not found');
        }
      }
    } catch (e) {
      return AuthResult.failure('Login failed: ${e.toString()}');
    }
  }

  /// Update user profile information
  static Future<AuthResult> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      if (_currentUser == null) {
        return AuthResult.failure('No user logged in');
      }

      final updatedUser = _currentUser!.copyWith(
        firstName: firstName,
        lastName: lastName,
        updatedAt: DateTime.now(),
      );

      _currentUser = updatedUser;
      await _saveUserData();
      
      // Also save to user-specific storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_${_currentUser!.email}', json.encode(_currentUser!.toJson()));

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.failure('Profile update failed: ${e.toString()}');
    }
  }

  /// Logout the current user
  static Future<void> logout() async {
    try {
      _currentUser = null;
      _isLoggedIn = false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      // Even if there's an error, ensure the in-memory state is clean
      _currentUser = null;
      _isLoggedIn = false;
    }
  }

  /// Save current user data to storage
  static Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_currentUser != null) {
      await prefs.setString(_userKey, json.encode(_currentUser!.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
    }
  }

  /// Validate email format
  static bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
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
