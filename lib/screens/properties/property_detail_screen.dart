import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/user_property.dart';
import '../../services/user_property_service.dart';
import '../../theme/app_theme.dart';
import 'edit_property_screen.dart';

class PropertyDetailScreen extends StatefulWidget {
  final UserProperty property;

  const PropertyDetailScreen({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late UserProperty _property;

  @override
  void initState() {
    super.initState();
    _property = widget.property;
  }

  Future<void> _navigateToEditProperty() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditPropertyScreen(property: _property),
      ),
    );

    if (result == true && mounted) {
      // Refresh property data
      final updatedProperty = await UserPropertyService.getUserProperties(_property.userId)
          .then((properties) => properties.firstWhere(
                (p) => p.id == _property.id,
                orElse: () => _property,
              ));
      
      setState(() {
        _property = updatedProperty;
      });
    }
  }

  Future<void> _deleteProperty() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Property'),
        content: Text('Are you sure you want to delete "${_property.propertyName}"? This action cannot be undone.'),
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
      final success = await UserPropertyService.deleteProperty(_property.userId, _property.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Property deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate deletion
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
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        title: Text(
          _property.propertyName,
          style: AppTheme.headingMedium,
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        foregroundColor: AppTheme.textPrimary,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20),
        ),
        actions: [
          IconButton(
            onPressed: _navigateToEditProperty,
            icon: const Icon(Icons.edit_outlined, size: 22),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') {
                _deleteProperty();
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
            child: const Icon(Icons.more_vert, size: 22),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            _buildHeroImageSection(),
            
            const SizedBox(height: 24),
            
            // Property Header Info
            _buildPropertyHeader(),
            
            const SizedBox(height: 24),
            
            // Financial Overview
            _buildFinancialOverview(),
            
            const SizedBox(height: 20),
            
            // Investment Analysis (if applicable)
            if (_property.monthlyRent != null || _property.annualAppreciationRate != null) ...[
              _buildInvestmentAnalysis(),
              const SizedBox(height: 20),
            ],
            
            // Property Details
            _buildPropertyDetails(),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.background,
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _navigateToEditProperty,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    'Edit Property',
                    style: AppTheme.buttonMedium.copyWith(color: AppTheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _deleteProperty,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: Text(
                    'Delete',
                    style: AppTheme.buttonMedium.copyWith(color: AppTheme.error),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorLight,
                    foregroundColor: AppTheme.error,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hero Image Section
  Widget _buildHeroImageSection() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: _property.imageUrls.isNotEmpty
            ? Image.file(
                File(_property.imageUrls.first),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return _buildNoImagePlaceholder();
                },
              )
            : _buildNoImagePlaceholder(),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryLight,
            AppTheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_outlined,
              color: AppTheme.white,
              size: 64,
            ),
            SizedBox(height: 12),
            Text(
              'No Image Available',
              style: TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Property Header Info
  Widget _buildPropertyHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_outlined,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _property.propertyName,
                      style: AppTheme.headingXLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _property.address,
                            style: AppTheme.textMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _property.propertyTypeString,
                  style: AppTheme.textSmall.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (_property.area != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.grey100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.square_foot,
                        size: 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_property.area!.toInt()} sq m',
                        style: AppTheme.textSmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }


  // Financial Overview
  Widget _buildFinancialOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppTheme.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Financial Overview',
                style: AppTheme.headingLarge,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundSecondary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderLight),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialItem(
                        'Purchase Price',
                        _property.formattedPurchasePrice,
                        Icons.shopping_cart_outlined,
                        AppTheme.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFinancialItem(
                        'Market Value',
                        _property.formattedMarketValue,
                        Icons.trending_up_outlined,
                        AppTheme.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildFinancialItem(
                        'Profit/Loss',
                        _property.formattedProfitLoss,
                        Icons.account_balance_wallet_outlined,
                        _property.profitLoss != null && _property.profitLoss! >= 0 
                            ? AppTheme.success 
                            : AppTheme.error,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildFinancialItem(
                        'Return %',
                        _property.formattedProfitLossPercentage,
                        Icons.percent_outlined,
                        _property.profitLossPercentage != null && _property.profitLossPercentage! >= 0 
                            ? AppTheme.success 
                            : AppTheme.error,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Investment Analysis
  Widget _buildInvestmentAnalysis() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.purpleLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.trending_up_outlined,
                  color: AppTheme.purple,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Investment Analysis',
                style: AppTheme.headingLarge,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          if (_property.monthlyRent != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildFinancialItem(
                          'Monthly Rent',
                          _property.formattedMonthlyRent,
                          Icons.home_work_outlined,
                          AppTheme.blue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFinancialItem(
                          'Annual Rent',
                          _property.formattedAnnualRent,
                          Icons.calendar_today_outlined,
                          AppTheme.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFinancialItem(
                          'Rental Yield',
                          _property.formattedRentalYield,
                          Icons.percent_outlined,
                          AppTheme.purple,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildFinancialItem(
                          'Total Return',
                          _property.formattedTotalReturnPercentage,
                          Icons.trending_up_outlined,
                          AppTheme.success,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          
          if (_property.annualAppreciationRate != null && _property.monthlyRent == null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundSecondary,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderLight),
              ),
              child: _buildFinancialItem(
                'Annual Appreciation',
                '${_property.annualAppreciationRate!.toStringAsFixed(1)}%',
                Icons.trending_up_outlined,
                AppTheme.success,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Property Details
  Widget _buildPropertyDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.blueLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outlined,
                  color: AppTheme.blue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Property Details',
                style: AppTheme.headingLarge,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          if (_property.purchaseDate != null) ...[
            _buildDetailItem(
              'Purchase Date',
              _formatDate(_property.purchaseDate!),
              Icons.calendar_today,
            ),
            const SizedBox(height: 16),
          ],
          
          if (_property.description != null && _property.description!.isNotEmpty) ...[
            _buildDetailItem(
              'Description',
              _property.description!,
              Icons.description,
            ),
            const SizedBox(height: 16),
          ],
          
          _buildDetailItem(
            'Property Type',
            _property.propertyTypeString,
            Icons.category,
          ),
          
          const SizedBox(height: 16),
          
          _buildDetailItem(
            'Created',
            _formatDate(_property.createdAt ?? DateTime.now()),
            Icons.access_time,
          ),
        ],
      ),
    );
  }

  // Financial Item Widget
  Widget _buildFinancialItem(
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
              padding: const EdgeInsets.all(8),
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
                style: AppTheme.textSmall.copyWith(
                  color: AppTheme.textSecondary,
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
          style: AppTheme.textLarge.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // Detail Item Widget
  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.blueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppTheme.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.textSmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.textMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}