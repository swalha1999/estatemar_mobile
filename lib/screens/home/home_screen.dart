import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/property_card.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../properties/property_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  SortOrder _sortOrder = SortOrder.none;
  final PropertyService _propertyService = PropertyService();
  final Set<String> _favoriteIds = {};
  Map<String, dynamic> _currentFilters = {};

  static const List<_PropertyTypeTab> _tabs = [
    _PropertyTypeTab(label: 'All Listings', icon: Icons.dashboard_customize_outlined, type: null),
    _PropertyTypeTab(label: 'Apartment', icon: Icons.apartment, type: PropertyType.apartment),
    _PropertyTypeTab(label: 'Villa', icon: Icons.villa, type: PropertyType.villa),
    _PropertyTypeTab(label: 'House', icon: Icons.house, type: PropertyType.house),
    _PropertyTypeTab(label: 'Condo', icon: Icons.location_city, type: PropertyType.condo),
  ];

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text('Price: High to Low'),
                onTap: () {
                  setState(() => _sortOrder = SortOrder.highToLow);
                  Navigator.pop(context);
                },
                selected: _sortOrder == SortOrder.highToLow,
              ),
              ListTile(
                leading: const Icon(Icons.arrow_downward),
                title: const Text('Price: Low to High'),
                onTap: () {
                  setState(() => _sortOrder = SortOrder.lowToHigh);
                  Navigator.pop(context);
                },
                selected: _sortOrder == SortOrder.lowToHigh,
              ),
              if (_sortOrder != SortOrder.none)
                ListTile(
                  leading: const Icon(Icons.cancel),
                  title: const Text('Clear Sorting'),
                  onTap: () {
                    setState(() => _sortOrder = SortOrder.none);
                    Navigator.pop(context);
                  },
                  selected: _sortOrder == SortOrder.none,
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _fetchFavoriteIds();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchFavoriteIds() async {
    final ids = await _propertyService.favoriteService.getFavoriteIds();
    setState(() {
      _favoriteIds
        ..clear()
        ..addAll(ids);
    });
  }

  Future<void> _toggleFavorite(String propertyId) async {
    await _propertyService.toggleFavorite(propertyId);
    await _fetchFavoriteIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          AnimatedSearchBar(
            onTap: () async {
              final result = await showGeneralDialog<Map<String, dynamic>>(
                context: context,
                barrierDismissible: true,
                barrierLabel: 'Search',
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
                transitionBuilder: (context, anim1, anim2, child) {
                  final curvedValue = Curves.easeOutCubic.transform(anim1.value);
                  return Transform.translate(
                    offset: Offset(0, -400 + curvedValue * 400),
                    child: Opacity(
                      opacity: anim1.value,
                      child: _AdvancedSearchModal(
                        initialFilters: _currentFilters,
                      ),
                    ),
                  );
                },
              );
              if (result != null) {
                setState(() {
                  _currentFilters = result;
                });
              }
            },
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 2.0, color: AppColors.primary),
                insets: EdgeInsets.zero,
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              tabs: List.generate(_tabs.length, (index) {
                final tab = _tabs[index];
                return Tab(
                  icon: Icon(tab.icon),
                  text: tab.label,
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentFilters.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _buildFilterChips(_currentFilters),
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    Icons.sort,
                    color: _sortOrder == SortOrder.none ? Colors.grey : AppColors.primary,
                  ),
                  tooltip: 'Sort',
                  onPressed: _showSortOptions,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Property>>(
              future: _propertyService.getProperties(
                propertyType: _tabs[_tabController.index].type,
                sortOrder: _sortOrder,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load properties: \\${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No properties found.'));
                }
                final filtered = snapshot.data!;
                if (filtered.isEmpty) {
                  return const Center(child: Text('No properties match your filter.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final property = filtered[index];
                    return PropertyCard(
                      property: property,
                      isFavorite: _favoriteIds.contains(property.id),
                      onFavoritePressed: () => _toggleFavorite(property.id),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailScreen(property: property),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFilterChips(Map<String, dynamic> filters) {
    final List<Widget> chips = [];
    if (filters['location'] != null && filters['location'] != 'Any') {
      chips.add(_FilterChipText(text: filters['location']));
    }
    if (filters['type'] != null && filters['type'] != 'Any') {
      chips.add(_FilterChipText(text: filters['type']));
    }
    if (filters['priceRange'] != null) {
      final range = filters['priceRange'] as RangeValues;
      chips.add(_FilterChipText(text: '${range.start.toInt()} - ${range.end.toInt()}'));
    }
    return chips;
  }
}

class _PropertyTypeTab {
  final String label;
  final IconData icon;
  final PropertyType? type;
  const _PropertyTypeTab({required this.label, required this.icon, required this.type});
}

class AnimatedSearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const AnimatedSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.search, color: Colors.grey),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Search properties...',
                  style: TextStyle(color: Colors.grey[700], fontSize: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _AdvancedSearchModal extends StatefulWidget {
  final Map<String, dynamic>? initialFilters;
  const _AdvancedSearchModal({this.initialFilters});

  @override
  State<_AdvancedSearchModal> createState() => _AdvancedSearchModalState();
}

class _AdvancedSearchModalState extends State<_AdvancedSearchModal> {
  String? _selectedLocation;
  String? _selectedType;
  RangeValues _priceRange = const RangeValues(100000, 1000000);

  final List<String> _locations = [
    'Any', 'Malibu', 'Downtown LA', 'Pasadena', 'West Hollywood'
  ];
  final List<IconData> _locationIcons = [
    Icons.public, Icons.beach_access, Icons.location_city, Icons.park, Icons.nightlife
  ];
  final List<String> _types = [
    'Any', 'Apartment', 'Villa', 'House', 'Condo', 'Studio'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialFilters != null) {
      _selectedLocation = widget.initialFilters!['location'] as String?;
      _selectedType = widget.initialFilters!['type'] as String?;
      _priceRange = widget.initialFilters!['priceRange'] as RangeValues? ?? _priceRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.98,
            constraints: const BoxConstraints(maxWidth: 500),
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  _SectionCard(
                    title: 'Location',
                    child: Wrap(
                      spacing: 8,
                      children: List.generate(_locations.length, (i) => ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_locationIcons[i], size: 18, color: Colors.blue),
                            const SizedBox(width: 4),
                            Text(_locations[i]),
                          ],
                        ),
                        selected: _selectedLocation == _locations[i],
                        onSelected: (_) => setState(() => _selectedLocation = _locations[i]),
                      )),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Property Type',
                    child: Wrap(
                      spacing: 8,
                      children: _types.map((type) => ChoiceChip(
                        label: Text(type),
                        selected: _selectedType == type,
                        onSelected: (_) => setState(() => _selectedType = type),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Price Range',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 2000000,
                          divisions: 40,
                          labels: RangeLabels(
                            '\$${_priceRange.start.toInt()}',
                            '\$${_priceRange.end.toInt()}',
                          ),
                          onChanged: (values) => setState(() => _priceRange = values),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Min: \$${_priceRange.start.toInt()}'),
                            Text('Max: \$${_priceRange.end.toInt()}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedLocation = _locations[0];
                              _selectedType = null;
                              _priceRange = const RangeValues(100000, 1000000);
                            });
                          },
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear All'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop({
                              'location': _selectedLocation,
                              'type': _selectedType,
                              'priceRange': _priceRange,
                            });
                          },
                          icon: const Icon(Icons.search),
                          label: const Text('Search'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _FilterChipText extends StatelessWidget {
  final String text;
  const _FilterChipText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }
}

 