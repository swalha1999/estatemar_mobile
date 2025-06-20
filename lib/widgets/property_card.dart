import 'package:flutter/material.dart';
import '../models/property.dart';
import '../theme/colors.dart';

class PropertyCard extends StatefulWidget {
  const PropertyCard({
    super.key,
    required this.property,
    this.onTap,
  });

  final Property property;
  final VoidCallback? onTap;

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
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: widget.onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                              return Image.network(
                                images[index],
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            },
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