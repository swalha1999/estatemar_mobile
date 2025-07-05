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
    return Container(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          
          // Property Price
          Row(
            children: [
              Icon(
                Icons.home,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Property Price',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      property.formattedPrice,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Payment Details
          Row(
            children: [
              Icon(
                Icons.credit_card,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flexible Financing',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '20% down payment required',
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
          const SizedBox(height: 20),
          
          // Payment Breakdown
          Row(
            children: [
              Expanded(
                child: _buildPaymentDetail(
                  'Down Payment',
                  _calculateDownPayment(0.20),
                  Colors.blue[700]!,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildPaymentDetail(
                  'Monthly Payment',
                  _calculateMonthlyPayment(0.20, 20),
                  Colors.blue[700]!,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Payment Timeline
          Row(
            children: [
              Icon(
                Icons.schedule,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Timeline',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'Time to recover full price',
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
          const SizedBox(height: 16),
          
          // Timeline Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimelineDetail('Monthly Payment', _calculateMonthlyPayment(0.20, 20)),
              _buildTimelineDetail('Payment Period', '20 years'),
              _buildTimelineDetail('Total Payments', _calculateTotalPayments(0.20, 20)),
            ],
          ),
          
          const SizedBox(height: 24),
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
                    'Contact us for personalized financing options and current rates.',
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
    );
  }

  Widget _buildPaymentDetail(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Colors.blue[700],
          ),
        ),
      ],
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

  String _calculateTotalPayments(double downPaymentPercentage, int years) {
    final downPayment = property.price * downPaymentPercentage;
    final monthlyPayment = _calculateMonthlyPaymentValue(downPaymentPercentage, years);
    final totalMonthlyPayments = monthlyPayment * years * 12;
    final totalAmount = downPayment + totalMonthlyPayments;
    
    if (totalAmount >= 1000000) {
      return '\$${(totalAmount / 1000000).toStringAsFixed(1)}M';
    } else if (totalAmount >= 1000) {
      return '\$${(totalAmount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${totalAmount.toStringAsFixed(0)}';
  }

  double _calculateMonthlyPaymentValue(double downPaymentPercentage, int years) {
    final loanAmount = property.price * (1 - downPaymentPercentage);
    final monthlyRate = 0.045 / 12; // 4.5% annual rate
    final numberOfPayments = years * 12;
    
    if (numberOfPayments == 0) return 0;
    
    return loanAmount * 
        (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) / 
        (pow(1 + monthlyRate, numberOfPayments) - 1);
  }

  String _calculateMonthlyPayment(double downPaymentPercentage, int years) {
    final monthlyPayment = _calculateMonthlyPaymentValue(downPaymentPercentage, years);
    
    if (monthlyPayment >= 1000) {
      return '\$${(monthlyPayment / 1000).toStringAsFixed(0)}K';
    }
    return '\$${monthlyPayment.toStringAsFixed(0)}';
  }
} 