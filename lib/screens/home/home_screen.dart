import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/property_card.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';
import '../../services/property_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  String _searchQuery = '';
  SortOrder _sortOrder = SortOrder.none;
  final PropertyService _propertyService = PropertyService();
  final Set<String> _favoriteIds = {};

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (context) => Padding(
                    padding: MediaQuery.of(context).viewInsets,
                    child: SizedBox(
                      height: 400,
                      child: Center(
                        child: Text(
                          'Advanced Search (Coming Soon)',
                          style: TextStyle(fontSize: 18, color: AppColors.primary),
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _searchController,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Search properties...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                ),
              ),
            ),
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
}

class _PropertyTypeTab {
  final String label;
  final IconData icon;
  final PropertyType? type;
  const _PropertyTypeTab({required this.label, required this.icon, required this.type});
}

class _CurvyTabIndicator extends Decoration {
  const _CurvyTabIndicator();

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _CurvyPainter();
  }
}

class _CurvyPainter extends BoxPainter {
  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    final Paint paint = Paint();
    paint.color = AppColors.primary;
    paint.style = PaintingStyle.fill;
    final double indicatorHeight = 8.0;
    final double indicatorRadius = 6.0;
    final double width = configuration.size!.width * 0.6;
    final double left = offset.dx + (configuration.size!.width - width) / 2;
    final double top = offset.dy + configuration.size!.height - indicatorHeight;
    final Rect rect = Rect.fromLTWH(left, top, width, indicatorHeight);
    final RRect rRect = RRect.fromRectAndRadius(rect, Radius.circular(indicatorRadius));
    canvas.drawRRect(rRect, paint);
  }
} 