import '../models/property.dart';

class ApiService {
  static const Duration _networkDelay = Duration(milliseconds: 1000);

  static final List<Property> _dummyProperties = [
    Property(
      id: '1',
      title: 'Modern Luxury Villa',
      description: 'Beautiful modern villa with stunning ocean views, private pool, and spacious garden. Perfect for families seeking luxury living.',
      price: 1250000,
      location: 'Malibu, CA',
      address: '123 Ocean Drive, Malibu, CA 90265',
      bedrooms: 4,
      bathrooms: 3,
      area: 2800.0,
      imageUrls: [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2075&q=80',
        'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2053&q=80',
        'https://images.unsplash.com/photo-1600566753190-17f0baa2a6c3?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80'
      ],
      propertyType: PropertyType.villa,
      listingType: ListingType.sale,
      isAvailable: true,
      isFeatured: true,
      amenities: ['Swimming Pool', 'Ocean View', 'Garden', 'Garage', 'Fireplace'],
      latitude: 34.0259,
      longitude: -118.7798,
      yearBuilt: 2020,
      parkingSpaces: 2,
      agentName: 'Sarah Johnson',
      agentPhone: '+1 (555) 123-4567',
      agentEmail: 'sarah.johnson@estatemar.com',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Property(
      id: '2',
      title: 'Downtown Luxury Apartment',
      description: 'Sophisticated downtown apartment with panoramic city views, modern amenities, and premium finishes.',
      price: 850000,
      location: 'Downtown LA, CA',
      address: '456 City Center Blvd, Los Angeles, CA 90012',
      bedrooms: 2,
      bathrooms: 2,
      area: 1200.0,
      imageUrls: [
        'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      ],
      propertyType: PropertyType.apartment,
      listingType: ListingType.sale,
      isAvailable: true,
      isFeatured: false,
      amenities: ['City View', 'Gym', 'Concierge', 'Rooftop Terrace'],
      latitude: 34.0522,
      longitude: -118.2437,
      yearBuilt: 2018,
      parkingSpaces: 1,
      agentName: 'Michael Chen',
      agentPhone: '+1 (555) 987-6543',
      agentEmail: 'michael.chen@estatemar.com',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Property(
      id: '3',
      title: 'Cozy Family House',
      description: 'Charming family home in quiet neighborhood with large backyard, perfect for children and pets.',
      price: 650000,
      location: 'Pasadena, CA',
      address: '789 Maple Street, Pasadena, CA 91101',
      bedrooms: 3,
      bathrooms: 2,
      area: 1800.0,
      imageUrls: [
        'https://images.unsplash.com/photo-1570129477492-45c003edd2be?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
        'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      ],
      propertyType: PropertyType.house,
      listingType: ListingType.sale,
      isAvailable: true,
      isFeatured: false,
      amenities: ['Large Backyard', 'Fireplace', 'Hardwood Floors', 'Garage'],
      latitude: 34.1478,
      longitude: -118.1445,
      yearBuilt: 2015,
      parkingSpaces: 2,
      agentName: 'Emily Rodriguez',
      agentPhone: '+1 (555) 456-7890',
      agentEmail: 'emily.rodriguez@estatemar.com',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Property(
      id: '4',
      title: 'Stylish Studio Apartment',
      description: 'Modern studio apartment in trendy neighborhood, perfect for young professionals.',
      price: 2800,
      location: 'West Hollywood, CA',
      address: '321 Sunset Blvd, West Hollywood, CA 90069',
      bedrooms: 0,
      bathrooms: 1,
      area: 500.0,
      imageUrls: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      ],
      propertyType: PropertyType.studio,
      listingType: ListingType.rent,
      isAvailable: true,
      isFeatured: true,
      amenities: ['Modern Kitchen', 'In-unit Laundry', 'Gym Access'],
      latitude: 34.0900,
      longitude: -118.3617,
      yearBuilt: 2019,
      parkingSpaces: 1,
      agentName: 'David Kim',
      agentPhone: '+1 (555) 234-5678',
      agentEmail: 'david.kim@estatemar.com',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Property(
      id: '5',
      title: 'Elegant Townhouse',
      description: 'Spacious townhouse with modern amenities and private patio, great for entertaining.',
      price: 4500,
      location: 'Beverly Hills, CA',
      address: '654 Rodeo Drive, Beverly Hills, CA 90210',
      bedrooms: 3,
      bathrooms: 2,
      area: 1600.0,
      imageUrls: [
        'https://images.unsplash.com/photo-1583608205776-bfd35f0d9f83?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
        'https://images.unsplash.com/photo-1572120360610-d971b9d7767c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=2070&q=80',
      ],
      propertyType: PropertyType.townhouse,
      listingType: ListingType.rent,
      isAvailable: true,
      isFeatured: false,
      amenities: ['Private Patio', 'Modern Kitchen', 'Garage', 'Central AC'],
      latitude: 34.0736,
      longitude: -118.4004,
      yearBuilt: 2017,
      parkingSpaces: 2,
      agentName: 'Lisa Thompson',
      agentPhone: '+1 (555) 345-6789',
      agentEmail: 'lisa.thompson@estatemar.com',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

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
    await Future.delayed(_networkDelay);

    List<Property> filteredProperties = List.from(_dummyProperties);

    if (location != null && location.isNotEmpty) {
      filteredProperties = filteredProperties
          .where((property) =>
              property.location.toLowerCase().contains(location.toLowerCase()) ||
              property.address.toLowerCase().contains(location.toLowerCase()))
          .toList();
    }

    if (propertyType != null) {
      filteredProperties = filteredProperties
          .where((property) => property.propertyType == propertyType)
          .toList();
    }

    if (listingType != null) {
      filteredProperties = filteredProperties
          .where((property) => property.listingType == listingType)
          .toList();
    }

    if (minPrice != null) {
      filteredProperties = filteredProperties
          .where((property) => property.price >= minPrice)
          .toList();
    }

    if (maxPrice != null) {
      filteredProperties = filteredProperties
          .where((property) => property.price <= maxPrice)
          .toList();
    }

    if (minBedrooms != null) {
      filteredProperties = filteredProperties
          .where((property) => property.bedrooms >= minBedrooms)
          .toList();
    }

    if (maxBedrooms != null) {
      filteredProperties = filteredProperties
          .where((property) => property.bedrooms <= maxBedrooms)
          .toList();
    }

    if (isFeatured != null) {
      filteredProperties = filteredProperties
          .where((property) => property.isFeatured == isFeatured)
          .toList();
    }

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

  Future<Property?> getPropertyById(String id) async {
    await Future.delayed(_networkDelay);

    try {
      return _dummyProperties.firstWhere((property) => property.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Property>> getFeaturedProperties({int limit = 5}) async {
    await Future.delayed(_networkDelay);

    final featuredProperties = _dummyProperties
        .where((property) => property.isFeatured)
        .take(limit)
        .toList();

    return featuredProperties;
  }

  Future<List<Property>> searchProperties(String query) async {
    await Future.delayed(_networkDelay);

    if (query.isEmpty) {
      return _dummyProperties;
    }

    final searchResults = _dummyProperties
        .where((property) =>
            property.title.toLowerCase().contains(query.toLowerCase()) ||
            property.description.toLowerCase().contains(query.toLowerCase()) ||
            property.location.toLowerCase().contains(query.toLowerCase()) ||
            property.address.toLowerCase().contains(query.toLowerCase()) ||
            property.propertyTypeString.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return searchResults;
  }

  Future<List<Property>> getSimilarProperties(String propertyId, {int limit = 3}) async {
    await Future.delayed(_networkDelay);

    final currentProperty = await getPropertyById(propertyId);
    if (currentProperty == null) {
      return [];
    }

    final similarProperties = _dummyProperties
        .where((property) =>
            property.id != propertyId &&
            (property.propertyType == currentProperty.propertyType ||
             property.location == currentProperty.location ||
             (property.price - currentProperty.price).abs() < 100000))
        .take(limit)
        .toList();

    return similarProperties;
  }

  Future<List<String>> getLocations() async {
    await Future.delayed(_networkDelay);

    final locations = _dummyProperties
        .map((property) => property.location)
        .toSet()
        .toList();

    return locations;
  }

  Future<Map<String, int>> getPropertyStats() async {
    await Future.delayed(_networkDelay);

    final totalProperties = _dummyProperties.length;
    final forSale = _dummyProperties
        .where((property) => property.listingType == ListingType.sale)
        .length;
    final forRent = _dummyProperties
        .where((property) => property.listingType == ListingType.rent)
        .length;
    final featured = _dummyProperties
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