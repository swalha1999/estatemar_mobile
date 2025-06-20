import '../models/property.dart';
import 'api_service.dart';
import 'favorite_service.dart';

enum SortOrder {
  none,
  highToLow,
  lowToHigh,
}

class PropertyService {
  final ApiService _apiService = ApiService();
  final FavoriteService _favoriteService = FavoriteService.instance;
  FavoriteService get favoriteService => _favoriteService;

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
    SortOrder sortOrder = SortOrder.none,
  }) async {
    final properties = await _apiService.getProperties(
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
    if (sortOrder == SortOrder.highToLow) {
      properties.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortOrder == SortOrder.lowToHigh) {
      properties.sort((a, b) => a.price.compareTo(b.price));
    }
    return properties;
  }

  Future<Property?> getPropertyById(String id) async {
    return await _apiService.getPropertyById(id);
  }

  Future<List<Property>> getFavoriteProperties() async {
    final favoriteIds = await _favoriteService.getFavoriteIds();
    if (favoriteIds.isEmpty) {
      return [];
    }
    return await _apiService.getPropertiesByIds(favoriteIds);
  }

  Future<bool> isFavorite(String propertyId) async {
    return await _favoriteService.isFavorite(propertyId);
  }

  Future<void> toggleFavorite(String propertyId) async {
    await _favoriteService.toggleFavorite(propertyId);
  }

  Future<void> addToFavorites(String propertyId) async {
    await _favoriteService.addToFavorites(propertyId);
  }

  Future<void> removeFromFavorites(String propertyId) async {
    await _favoriteService.removeFromFavorites(propertyId);
  }

  Future<int> getFavoriteCount() async {
    return await _favoriteService.getFavoriteCount();
  }

  Future<List<Property>> getFeaturedProperties({int limit = 5}) async {
    return await _apiService.getFeaturedProperties(limit: limit);
  }

  Future<List<Property>> searchProperties(String query) async {
    return await _apiService.searchProperties(query);
  }

  Future<List<Property>> getSimilarProperties(String propertyId, {int limit = 3}) async {
    return await _apiService.getSimilarProperties(propertyId, limit: limit);
  }

  Future<List<String>> getLocations() async {
    return await _apiService.getLocations();
  }

  Future<Map<String, int>> getPropertyStats() async {
    return await _apiService.getPropertyStats();
  }
} 