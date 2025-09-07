# Network Setup Guide

## Current Status
The app is currently configured to use **mock data** to avoid network connectivity issues during development and testing.

## Switching to Real API

To use the real API instead of mock data:

1. **Open the configuration file:**
   ```
   lib/config/app_config.dart
   ```

2. **Change the mock data setting:**
   ```dart
   class AppConfig {
     // Change this to false to use real API
     static const bool useMockData = false;
     
     // Make sure the API URL is correct
     static const String apiBaseUrl = 'https://estatemar.com/api';
   }
   ```

3. **Restart the app** to apply the changes.

## Network Error Handling

The app includes automatic fallback to mock data when:
- Network connection fails
- API server is unavailable
- Timeout occurs
- Any other network-related error

This ensures the app continues to work even when the API is not available.

## Mock Data Features

The mock data includes:
- 8 sample properties with realistic data
- Full filtering support (location, type, price, bedrooms, etc.)
- Search functionality
- Pagination support
- Featured properties
- Property statistics

## API Requirements

When using the real API, ensure it returns data in the following format:

```json
{
  "success": true,
  "data": [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "price": number,
      "location": "string",
      "address": "string",
      "bedrooms": number,
      "bathrooms": number,
      "area": number,
      "imageUrls": ["string"],
      "propertyType": "string",
      "listingType": "string",
      "isAvailable": boolean,
      "isFeatured": boolean,
      "amenities": ["string"],
      "monthlyRent": number,
      "annualAppreciationRate": number,
      "createdAt": "ISO8601 string"
    }
  ]
}
```

## Troubleshooting

### If you get network errors:
1. Check your internet connection
2. Verify the API URL is correct
3. Ensure the API server is running
4. Check firewall settings
5. The app will automatically fall back to mock data

### If mock data doesn't work:
1. Check that `useMockData = true` in `app_config.dart`
2. Restart the app
3. Check the console for error messages

## Development Notes

- Mock data is perfect for development and testing
- Real API should be used for production
- The app gracefully handles both scenarios
- All features work with both mock data and real API
