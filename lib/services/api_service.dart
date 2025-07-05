import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';

class ApiService {
  static const String _baseUrl = 'https://estatemar.com/api';
  static const Duration _networkDelay = Duration(milliseconds: 1000);

  Future<List<Property>> getProperties({
    int page = 1,
    int limit = 10,
    String? location,
    PropertyType? propertyType,
    ListingType? listingType,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    bool? isFeatured,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (location != null && location.isNotEmpty) {
        queryParams['location'] = location;
      }

      if (propertyType != null) {
        queryParams['propertyType'] = propertyType.name;
      }

      if (listingType != null) {
        queryParams['listingType'] = listingType.name;
      }

      if (minPrice != null) {
        queryParams['minPrice'] = minPrice.toString();
      }

      if (maxPrice != null) {
        queryParams['maxPrice'] = maxPrice.toString();
      }

      if (minBedrooms != null) {
        queryParams['minBedrooms'] = minBedrooms.toString();
      }

      if (maxBedrooms != null) {
        queryParams['maxBedrooms'] = maxBedrooms.toString();
      }

      if (isFeatured != null) {
        queryParams['isFeatured'] = isFeatured.toString();
      }

      final uri = Uri.parse('$_baseUrl/properties').replace(queryParameters: queryParams);
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> propertiesJson = jsonData['data'];
          try {
            return propertiesJson.map((json) => Property.fromJson(json)).toList();
          } catch (parseError) {
            throw Exception('Failed to parse property data: $parseError');
          }
        } else {
          throw Exception('Failed to load properties: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Property?> getPropertyById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/properties/$id');
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          try {
            return Property.fromJson(jsonData['data']);
          } catch (parseError) {
            throw Exception('Failed to parse property data: $parseError');
          }
        } else {
          throw Exception('Failed to load property: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load property: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Property>> getPropertiesByIds(List<String> ids) async {
    final properties = <Property>[];
    
    for (final id in ids) {
      final property = await getPropertyById(id);
      if (property != null) {
        properties.add(property);
      }
    }
    
    return properties;
  }

  Future<List<Property>> getFeaturedProperties({int limit = 5}) async {
    return getProperties(isFeatured: true, limit: limit);
  }

  Future<List<Property>> searchProperties(String query) async {
    if (query.isEmpty) {
      return getProperties();
    }

    try {
      final uri = Uri.parse('$_baseUrl/properties').replace(
        queryParameters: {'search': query},
      );
      
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> propertiesJson = jsonData['data'];
          try {
            return propertiesJson.map((json) => Property.fromJson(json)).toList();
          } catch (parseError) {
            throw Exception('Failed to parse search results: $parseError');
          }
        } else {
          throw Exception('Failed to search properties: ${jsonData['message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('Failed to search properties: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Property>> getSimilarProperties(String propertyId, {int limit = 3}) async {
    final currentProperty = await getPropertyById(propertyId);
    if (currentProperty == null) {
      return [];
    }

    try {
      final allProperties = await getProperties(limit: 50);
      
      final similarProperties = allProperties
          .where((property) =>
              property.id != propertyId &&
              (property.propertyType == currentProperty.propertyType ||
               property.location == currentProperty.location ||
               (property.price - currentProperty.price).abs() < 100000))
          .take(limit)
          .toList();

      return similarProperties;
    } catch (e) {
      return [];
    }
  }

  Future<List<String>> getLocations() async {
    try {
      final properties = await getProperties(limit: 100);
      
      final locations = properties
          .map((property) => property.location)
          .toSet()
          .toList();

      return locations;
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, int>> getPropertyStats() async {
    try {
      final properties = await getProperties(limit: 100);
      
      final totalProperties = properties.length;
      final forSale = properties
          .where((property) => property.listingType == ListingType.sale)
          .length;
      final forRent = properties
          .where((property) => property.listingType == ListingType.rent)
          .length;
      final featured = properties
          .where((property) => property.isFeatured)
          .length;

      return {
        'total': totalProperties,
        'forSale': forSale,
        'forRent': forRent,
        'featured': featured,
      };
    } catch (e) {
      return {
        'total': 0,
        'forSale': 0,
        'forRent': 0,
        'featured': 0,
      };
    }
  }
} 