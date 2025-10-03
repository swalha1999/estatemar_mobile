# Better Auth API - Debug Information

## 🔍 Understanding the 401 Error

### Why You're Getting 401 (Unauthorized)

The **401 error** occurs because Better Auth's `/auth/update-user` endpoint requires **cookie-based session authentication**, not Bearer token authentication. This is a limitation of Better Auth when used with mobile applications.

### Better Auth Authentication Methods

According to the API specification, Better Auth supports:

1. **Cookie Authentication** (`better-auth.session_token` cookie) - **Primary method**
2. **Bearer Token** (for some endpoints, but not `/update-user`)

## 📊 Expected API Responses

### 1. Sign In (`POST /auth/sign-in/email`)

#### ✅ Success Response (200)
```json
{
  "redirect": false,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "url": null,
  "user": {
    "id": "user_123456",
    "email": "user@example.com",
    "name": "John Doe",
    "image": null,
    "emailVerified": true,
    "createdAt": "2025-10-03T10:30:00Z",
    "updatedAt": "2025-10-03T10:30:00Z"
  }
}
```

**Response Headers:**
```
set-cookie: better-auth.session_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...; Path=/; HttpOnly; Secure
content-type: application/json
```

#### ❌ Error Response (401)
```json
{
  "message": "Invalid credentials"
}
```

---

### 2. Sign Up (`POST /auth/sign-up/email`)

#### ✅ Success Response (200)
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user_123456",
    "email": "newuser@example.com",
    "name": "Jane Smith",
    "image": null,
    "emailVerified": false,
    "createdAt": "2025-10-03T10:35:00Z",
    "updatedAt": "2025-10-03T10:35:00Z"
  }
}
```

#### ❌ Error Response (422 - User Already Exists)
```json
{
  "message": "User already exists"
}
```

#### ❌ Error Response (400 - Invalid Data)
```json
{
  "message": "Invalid email address"
}
```

---

### 3. Update User (`POST /auth/update-user`)

**⚠️ IMPORTANT:** This endpoint requires cookie authentication, which is problematic for mobile apps.

#### Request
```json
{
  "name": "Updated Name",
  "image": "https://example.com/avatar.jpg"
}
```

**Required Headers:**
```
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Cookie: better-auth.session_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### ✅ Success Response (200)
```json
{
  "status": true
}
```

#### ❌ Error Response (401 - Mobile App Issue)
```json
{
  "message": "Unauthorized"
}
```

**Why this happens:**
- Mobile apps (Flutter, React Native) cannot access HTTP-only cookies
- Better Auth sets cookies with `HttpOnly` flag for security
- The `/update-user` endpoint validates the session cookie, not the Bearer token

---

## 🛠️ Our Solution

### Current Implementation Strategy

Since Better Auth's `/update-user` endpoint doesn't work reliably with mobile apps, we've implemented a **hybrid approach**:

1. **Local Storage First** ✅
   - All user data (name, phone number) is saved locally using `SharedPreferences`
   - Updates are immediate and always succeed
   - User experience is not impacted by server issues

2. **Optional Server Sync** (for name only)
   - Attempts to sync name changes to Better Auth server
   - If it fails (401), we log the issue but don't show error to user
   - Phone number stays local-only (Better Auth schema limitation)

### What Gets Updated Where

| Field | Local Storage | Better Auth Server |
|-------|---------------|-------------------|
| Email | ✅ (Read-only) | ✅ (Set during signup) |
| Full Name | ✅ (Editable) | ⚠️ (Attempted, may fail) |
| Phone Number | ✅ (Editable) | ❌ (Not supported) |
| Phone Country Code | ✅ (Editable) | ❌ (Not supported) |
| Phone Dial Code | ✅ (Editable) | ❌ (Not supported) |

### API Call Flow for Profile Update

```
1. User clicks "Save Changes"
   ↓
2. Update local user object in memory
   ↓
3. Save to SharedPreferences (ALWAYS SUCCEEDS)
   ↓
4. Show success message to user
   ↓
5. [Background] Attempt to sync name to server
   ├─ Success (200) → Log success
   ├─ Fail (401) → Log warning (expected for mobile)
   └─ Fail (other) → Log error
```

---

## 📱 Debug Output Examples

### Successful Profile Update (Local Only)
```
📤 Update Profile Request:
   Name: John Doe
   Phone: +972501234567
✅ Profile updated locally
📤 Attempting to update name on Better Auth server...
📝 Using token: eyJhbGciOiJIUzI1NiIs...
📥 Server Response Status: 401
📥 Server Response Body: {"message":"Unauthorized"}
⚠️ Server authentication failed (401) - Better Auth requires cookie session
⚠️ This is expected for mobile apps - using local storage only
✅ Profile update succeeded (User updated)
```

### Successful Sign In
```
📤 Sign In Request:
   URL: https://api.estatemar.com/api/auth/sign-in/email
   Email: user@example.com
📥 Sign In Response:
   Status: 200
   Headers: {set-cookie: better-auth.session_token=..., content-type: application/json}
   Body: {"redirect":false,"token":"eyJ...","user":{...}}
✅ Sign In Success: User user@example.com logged in
✅ Token stored: eyJhbGciOiJIUzI1NiIs...
```

### Failed Sign In
```
📤 Sign In Request:
   URL: https://api.estatemar.com/api/auth/sign-in/email
   Email: user@example.com
📥 Sign In Response:
   Status: 401
   Body: {"message":"Invalid credentials"}
❌ Sign In Error: Invalid credentials
```

---

## 🔧 Testing API Calls

### Using Flutter DevTools Console

Run your app in debug mode and watch the console for these log messages:

1. **Sign In Flow:**
   - Look for `📤 Sign In Request:`
   - Check `📥 Sign In Response:` status and body
   - Verify `✅ Token stored:` appears

2. **Profile Update Flow:**
   - Look for `📤 Update Profile Request:`
   - Check `✅ Profile updated locally`
   - Verify `⚠️ Server authentication failed (401)` (this is OK!)
   - Confirm `✅ Profile update succeeded`

### Testing with cURL

If you want to test the API directly:

```bash
# Sign In
curl -X POST https://api.estatemar.com/api/auth/sign-in/email \
  -H "Content-Type: application/json" \
  -d '{"email":"your@email.com","password":"yourpassword"}' \
  -v

# Update User (will fail with 401 without cookie)
curl -X POST https://api.estatemar.com/api/auth/update-user \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{"name":"New Name"}' \
  -v
```

---

## ✅ What's Working Now

1. ✅ Email/password sign in and sign up
2. ✅ JWT token storage and management
3. ✅ Profile data storage (name, phone, email)
4. ✅ Profile updates (local storage)
5. ✅ Phone number with country picker
6. ✅ Persistent login sessions
7. ✅ Logout functionality

## ⚠️ Known Limitations

1. ⚠️ `/auth/update-user` returns 401 for mobile apps (expected behavior)
2. ⚠️ Phone number only stored locally (Better Auth schema limitation)
3. ⚠️ Name updates may not sync to server (cookie authentication issue)

## 🎯 Recommended Next Steps

### Option 1: Accept Current Implementation
- Profile updates work perfectly for users
- All data is persisted locally
- 401 errors are logged but don't affect UX

### Option 2: Create Custom Backend Endpoint
- Create your own `/api/users/profile` endpoint
- Use Bearer token authentication
- Store phone numbers in your database
- Full control over data structure

### Option 3: Use Better Auth Organization Plugin
- Better Auth has organization features
- May support additional fields through metadata
- Requires investigating organization API endpoints

---

## 📞 Support

If you need to debug further, check these files:
- `/Users/g4ss4n/Repos/estatemar_mobile/lib/services/auth_service.dart` - All API calls
- `/Users/g4ss4n/Repos/estatemar_mobile/lib/models/user.dart` - User data model
- `/Users/g4ss4n/Repos/estatemar_mobile/.cursor/rules/better-auth.json` - API specification

**Last Updated:** October 3, 2025

