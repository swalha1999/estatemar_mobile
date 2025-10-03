import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _phoneNumber;
  String? _phoneCountryCode;
  String? _phoneDialCode;
  Country? _selectedCountry;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = AuthService.currentUser;
    if (user != null) {
      if (user.fullName != null) {
        _fullNameController.text = user.fullName!;
      }
      if (user.phoneNumber != null) {
        _phoneController.text = user.phoneNumber!;
        _phoneNumber = user.phoneNumber;
      }
      if (user.phoneCountryCode != null) {
        _phoneCountryCode = user.phoneCountryCode;
        _selectedCountry = Country.tryParse(user.phoneCountryCode!);
      } else {
        _phoneCountryCode = 'IL';
        _selectedCountry = Country.tryParse('IL');
      }
      if (user.phoneDialCode != null) {
        _phoneDialCode = user.phoneDialCode;
      } else {
        _phoneDialCode = '+972';
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.updateProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneNumber?.trim(),
        phoneCountryCode: _phoneCountryCode,
        phoneDialCode: _phoneDialCode,
      );

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate successful update
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Profile update failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile update failed: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile', style: AppTheme.headingMedium),
          backgroundColor: AppTheme.background,
          elevation: 0,
        ),
        body: const Center(
          child: Text('No user logged in'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTheme.headingMedium),
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSaveProfile,
            child: _isLoading
                ? SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: AppTheme.buttonMedium.copyWith(color: AppTheme.primary),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                ),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Text(
                          user.fullName?.isNotEmpty == true
                              ? user.fullName!.substring(0, 2).toUpperCase()
                              : user.email[0].toUpperCase(),
                          style: AppTheme.textXLarge.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email (Read-only)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundSecondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.email_outlined, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Email',
                                  style: AppTheme.textSmall.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.email,
                                  style: AppTheme.textMedium.copyWith(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Form Fields Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                            'Personal Information',
                            style: AppTheme.textLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Full Name Input
                          TextFormField(
                            controller: _fullNameController,
                            textInputAction: TextInputAction.next,
                            style: AppTheme.formInput,
                            decoration: InputDecoration(
                              labelText: 'Full Name *',
                              hintText: 'Enter your full name',
                              labelStyle: AppTheme.formLabel,
                              hintStyle: AppTheme.formHint,
                              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.primary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.borderLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: AppTheme.backgroundSecondary,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your full name';
                              }
                              if (value.trim().length < 3) {
                                return 'Name must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Country Selector
                          GestureDetector(
                            onTap: () {
                              showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                favorite: const ['IL', 'US', 'GB'],
                                countryListTheme: CountryListThemeData(
                                  backgroundColor: AppTheme.background,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    topRight: Radius.circular(16),
                                  ),
                                  bottomSheetHeight: MediaQuery.of(context).size.height * 0.75,
                                  inputDecoration: InputDecoration(
                                    hintText: 'Search country',
                                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
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
                                  ),
                                  textStyle: AppTheme.formInput,
                                ),
                                onSelect: (Country c) {
                                  setState(() {
                                    _selectedCountry = c;
                                    _phoneCountryCode = c.countryCode;
                                    _phoneDialCode = '+${c.phoneCode}';
                                  });
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              decoration: BoxDecoration(
                                color: AppTheme.backgroundSecondary,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppTheme.borderLight),
                              ),
                              child: Row(
                                children: [
                                  if (_selectedCountry != null) ...[
                                    Text(
                                      _selectedCountry!.flagEmoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 8),
                                  ] else ...[
                                    const Text('🇮🇱', style: TextStyle(fontSize: 20)),
                                    const SizedBox(width: 8),
                                  ],
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedCountry?.name ?? 'Israel',
                                          style: AppTheme.formInput,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _phoneDialCode ?? '+972',
                                          style: AppTheme.formHint,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textSecondary),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Phone Number Input
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.done,
                            onChanged: (v) => _phoneNumber = v.trim(),
                            onFieldSubmitted: (_) => _handleSaveProfile(),
                            style: AppTheme.formInput,
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              hintText: '5X-XXXXXXX',
                              labelStyle: AppTheme.formLabel,
                              hintStyle: AppTheme.formHint,
                              prefixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 12),
                                  Text(
                                    _phoneDialCode ?? '+972',
                                    style: AppTheme.formInput,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(width: 1, height: 20, color: AppTheme.borderLight),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.borderLight),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: AppTheme.backgroundSecondary,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            ),
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty && value.trim().length < 6) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSaveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                          ),
                        )
                      : Text('Save Changes', style: AppTheme.buttonLarge.copyWith(color: AppTheme.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
