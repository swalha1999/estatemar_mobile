import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Favorites',
          style: TextStyle(color: AppColors.grey),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 100,
              color: AppColors.primary,
            ),
            SizedBox(height: 20),
            Text(
              'Your Favorites',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Saved properties you love',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 