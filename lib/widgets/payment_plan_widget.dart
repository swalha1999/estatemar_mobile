import 'package:flutter/material.dart';
import 'dart:math';
import '../models/property.dart';

class PaymentPlanWidget extends StatelessWidget {
  const PaymentPlanWidget({
    super.key,
    required this.property,
  });

  final Property property;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.payment,
                    color: Colors.blue[700],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Plans',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Choose your preferred payment option',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildPaymentOption(
              context,
              title: 'Cash Payment',
              subtitle: 'Full payment upfront',
              amount: property.formattedPrice,
              icon: Icons.attach_money,
              color: Colors.green,
              isRecommended: false,
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context,
              title: '20% Down Payment',
              subtitle: '80% financed over 20 years',
              amount: _calculateDownPayment(0.20),
              icon: Icons.credit_card,
              color: Colors.blue,
              isRecommended: true,
              monthlyPayment: _calculateMonthlyPayment(0.20, 20),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context,
              title: '30% Down Payment',
              subtitle: '70% financed over 15 years',
              amount: _calculateDownPayment(0.30),
              icon: Icons.account_balance,
              color: Colors.orange,
              isRecommended: false,
              monthlyPayment: _calculateMonthlyPayment(0.30, 15),
            ),
            const SizedBox(height: 16),
            _buildPaymentOption(
              context,
              title: '50% Down Payment',
              subtitle: '50% financed over 10 years',
              amount: _calculateDownPayment(0.50),
              icon: Icons.savings,
              color: Colors.purple,
              isRecommended: false,
              monthlyPayment: _calculateMonthlyPayment(0.50, 10),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Interest rates and terms may vary. Contact us for personalized financing options.',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildPaymentOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String amount,
    required IconData icon,
    required Color color,
    required bool isRecommended,
    String? monthlyPayment,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 80),
      decoration: BoxDecoration(
        color: isRecommended ? color.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended ? color.withOpacity(0.3) : Colors.grey[200]!,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                if (monthlyPayment != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Monthly: $monthlyPayment',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: color,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }

  String _calculateDownPayment(double percentage) {
    final downPayment = property.price * percentage;
    if (downPayment >= 1000000) {
      return '\$${(downPayment / 1000000).toStringAsFixed(1)}M';
    } else if (downPayment >= 1000) {
      return '\$${(downPayment / 1000).toStringAsFixed(0)}K';
    }
    return '\$${downPayment.toStringAsFixed(0)}';
  }

  String _calculateMonthlyPayment(double downPaymentPercentage, int years) {
    final loanAmount = property.price * (1 - downPaymentPercentage);
    final monthlyRate = 0.045 / 12; // 4.5% annual rate
    final numberOfPayments = years * 12;
    
    if (numberOfPayments == 0) return '\$0';
    
    final monthlyPayment = loanAmount * 
        (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) / 
        (pow(1 + monthlyRate, numberOfPayments) - 1);
    
    if (monthlyPayment >= 1000) {
      return '\$${(monthlyPayment / 1000).toStringAsFixed(0)}K';
    }
    return '\$${monthlyPayment.toStringAsFixed(0)}';
  }
} 