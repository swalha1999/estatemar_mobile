import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/property_card.dart';
import '../../services/property_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final propertyService = PropertyService();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder(
        future: propertyService.getFavoriteProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load favorites: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No favorite properties yet.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          final favorites = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              return PropertyCard(
                property: favorites[index],
                isFavorite: true,
                onFavoritePressed: () async {
                  await propertyService.toggleFavorite(favorites[index].id);
                  (context as Element).markNeedsBuild();
                },
              );
            },
          );
        },
      ),
    );
  }
} 