import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../theme/app_theme.dart';
import '../../widgets/safe_image.dart';

class PropertyViewScreen extends StatelessWidget {
  final Property property;

  const PropertyViewScreen({
    super.key,
    required this.property,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        title: Text(
          property.title,
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
            onPressed: () {
              // TODO: Add to favorites functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Added to favorites'),
                  backgroundColor: AppTheme.success,
                ),
              );
            },
            icon: const Icon(Icons.favorite_border, size: 22),
          ),
          IconButton(
            onPressed: () {
              // TODO: Share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sharing property...'),
                  backgroundColor: AppTheme.info,
                ),
              );
            },
            icon: const Icon(Icons.share, size: 22),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            _buildHeroImageSection(),
            
            const SizedBox(height: 24),
            
            // Property Header Info
            _buildPropertyHeader(),
            
            const SizedBox(height: 24),
            
            // Price Information
            _buildPriceInformation(),
            
            const SizedBox(height: 20),
            
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
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showContactDialog(context);
                  },
                  icon: const Icon(Icons.message_outlined, size: 18),
                  label: Text(
                    'Message',
                    style: AppTheme.buttonMedium.copyWith(color: AppTheme.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.white,
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
      height: 320,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: property.imageUrls.isNotEmpty
            ? PageView.builder(
                itemCount: property.imageUrls.length,
                itemBuilder: (context, index) {
                  return SafeImage(
                    imageUrl: property.imageUrls[index],
                    fit: BoxFit.cover,
                    height: 320,
                    width: double.infinity,
                  );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
                        property.title,
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
                              property.location,
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
                    property.propertyTypeString,
                    style: AppTheme.textSmall.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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
                        '${(property.area * 0.092903).toStringAsFixed(0)} sq m',
                        style: AppTheme.textSmall.copyWith(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Price Information
  Widget _buildPriceInformation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
                    Icons.attach_money_outlined,
                    color: AppTheme.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Price Information',
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
                        child: _buildPriceItem(
                          'Price',
                          property.formattedPrice,
                          Icons.attach_money_outlined,
                          AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPriceItem(
                          'Monthly Rent',
                          property.formattedMonthlyRent,
                          Icons.home_work_outlined,
                          AppTheme.blue,
                        ),
                      ),
                    ],
                  ),
                  
                  if (property.annualRent != null) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPriceItem(
                            'Annual Rent',
                            property.formattedAnnualRent,
                            Icons.calendar_today_outlined,
                            AppTheme.orange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPriceItem(
                            'ROI',
                            property.formattedRoiPercentage,
                            Icons.percent_outlined,
                            AppTheme.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Property Details
  Widget _buildPropertyDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
            
            _buildDetailItem(
              'Bedrooms',
              '${property.bedrooms}',
              Icons.bed_outlined,
            ),
            
            const SizedBox(height: 16),
            
            _buildDetailItem(
              'Bathrooms',
              '${property.bathrooms}',
              Icons.bathroom_outlined,
            ),
            
            const SizedBox(height: 16),
            
            _buildDetailItem(
              'Area',
              '${(property.area * 0.092903).toStringAsFixed(0)} sq m',
              Icons.square_foot_outlined,
            ),
            
            const SizedBox(height: 16),
            
            _buildDetailItem(
              'Location',
              property.location,
              Icons.location_on_outlined,
            ),
            
            if (property.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildDetailItem(
                'Description',
                property.description,
                Icons.description_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Price Item Widget
  Widget _buildPriceItem(
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

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Contact Agent',
          style: AppTheme.headingLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get in touch with our real estate agent for more information about this property.',
              style: AppTheme.textMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Opening messages...'),
                          backgroundColor: AppTheme.info,
                        ),
                      );
                    },
                    icon: const Icon(Icons.message_outlined, size: 18),
                    label: Text(
                      'Message',
                      style: AppTheme.buttonMedium.copyWith(color: AppTheme.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: AppTheme.buttonMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
