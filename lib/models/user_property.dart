import 'property.dart';

class UserProperty {
  const UserProperty({
    required this.id,
    required this.userId,
    required this.propertyName,
    required this.address,
    required this.purchasePrice,
    this.marketValue,
    this.description,
    this.propertyType,
    this.bedrooms,
    this.bathrooms,
    this.area,
    this.purchaseDate,
    this.createdAt,
    this.updatedAt,
    this.monthlyRent,
    this.annualAppreciationRate,
    this.imageUrls = const [],
    this.isForSale = false,
    this.isForRent = false,
  });

  final String id;
  final String userId;
  final String propertyName;
  final String address;
  final double purchasePrice;
  final double? marketValue;
  final String? description;
  final PropertyType? propertyType;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final DateTime? purchaseDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? monthlyRent;
  final double? annualAppreciationRate;
  final List<String> imageUrls;
  final bool isForSale;
  final bool isForRent;

  String get formattedPurchasePrice {
    if (purchasePrice >= 1000000) {
      return '\$${(purchasePrice / 1000000).toStringAsFixed(1)}M';
    } else if (purchasePrice >= 1000) {
      return '\$${(purchasePrice / 1000).toStringAsFixed(0)}K';
    }
    return '\$${purchasePrice.toStringAsFixed(0)}';
  }

  String get formattedMarketValue {
    if (marketValue == null) return 'Not set';
    if (marketValue! >= 1000000) {
      return '\$${(marketValue! / 1000000).toStringAsFixed(1)}M';
    } else if (marketValue! >= 1000) {
      return '\$${(marketValue! / 1000).toStringAsFixed(0)}K';
    }
    return '\$${marketValue!.toStringAsFixed(0)}';
  }

  double? get profitLoss {
    if (marketValue == null) return null;
    return marketValue! - purchasePrice;
  }

  String get formattedProfitLoss {
    final pl = profitLoss;
    if (pl == null) return 'N/A';
    
    final sign = pl >= 0 ? '+' : '';
    if (pl.abs() >= 1000000) {
      return '$sign\$${(pl / 1000000).toStringAsFixed(1)}M';
    } else if (pl.abs() >= 1000) {
      return '$sign\$${(pl / 1000).toStringAsFixed(0)}K';
    }
    return '$sign\$${pl.toStringAsFixed(0)}';
  }

  double? get profitLossPercentage {
    if (marketValue == null || purchasePrice <= 0) return null;
    return ((marketValue! - purchasePrice) / purchasePrice) * 100;
  }

  String get formattedProfitLossPercentage {
    final percentage = profitLossPercentage;
    if (percentage == null) return 'N/A';
    final sign = percentage >= 0 ? '+' : '';
    return '$sign${percentage.toStringAsFixed(1)}%';
  }

  double? get annualRent => monthlyRent != null ? monthlyRent! * 12 : null;

  String get formattedMonthlyRent {
    if (monthlyRent == null) return 'N/A';
    if (monthlyRent! >= 1000) {
      return '\$${(monthlyRent! / 1000).toStringAsFixed(0)}K/mo';
    }
    return '\$${monthlyRent!.toStringAsFixed(0)}/mo';
  }

  String get formattedAnnualRent {
    if (annualRent == null) return 'N/A';
    if (annualRent! >= 1000000) {
      return '\$${(annualRent! / 1000000).toStringAsFixed(1)}M/yr';
    } else if (annualRent! >= 1000) {
      return '\$${(annualRent! / 1000).toStringAsFixed(0)}K/yr';
    }
    return '\$${annualRent!.toStringAsFixed(0)}/yr';
  }

  double? get rentalYield {
    if (annualRent == null || purchasePrice <= 0) return null;
    return (annualRent! / purchasePrice) * 100;
  }

  String get formattedRentalYield {
    final yield = rentalYield;
    if (yield == null) return 'N/A';
    return '${yield.toStringAsFixed(1)}%';
  }

  double? get totalReturn {
    if (annualRent == null || purchasePrice <= 0) return null;
    
    // Calculate total return including rental income and appreciation
    double totalReturn = annualRent!;
    
    if (annualAppreciationRate != null) {
      final appreciationValue = purchasePrice * (annualAppreciationRate! / 100);
      totalReturn += appreciationValue;
    }
    
    return totalReturn;
  }

  double? get totalReturnPercentage {
    if (totalReturn == null || purchasePrice <= 0) return null;
    return (totalReturn! / purchasePrice) * 100;
  }

  String get formattedTotalReturnPercentage {
    final percentage = totalReturnPercentage;
    if (percentage == null) return 'N/A';
    return '${percentage.toStringAsFixed(1)}%';
  }

  String get propertyTypeString {
    if (propertyType == null) return 'Not specified';
    switch (propertyType!) {
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

  UserProperty copyWith({
    String? id,
    String? userId,
    String? propertyName,
    String? address,
    double? purchasePrice,
    double? marketValue,
    String? description,
    PropertyType? propertyType,
    int? bedrooms,
    int? bathrooms,
    double? area,
    DateTime? purchaseDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? monthlyRent,
    double? annualAppreciationRate,
    bool? isForSale,
    bool? isForRent,
  }) {
    return UserProperty(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyName: propertyName ?? this.propertyName,
      address: address ?? this.address,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      marketValue: marketValue ?? this.marketValue,
      description: description ?? this.description,
      propertyType: propertyType ?? this.propertyType,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      area: area ?? this.area,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      annualAppreciationRate: annualAppreciationRate ?? this.annualAppreciationRate,
      isForSale: isForSale ?? this.isForSale,
      isForRent: isForRent ?? this.isForRent,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'propertyName': propertyName,
      'address': address,
      'purchasePrice': purchasePrice,
      'marketValue': marketValue,
      'description': description,
      'propertyType': propertyType?.name,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area': area,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'monthlyRent': monthlyRent,
      'annualAppreciationRate': annualAppreciationRate,
      'isForSale': isForSale,
      'isForRent': isForRent,
    };
  }

  factory UserProperty.fromJson(Map<String, dynamic> json) {
    return UserProperty(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      propertyName: json['propertyName']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      purchasePrice: (json['purchasePrice'] as num?)?.toDouble() ?? 0.0,
      marketValue: json['marketValue'] != null ? (json['marketValue'] as num).toDouble() : null,
      description: json['description'] as String?,
      propertyType: json['propertyType'] != null 
          ? _parsePropertyType(json['propertyType'])
          : null,
      bedrooms: json['bedrooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      area: json['area'] != null ? (json['area'] as num).toDouble() : null,
      purchaseDate: json['purchaseDate'] != null 
          ? DateTime.parse(json['purchaseDate'])
          : null,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      monthlyRent: json['monthlyRent'] != null ? (json['monthlyRent'] as num).toDouble() : null,
      annualAppreciationRate: json['annualAppreciationRate'] != null ? (json['annualAppreciationRate'] as num).toDouble() : null,
      isForSale: json['isForSale'] as bool? ?? false,
      isForRent: json['isForRent'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProperty && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserProperty(id: $id, propertyName: $propertyName, purchasePrice: $purchasePrice)';
  }

  static PropertyType _parsePropertyType(String type) {
    switch (type.toLowerCase()) {
      case 'house':
        return PropertyType.house;
      case 'apartment':
        return PropertyType.apartment;
      case 'condo':
        return PropertyType.condo;
      case 'townhouse':
        return PropertyType.townhouse;
      case 'villa':
        return PropertyType.villa;
      case 'studio':
        return PropertyType.studio;
      default:
        return PropertyType.house;
    }
  }
}
