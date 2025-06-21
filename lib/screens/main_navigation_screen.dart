import 'package:flutter/material.dart';
import 'home/home_screen.dart';
// import 'properties/property_search_screen.dart';
import 'properties/property_favorites_screen.dart';
import 'news/news_screen.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const NewsScreen();
      case 2:
        return const FavoritesScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_currentIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          CustomBottomNavigationBarItem(
            icon: Icons.terrain,
            label: 'Home',
          ),
          CustomBottomNavigationBarItem(
            icon: Icons.article,
            label: 'News',
          ),
          CustomBottomNavigationBarItem(
            icon: Icons.favorite,
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
} 