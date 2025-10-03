# Debugging 422 Error - Step by Step

## How to Debug

1. **Run the app with logging enabled:**
   ```bash
   flutter run
   ```

2. **Try to Sign Up with a new email:**
   - Email: `test@example.com`
   - Password: `Test123456`

3. **Check the console output** - You should see:
   ```
   📤 Sign Up Request:
      URL: https://api.estatemar.com/api/auth/sign-up/email
      Email: test@example.com
   📥 Sign Up Response:
      Status: 422
      Body: {the actual error message from API}
   ```

4. **Share the response body** - It will tell us exactly what's wrong:
   - Missing fields?
   - Wrong field names?
   - Validation errors?
   - User already exists?

## Common 422 Fixes

### If API expects different fields:

**Current request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Try these alternatives if needed:**

1. With full_name (some APIs require name during signup):
```json
{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "Test User"
}
```

2. With confirm_password:
```json
{
  "email": "user@example.com",
  "password": "password123",
  "confirm_password": "password123"
}
```

3. With phone (if required):
```json
{
  "email": "user@example.com",
  "password": "password123",
  "phone_number": "+1234567890"
}
```

## What to Look For in Error Response

The API response will contain validation errors like:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": {
    "email": ["Email already exists"],
    "password": ["Password must be at least 8 characters"],
    "full_name": ["Full name is required"]
  }
}
```

Once you share the actual error response, I can fix the exact issue!
