import 'package:flutter/material.dart';
import '../../models/property.dart';

class PropertyDetailScreen extends StatelessWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(property.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          _buildImageGallery(context),
          _buildPropertyDetails(context),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    return _PropertyImageGallery(imageUrls: property.imageUrls);
  }

  Widget _buildPropertyDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            property.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            property.formattedPrice,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  property.location,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFeatureChip(Icons.bed, '${property.bedrooms} beds'),
              const SizedBox(width: 8),
              _buildFeatureChip(Icons.bathroom, '${property.bathrooms} baths'),
              const SizedBox(width: 8),
              _buildFeatureChip(Icons.square_foot, '${property.area.toInt()} sq ft'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            property.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (property.amenities.isNotEmpty) ...[
            Text('Amenities', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: property.amenities.map((a) => Chip(
                avatar: Icon(_amenityIcon(a), size: 18, color: Colors.grey[800]),
                label: Text(a),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],
          _buildAgentInfo(context),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentInfo(BuildContext context) {
    if (property.agentName == null && property.agentPhone == null && property.agentEmail == null) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Agent', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (property.agentName != null)
          Text(property.agentName!, style: Theme.of(context).textTheme.bodyLarge),
        if (property.agentPhone != null)
          Row(
            children: [
              const Icon(Icons.phone, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(property.agentPhone!, style: const TextStyle(fontSize: 15)),
            ],
          ),
        if (property.agentEmail != null)
          Row(
            children: [
              const Icon(Icons.email, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(property.agentEmail!, style: const TextStyle(fontSize: 15)),
            ],
          ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 18),
          Text(
            'Property price: ${property.formattedPrice}',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement contact action
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {
                // TODO: Implement add to favorites action
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: Colors.grey[800],
              ),
              child: Text(
                'Add to Favorites',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _amenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('pool')) return Icons.pool;
    if (lower.contains('ocean') || lower.contains('sea') || lower.contains('view')) return Icons.waves;
    if (lower.contains('garden') || lower.contains('yard')) return Icons.park;
    if (lower.contains('garage') || lower.contains('parking')) return Icons.garage;
    if (lower.contains('fireplace')) return Icons.fireplace;
    if (lower.contains('gym') || lower.contains('fitness')) return Icons.fitness_center;
    if (lower.contains('concierge')) return Icons.room_service;
    if (lower.contains('rooftop')) return Icons.roofing;
    if (lower.contains('kitchen')) return Icons.kitchen;
    if (lower.contains('laundry')) return Icons.local_laundry_service;
    if (lower.contains('balcony') || lower.contains('terrace')) return Icons.balcony;
    if (lower.contains('security')) return Icons.security;
    if (lower.contains('elevator') || lower.contains('lift')) return Icons.elevator;
    if (lower.contains('wifi') || lower.contains('internet')) return Icons.wifi;
    if (lower.contains('air conditioning') || lower.contains('ac')) return Icons.ac_unit;
    if (lower.contains('pet')) return Icons.pets;
    if (lower.contains('floor')) return Icons.layers;
    if (lower.contains('access')) return Icons.lock_open;
    return Icons.check_circle_outline;
  }
}

class _PropertyImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  const _PropertyImageGallery({required this.imageUrls});

  @override
  State<_PropertyImageGallery> createState() => _PropertyImageGalleryState();
}

class _PropertyImageGalleryState extends State<_PropertyImageGallery> {
  int _currentIndex = 0;
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey[200],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(child: CircularProgressIndicator(value: progress.expectedTotalBytes != null ? progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1) : null));
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                ),
              );
            },
          ),
          Positioned(
            top: 20,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 