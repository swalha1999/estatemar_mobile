# Authentication Flow - Estatemar Mobile

## Overview

The app now uses **email/password authentication** with the Estatemar API. New users need to complete their profile by providing their full name and phone number after signup.

## Authentication Endpoints

- **Sign In**: `POST /auth/sign-in/email`
- **Sign Up**: `POST /auth/sign-up/email`
- **Complete Signup**: `POST /auth/complete-signup`
- **Update Profile**: `PUT /auth/profile`

## User Flow

### 1. Sign In / Sign Up Screen (`LoginScreen`)

**Sign In Mode:**
- Email address (validated format)
- Password

**Sign Up Mode:**
- Full Name (minimum 3 characters)
- Email address (validated format)
- Password (minimum 6 characters)

On success:
- If profile is incomplete (missing phone) → Navigate to Profile Setup
- If profile is complete → Navigate to main app

### 2. Complete Profile (`ProfileSetupScreen`)

Shown only for users who need to add their phone number.

- Displays user's email and full name (read-only)
- Required fields:
  - **Country**: Searchable dropdown with flags and dial codes (default: Israel +972)
  - **Phone Number**: National format without country code

### 3. Profile Management

#### View Profile (`ProfileScreen`)
- Displays:
  - Avatar with initials (from full name or email)
  - Display name (full name or email username)
  - Email address
  - Full name
  - Phone number (if set)
  - Account creation date

#### Edit Profile (`EditProfileScreen`)
- Email is read-only (cannot be changed)
- Can update:
  - Full name

## User Model Structure

```dart
class User {
  final String id;
  final String email;           // Required - used for authentication
  final String? fullName;        // Optional - set during complete signup
  final String? phoneNumber;     // Optional - national format
  final String? phoneCountryCode; // Optional - ISO code (e.g., "IL")
  final String? phoneDialCode;   // Optional - e.g., "+972"
  final String? token;           // JWT token from API
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Computed properties
  String get displayName;        // Returns fullName or email username
  String? get fullPhoneNumber;   // Returns dialCode + phoneNumber
  bool get isProfileComplete;    // Checks if fullName and phoneNumber are set
}
```

## API Request/Response Examples

### Sign Up Request
```json
{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "John Doe"
}
```

### Sign Up Response
```json
{
  "success": true,
  "data": {
    "id": "user123",
    "email": "user@example.com",
    "full_name": "John Doe",
    "token": "jwt_token_here"
  }
}
```

### Complete Signup Request (Add Phone Number)
```json
{
  "phone_number": "+972501234567",
  "phone_country_code": "IL",
  "phone_dial_code": "+972"
}
```

### Complete Signup Response
```json
{
  "success": true,
  "data": {
    "id": "user123",
    "email": "user@example.com",
    "fullName": "John Doe",
    "phoneNumber": "501234567",
    "phoneCountryCode": "IL",
    "phoneDialCode": "+972",
    "token": "jwt_token_here"
  }
}
```

## Dependencies

- `http`: ^0.13.4 - For API calls
- `shared_preferences`: ^2.0.15 - For local storage
- `country_picker`: ^2.0.20 - For country selection with flags

## Security Notes

- JWT tokens are stored in SharedPreferences
- Tokens are sent in Authorization header: `Bearer {token}`
- Email and password validation on client side
- API handles server-side validation and security

## Testing

To test the authentication flow:

1. Run the app
2. Click "Sign Up" on the login screen
3. Enter email and password
4. Complete profile with full name and phone number
5. Profile will be saved and user will be logged in
6. To test sign in, logout and sign in with the same credentials

## Files Modified

- `lib/models/user.dart` - Updated User model
- `lib/services/auth_service.dart` - Complete rewrite for API integration
- `lib/screens/auth/login_screen.dart` - Email/password authentication
- `lib/screens/auth/profile_setup_screen.dart` - Complete signup with name and phone
- `lib/screens/profile/profile_screen.dart` - Display user information
- `lib/screens/profile/edit_profile_screen.dart` - Update user profile
- `lib/config/app_config.dart` - Updated API base URL

## Files Removed

- `lib/screens/auth/otp_verification_screen.dart` - No longer needed (was for phone auth)

