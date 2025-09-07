import 'package:flutter/material.dart';
import '../../theme/colors.dart';
import '../../models/user_property.dart';
import '../../models/listing_request.dart';
import '../../services/user_property_service.dart';
import '../../services/auth_service.dart';
import '../../services/listing_request_service.dart';

class SellScreen extends StatefulWidget {
  final VoidCallback? onAuthChange;
  final VoidCallback? onNavigateToMyProperties;
  
  const SellScreen({
    super.key, 
    this.onAuthChange,
    this.onNavigateToMyProperties,
  });

  @override
  State<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _askingPriceController = TextEditingController();
  
  List<UserProperty> _userProperties = [];
  List<ListingRequest> _listingRequests = [];
  UserProperty? _selectedProperty;
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadUserProperties();
  }

  @override
  void dispose() {
    _askingPriceController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProperties() async {
    setState(() => _isLoading = true);
    
    try {
      final user = AuthService.currentUser;
      if (user != null) {
        final properties = await UserPropertyService.getUserProperties(user.id);
        final listingRequests = await ListingRequestService.getUserListingRequests(user.id);
        setState(() {
          _userProperties = properties;
          _listingRequests = listingRequests;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load properties: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitListingRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProperty == null) {
      _showErrorSnackBar('Please select a property to list');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = AuthService.currentUser;
      if (user == null) {
        _showErrorSnackBar('Please log in to submit a listing request');
        return;
      }

      // Check if there's already a pending request for this property
      final hasExistingRequest = await ListingRequestService.hasExistingRequestForProperty(_selectedProperty!.id);
      if (hasExistingRequest) {
        _showErrorSnackBar('You already have a pending listing request for this property');
        return;
      }

      final askingPrice = double.tryParse(_askingPriceController.text) ?? 0.0;
      if (askingPrice <= 0) {
        _showErrorSnackBar('Please enter a valid asking price');
        return;
      }

      final listingRequest = ListingRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        propertyId: _selectedProperty!.id,
        propertyName: _selectedProperty!.propertyName,
        propertyAddress: _selectedProperty!.address,
        askingPrice: askingPrice,
        description: '', // No description needed
        imageUrls: [], // No images needed
        status: ListingRequestStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final success = await ListingRequestService.addListingRequest(listingRequest);
      
      if (mounted) {
        if (success) {
          _showSuccessSnackBar('Listing request submitted successfully! Our team will review it soon.');
          _clearForm();
          // Refresh the page to show the new listing request
          await _loadUserProperties();
        } else {
          _showErrorSnackBar('Failed to submit listing request');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to submit listing request: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _clearForm() {
    _askingPriceController.clear();
    setState(() {
      _selectedProperty = null;
    });
  }


  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Request Property Listing',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _userProperties.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Card
                        _buildHeaderCard(),
                        const SizedBox(height: 24),
                        
                        // Property Selection Card
                        _buildPropertySelectionCard(),
                        const SizedBox(height: 16),
                        
                        // Existing Listing Requests
                        if (_listingRequests.isNotEmpty) ...[
                          _buildListingRequestsCard(),
                          const SizedBox(height: 16),
                        ],
                        
                        // Listing Details Card
                        if (_selectedProperty != null) ...[
                          _buildListingDetailsCard(),
                          const SizedBox(height: 24),
                          
                          // Submit Button
                          _buildSubmitButton(),
                          const SizedBox(height: 16),
                          
                          // Info Box
                          _buildInfoBox(),
                        ],
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
            Icon(
              Icons.home_work_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Properties Found',
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You need to add properties to your portfolio before you can request a listing.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to My Properties tab
                    widget.onNavigateToMyProperties?.call();
                  },
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Add Property',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
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

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Icon(
                Icons.request_quote,
                size: 24,
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Request Property Listing',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 18,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Select a property from your portfolio and submit a listing request. Our team will review and approve your listing.',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingRequestsCard() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.list_alt, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Your Listing Requests',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._listingRequests.map((request) => _buildListingRequestItem(request)),
        ],
      ),
    );
  }

  Widget _buildListingRequestItem(ListingRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: request.statusColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: request.statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            request.status == ListingRequestStatus.pending
                ? Icons.hourglass_empty
                : request.status == ListingRequestStatus.approved
                    ? Icons.check_circle
                    : Icons.cancel,
            color: request.statusColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.propertyName,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.propertyAddress,
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Status: ',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      request.statusDisplayName,
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: request.statusColor,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      request.formattedAskingPrice,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
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

  Widget _buildPropertySelectionCard() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.home, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Select Property',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Choose a property from your portfolio to list for sale:',
            style: const TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          ..._userProperties.map((property) => _buildPropertyOption(property)),
        ],
      ),
    );
  }

  Widget _buildPropertyOption(UserProperty property) {
    final isSelected = _selectedProperty?.id == property.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProperty = property;
          // Pre-fill asking price with market value if available
          if (property.marketValue != null && property.marketValue! > 0) {
            _askingPriceController.text = property.marketValue!.toStringAsFixed(0);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.propertyName,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property.address,
                    style: const TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (property.marketValue != null && property.marketValue! > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Market Value: \$${property.marketValue!.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildListingDetailsCard() {
    return Container(
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
          Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Listing Details',
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormField(
            'Asking Price *',
            _askingPriceController,
            'Enter your desired selling price',
            keyboardType: TextInputType.number,
            prefixText: '\$ ',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter the asking price';
              }
              final price = double.tryParse(value);
              if (price == null || price <= 0) {
                return 'Please enter a valid price';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }


  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isSubmitting ? null : _submitListingRequest,
        icon: _isSubmitting
            ? const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.send, size: 18),
        label: Text(
          _isSubmitting ? 'Submitting Request...' : 'Submit Listing Request',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue[700], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your listing request will be reviewed by our team within 24-48 hours. You\'ll receive a notification once approved.',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 12,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController? controller,
    String hintText, {
    TextInputType? keyboardType,
    String? prefixText,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            prefixText: prefixText,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          validator: validator,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
          ),
        ),
      ],
    );
  }

}