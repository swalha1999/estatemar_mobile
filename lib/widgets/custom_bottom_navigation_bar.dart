import 'package:flutter/material.dart';
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.transparent,
                                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(item.icon, size: 24, color: isSelected ? AppColors.primary : Colors.grey),
                     const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppColors.primary : Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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