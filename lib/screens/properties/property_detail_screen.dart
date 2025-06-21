import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property.dart';
import '../../widgets/property_3d_viewer.dart';
import '../../services/property_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;
  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  bool _isFavorite = false;
  final PropertyService _propertyService = PropertyService();
  bool _loadingFavorite = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteState();
  }

  Future<void> _loadFavoriteState() async {
    final isFav = await _propertyService.isFavorite(widget.property.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _loadingFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _loadingFavorite = true);
    await _propertyService.toggleFavorite(widget.property.id);
    final isFav = await _propertyService.isFavorite(widget.property.id);
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _loadingFavorite = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.property.title, maxLines: 1, overflow: TextOverflow.ellipsis),
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
    return _PropertyImageGallery(imageUrls: widget.property.imageUrls);
  }

  Widget _buildPropertyDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.property.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.property.formattedPrice,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
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
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFeatureChip(Icons.bed, '${widget.property.bedrooms} beds'),
              const SizedBox(width: 8),
              _buildFeatureChip(Icons.bathroom, '${widget.property.bathrooms} baths'),
              const SizedBox(width: 8),
              _buildFeatureChip(Icons.square_foot, '${widget.property.area.toInt()} sq ft'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.property.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          if (widget.property.latitude != null && widget.property.longitude != null) ...[
            _PropertyLocationMap(
              latitude: widget.property.latitude!,
              longitude: widget.property.longitude!,
            ),
            const SizedBox(height: 24),
          ],
          if (widget.property.virtualTourUrl != null) ...[
            Property3DViewerCard(
              virtualTourUrl: widget.property.virtualTourUrl,
              propertyTitle: widget.property.title,
            ),
            const SizedBox(height: 24),
          ],
          if (widget.property.amenities.isNotEmpty) ...[
            Text('Amenities', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.property.amenities.map((a) => Chip(
                avatar: Icon(_amenityIcon(a), size: 18, color: Colors.grey[800]),
                label: Text(a),
              )).toList(),
            ),
            const SizedBox(height: 24),
          ],

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
            'Property price:  ${widget.property.formattedPrice}',
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
              onPressed: _loadingFavorite ? null : _toggleFavorite,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: _isFavorite ? Colors.red : Colors.grey[800],
              ),
              child: _loadingFavorite
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: _isFavorite ? Colors.red : Colors.grey[800]),
                        const SizedBox(width: 8),
                        Text(
                          _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _isFavorite ? Colors.red : Colors.grey[800]),
                        ),
                      ],
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

class _PropertyLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const _PropertyLocationMap({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(latitude, longitude),
                initialZoom: 12.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(latitude, longitude),
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© OpenStreetMap contributors',
                      onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                    ),
                    TextSourceAttribution(
                      '© CARTO',
                      onTap: () => launchUrl(Uri.parse('https://carto.com/attributions')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
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