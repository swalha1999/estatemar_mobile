import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'properties/property_favorites_screen.dart';
import 'properties/my_properties_screen.dart';
import 'sell/sell_screen.dart';
import 'profile/profile_screen.dart';
import 'auth/login_screen.dart';
import '../services/auth_service.dart';
import '../widgets/custom_bottom_navigation_bar.dart';
import '../theme/app_theme.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      await AuthService.initialize();
      if (mounted) {
        setState(() {
          _isLoggedIn = AuthService.isLoggedIn;
        });
      }
    } catch (e) {
      // If there's an error, assume not logged in
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
      }
    }
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(); // Discover
      case 1:
        return const FavoritesScreen(); // Favorites
      case 2:
        return _isLoggedIn 
            ? MyPropertiesScreen(
                onAuthChange: _handleLogoutResult,
              ) 
            : LoginScreen(
                onLoginSuccess: _handleLoginResult,
              ); // My Properties
      case 3:
        return _isLoggedIn 
            ? SellScreen(
                onAuthChange: _handleLogoutResult,
                onNavigateToMyProperties: () {
                  setState(() {
                    _currentIndex = 2; // Switch to My Properties tab
                  });
                },
              ) 
            : LoginScreen(
                onLoginSuccess: _handleLoginResult,
              ); // Sell
      case 4:
        return _isLoggedIn 
            ? ProfileScreen(
                onLogout: _handleLogoutResult,
              ) 
            : LoginScreen(
                onLoginSuccess: _handleLoginResult,
              ); // Profile
      default:
        return const HomeScreen();
    }
  }

  Future<void> _handleLoginResult() async {
    print('🔄 handleLoginResult called');
    try {
      await _checkAuthStatus();
      print('✅ Auth status updated: $_isLoggedIn');
      // The setState in _checkAuthStatus will automatically update the UI
    } catch (e) {
      print('❌ Error in handleLoginResult: $e');
      // Handle any errors during auth check
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
        });
      }
    }
  }

  Future<void> _handleLogoutResult() async {
    try {
      await _checkAuthStatus();
      // Navigate to Discover page after logout
      if (mounted) {
        setState(() {
          _currentIndex = 0;
        });
      }
    } catch (e) {
      // Handle any errors during auth check
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _currentIndex = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🏗️ Building MainNavigationScreen - isLoggedIn: $_isLoggedIn, currentIndex: $_currentIndex');
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      body: _buildPage(_currentIndex),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          if (mounted) {
            setState(() {
              _currentIndex = index;
            });
            
            // Handle login result for auth-required pages
            if (index == 2 || index == 3 || index == 4) {
              try {
                await _handleLoginResult();
              } catch (e) {
                // Handle any errors silently
              }
            }
          }
        },
        items: const [
          CustomBottomNavigationBarItem(
            icon: Icons.explore,
            label: 'Discover',
          ),
          CustomBottomNavigationBarItem(
            icon: Icons.favorite,
            label: 'Favorites',
          ),
          CustomBottomNavigationBarItem(
            icon: Icons.home_work,
            label: 'My Properties',
          ),
          CustomBottomNavigationBarItem(
            icon: Icons.sell,
            label: 'Sell',
          ),
          CustomBottomNavigationBarItem(
            icon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 