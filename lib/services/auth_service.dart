import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _sessionCookieKey = 'session_cookie';

  static User? _currentUser;
  static bool _isLoggedIn = false;
  static String? _authToken;
  static String? _sessionCookie;

  static User? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;
  static String? get authToken => _authToken;
  static String? get sessionCookie => _sessionCookie;

  /// Initialize the auth service and load user data from storage
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      _authToken = prefs.getString(_tokenKey);
      _sessionCookie = prefs.getString(_sessionCookieKey);
      
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
      _sessionCookie = null;
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
      print('   Headers: ${response.headers}');
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
          
          // Extract session cookie from response headers
          final setCookie = response.headers['set-cookie'];
          if (setCookie != null) {
            _sessionCookie = setCookie.split(';')[0]; // Get just the cookie value
            print('🍪 Session cookie extracted: ${_sessionCookie?.substring(0, 50)}...');
          }
          
          await _saveUserData();
          
          // Fetch user data from server to get phone number
          await getUserData();
          
          // Check if user was created more than 10 minutes ago
          final now = DateTime.now();
          final createdAt = _currentUser!.createdAt ?? now;
          final accountAge = now.difference(createdAt);
          final isAccountOld = accountAge.inMinutes > 10;
          
          // Check if profile is complete (has phone number)
          final isProfileComplete = _currentUser?.isProfileComplete ?? false;
          
          // Skip setup if account is older than 10 minutes OR profile is complete
          final isNewUser = !isProfileComplete && !isAccountOld;
          
          print('✅ Sign In Success: User ${user.email} logged in');
          print('✅ Token stored: ${_authToken!.substring(0, 20)}...');
          print('📅 Account age: ${accountAge.inMinutes} minutes');
          print('📋 Profile complete: $isProfileComplete');
          print('🆕 Show setup: $isNewUser');
          return AuthResult.success(_currentUser!, isNewUser: isNewUser);
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
          
          // Extract session cookie from response headers
          final setCookie = response.headers['set-cookie'];
          if (setCookie != null) {
            _sessionCookie = setCookie.split(';')[0]; // Get just the cookie value
            print('🍪 Session cookie extracted: ${_sessionCookie?.substring(0, 50)}...');
          }
          
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

  /// Complete signup by adding phone number
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

      if (_currentUser == null) {
        return AuthResult.failure('No user logged in');
      }

      final fullPhoneNumber = '$phoneDialCode$phoneNumber';
      
      print('📤 Complete Signup Request:');
      print('   Phone: $fullPhoneNumber');

      // Send phone number to server
      final phoneAdded = await addPhoneNumber(fullPhoneNumber);
      
      // Update local user data regardless of server response
      _currentUser = _currentUser!.copyWith(
        phoneNumber: phoneNumber,
        phoneCountryCode: phoneCountryCode,
        phoneDialCode: phoneDialCode,
      );
      await _saveUserData();
      
      if (phoneAdded) {
        print('✅ Profile completed - phone number synced to server');
      } else {
        print('⚠️ Profile completed locally - server sync may have failed');
      }
      
      return AuthResult.success(_currentUser!);
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
      if (_currentUser == null) {
        return AuthResult.failure('No user logged in');
      }

      print('📤 Update Profile Request:');
      print('   Name: $fullName');
      print('   Phone: ${phoneDialCode ?? ''}${phoneNumber ?? ''}');

      // Update local user data immediately
      _currentUser = _currentUser!.copyWith(
        fullName: fullName ?? _currentUser!.fullName,
        phoneNumber: phoneNumber ?? _currentUser!.phoneNumber,
        phoneCountryCode: phoneCountryCode ?? _currentUser!.phoneCountryCode,
        phoneDialCode: phoneDialCode ?? _currentUser!.phoneDialCode,
      );

      // Save to local storage
      await _saveUserData();
      
      print('✅ Profile updated locally');

      // Optionally try to update name on Better Auth server (if fullName changed)
      // Phone number stays local-only due to Better Auth schema limitations
      // Note: Better Auth's /auth/update-user requires cookie authentication
      // Since we're using a mobile app, we'll skip server sync and keep everything local
      if (fullName != null && _authToken != null) {
        try {
          print('📤 Attempting to update name on Better Auth server...');
          print('📝 Using token: ${_authToken!.substring(0, 20)}...');
          
          final response = await http.post(
            Uri.parse('${AppConfig.apiBaseUrl}/auth/update-user'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_authToken',
              'Cookie': 'better-auth.session_token=$_authToken',
            },
            body: json.encode({
              'name': fullName,
            }),
          ).timeout(AppConfig.networkTimeout);

          print('📥 Server Response Status: ${response.statusCode}');
          print('📥 Server Response Headers: ${response.headers}');
          print('📥 Server Response Body: ${response.body.isEmpty ? '(empty)' : response.body}');
          
          if (response.statusCode == 200) {
            if (response.body.isEmpty) {
              print('⚠️ Server returned 200 but empty body - Better Auth cookie auth limitation');
              print('⚠️ Name update may not have persisted on server');
            } else {
              try {
                final responseData = json.decode(response.body);
                if (responseData['status'] == true) {
                  print('✅ Name updated on server successfully');
                } else {
                  print('⚠️ Server returned success but status was not true: $responseData');
                }
              } catch (e) {
                print('⚠️ Could not parse server response: $e');
              }
            }
          } else if (response.statusCode == 401) {
            print('⚠️ Server authentication failed (401) - Better Auth requires cookie session');
            print('⚠️ This is expected for mobile apps - using local storage only');
          } else {
            print('⚠️ Server update failed (status ${response.statusCode}): ${response.body}');
          }
        } catch (e) {
          print('⚠️ Server update exception: $e');
          print('⚠️ This is expected for mobile apps - local update succeeded');
          // Continue - local update is already saved
        }
      }
      
      return AuthResult.success(_currentUser!);
    } catch (e) {
      print('❌ Update Profile Exception: $e');
      return AuthResult.failure('Profile update failed: ${e.toString()}');
    }
  }

  /// Fetch user data from server
  static Future<void> getUserData() async {
    if (_authToken == null) return;
    
    try {
      print('📤 Fetching user data from server...');
      print('   Token: ${_authToken!.substring(0, 20)}...');
      if (_sessionCookie != null) {
        print('   Cookie: ${_sessionCookie!.substring(0, 50)}...');
      }
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      };
      
      // Add session cookie if available
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/user/organization/getUserData'),
        headers: headers,
        body: json.encode({}),
      ).timeout(AppConfig.networkTimeout);

      print('📥 Get User Data Response: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📥 User Data: $data');
        
        if (data != null && _currentUser != null) {
          _currentUser = _currentUser!.copyWith(
            fullName: data['name'] ?? _currentUser!.fullName,
            phoneNumber: data['phoneNumber'],
          );
          await _saveUserData();
          print('✅ User data updated from server');
          if (data['phoneNumber'] != null) {
            print('📞 Phone number found: ${data['phoneNumber']}');
          }
        }
      } else {
        print('⚠️ Failed to fetch user data: ${response.body}');
      }
    } catch (e) {
      print('⚠️ Error fetching user data: $e');
    }
  }

  /// Add phone number to server
  static Future<bool> addPhoneNumber(String phoneNumber) async {
    if (_authToken == null) {
      print('⚠️ No auth token available');
      return false;
    }
    
    try {
      print('📤 Adding phone number to server...');
      print('   Phone: $phoneNumber');
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      };
      
      // Add session cookie if available
      if (_sessionCookie != null) {
        headers['Cookie'] = _sessionCookie!;
      }
      
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/user/organization/addPhoneNumber'),
        headers: headers,
        body: json.encode({
          'phoneNumber': phoneNumber,
        }),
      ).timeout(AppConfig.networkTimeout);

      print('📥 Add Phone Response: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        print('✅ Phone number added successfully on server');
        return true;
      } else {
        print('⚠️ Failed to add phone number: ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error adding phone number: $e');
      return false;
    }
  }

  /// Logout the current user
  static Future<void> logout() async {
    try {
      _currentUser = null;
      _isLoggedIn = false;
      _authToken = null;
      _sessionCookie = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.remove(_tokenKey);
      await prefs.remove(_sessionCookieKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      // Even if there's an error, ensure the in-memory state is clean
      _currentUser = null;
      _isLoggedIn = false;
      _authToken = null;
      _sessionCookie = null;
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
      
      if (_sessionCookie != null) {
        await prefs.setString(_sessionCookieKey, _sessionCookie!);
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
