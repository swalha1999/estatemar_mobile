import 'package:shared_preferences/shared_preferences.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorite_properties';
  static FavoriteService? _instance;
  SharedPreferences? _prefs;

  FavoriteService._internal();

  static FavoriteService get instance {
    _instance ??= FavoriteService._internal();
    return _instance!;
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<List<String>> getFavoriteIds() async {
    await _initPrefs();
    return _prefs?.getStringList(_favoritesKey) ?? [];
  }

  Future<bool> isFavorite(String propertyId) async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.contains(propertyId);
  }

  Future<void> addToFavorites(String propertyId) async {
    await _initPrefs();
    final favoriteIds = await getFavoriteIds();
    
    if (!favoriteIds.contains(propertyId)) {
      favoriteIds.add(propertyId);
      await _prefs?.setStringList(_favoritesKey, favoriteIds);
    }
  }

  Future<void> removeFromFavorites(String propertyId) async {
    await _initPrefs();
    final favoriteIds = await getFavoriteIds();
    
    if (favoriteIds.contains(propertyId)) {
      favoriteIds.remove(propertyId);
      await _prefs?.setStringList(_favoritesKey, favoriteIds);
    }
  }

  Future<void> toggleFavorite(String propertyId) async {
    final isCurrentlyFavorite = await isFavorite(propertyId);
    
    if (isCurrentlyFavorite) {
      await removeFromFavorites(propertyId);
    } else {
      await addToFavorites(propertyId);
    }
  }

  Future<void> clearAllFavorites() async {
    await _initPrefs();
    await _prefs?.remove(_favoritesKey);
  }

  Future<int> getFavoriteCount() async {
    final favoriteIds = await getFavoriteIds();
    return favoriteIds.length;
  }
} 