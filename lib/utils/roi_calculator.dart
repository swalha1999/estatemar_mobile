class RoiCalculator {
  /// Calculate annual ROI percentage
  static double? calculateRoiPercentage({
    required double propertyPrice,
    required double monthlyRent,
    double annualExpenses = 0,
  }) {
    if (propertyPrice <= 0) return null;
    
    final annualRent = monthlyRent * 12;
    final annualNetIncome = annualRent - annualExpenses;
    
    if (annualNetIncome <= 0) return null;
    
    return (annualNetIncome / propertyPrice) * 100;
  }

  /// Calculate annual net income
  static double calculateAnnualNetIncome({
    required double monthlyRent,
    double annualExpenses = 0,
  }) {
    return (monthlyRent * 12) - annualExpenses;
  }

  /// Calculate monthly net income
  static double calculateMonthlyNetIncome({
    required double monthlyRent,
    double annualExpenses = 0,
  }) {
    return monthlyRent - (annualExpenses / 12);
  }

  /// Format ROI percentage with appropriate precision
  static String formatRoiPercentage(double? roi) {
    if (roi == null) return 'N/A';
    if (roi < 0.1) return '${roi.toStringAsFixed(2)}%';
    if (roi < 1) return '${roi.toStringAsFixed(1)}%';
    return '${roi.toStringAsFixed(1)}%';
  }

  /// Format currency with appropriate units
  static String formatCurrency(double? amount, {String suffix = ''}) {
    if (amount == null) return 'N/A';
    
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M$suffix';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K$suffix';
    }
    return '\$${amount.toStringAsFixed(0)}$suffix';
  }

  /// Get ROI color based on percentage
  static int getRoiColor(double? roi) {
    if (roi == null) return 0xFF9E9E9E; // Grey
    
    if (roi >= 8.0) return 0xFF4CAF50; // Green - Excellent ROI
    if (roi >= 6.0) return 0xFF8BC34A; // Light Green - Good ROI
    if (roi >= 4.0) return 0xFFFFC107; // Amber - Average ROI
    if (roi >= 2.0) return 0xFFFF9800; // Orange - Below Average ROI
    return 0xFFF44336; // Red - Poor ROI
  }

  /// Get ROI description based on percentage
  static String getRoiDescription(double? roi) {
    if (roi == null) return 'No data';
    
    if (roi >= 8.0) return 'Excellent ROI';
    if (roi >= 6.0) return 'Good ROI';
    if (roi >= 4.0) return 'Average ROI';
    if (roi >= 2.0) return 'Below Average ROI';
    return 'Poor ROI';
  }

  /// Calculate estimated annual expenses based on property price
  /// This is a rough estimation - in real apps, this would be more detailed
  static double estimateAnnualExpenses(double propertyPrice) {
    // Rough estimation: 1-2% of property value for maintenance, taxes, insurance
    return propertyPrice * 0.015; // 1.5% of property value
  }

  /// Calculate estimated monthly rent based on property price
  /// This is a rough estimation - in real apps, this would use market data
  static double estimateMonthlyRent(double propertyPrice) {
    // Rough estimation: 0.5-1% of property value per month
    return propertyPrice * 0.007; // 0.7% of property value
  }
} 