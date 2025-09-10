import 'package:flutter/material.dart';
import '../../models/property.dart';
import '../../models/user_property.dart';
import '../../services/user_property_service.dart';
import '../../theme/app_theme.dart';

class EditPropertyScreen extends StatefulWidget {
  final UserProperty property;

  const EditPropertyScreen({
    super.key,
    required this.property,
  });

  @override
  State<EditPropertyScreen> createState() => _EditPropertyScreenState();
}

class _EditPropertyScreenState extends State<EditPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propertyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _marketValueController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _monthlyRentController = TextEditingController();
  final _sizeController = TextEditingController();
  
  DateTime? _purchaseDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPropertyData();
    // Add listeners for price formatting
    _purchasePriceController.addListener(_formatPurchasePrice);
    _marketValueController.addListener(_formatMarketValue);
    _monthlyRentController.addListener(_formatMonthlyRent);
  }

  void _loadPropertyData() {
    _propertyNameController.text = widget.property.propertyName;
    _addressController.text = widget.property.address;
    _purchasePriceController.text = _formatNumber(widget.property.purchasePrice.toInt());
    _marketValueController.text = widget.property.marketValue != null 
        ? _formatNumber(widget.property.marketValue!.toInt()) 
        : '';
    _descriptionController.text = widget.property.description ?? '';
    _monthlyRentController.text = widget.property.monthlyRent != null 
        ? _formatNumber(widget.property.monthlyRent!.toInt()) 
        : '';
    _sizeController.text = widget.property.area != null 
        ? widget.property.area!.toInt().toString() 
        : '';
    _purchaseDate = widget.property.purchaseDate;
  }

  @override
  void dispose() {
    _propertyNameController.dispose();
    _addressController.dispose();
    _purchasePriceController.dispose();
    _marketValueController.dispose();
    _descriptionController.dispose();
    _monthlyRentController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  void _formatPurchasePrice() {
    final text = _purchasePriceController.text;
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isNotEmpty) {
      final number = int.parse(cleanText);
      final formatted = _formatNumber(number);
      if (formatted != text) {
        _purchasePriceController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  void _formatMarketValue() {
    final text = _marketValueController.text;
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isNotEmpty) {
      final number = int.parse(cleanText);
      final formatted = _formatNumber(number);
      if (formatted != text) {
        _marketValueController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  void _formatMonthlyRent() {
    final text = _monthlyRentController.text;
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isNotEmpty) {
      final number = int.parse(cleanText);
      final formatted = _formatNumber(number);
      if (formatted != text) {
        _monthlyRentController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    }
  }

  String _formatNumber(int number) {
    if (number == 0) return '';
    return number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  double? _parseFormattedNumber(String text) {
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanText.isEmpty) return null;
    return double.tryParse(cleanText);
  }

  Future<void> _handleSaveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedProperty = widget.property.copyWith(
        propertyName: _propertyNameController.text.trim(),
        address: _addressController.text.trim(),
        purchasePrice: _parseFormattedNumber(_purchasePriceController.text) ?? 0.0,
        marketValue: _parseFormattedNumber(_marketValueController.text),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        propertyType: widget.property.propertyType ?? PropertyType.house,
        purchaseDate: _purchaseDate,
        monthlyRent: _parseFormattedNumber(_monthlyRentController.text),
        area: _sizeController.text.trim().isNotEmpty 
            ? double.tryParse(_sizeController.text.trim())
            : null,
        annualAppreciationRate: null,
        updatedAt: DateTime.now(),
      );

      final success = await UserPropertyService.updateProperty(updatedProperty);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Property updated successfully!'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate successful update
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to update property'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectPurchaseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _purchaseDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() => _purchaseDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: AppTheme.textPrimary),
        ),
        title: Text('Edit Property', style: AppTheme.headingMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Required Fields Card
              Container(
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
                    Text(
                      'Required Information',
                      style: AppTheme.headingLarge,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Property Name
                    TextFormField(
                      controller: _propertyNameController,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Property Name/Address *',
                        hintText: 'e.g., 123 Main Street, Downtown Apartment',
                        labelStyle: AppTheme.formLabel,
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.home, color: AppTheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter property name/address';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Address
                    TextFormField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Full Address *',
                        hintText: 'e.g., 123 Main Street, City, State 12345',
                        labelStyle: AppTheme.formLabel,
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.location_on, color: AppTheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter full address';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Purchase Price
                    TextFormField(
                      controller: _purchasePriceController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Purchase Price *',
                        hintText: 'e.g., 500000',
                        labelStyle: AppTheme.formLabel,
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.attach_money, color: AppTheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter purchase price';
                        }
                        final price = _parseFormattedNumber(value);
                        if (price == null || price <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Optional Fields Card
              Container(
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
                    Text(
                      'Optional Information',
                      style: AppTheme.headingLarge,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Market Value
                    TextFormField(
                      controller: _marketValueController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Current Market Value',
                        hintText: 'e.g., 550000',
                        labelStyle: AppTheme.formLabel,
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.trending_up),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final price = _parseFormattedNumber(value);
                          if (price == null || price <= 0) {
                            return 'Please enter a valid market value';
                          }
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Purchase Date
                    InkWell(
                      onTap: _selectPurchaseDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundSecondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: AppTheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Purchase Date',
                                    style: AppTheme.textSmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _purchaseDate != null
                                        ? '${_purchaseDate!.day}/${_purchaseDate!.month}/${_purchaseDate!.year}'
                                        : 'Select purchase date',
                                    style: AppTheme.textMedium.copyWith(
                                      color: _purchaseDate != null 
                                          ? AppTheme.textPrimary 
                                          : AppTheme.grey500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Monthly Rent
                    TextFormField(
                      controller: _monthlyRentController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Monthly Rent',
                        hintText: 'e.g., 2500',
                        labelStyle: AppTheme.formLabel,
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.home_work, color: AppTheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final rent = _parseFormattedNumber(value);
                          if (rent == null || rent <= 0) {
                            return 'Please enter a valid monthly rent';
                          }
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Property Size
                    TextFormField(
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Property Size (sq m)',
                        hintText: 'e.g., 120',
                        labelStyle: AppTheme.formLabel,
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.square_foot, color: AppTheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final size = double.tryParse(value);
                          if (size == null || size <= 0) {
                            return 'Please enter a valid size';
                          }
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        hintText: '📝 Additional details about the property...',
                        labelStyle: AppTheme.formLabel,
                        hintStyle: AppTheme.formHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 100), // Add space for fixed bottom button
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSaveProperty,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                      ),
                    )
                  : const Text(
                      'Update Property',
                      style: AppTheme.buttonMedium,
                    ),
            ),
          ),
        ),
      ),
    );
  }

}
