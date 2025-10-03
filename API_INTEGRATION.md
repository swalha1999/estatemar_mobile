# User Property API Integration

## Overview
The app now uploads user properties to the backend API instead of only storing them locally. All property operations (create, read, update, delete) now sync with the server while maintaining local cache for offline functionality.

## API Endpoints

### Base URL
```
https://api.estatemar.com/api
```

### Authentication
All endpoints require authentication headers:
```http
Authorization: Bearer {token}
Cookie: {session_cookie}
```

---

## 1. Create User Property

### Endpoint
```http
POST /user/properties
```

### Request Headers
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}",
  "Cookie": "__Secure-better-auth.session_token={cookie}"
}
```

### Request Body
```json
{
  "id": "string",
  "userId": "string",
  "propertyName": "string",
  "address": "string",
  "purchasePrice": 0.0,
  "marketValue": 0.0,
  "description": "string (optional)",
  "propertyType": "house|apartment|condo|townhouse|villa|studio",
  "bedrooms": 0,
  "bathrooms": 0,
  "area": 0.0,
  "purchaseDate": "ISO8601 datetime string",
  "createdAt": "ISO8601 datetime string",
  "updatedAt": "ISO8601 datetime string",
  "monthlyRent": 0.0,
  "annualAppreciationRate": 0.0,
  "imageUrls": ["string"],
  "isForSale": false,
  "isForRent": false
}
```

### Response (Success)
```json
Status: 200 or 201

{
  "data": {
    "id": "string",
    "userId": "string",
    "propertyName": "string",
    "address": "string",
    "purchasePrice": 0.0,
    // ... all other property fields
  }
}

// OR

{
  "property": {
    // ... property fields
  }
}

// OR just the property object directly
{
  "id": "string",
  "userId": "string",
  // ... property fields
}
```

### Response (Error)
```json
Status: 401
{
  "message": "Authentication required"
}

Status: 500
{
  "message": "Error message"
}
```

---

## 2. Get All User Properties

### Endpoint
```http
GET /user/properties
```

### Request Headers
```json
{
  "Authorization": "Bearer {token}",
  "Cookie": "__Secure-better-auth.session_token={cookie}"
}
```

### Response (Success)
```json
Status: 200

{
  "data": [
    {
      "id": "string",
      "userId": "string",
      "propertyName": "string",
      // ... property fields
    }
  ]
}

// OR

{
  "properties": [
    // ... array of properties
  ]
}

// OR just array directly
[
  {
    "id": "string",
    // ... property fields
  }
]
```

---

## 3. Update User Property

### Endpoint
```http
PUT /user/properties/{propertyId}
```

### Request Headers
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {token}",
  "Cookie": "__Secure-better-auth.session_token={cookie}"
}
```

### Request Body
```json
{
  "id": "string",
  "userId": "string",
  "propertyName": "string",
  "address": "string",
  // ... all property fields (same as create)
}
```

### Response (Success)
```json
Status: 200

{
  "data": {
    // ... updated property
  }
}
```

---

## 4. Delete User Property

### Endpoint
```http
DELETE /user/properties/{propertyId}
```

### Request Headers
```json
{
  "Authorization": "Bearer {token}",
  "Cookie": "__Secure-better-auth.session_token={cookie}"
}
```

### Response (Success)
```json
Status: 200 or 204

{
  "success": true
}

// OR just empty response for 204
```

---

## Property Data Model

### UserProperty Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | String | Yes | Unique property identifier |
| userId | String | Yes | Owner's user ID |
| propertyName | String | Yes | Property name/title |
| address | String | Yes | Full address |
| purchasePrice | Double | Yes | Purchase price in dollars |
| marketValue | Double | No | Current market value |
| description | String | No | Property description |
| propertyType | String | No | Type: house, apartment, condo, townhouse, villa, studio |
| bedrooms | Integer | No | Number of bedrooms |
| bathrooms | Integer | No | Number of bathrooms |
| area | Double | No | Area in square feet |
| purchaseDate | DateTime | No | Purchase date (ISO8601) |
| createdAt | DateTime | No | Created timestamp |
| updatedAt | DateTime | No | Last updated timestamp |
| monthlyRent | Double | No | Monthly rental income |
| annualAppreciationRate | Double | No | Annual appreciation rate (%) |
| imageUrls | String[] | No | Array of image URLs |
| isForSale | Boolean | No | Whether property is for sale |
| isForRent | Boolean | No | Whether property is for rent |

---

## Implementation Details

### Offline-First Architecture

The app implements an offline-first approach:

1. **Create Property**
   - Try to save to API first
   - If successful, save to local cache
   - If API fails, save to local cache only (will sync when online)

2. **Load Properties**
   - Try to load from API first
   - Cache results locally
   - If API fails, fallback to local cache

3. **Update Property**
   - Try to update on API first
   - If successful, update local cache
   - If API fails, update local cache only (will sync when online)

4. **Delete Property**
   - Try to delete from API first
   - If successful, delete from local cache
   - If API fails, delete from local cache only (will sync when online)

### Code Files Modified

1. **`lib/services/api_service.dart`**
   - Added `_getHeaders()` method for auth headers
   - Added `createUserProperty()` method
   - Added `updateUserProperty()` method
   - Added `deleteUserProperty()` method
   - Added `getUserProperties()` method
   - Updated all GET requests to include auth headers

2. **`lib/services/user_property_service.dart`**
   - Updated `getUserProperties()` to use API with fallback
   - Updated `addProperty()` to use API with fallback
   - Updated `updateProperty()` to use API with fallback
   - Updated `deleteProperty()` to use API with fallback
   - Added helper methods for local storage

3. **`lib/services/auth_service.dart`**
   - Added `sessionCookie` getter for API authentication

4. **`lib/models/user_property.dart`**
   - Added `imageUrls` to `copyWith()` method
   - Added `imageUrls` to `toJson()` method
   - Added `imageUrls` parsing to `fromJson()` method

### Logging

The implementation includes comprehensive logging:
- 📤 Request logs (endpoint, data)
- 📥 Response logs (status, body)
- ✅ Success logs
- ⚠️ Warning logs (fallback to local)
- ❌ Error logs

### Error Handling

- **401 Unauthorized**: Throws `Authentication required` exception
- **Network Errors**: Falls back to local storage with warning log
- **Timeouts**: 10-second timeout with fallback to local storage
- **Parse Errors**: Logged and handled gracefully

---

## Testing the Integration

### 1. Test Create Property
```dart
final property = UserProperty(
  id: DateTime.now().millisecondsSinceEpoch.toString(),
  userId: 'user123',
  propertyName: 'Test Property',
  address: '123 Main St',
  purchasePrice: 500000,
  // ... other fields
);

final success = await UserPropertyService.addProperty(property);
```

Expected logs:
```
📤 Creating user property...
   Property: Test Property
   Address: 123 Main St
📥 Create Property Response: 201
📥 Response Body: {...}
✅ Property created successfully on server
✅ Property added successfully (API + Local)
```

### 2. Test Load Properties
```dart
final properties = await UserPropertyService.getUserProperties('user123');
```

Expected logs:
```
📤 Fetching user properties...
📥 Get User Properties Response: 200
✅ Loaded X properties from server
```

### 3. Test Offline Mode
Turn off network and try to add a property:

Expected logs:
```
📤 Creating user property...
❌ Error creating property: SocketException...
⚠️ Failed to save to API, saving locally only: ...
✅ Property saved locally (will sync when online)
```

---

## Future Enhancements

1. **Sync Queue**: Implement a queue to retry failed API calls when connectivity is restored
2. **Image Upload**: Add dedicated endpoint for uploading property images
3. **Conflict Resolution**: Handle conflicts when local and server data differ
4. **Optimistic Updates**: Update UI immediately, then sync in background
5. **Batch Operations**: Support uploading multiple properties at once

---

## Notes for Backend Team

### Expected Response Formats
The app is flexible with response formats and handles:
- `{ "data": {...} }`
- `{ "property": {...} }`
- Direct property object `{...}`
- Arrays: `{ "data": [...] }`, `{ "properties": [...] }`, or direct array `[...]`

### Authentication
Both Bearer token and session cookie are sent with every request. The backend should accept either authentication method.

### Property Images
Currently, image URLs are sent as strings. Consider implementing:
- Direct file upload endpoint: `POST /user/properties/{id}/images`
- Support for multiple image formats
- Image optimization/resizing on server
- Secure URL generation for uploaded images

### Validation
Backend should validate:
- User owns the property being updated/deleted
- Required fields are present
- Data types are correct
- Price values are positive
- Dates are valid ISO8601 format

