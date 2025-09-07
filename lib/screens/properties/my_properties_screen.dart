import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/user_property.dart';
import '../../models/listing_request.dart';
import '../../services/auth_service.dart';
import '../../services/user_property_service.dart';
import '../../services/listing_request_service.dart';
import '../../theme/colors.dart';
import '../../theme/text_styles.dart';
import 'add_property_screen.dart';
import 'property_detail_screen.dart';

class MyPropertiesScreen extends StatefulWidget {
  final VoidCallback? onAuthChange;
  final bool autoOpenAddProperty;
  
  const MyPropertiesScreen({
    super.key, 
    this.onAuthChange,
    this.autoOpenAddProperty = false,
  });

  @override
  State<MyPropertiesScreen> createState() => _MyPropertiesScreenState();
}

class _MyPropertiesScreenState extends State<MyPropertiesScreen> {
  List<UserProperty> _properties = [];
  List<ListingRequest> _listingRequests = [];
  PropertyAnalytics? _analytics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProperties();
    
    // Auto-open Add Property screen if requested
    if (widget.autoOpenAddProperty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToAddProperty();
      });
    }
  }

  Future<void> _loadProperties() async {
    setState(() => _isLoading = true);
    
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final properties = await UserPropertyService.getUserProperties(user.id);
        final analytics = await UserPropertyService.getPropertyAnalytics(user.id);
        final listingRequests = await ListingRequestService.getUserListingRequests(user.id);
        
        setState(() {
          _properties = properties;
          _analytics = analytics;
          _listingRequests = listingRequests;
          _isLoading = false;
        });
      } else {
        setState(() {
          _properties = [];
          _analytics = null;
          _listingRequests = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load properties: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _navigateToAddProperty() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPropertyScreen(),
      ),
    );

    if (result == true && mounted) {
      _loadProperties(); // Refresh properties list
    }
  }

  Future<void> _navigateToPropertyDetail(UserProperty property) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailScreen(property: property),
      ),
    );

    if (result == true && mounted) {
      _loadProperties(); // Refresh properties list
    }
  }

  ListingRequest? _getListingRequestForProperty(String propertyId) {
    try {
      return _listingRequests.firstWhere((request) => request.propertyId == propertyId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _deleteProperty(UserProperty property) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${property.propertyName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await UserPropertyService.deleteProperty(property.userId, property.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProperties(); // Refresh properties list
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete property'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    
    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Please login to view your properties',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Properties'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _navigateToAddProperty,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _properties.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadProperties,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_analytics != null) ...[
                          _buildAnalyticsCard(),
                          const SizedBox(height: 24),
                        ],
                        _buildPropertiesList(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.home_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Properties Yet',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your property portfolio by adding your first property.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToAddProperty,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Property'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    if (_analytics == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Portfolio Analytics',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsItem(
                  'Total Properties',
                  '${_analytics!.totalProperties}',
                  Icons.home,
                ),
              ),
              Expanded(
                child: _buildAnalyticsItem(
                  'Total Value',
                  _analytics!.formattedTotalMarketValue,
                  Icons.attach_money,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildAnalyticsItem(
                  'Total Profit/Loss',
                  _analytics!.formattedTotalProfitLoss,
                  Icons.trending_up,
                  isProfit: _analytics!.totalProfitLoss >= 0,
                ),
              ),
              Expanded(
                child: _buildAnalyticsItem(
                  'Avg. Rental Yield',
                  _analytics!.formattedAverageRentalYield,
                  Icons.percent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsItem(
    String label,
    String value,
    IconData icon, {
    bool isProfit = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isProfit 
                ? (value.startsWith('+') ? Colors.green : Colors.red)
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertiesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Properties',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _properties.length,
          itemBuilder: (context, index) {
            final property = _properties[index];
            return _buildPropertyCard(property);
          },
        ),
      ],
    );
  }

  Widget _buildPropertyCard(UserProperty property) {
    final listingRequest = _getListingRequestForProperty(property.id);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToPropertyDetail(property),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                property.propertyName,
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (property.isForSale) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orange[300]!),
                                ),
                                child: Text(
                                  'FOR SALE',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.orange[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                            if (property.isForRent) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.blue[300]!),
                                ),
                                child: Text(
                                  'FOR RENT',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.blue[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (listingRequest != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: listingRequest.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: listingRequest.statusColor.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  listingRequest.status == ListingRequestStatus.pending
                                      ? Icons.hourglass_empty
                                      : listingRequest.status == ListingRequestStatus.approved
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                  size: 12,
                                  color: listingRequest.statusColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Listing: ${listingRequest.statusDisplayName}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: listingRequest.statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        // Property Image
                        if (property.imageUrls.isNotEmpty) ...[
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey[200],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(property.imageUrls.first),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                      size: 40,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          property.address,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteProperty(property);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _buildPropertyInfo(
                      'Purchase Price',
                      property.formattedPurchasePrice,
                      Icons.shopping_cart,
                    ),
                  ),
                  Expanded(
                    child: _buildPropertyInfo(
                      'Market Value',
                      property.formattedMarketValue,
                      Icons.trending_up,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _buildPropertyInfo(
                      'Profit/Loss',
                      property.formattedProfitLoss,
                      Icons.account_balance_wallet,
                      isProfit: property.profitLoss != null && property.profitLoss! >= 0,
                    ),
                  ),
                  Expanded(
                    child: _buildPropertyInfo(
                      'Rental Yield',
                      property.formattedRentalYield,
                      Icons.percent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyInfo(
    String label,
    String value,
    IconData icon, {
    bool isProfit = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isProfit 
                ? (value.startsWith('+') ? Colors.green : Colors.red)
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
