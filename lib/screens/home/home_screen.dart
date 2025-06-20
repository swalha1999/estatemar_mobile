import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../widgets/property_card.dart';
import '../../models/property.dart';
import '../../services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'EstateMar Mobile',
          style: TextStyle(color: AppColors.grey),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Property>>(
              future: ApiService().getProperties(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load properties: \\${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No properties found.'));
                }
                final properties = snapshot.data!;
                final filtered = _searchQuery.isEmpty
                    ? properties
                    : properties.where((p) =>
                        p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                        p.location.toLowerCase().contains(_searchQuery.toLowerCase())
                      ).toList();
                if (filtered.isEmpty) {
                  return const Center(child: Text('No properties match your search.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return PropertyCard(property: filtered[index]);
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