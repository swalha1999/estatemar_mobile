import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/property_card.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import 'package:estatemar_mobile/screens/properties/advanced_search_screen.dart';
import 'package:estatemar_mobile/screens/properties/property_detail_screen.dart';
import 'package:intl/intl.dart';

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
  List<Property> _allProperties = [];
  bool _isLoading = true;

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
    _fetchInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchFavoriteIds() async {
    final ids = await _propertyService.favoriteService.getFavoriteIds();
    if (mounted) {
      setState(() {
        _favoriteIds
          ..clear()
          ..addAll(ids);
      });
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    final properties = await _propertyService.getProperties();
    if (mounted) {
      setState(() {
        _allProperties = properties;
        _isLoading = false;
      });
    }
    await _fetchFavoriteIds();
  }

  Future<void> _toggleFavorite(String propertyId) async {
    await _propertyService.toggleFavorite(propertyId);
    await _fetchFavoriteIds();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AnimatedSearchBar(
              onTap: () async {
               final result = await Navigator.of(context).push<Map<String, dynamic>>(
                 MaterialPageRoute(
                   builder: (context) => AdvancedSearchScreen(
                     properties: _allProperties,
                     initialFilters: _currentFilters,
                   ),
                 ),
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
                    icon: Icon(tab.icon, size: 20),
                    child: Text(
                      tab.label,
                      style: const TextStyle(fontSize: 12),
                    ),
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
            _buildPropertyList(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterChips(Map<String, dynamic> filters) {
    final List<Widget> chips = [];
    final format = NumberFormat.simpleCurrency(decimalDigits: 0);

    if (filters['location'] != null && filters['location'] != 'Any') {
      chips.add(_FilterChipText(text: filters['location']));
    }
    if (filters['type'] != null && filters['type'] != 'Any') {
      chips.add(_FilterChipText(text: (filters['type'] as PropertyType).name.capitalize()));
    }
    if (filters['priceRange'] != null) {
      final range = filters['priceRange'] as RangeValues;
      final start = format.format(range.start);
      final end = format.format(range.end);
      chips.add(_FilterChipText(text: '$start - $end'));
    }
    return chips;
  }

  Widget _buildPropertyList() {
    if (_isLoading) {
      return const Expanded(child: Center(child: CircularProgressIndicator()));
    }

    // Apply filters
    List<Property> filtered = _allProperties;
    final selectedTabType = _tabs[_tabController.index].type;
    if (selectedTabType != null) {
      filtered = filtered.where((p) => p.propertyType == selectedTabType).toList();
    }

    // Apply search filters
    if (_currentFilters['location'] != null && _currentFilters['location'] != 'Any') {
      filtered = filtered.where((p) => p.location == _currentFilters['location']).toList();
    }
    if (_currentFilters['type'] != null && _currentFilters['type'] != 'Any' && _currentFilters['type'] != null) {
      filtered = filtered.where((p) => p.propertyType == _currentFilters['type']).toList();
    }
    if (_currentFilters['priceRange'] != null) {
      final range = _currentFilters['priceRange'] as RangeValues;
      filtered = filtered.where((p) => p.price >= range.start && p.price <= range.end).toList();
    }

    // Apply sorting
    if (_sortOrder == SortOrder.lowToHigh) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOrder == SortOrder.highToLow) {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    if (filtered.isEmpty) {
      return const Expanded(child: Center(child: Text('No properties found.')));
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final property = filtered[index];
          return PropertyCard(
            property: property,
            isFavorite: _favoriteIds.contains(property.id),
            onFavoritePressed: () => _toggleFavorite(property.id),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertyDetailScreen(property: property),
                ),
              );
              await _fetchFavoriteIds();
            },
          );
        },
      ),
    );
  }
}

extension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
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

 