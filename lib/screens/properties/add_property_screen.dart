import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/property.dart';
import '../../models/user_property.dart';
import '../../services/auth_service.dart';
import '../../services/user_property_service.dart';
import '../../theme/colors.dart';

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
  final _appreciationRateController = TextEditingController();
  
  PropertyType _selectedPropertyType = PropertyType.house;
  DateTime? _purchaseDate;
  bool _isLoading = false;
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _propertyNameController.dispose();
    _addressController.dispose();
    _purchasePriceController.dispose();
    _marketValueController.dispose();
    _descriptionController.dispose();
    _monthlyRentController.dispose();
    _appreciationRateController.dispose();
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
        purchasePrice: double.parse(_purchasePriceController.text.trim()),
        marketValue: _marketValueController.text.trim().isNotEmpty 
            ? double.parse(_marketValueController.text.trim()) 
            : null,
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        propertyType: _selectedPropertyType,
        purchaseDate: _purchaseDate,
        monthlyRent: _monthlyRentController.text.trim().isNotEmpty 
            ? double.parse(_monthlyRentController.text.trim()) 
            : null,
        annualAppreciationRate: _appreciationRateController.text.trim().isNotEmpty 
            ? double.parse(_appreciationRateController.text.trim()) 
            : null,
        imageUrls: _selectedImages.map((file) => file.path).toList(),
        createdAt: DateTime.now(),
      );

      final success = await UserPropertyService.addProperty(property);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Property added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate successful addition
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add property'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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
            backgroundColor: Colors.red,
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Add Property',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
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
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Required Information',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Property Name
                    TextFormField(
                      controller: _propertyNameController,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Property Name/Address *',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        hintText: 'e.g., 123 Main Street, Downtown Apartment',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(Icons.home, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Full Address *',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        hintText: 'e.g., 123 Main Street, City, State 12345',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(Icons.location_on, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Purchase Price *',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        hintText: 'e.g., 500000',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(Icons.attach_money, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter purchase price';
                        }
                        final price = double.tryParse(value.trim());
                        if (price == null || price <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Property Type
                    DropdownButtonFormField<PropertyType>(
                      value: _selectedPropertyType,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                      isExpanded: true,
                      menuMaxHeight: 300,
                      decoration: InputDecoration(
                        labelText: 'Property Type *',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(Icons.category, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: PropertyType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(
                            _getPropertyTypeString(type),
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPropertyType = value);
                        }
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Optional Information',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Market Value
                    TextFormField(
                      controller: _marketValueController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Current Market Value',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        hintText: 'e.g., 550000',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(Icons.trending_up, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final price = double.tryParse(value.trim());
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
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: Colors.grey[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Purchase Date',
                                    style: const TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _purchaseDate != null
                                        ? '${_purchaseDate!.day}/${_purchaseDate!.month}/${_purchaseDate!.year}'
                                        : 'Select purchase date',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 12,
                                      color: _purchaseDate != null 
                                          ? AppColors.textPrimary 
                                          : Colors.grey[500],
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
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Monthly Rent',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        hintText: 'e.g., 2500',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(Icons.home_work, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final rent = double.tryParse(value.trim());
                          if (rent == null || rent <= 0) {
                            return 'Please enter a valid monthly rent';
                          }
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Annual Appreciation Rate
                    TextFormField(
                      controller: _appreciationRateController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Annual Appreciation Rate (%)',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        hintText: 'e.g., 3.5',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(Icons.trending_up, size: 18),
                        suffixIcon: const Icon(Icons.percent, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        isDense: true,
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final rate = double.tryParse(value.trim());
                          if (rate == null || rate < 0 || rate > 100) {
                            return 'Please enter a valid appreciation rate (0-100)';
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
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        hintText: 'Additional details about the property...',
                        hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        prefixIcon: const Icon(Icons.description, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
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
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Add Property',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Add up to 10 images of your property',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 11,
            color: AppColors.textSecondary,
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
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 32,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add images',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: Colors.grey[600],
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
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey[300]!,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                size: 24,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add More',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontSize: 10,
                                  color: Colors.grey[600],
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
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
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
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  String _getPropertyTypeString(PropertyType type) {
    switch (type) {
      case PropertyType.house:
        return 'House';
      case PropertyType.apartment:
        return 'Apartment';
      case PropertyType.condo:
        return 'Condo';
      case PropertyType.townhouse:
        return 'Townhouse';
      case PropertyType.villa:
        return 'Villa';
      case PropertyType.studio:
        return 'Studio';
    }
  }
}
