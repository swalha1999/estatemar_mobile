import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'properties/property_search_screen.dart';
import 'properties/property_favorites_screen.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
            icon: Icons.search,
            label: 'Search',
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