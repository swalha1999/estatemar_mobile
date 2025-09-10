import 'package:flutter/material.dart';
import 'dart:io';
import '../../models/user_property.dart';
import '../../models/listing_request.dart';
import '../../services/auth_service.dart';
import '../../services/user_property_service.dart';
import '../../services/listing_request_service.dart';
import '../../theme/app_theme.dart';
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
            backgroundColor: AppTheme.error,
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
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
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
            backgroundColor: AppTheme.success,
          ),
        );
        _loadProperties(); // Refresh properties list
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete property'),
            backgroundColor: AppTheme.error,
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
                color: AppTheme.grey400,
              ),
              const SizedBox(height: 16),
              Text(
                'Please login to view your properties',
                style: AppTheme.headingMedium.copyWith(
                  color: AppTheme.grey600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        title: const Text('My Properties'),
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
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.home_outlined,
                size: 60,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Properties Yet',
              style: AppTheme.headingMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start building your property portfolio by adding your first property.',
              style: AppTheme.textMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToAddProperty,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Property'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.white,
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
                  color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.05),
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
              Icon(Icons.analytics, color: AppTheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Portfolio Analytics',
                style: AppTheme.textLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
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
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTheme.textSmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTheme.textLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: isProfit 
                ? (value.startsWith('+') ? AppTheme.success : AppTheme.error)
                : AppTheme.textPrimary,
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
          style: AppTheme.headingLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
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
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
                  color: AppTheme.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppTheme.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
            spreadRadius: 0,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToPropertyDetail(property),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (property.imageUrls.isNotEmpty) ...[
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  color: AppTheme.grey100,
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.file(
                        File(property.imageUrls.first),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.grey200,
                            child: const Center(
                              child: Icon(
                                Icons.home,
                                color: AppTheme.textSecondary,
                                size: 48,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Gradient overlay
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppTheme.black.withOpacity(0.3),
                              AppTheme.background,
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Status badges
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          if (property.isForSale) ...[
                            _buildStatusBadge('FOR SALE', AppTheme.orange, Icons.sell),
                            const SizedBox(width: 8),
                          ],
                          if (property.isForRent) ...[
                            _buildStatusBadge('FOR RENT', AppTheme.blue, Icons.home_work),
                            const SizedBox(width: 8),
                          ],
                          if (listingRequest != null) ...[
                            _buildListingStatusBadge(listingRequest),
                          ],
                        ],
                      ),
                    ),
                    // Menu button
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: PopupMenuButton<String>(
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
                                  Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete Property'),
                                ],
                              ),
                            ),
                          ],
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.more_vert,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // No image placeholder with modern design
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.blueLight,
                      AppTheme.indigoLight,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PropertyPlaceholderPainter(),
                      ),
                    ),
                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.home_outlined,
                              color: AppTheme.blue,
                              size: 48,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Property Image',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No image available',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: AppTheme.grey600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badges (same as with image)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 12,
                      child: Row(
                        children: [
                          if (property.isForSale) ...[
                            _buildStatusBadge('FOR SALE', AppTheme.orange, Icons.sell),
                            const SizedBox(width: 8),
                          ],
                          if (property.isForRent) ...[
                            _buildStatusBadge('FOR RENT', AppTheme.blue, Icons.home_work),
                            const SizedBox(width: 8),
                          ],
                          if (listingRequest != null) ...[
                            _buildListingStatusBadge(listingRequest),
                          ],
                        ],
                      ),
                    ),
                    // Menu button (same as with image)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: PopupMenuButton<String>(
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
                                  Icon(Icons.delete_outline, color: AppTheme.error, size: 18),
                                  SizedBox(width: 8),
                                  Text('Delete Property'),
                                ],
                              ),
                            ),
                          ],
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.more_vert,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property Name
                  Text(
                    property.propertyName,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppTheme.grey600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.address,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 14,
                            color: AppTheme.grey600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Financial Info Grid
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.grey50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.grey200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernPropertyInfo(
                                'Purchase Price',
                                property.formattedPurchasePrice,
                                Icons.shopping_cart_outlined,
                                AppTheme.blue,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernPropertyInfo(
                                'Market Value',
                                property.formattedMarketValue,
                                Icons.trending_up_outlined,
                                AppTheme.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernPropertyInfo(
                                'Profit/Loss',
                                property.formattedProfitLoss,
                                Icons.account_balance_wallet_outlined,
                                property.profitLoss != null && property.profitLoss! >= 0 
                                    ? AppTheme.success 
                                    : AppTheme.error,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildModernPropertyInfo(
                                'Rental Yield',
                                property.formattedRentalYield,
                                Icons.percent_outlined,
                                AppTheme.purple,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
                  color: AppTheme.background,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.bold,
                  color: AppTheme.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingStatusBadge(ListingRequest request) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: request.statusColor.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: request.statusColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            request.status == ListingRequestStatus.pending
                ? Icons.hourglass_empty
                : request.status == ListingRequestStatus.approved
                    ? Icons.check_circle
                    : request.status == ListingRequestStatus.cancelled
                        ? Icons.cancel_outlined
                        : Icons.cancel,
            size: 12,
                  color: AppTheme.background,
          ),
          const SizedBox(width: 4),
          Text(
            request.statusDisplayName,
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 10,
              fontWeight: FontWeight.bold,
                  color: AppTheme.background,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernPropertyInfo(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  color: AppTheme.grey600,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

}

class _PropertyPlaceholderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Add some diagonal lines for subtle texture
    final linePaint = Paint()
      ..color = AppTheme.blue.withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 5; i++) {
      final startY = (size.height / 5) * i;
      final endX = size.width;
      final endY = startY + (size.height / 3);
      
      canvas.drawLine(
        Offset(0, startY),
        Offset(endX, endY),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
