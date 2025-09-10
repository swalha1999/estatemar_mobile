import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/property_card.dart';
import '../../widgets/animated_search_header.dart';
import '../../models/property.dart';
import '../../services/property_service.dart';
import '../../config/app_config.dart';
import 'package:estatemar_mobile/screens/properties/advanced_search_screen.dart';
import 'package:estatemar_mobile/screens/properties/property_view_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  late ScrollController _scrollController;
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
    _scrollController = ScrollController();
    _fetchInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
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
      backgroundColor: AppTheme.backgroundSecondary,
      body: SafeArea(
        child: Column(
          children: [
            // Mock data indicator
            if (AppConfig.useMockData)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppTheme.warningLight,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppTheme.warning, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Demo Mode: Using sample data. Switch to real API in app_config.dart',
                        style: AppTheme.textSmall.copyWith(
                          color: AppTheme.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Animated search header
            AnimatedSearchHeader(
              onSearchTap: () async {
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
              onFilterTap: () async {
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
              onSortTap: _showSortOptions,
              hasFilters: _currentFilters.isNotEmpty,
              sortActive: _sortOrder != SortOrder.none,
            ),
            // Tabs
            Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.black.withOpacity(0.03),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Tab bar
                  Container(
                    height: 56,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                          width: 3.0,
                          color: AppTheme.primary,
                        ),
                        insets: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      labelColor: AppTheme.primary,
                      unselectedLabelColor: AppTheme.grey600,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      tabs: List.generate(_tabs.length, (index) {
                        final tab = _tabs[index];
                        return Tab(
                          icon: Icon(tab.icon, size: 20),
                          child: Text(
                            tab.label,
                            style: AppTheme.textSmall.copyWith(fontWeight: FontWeight.w600),
                          ),
                        );
                      }),
                    ),
                  ),
                  // Filter chips (if any)
                  if (_currentFilters.isNotEmpty)
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _buildFilterChips(_currentFilters),
                      ),
                    ),
                ],
              ),
            ),
            // Property list
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
      chips.add(_FilterChip(
        text: filters['location'],
        onDelete: () {
          setState(() {
            _currentFilters.remove('location');
          });
        },
      ));
    }
    if (filters['type'] != null && filters['type'] != 'Any') {
      chips.add(_FilterChip(
        text: (filters['type'] as PropertyType).name.capitalize(),
        onDelete: () {
          setState(() {
            _currentFilters.remove('type');
          });
        },
      ));
    }
    if (filters['priceRange'] != null) {
      final range = filters['priceRange'] as RangeValues;
      final start = format.format(range.start);
      final end = format.format(range.end);
      chips.add(_FilterChip(
        text: '$start - $end',
        onDelete: () {
          setState(() {
            _currentFilters.remove('priceRange');
          });
        },
      ));
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
      return Expanded(
        child: Center(
          child: Text(
            'No properties found.',
            style: AppTheme.textLarge.copyWith(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 80),
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
                  builder: (context) => PropertyViewScreen(property: property),
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



class _FilterChip extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;
  const _FilterChip({required this.text, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(
          text,
          style: AppTheme.textMedium.copyWith(fontWeight: FontWeight.w600, color: AppTheme.primary),
        ),
        deleteIcon: const Icon(Icons.close, size: 16, color: AppTheme.primary),
        onDeleted: onDelete,
        backgroundColor: AppTheme.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.primary.withOpacity(0.2)),
        ),
      ),
    );
  }
}

 