import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'EstateMar Mobile',
          style: TextStyle(color: AppColors.grey),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.terrain,
              size: 100,
              color: AppColors.primary,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to EstateMar Mobile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Your Real Estate Solution',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
} 