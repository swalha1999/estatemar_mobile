import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/property.dart';
import '../../models/user_property.dart';
import '../../services/auth_service.dart';
import '../../services/user_property_service.dart';
import '../../theme/app_theme.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
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
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Add listeners for price formatting
    _purchasePriceController.addListener(_formatPurchasePrice);
    _marketValueController.addListener(_formatMarketValue);
    _monthlyRentController.addListener(_formatMonthlyRent);
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

  Future<void> _handleSaveProperty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      final property = UserProperty(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        propertyName: _propertyNameController.text.trim(),
        address: _addressController.text.trim(),
        purchasePrice: _parseFormattedNumber(_purchasePriceController.text) ?? 0.0,
        marketValue: _parseFormattedNumber(_marketValueController.text),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        propertyType: PropertyType.house, // Default to house
        purchaseDate: _purchaseDate,
        monthlyRent: _parseFormattedNumber(_monthlyRentController.text),
        area: _sizeController.text.trim().isNotEmpty 
            ? double.tryParse(_sizeController.text.trim())
            : null,
        imageUrls: _selectedImages.map((file) => file.path).toList(),
        createdAt: DateTime.now(),
      );

      final success = await UserPropertyService.addProperty(property);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Property added successfully!'),
              backgroundColor: AppTheme.success,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate successful addition
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to add property'),
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

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick images: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Add Property'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSaveProperty,
            child: _isLoading
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: AppTheme.buttonMedium.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
          ),
        ],
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required Information',
                      style: AppTheme.headingMedium,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Property Name
                    TextFormField(
                      controller: _propertyNameController,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Property Name/Address *',
                        labelStyle: AppTheme.formLabel,
                        hintText: 'e.g., 123 Main Street, Downtown Apartment',
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.home, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter property name/address';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Address
                    TextFormField(
                      controller: _addressController,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Full Address *',
                        labelStyle: AppTheme.formLabel,
                        hintText: 'e.g., 123 Main Street, City, State 12345',
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.location_on, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter full address';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Purchase Price
                    TextFormField(
                      controller: _purchasePriceController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Purchase Price *',
                        labelStyle: AppTheme.formLabel,
                        hintText: 'e.g., 500000',
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.attach_money, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
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
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Optional Information',
                      style: AppTheme.headingMedium,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Market Value
                    TextFormField(
                      controller: _marketValueController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Current Market Value',
                        labelStyle: AppTheme.formLabel,
                        hintText: 'e.g., 550000',
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.trending_up, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
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
                    
                    const SizedBox(height: 12),
                    
                    // Purchase Date
                    InkWell(
                      onTap: _selectPurchaseDate,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundSecondary,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.borderLight),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: AppTheme.grey600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Purchase Date',
                                    style: AppTheme.textSmall.copyWith(
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _purchaseDate != null
                                        ? '${_purchaseDate!.day}/${_purchaseDate!.month}/${_purchaseDate!.year}'
                                        : 'Select purchase date',
                                    style: AppTheme.textSmall.copyWith(
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
                    
                    const SizedBox(height: 12),
                    
                    // Monthly Rent
                    TextFormField(
                      controller: _monthlyRentController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Monthly Rent',
                        labelStyle: AppTheme.formLabel,
                        hintText: 'e.g., 2500',
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.home_work, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
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
                    
                    const SizedBox(height: 12),
                    
                    // Property Size
                    TextFormField(
                      controller: _sizeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Property Size (sq m)',
                        labelStyle: AppTheme.formLabel,
                        hintText: 'e.g., 120',
                        hintStyle: AppTheme.formHint,
                        prefixIcon: const Icon(Icons.square_foot, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
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
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      style: AppTheme.formInput,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: AppTheme.formLabel,
                        hintText: '📝 Additional details about the property...',
                        hintStyle: AppTheme.formHint,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundSecondary,
                        alignLabelWithHint: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Property Images
                    _buildImageUploadSection(),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              Container(
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSaveProperty,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                          : Text(
                              'Add Property',
                              style: AppTheme.buttonMedium.copyWith(
                                color: AppTheme.background,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Property Images (Optional)',
          style: AppTheme.headingSmall,
        ),
        const SizedBox(height: 6),
        Text(
          'Add up to 10 images of your property',
          style: AppTheme.textSmall.copyWith(
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 12),
        if (_selectedImages.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.grey100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.grey300,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: AppTheme.grey600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add images',
                    style: AppTheme.textSmall.copyWith(
                      color: AppTheme.grey600,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _selectedImages.length) {
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppTheme.grey100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.grey300,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 24,
                                color: AppTheme.grey600,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add More',
                                style: AppTheme.textSmall.copyWith(
                                  fontSize: 10,
                                  color: AppTheme.grey600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_selectedImages[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  color: AppTheme.error,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: AppTheme.background,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedImages.length} image(s) selected',
                style: AppTheme.textSmall.copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
      ],
    );
  }

}
