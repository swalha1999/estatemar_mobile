# API Debug Notes - 422 Error Fix

## Common Causes of 422 Error

1. **Wrong field names** - API might expect different field names
2. **Missing required fields** - API might require additional fields
3. **Invalid data format** - Email/password might not meet validation rules
4. **User already exists** - Email might already be registered

## Possible Field Name Variations

The API might expect different field names. Try these variations:

### Option 1: Lowercase with underscores (snake_case)
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### Option 2: Camel case
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

### Option 3: With confirmPassword
```json
{
  "email": "user@example.com",
  "password": "password123",
  "confirmPassword": "password123"
}
```

### Option 4: With additional fields
```json
{
  "email": "user@example.com",
  "password": "password123",
  "full_name": "User Name",
  "phone_number": "+1234567890"
}
```

## Test Instructions

1. Run the app
2. Try to sign up with a new email
3. Check the console/logs for the detailed error message
4. Look for:
   - Request URL
   - Request body
   - Response status
   - Response body (will show validation errors)

## Next Steps

Once you see the actual error message in the logs, we can:
1. Adjust the field names if needed
2. Add missing required fields
3. Update validation rules
4. Handle the specific error case

