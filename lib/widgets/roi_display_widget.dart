import 'package:flutter/material.dart';
import '../models/property.dart';
import '../utils/roi_calculator.dart';

class RoiDisplayWidget extends StatelessWidget {
  const RoiDisplayWidget({
    super.key,
    required this.property,
    this.showDetails = false,
    this.compact = false,
  });

  final Property property;
  final bool showDetails;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final roi = property.roiPercentage;
    final annualNetIncome = property.annualNetIncome;
    
    if (roi == null || annualNetIncome == null) {
      return _buildNoDataWidget();
    }

    if (compact) {
      return _buildCompactWidget(roi, annualNetIncome);
    }

    // For property card overlay, use the overlay widget
    if (!showDetails) {
      return _buildOverlayWidget(roi, annualNetIncome);
    }

    return _buildFullWidget(roi, annualNetIncome);
  }

  Widget _buildNoDataWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            'ROI data not available',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactWidget(double roi, double annualNetIncome) {
    final roiColor = Color(RoiCalculator.getRoiColor(roi));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: roiColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: roiColor.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            size: 14,
            color: roiColor,
          ),
          const SizedBox(width: 4),
          Text(
            '${roi.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: roiColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayWidget(double roi, double annualNetIncome) {
    final roiColor = Color(RoiCalculator.getRoiColor(roi));
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: roiColor.withOpacity(0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.trending_up,
            size: 16,
            color: roiColor,
          ),
          const SizedBox(width: 4),
          Text(
            property.formattedTotalRoi,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: roiColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidget(double roi, double annualNetIncome) {
    final roiColor = Color(RoiCalculator.getRoiColor(roi));
    final roiDescription = RoiCalculator.getRoiDescription(roi);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: roiColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: roiColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.trending_up,
                size: 20,
                color: roiColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Annual Return',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      property.formattedAnnualNetIncome,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: roiColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roiColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  property.formattedTotalRoi,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: roiColor,
                  ),
                ),
              ),
            ],
          ),
          if (showDetails) ...[
            const SizedBox(height: 8),
            _buildDetailRow('Monthly Rent', property.formattedMonthlyRent),
            if (property.appreciationRoi != null)
              _buildDetailRow('Appreciation', '${property.formattedAppreciationRoi}/yr'),
            _buildDetailRow('Cash ROI', property.formattedCashOnCashRoi),
            _buildDetailRow('Total ROI', property.formattedTotalRoi),
            _buildDetailRow('ROI Rating', roiDescription),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class RoiComparisonWidget extends StatelessWidget {
  const RoiComparisonWidget({
    super.key,
    required this.properties,
    this.maxItems = 5,
  });

  final List<Property> properties;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final propertiesWithRoi = properties
        .where((p) => p.roiPercentage != null)
        .toList()
      ..sort((a, b) => (b.roiPercentage ?? 0).compareTo(a.roiPercentage ?? 0));

    if (propertiesWithRoi.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('No ROI data available for comparison'),
        ),
      );
    }

    final topProperties = propertiesWithRoi.take(maxItems).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[600]),
                const SizedBox(width: 8),
                const Text(
                  'Top ROI Properties',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...topProperties.asMap().entries.map((entry) {
              final index = entry.key;
              final property = entry.value;
              final roi = property.roiPercentage!;
              final roiColor = Color(RoiCalculator.getRoiColor(roi));
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: roiColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: roiColor),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: roiColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            property.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${roi.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: roiColor,
                          ),
                        ),
                        Text(
                          property.formattedAnnualNetIncome,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
} 