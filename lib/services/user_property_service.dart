import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_property.dart';

class UserPropertyService {
  static const String _propertiesKey = 'user_properties';

  /// Get all properties for a specific user
  static Future<List<UserProperty>> getUserProperties(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final propertiesJson = prefs.getString('${_propertiesKey}_$userId');
      
      if (propertiesJson == null) {
        return [];
      }

      final List<dynamic> propertiesList = json.decode(propertiesJson);
      return propertiesList
          .map((json) => UserProperty.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add a new property for a user
  static Future<bool> addProperty(UserProperty property) async {
    try {
      final properties = await getUserProperties(property.userId);
      properties.add(property);
      
      final prefs = await SharedPreferences.getInstance();
      final propertiesJson = json.encode(
        properties.map((p) => p.toJson()).toList(),
      );
      
      await prefs.setString('${_propertiesKey}_${property.userId}', propertiesJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update an existing property
  static Future<bool> updateProperty(UserProperty property) async {
    try {
      final properties = await getUserProperties(property.userId);
      final index = properties.indexWhere((p) => p.id == property.id);
      
      if (index == -1) {
        return false;
      }

      properties[index] = property.copyWith(updatedAt: DateTime.now());
      
      final prefs = await SharedPreferences.getInstance();
      final propertiesJson = json.encode(
        properties.map((p) => p.toJson()).toList(),
      );
      
      await prefs.setString('${_propertiesKey}_${property.userId}', propertiesJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Delete a property
  static Future<bool> deleteProperty(String userId, String propertyId) async {
    try {
      final properties = await getUserProperties(userId);
      properties.removeWhere((p) => p.id == propertyId);
      
      final prefs = await SharedPreferences.getInstance();
      final propertiesJson = json.encode(
        properties.map((p) => p.toJson()).toList(),
      );
      
      await prefs.setString('${_propertiesKey}_$userId', propertiesJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get property analytics for a user
  static Future<PropertyAnalytics> getPropertyAnalytics(String userId) async {
    final properties = await getUserProperties(userId);
    
    if (properties.isEmpty) {
      return PropertyAnalytics.empty();
    }

    double totalPurchasePrice = 0;
    double totalMarketValue = 0;
    double totalProfitLoss = 0;
    double totalAnnualRent = 0;
    int propertiesWithMarketValue = 0;
    int propertiesWithRent = 0;

    for (final property in properties) {
      totalPurchasePrice += property.purchasePrice;
      
      if (property.marketValue != null) {
        totalMarketValue += property.marketValue!;
        totalProfitLoss += property.profitLoss ?? 0;
        propertiesWithMarketValue++;
      }
      
      if (property.annualRent != null) {
        totalAnnualRent += property.annualRent!;
        propertiesWithRent++;
      }
    }

    final averageRentalYield = propertiesWithRent > 0 
        ? (totalAnnualRent / totalPurchasePrice) * 100 
        : 0.0;

    final totalReturnPercentage = totalPurchasePrice > 0 
        ? (totalProfitLoss / totalPurchasePrice) * 100 
        : 0.0;

    return PropertyAnalytics(
      totalProperties: properties.length,
      totalPurchasePrice: totalPurchasePrice,
      totalMarketValue: totalMarketValue,
      totalProfitLoss: totalProfitLoss,
      totalAnnualRent: totalAnnualRent,
      averageRentalYield: averageRentalYield,
      totalReturnPercentage: totalReturnPercentage,
      propertiesWithMarketValue: propertiesWithMarketValue,
      propertiesWithRent: propertiesWithRent,
    );
  }
}

class PropertyAnalytics {
  final int totalProperties;
  final double totalPurchasePrice;
  final double totalMarketValue;
  final double totalProfitLoss;
  final double totalAnnualRent;
  final double averageRentalYield;
  final double totalReturnPercentage;
  final int propertiesWithMarketValue;
  final int propertiesWithRent;

  const PropertyAnalytics({
    required this.totalProperties,
    required this.totalPurchasePrice,
    required this.totalMarketValue,
    required this.totalProfitLoss,
    required this.totalAnnualRent,
    required this.averageRentalYield,
    required this.totalReturnPercentage,
    required this.propertiesWithMarketValue,
    required this.propertiesWithRent,
  });

  factory PropertyAnalytics.empty() {
    return const PropertyAnalytics(
      totalProperties: 0,
      totalPurchasePrice: 0,
      totalMarketValue: 0,
      totalProfitLoss: 0,
      totalAnnualRent: 0,
      averageRentalYield: 0,
      totalReturnPercentage: 0,
      propertiesWithMarketValue: 0,
      propertiesWithRent: 0,
    );
  }

  String get formattedTotalPurchasePrice {
    if (totalPurchasePrice >= 1000000) {
      return '\$${(totalPurchasePrice / 1000000).toStringAsFixed(1)}M';
    } else if (totalPurchasePrice >= 1000) {
      return '\$${(totalPurchasePrice / 1000).toStringAsFixed(0)}K';
    }
    return '\$${totalPurchasePrice.toStringAsFixed(0)}';
  }

  String get formattedTotalMarketValue {
    if (totalMarketValue >= 1000000) {
      return '\$${(totalMarketValue / 1000000).toStringAsFixed(1)}M';
    } else if (totalMarketValue >= 1000) {
      return '\$${(totalMarketValue / 1000).toStringAsFixed(0)}K';
    }
    return '\$${totalMarketValue.toStringAsFixed(0)}';
  }

  String get formattedTotalProfitLoss {
    final sign = totalProfitLoss >= 0 ? '+' : '';
    if (totalProfitLoss.abs() >= 1000000) {
      return '$sign\$${(totalProfitLoss / 1000000).toStringAsFixed(1)}M';
    } else if (totalProfitLoss.abs() >= 1000) {
      return '$sign\$${(totalProfitLoss / 1000).toStringAsFixed(0)}K';
    }
    return '$sign\$${totalProfitLoss.toStringAsFixed(0)}';
  }

  String get formattedTotalAnnualRent {
    if (totalAnnualRent >= 1000000) {
      return '\$${(totalAnnualRent / 1000000).toStringAsFixed(1)}M';
    } else if (totalAnnualRent >= 1000) {
      return '\$${(totalAnnualRent / 1000).toStringAsFixed(0)}K';
    }
    return '\$${totalAnnualRent.toStringAsFixed(0)}';
  }

  String get formattedAverageRentalYield {
    return '${averageRentalYield.toStringAsFixed(1)}%';
  }

  String get formattedTotalReturnPercentage {
    final sign = totalReturnPercentage >= 0 ? '+' : '';
    return '$sign${totalReturnPercentage.toStringAsFixed(1)}%';
  }
}
