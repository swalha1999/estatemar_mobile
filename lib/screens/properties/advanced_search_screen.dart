import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/property.dart';

class AdvancedSearchScreen extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  final List<Property> properties;

  const AdvancedSearchScreen({
    super.key,
    this.initialFilters,
    required this.properties,
  });

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  String? _selectedLocation;
  PropertyType? _selectedType;
  RangeValues? _priceRange;

  double _minPrice = 0;
  double _maxPrice = 2000000;

  List<String> _locations = ['Any'];
  List<IconData> _locationIcons = [Icons.public];

  @override
  void _generateLocationsFromProperties() {
    final uniqueLocations = widget.properties.map((p) => p.location).toSet().toList();
    uniqueLocations.sort();
    _locations = ['Any', ...uniqueLocations];
    // Assign icons (first is 'Any', rest are defaulted to Icons.location_city)
    _locationIcons = [Icons.public, ...List.filled(uniqueLocations.length, Icons.location_city)];
  }

  @override
  void initState() {
    super.initState();
    _generateLocationsFromProperties();
    _initializeFilters();
  }

  void _initializeFilters() {
    // Set price range from properties
    if (widget.properties.isNotEmpty) {
      final prices = widget.properties.map((p) => p.price).toList();
      prices.sort();
      _minPrice = prices.first;
      _maxPrice = prices.last;
    }

    // Initialize filters from passed values or defaults
    final initial = widget.initialFilters;
    if (initial != null) {
      _selectedLocation = initial['location'] as String?;
      _selectedType = initial['type'] as PropertyType?;
      _priceRange = initial['priceRange'] as RangeValues?;
    }

    _priceRange ??= RangeValues(_minPrice, _maxPrice);
  }

  String _formatCurrency(double value) {
    return NumberFormat.simpleCurrency(decimalDigits: 0).format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Properties'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Location',
              child: _buildLocationSelector(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Property Type',
              child: _buildPropertyTypeSelector(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Price Range',
              child: _buildPriceRangeSelector(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildLocationSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(_locations.length, (i) {
        final isSelected = _selectedLocation == _locations[i] || (_selectedLocation == null && _locations[i] == 'Any');
        return ChoiceChip(
          avatar: Icon(_locationIcons[i], size: 20, color: isSelected ? Colors.white : Colors.blue),
          label: Text(_locations[i]),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedLocation = _locations[i]),
          selectedColor: Colors.blue,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          showCheckmark: false,
        );
      }),
    );
  }
  
  Widget _buildPropertyTypeSelector() {
    final List<IconData> propertyTypeIcons = [
      Icons.house,         // house
      Icons.apartment,     // apartment
      Icons.location_city, // condo
      Icons.home_work,     // townhouse
      Icons.villa,         // villa
      Icons.meeting_room,  // studio
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: List.generate(PropertyType.values.length, (i) {
        final type = PropertyType.values[i];
        final isSelected = _selectedType == type;
        return ChoiceChip(
          avatar: Icon(propertyTypeIcons[i], size: 20, color: isSelected ? Colors.white : Colors.blue),
          label: Text(type.name[0].toUpperCase() + type.name.substring(1)),
          selected: isSelected,
          onSelected: (_) => setState(() => _selectedType = type),
          selectedColor: Colors.blue,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          showCheckmark: false,
        );
      }),
    );
  }

  Widget _buildPriceRangeSelector() {
    return Column(
      children: [
        RangeSlider(
          values: _priceRange!,
          min: _minPrice,
          max: _maxPrice,
          divisions: 50,
          onChanged: (values) => setState(() => _priceRange = values),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatCurrency(_priceRange!.start)),
            Text(_formatCurrency(_priceRange!.end)),
          ],
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15).copyWith(bottom: MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _selectedLocation = 'Any';
                  _selectedType = null;
                  _priceRange = RangeValues(_minPrice, _maxPrice);
                });
              },
              child: const Text('Clear All'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop({
                  'location': _selectedLocation,
                  'type': _selectedType,
                  'priceRange': _priceRange,
                });
              },
              icon: const Icon(Icons.search),
              label: const Text('Apply Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 