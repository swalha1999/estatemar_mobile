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
    this.monthlyRent,
    this.annualAppreciationRate,
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
  final double? monthlyRent;
  final double? annualAppreciationRate;

  String get formattedPrice {
    if (price >= 1000000) {
      return '\$${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '\$${(price / 1000).toStringAsFixed(0)}K';
    }
    return '\$${price.toStringAsFixed(0)}';
  }

  String get formattedMonthlyRent {
    if (monthlyRent == null) return 'N/A';
    if (monthlyRent! >= 1000) {
      return '\$${(monthlyRent! / 1000).toStringAsFixed(0)}K/mo';
    }
    return '\$${monthlyRent!.toStringAsFixed(0)}/mo';
  }

  String get formattedAnnualRent {
    if (monthlyRent == null) return 'N/A';
    final annualRent = monthlyRent! * 12;
    if (annualRent >= 1000000) {
      return '\$${(annualRent / 1000000).toStringAsFixed(1)}M/yr';
    } else if (annualRent >= 1000) {
      return '\$${(annualRent / 1000).toStringAsFixed(0)}K/yr';
    }
    return '\$${annualRent.toStringAsFixed(0)}/yr';
  }

  double? get annualRent => monthlyRent != null ? monthlyRent! * 12 : null;

  double? get annualNetIncome {
    if (annualRent == null) return null;
    return annualRent!;
  }

  String get formattedAnnualNetIncome {
    final netIncome = annualNetIncome;
    if (netIncome == null) return 'N/A';
    if (netIncome >= 1000000) {
      return '\$${(netIncome / 1000000).toStringAsFixed(1)}M/yr';
    } else if (netIncome >= 1000) {
      return '\$${(netIncome / 1000).toStringAsFixed(0)}K/yr';
    }
    return '\$${netIncome.toStringAsFixed(0)}/yr';
  }

  double? get roiPercentage {
    if (annualNetIncome == null || price <= 0) return null;
    
    // Calculate cash-on-cash ROI (rental income only)
    final cashOnCashRoi = (annualNetIncome! / price) * 100;
    
    // Add appreciation if available
    if (annualAppreciationRate != null) {
      final appreciationValue = price * (annualAppreciationRate! / 100);
      final totalReturn = annualNetIncome! + appreciationValue;
      return (totalReturn / price) * 100;
    }
    
    return cashOnCashRoi;
  }

  double? get cashOnCashRoi {
    if (annualNetIncome == null || price <= 0) return null;
    return (annualNetIncome! / price) * 100;
  }

  double? get appreciationRoi {
    if (annualAppreciationRate == null || price <= 0) return null;
    return annualAppreciationRate;
  }

  String get formattedRoiPercentage {
    final roi = roiPercentage;
    if (roi == null) return 'N/A';
    return '${roi.toStringAsFixed(1)}%';
  }

  String get formattedCashOnCashRoi {
    final roi = cashOnCashRoi;
    if (roi == null) return 'N/A';
    return '${roi.toStringAsFixed(1)}%';
  }

  String get formattedAppreciationRoi {
    final roi = appreciationRoi;
    if (roi == null) return 'N/A';
    return '${roi.toStringAsFixed(1)}%';
  }

  String get formattedTotalRoi {
    final totalRoi = roiPercentage;
    final cashRoi = cashOnCashRoi;
    final appRoi = appreciationRoi;
    
    if (totalRoi == null) return 'N/A';
    
    if (appRoi != null && cashRoi != null) {
      return '${totalRoi.toStringAsFixed(1)}% (${cashRoi.toStringAsFixed(1)}% + ${appRoi.toStringAsFixed(1)}%)';
    }
    
    return '${totalRoi.toStringAsFixed(1)}%';
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
    double? monthlyRent,
    double? annualAppreciationRate,
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
      monthlyRent: monthlyRent ?? this.monthlyRent,
      annualAppreciationRate: annualAppreciationRate ?? this.annualAppreciationRate,
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
      'monthlyRent': monthlyRent,
      'annualAppreciationRate': annualAppreciationRate,
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
      monthlyRent: json['monthlyRent'] as double?,
      annualAppreciationRate: json['annualAppreciationRate'] as double?,
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