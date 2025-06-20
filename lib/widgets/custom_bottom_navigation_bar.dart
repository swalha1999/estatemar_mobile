import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<CustomBottomNavigationBarItem> items;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final int index = entry.key;
          final CustomBottomNavigationBarItem item = entry.value;
          final bool isSelected = index == currentIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                color: Colors.transparent,
                                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     const SizedBox(height: 12),
                     Icon(
                       item.icon,
                       color: isSelected 
                           ? AppColors.primary 
                           : AppColors.greyWithOpacity(0.6),
                       size: 36,
                     ),
                     const SizedBox(height: 10),
                     Text(
                       item.label,
                       style: TextStyle(
                         fontSize: 14,
                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                         color: isSelected ? AppColors.primary : AppColors.greyWithOpacity(0.6),
                       ),
                     ),
                     const SizedBox(height: 14),
                   ],
                 ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CustomBottomNavigationBarItem {
  final IconData icon;
  final String label;

  const CustomBottomNavigationBarItem({
    required this.icon,
    required this.label,
  });
} 