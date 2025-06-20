class Property {
  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.address,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.imageUrls,
    required this.propertyType,
    required this.listingType,
    required this.isAvailable,
    required this.isFeatured,
    this.amenities = const [],
    this.latitude,
    this.longitude,
    this.yearBuilt,
    this.parkingSpaces,
    this.agentId,
    this.agentName,
    this.agentPhone,
    this.agentEmail,
    this.createdAt,
    this.updatedAt,
    this.virtualTourUrl,
  });

  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String address;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final List<String> imageUrls;
  final PropertyType propertyType;
  final ListingType listingType;
  final bool isAvailable;
  final bool isFeatured;
  final List<String> amenities;
  final double? latitude;
  final double? longitude;
  final int? yearBuilt;
  final int? parkingSpaces;
  final String? agentId;
  final String? agentName;
  final String? agentPhone;
  final String? agentEmail;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? virtualTourUrl;

  String get formattedPrice {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(0)}K';
    }
    return '\$${price.toStringAsFixed(0)}';
  }

  String get propertyTypeString {
    switch (propertyType) {
      case PropertyType.house:
        return 'House';
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.condo:
        return 'Condo';
      case PropertyType.townhouse:
        return 'Townhouse';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.studio:
        return 'Studio';
    }
  }

  String get listingTypeString {
    switch (listingType) {
      case ListingType.sale:
        return 'For Sale';
      case ListingType.rent:
        return 'For Rent';
    }
  }

  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    String? address,
    int? bedrooms,
    int? bathrooms,
    double? area,
    List<String>? imageUrls,
    PropertyType? propertyType,
    ListingType? listingType,
    bool? isAvailable,
    bool? isFeatured,
    List<String>? amenities,
    double? latitude,
    double? longitude,
    int? yearBuilt,
    int? parkingSpaces,
    String? agentId,
    String? agentName,
    String? agentPhone,
    String? agentEmail,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? virtualTourUrl,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      address: address ?? this.address,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      imageUrls: imageUrls ?? this.imageUrls,
      propertyType: propertyType ?? this.propertyType,
      listingType: listingType ?? this.listingType,
      isAvailable: isAvailable ?? this.isAvailable,
      isFeatured: isFeatured ?? this.isFeatured,
      amenities: amenities ?? this.amenities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      yearBuilt: yearBuilt ?? this.yearBuilt,
      parkingSpaces: parkingSpaces ?? this.parkingSpaces,
      agentId: agentId ?? this.agentId,
      agentName: agentName ?? this.agentName,
      agentPhone: agentPhone ?? this.agentPhone,
      agentEmail: agentEmail ?? this.agentEmail,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      virtualTourUrl: virtualTourUrl ?? this.virtualTourUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'address': address,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'imageUrls': imageUrls,
      'propertyType': propertyType.name,
      'listingType': listingType.name,
      'isAvailable': isAvailable,
      'isFeatured': isFeatured,
      'amenities': amenities,
      'latitude': latitude,
      'longitude': longitude,
      'yearBuilt': yearBuilt,
      'parkingSpaces': parkingSpaces,
      'agentId': agentId,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'agentEmail': agentEmail,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'virtualTourUrl': virtualTourUrl,
    };
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      location: json['location'] as String,
      address: json['address'] as String,
      bedrooms: json['bedrooms'] as int,
      bathrooms: json['bathrooms'] as int,
      area: (json['area'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls']),
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == json['propertyType'],
        orElse: () => PropertyType.house,
      ),
      listingType: ListingType.values.firstWhere(
        (e) => e.name == json['listingType'],
        orElse: () => ListingType.sale,
      ),
      isAvailable: json['isAvailable'] as bool,
      isFeatured: json['isFeatured'] as bool,
      amenities: List<String>.from(json['amenities'] ?? []),
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      yearBuilt: json['yearBuilt'] as int?,
      parkingSpaces: json['parkingSpaces'] as int?,
      agentId: json['agentId'] as String?,
      agentName: json['agentName'] as String?,
      agentPhone: json['agentPhone'] as String?,
      agentEmail: json['agentEmail'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      virtualTourUrl: json['virtualTourUrl'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Property && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Property(id: $id, title: $title, price: $price, location: $location)';
  }
}

enum PropertyType {
  house,
  apartment,
  condo,
  townhouse,
  villa,
  studio,
}

enum ListingType {
  sale,
  rent,
} 