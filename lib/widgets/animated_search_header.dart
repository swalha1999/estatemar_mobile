import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AnimatedSearchHeader extends StatelessWidget {
  const AnimatedSearchHeader({
    super.key,
    required this.onSearchTap,
    required this.onFilterTap,
    required this.onSortTap,
    this.hasFilters = false,
    this.sortActive = false,
  });

  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;
  final bool hasFilters;
  final bool sortActive;

  static const double headerHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // Search bar - always visible
            Expanded(
              child: GestureDetector(
                onTap: onSearchTap,
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(
                          Icons.search,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Search properties...',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Filter button
            _IconButton(
              icon: Icons.tune,
              onTap: onFilterTap,
              isActive: hasFilters,
              size: 44,
              badge: hasFilters,
            ),
            
            const SizedBox(width: 8),
            
            // Sort button
            _IconButton(
              icon: Icons.sort,
              onTap: onSortTap,
              isActive: sortActive,
              size: 44,
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon,
    required this.onTap,
    required this.isActive,
    required this.size,
    this.badge = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isActive;
  final double size;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.grey[100],
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: isActive ? AppColors.primary : Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[700],
                size: 20,
              ),
              if (badge)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
} 