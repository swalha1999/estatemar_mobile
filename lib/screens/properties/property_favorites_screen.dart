import 'package:flutter/material.dart';
import '../../widgets/property_card.dart';
import '../../services/property_service.dart';
import '../../screens/properties/property_detail_screen.dart';
import '../../models/property.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PropertyService propertyService = PropertyService();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<Property> _favorites = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final favorites = await propertyService.getFavoriteProperties();
      if (!mounted) return;
      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _removeFavorite(int index) async {
    final property = _favorites[index];
    await propertyService.toggleFavorite(property.id);
    setState(() {
      _favorites.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => SizeTransition(
          sizeFactor: animation,
          child: PropertyCard(
            key: ValueKey(property.id),
            property: property,
            isFavorite: true,
            onFavoritePressed: null,
            onTap: null,
          ),
        ),
        duration: const Duration(milliseconds: 400),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                'Favorite Properties',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Failed to load favorites: \\$_error'))
                      : _favorites.isEmpty
                          ? const Center(
                              child: Text(
                                'No favorite properties yet.',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            )
                          : AnimatedList(
                              key: _listKey,
                              initialItemCount: _favorites.length,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemBuilder: (context, index, animation) {
                                final property = _favorites[index];
                                return SizeTransition(
                                  sizeFactor: animation,
                                  child: PropertyCard(
                                    key: ValueKey(property.id),
                                    property: property,
                                    isFavorite: true,
                                    onFavoritePressed: () => _removeFavorite(index),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => PropertyDetailScreen(property: property),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
} 