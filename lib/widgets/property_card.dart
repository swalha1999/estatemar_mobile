import 'package:flutter/material.dart';
import '../models/property.dart';
import '../theme/colors.dart';
import 'roi_display_widget.dart';
import 'safe_image.dart';

class PropertyCard extends StatefulWidget {
  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.isFavorite = false,
    this.onFavoritePressed,
  });

  final Property property;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  int _currentImage = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.property.imageUrls;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: images.isNotEmpty
                        ? Stack(
                            children: [
                              PageView.builder(
                                itemCount: images.length,
                                onPageChanged: (index) {
                                  setState(() => _currentImage = index);
                                },
                                itemBuilder: (context, index) {
                                  return SafeImage(
                                    imageUrl: images[index],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    borderRadius: BorderRadius.zero,
                                    showRetry: false,
                                  );
                                },
                              ),
                              // ROI Widget overlay on top left
                              if (widget.property.annualNetIncome != null)
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: RoiDisplayWidget(
                                    property: widget.property,
                                    compact: false,
                                  ),
                                ),
                              if (images.length > 1)
                                Positioned(
                                  bottom: 8,
                                  left: 0,
                                  right: 0,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(images.length, (i) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: i == _currentImage
                                              ? AppColors.primary
                                              : Colors.white.withOpacity(0.7),
                                        ),
                                      );
                                    }),
                                  ),
                                ),
                            ],
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 48, color: Colors.white),
                          ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Material(
                    color: Colors.white.withOpacity(0.8),
                    shape: const CircleBorder(),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                      child: IconButton(
                        key: ValueKey(widget.isFavorite),
                        icon: Icon(
                          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: widget.isFavorite ? Colors.red : Colors.grey,
                        ),
                        onPressed: widget.onFavoritePressed,
                        tooltip: widget.isFavorite ? 'Remove from favorites' : 'Add to favorites',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                                    Text(
                    widget.property.formattedPrice,
                    style: const TextStyle(fontSize: 16, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.property.location,
                          style: const TextStyle(color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildFeature(Icons.bed, '${widget.property.bedrooms} beds'),
                      const SizedBox(width: 12),
                      _buildFeature(Icons.bathtub, '${widget.property.bathrooms} baths'),
                      const SizedBox(width: 12),
                      _buildFeature(Icons.square_foot, '${widget.property.area.toInt()} sqft'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
} 