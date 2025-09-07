import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property.dart';
import '../config/app_config.dart';

class ApiService {
  static const String _baseUrl = AppConfig.apiBaseUrl;
  static const bool _useMockData = AppConfig.useMockData;

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
    // Use mock data if enabled or if network fails
    if (_useMockData) {
      return _getMockProperties(
        page: page,
        limit: limit,
        location: location,
        propertyType: propertyType,
        listingType: listingType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBedrooms: minBedrooms,
        maxBedrooms: maxBedrooms,
        isFeatured: isFeatured,
      );
    }

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
      // Fallback to mock data when network fails
      print('Network error, using mock data: $e');
      return _getMockProperties(
        page: page,
        limit: limit,
        location: location,
        propertyType: propertyType,
        listingType: listingType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBedrooms: minBedrooms,
        maxBedrooms: maxBedrooms,
        isFeatured: isFeatured,
      );
    }
  }

  Future<Property?> getPropertyById(String id) async {
    if (_useMockData) {
      final mockProperties = await _getMockProperties();
      try {
        return mockProperties.firstWhere((property) => property.id == id);
      } catch (e) {
        return null;
      }
    }

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
      // Fallback to mock data
      print('Network error, using mock data: $e');
      final mockProperties = await _getMockProperties();
      try {
        return mockProperties.firstWhere((property) => property.id == id);
      } catch (e) {
        return null;
      }
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

    if (_useMockData) {
      final allProperties = await _getMockProperties();
      return allProperties.where((property) {
        return property.title.toLowerCase().contains(query.toLowerCase()) ||
               property.description.toLowerCase().contains(query.toLowerCase()) ||
               property.location.toLowerCase().contains(query.toLowerCase()) ||
               property.address.toLowerCase().contains(query.toLowerCase());
      }).toList();
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
      // Fallback to mock data
      print('Network error, using mock data: $e');
      final allProperties = await _getMockProperties();
      return allProperties.where((property) {
        return property.title.toLowerCase().contains(query.toLowerCase()) ||
               property.description.toLowerCase().contains(query.toLowerCase()) ||
               property.location.toLowerCase().contains(query.toLowerCase()) ||
               property.address.toLowerCase().contains(query.toLowerCase());
      }).toList();
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
      // Fallback to mock data
      final mockProperties = await _getMockProperties();
      return mockProperties
          .map((property) => property.location)
          .toSet()
          .toList();
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
      // Fallback to mock data
      final mockProperties = await _getMockProperties();
      final totalProperties = mockProperties.length;
      final forSale = mockProperties
          .where((property) => property.listingType == ListingType.sale)
          .length;
      final forRent = mockProperties
          .where((property) => property.listingType == ListingType.rent)
          .length;
      final featured = mockProperties
          .where((property) => property.isFeatured)
          .length;

      return {
        'total': totalProperties,
        'forSale': forSale,
        'forRent': forRent,
        'featured': featured,
      };
    }
  }

  // Mock data for offline/demo purposes
  Future<List<Property>> _getMockProperties({
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
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    final allMockProperties = [
      Property(
        id: '1',
        title: 'Modern Downtown Apartment',
        description: 'Beautiful modern apartment in the heart of downtown with stunning city views.',
        price: 450000,
        location: 'Downtown',
        address: '123 Main Street, Downtown',
        bedrooms: 2,
        bathrooms: 2,
        area: 1200,
        imageUrls: [
          'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800',
          'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=800',
        ],
        propertyType: PropertyType.apartment,
        listingType: ListingType.sale,
        isAvailable: true,
        isFeatured: true,
        amenities: ['Parking', 'Gym', 'Pool', 'Balcony'],
        monthlyRent: 2500,
        annualAppreciationRate: 3.5,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Property(
        id: '2',
        title: 'Luxury Villa with Pool',
        description: 'Spacious luxury villa with private pool and garden in exclusive neighborhood.',
        price: 1200000,
        location: 'Beverly Hills',
        address: '456 Oak Avenue, Beverly Hills',
        bedrooms: 5,
        bathrooms: 4,
        area: 3500,
        imageUrls: [
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811?w=800',
          'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=800',
        ],
        propertyType: PropertyType.villa,
        listingType: ListingType.sale,
        isAvailable: true,
        isFeatured: true,
        amenities: ['Pool', 'Garden', 'Garage', 'Security'],
        monthlyRent: 8000,
        annualAppreciationRate: 4.2,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      Property(
        id: '3',
        title: 'Cozy Family House',
        description: 'Perfect family home with large backyard and quiet neighborhood.',
        price: 350000,
        location: 'Suburbs',
        address: '789 Elm Street, Suburbs',
        bedrooms: 3,
        bathrooms: 2,
        area: 1800,
        imageUrls: [
          'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800',
          'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800',
        ],
        propertyType: PropertyType.house,
        listingType: ListingType.sale,
        isAvailable: true,
        isFeatured: false,
        amenities: ['Backyard', 'Garage', 'Fireplace'],
        monthlyRent: 1800,
        annualAppreciationRate: 2.8,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
      Property(
        id: '4',
        title: 'Modern Studio Apartment',
        description: 'Contemporary studio apartment perfect for young professionals.',
        price: 280000,
        location: 'City Center',
        address: '321 Pine Street, City Center',
        bedrooms: 1,
        bathrooms: 1,
        area: 600,
        imageUrls: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800',
          'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800',
        ],
        propertyType: PropertyType.studio,
        listingType: ListingType.sale,
        isAvailable: true,
        isFeatured: false,
        amenities: ['Modern Kitchen', 'Balcony', 'Storage'],
        monthlyRent: 1500,
        annualAppreciationRate: 3.0,
        createdAt: DateTime.now().subtract(const Duration(days: 20)),
      ),
      Property(
        id: '5',
        title: 'Penthouse with City Views',
        description: 'Luxurious penthouse with panoramic city views and premium finishes.',
        price: 2500000,
        location: 'Financial District',
        address: '555 High Street, Financial District',
        bedrooms: 4,
        bathrooms: 3,
        area: 2800,
        imageUrls: [
          'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
          'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=800',
        ],
        propertyType: PropertyType.apartment,
        listingType: ListingType.sale,
        isAvailable: true,
        isFeatured: true,
        amenities: ['City Views', 'Rooftop', 'Concierge', 'Gym'],
        monthlyRent: 15000,
        annualAppreciationRate: 5.0,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Property(
        id: '6',
        title: 'Charming Townhouse',
        description: 'Beautiful townhouse with modern amenities in a friendly community.',
        price: 420000,
        location: 'Riverside',
        address: '888 River Road, Riverside',
        bedrooms: 3,
        bathrooms: 2,
        area: 1600,
        imageUrls: [
          'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=800',
          'https://images.unsplash.com/photo-1600566753190-17f63ba644f7?w=800',
        ],
        propertyType: PropertyType.townhouse,
        listingType: ListingType.sale,
        isAvailable: true,
        isFeatured: false,
        amenities: ['Community Pool', 'Playground', 'Walking Trails'],
        monthlyRent: 2200,
        annualAppreciationRate: 3.2,
        createdAt: DateTime.now().subtract(const Duration(days: 25)),
      ),
      Property(
        id: '7',
        title: 'Beachfront Condo',
        description: 'Stunning beachfront condo with ocean views and resort-style amenities.',
        price: 850000,
        location: 'Beachside',
        address: '999 Ocean Drive, Beachside',
        bedrooms: 2,
        bathrooms: 2,
        area: 1400,
        imageUrls: [
          'https://images.unsplash.com/photo-1600607687644-c7171b42498b?w=800',
          'https://images.unsplash.com/photo-1600566753086-00f18fb6b3ea?w=800',
        ],
        propertyType: PropertyType.condo,
        listingType: ListingType.sale,
        isAvailable: true,
        isFeatured: true,
        amenities: ['Ocean Views', 'Beach Access', 'Pool', 'Spa'],
        monthlyRent: 4500,
        annualAppreciationRate: 4.5,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Property(
        id: '8',
        title: 'Historic Brownstone',
        description: 'Charming historic brownstone with original details and modern updates.',
        price: 750000,
        location: 'Historic District',
        address: '777 Heritage Lane, Historic District',
        bedrooms: 4,
        bathrooms: 3,
        area: 2200,
        imageUrls: [
          'https://images.unsplash.com/photo-1600607687920-4e2a09cf159d?w=800',
          'https://images.unsplash.com/photo-1600566753190-17f63ba644f7?w=800',
        ],
        propertyType: PropertyType.house,
        listingType: ListingType.sale,
        isAvailable: true,
        isFeatured: false,
        amenities: ['Historic Details', 'Garden', 'Fireplace', 'Hardwood Floors'],
        monthlyRent: 3800,
        annualAppreciationRate: 3.8,
        createdAt: DateTime.now().subtract(const Duration(days: 40)),
      ),
    ];

    // Apply filters
    var filteredProperties = allMockProperties.where((property) {
      if (location != null && location.isNotEmpty) {
        if (!property.location.toLowerCase().contains(location.toLowerCase()) &&
            !property.address.toLowerCase().contains(location.toLowerCase())) {
          return false;
        }
      }

      if (propertyType != null && property.propertyType != propertyType) {
        return false;
      }

      if (listingType != null && property.listingType != listingType) {
        return false;
      }

      if (minPrice != null && property.price < minPrice) {
        return false;
      }

      if (maxPrice != null && property.price > maxPrice) {
        return false;
      }

      if (minBedrooms != null && property.bedrooms < minBedrooms) {
        return false;
      }

      if (maxBedrooms != null && property.bedrooms > maxBedrooms) {
        return false;
      }

      if (isFeatured != null && property.isFeatured != isFeatured) {
        return false;
      }

      return true;
    }).toList();

    // Apply pagination
    final startIndex = (page - 1) * limit;
    final endIndex = startIndex + limit;
    
    if (startIndex >= filteredProperties.length) {
      return [];
    }

    return filteredProperties.sublist(
      startIndex,
      endIndex > filteredProperties.length ? filteredProperties.length : endIndex,
    );
  }
} 