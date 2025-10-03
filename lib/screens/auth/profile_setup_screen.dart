import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  final User user;
  final VoidCallback? onSetupComplete;

  const ProfileSetupScreen({
    super.key,
    required this.user,
    this.onSetupComplete,
  });

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
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
    // Set default country to Israel
    _phoneCountryCode = 'IL';
    _phoneDialCode = '+972';
    // Pre-fill if data exists
    if (widget.user.fullName != null) {
      _fullNameController.text = widget.user.fullName!;
    }
    if (widget.user.phoneNumber != null) {
      _phoneController.text = widget.user.phoneNumber!;
      _phoneNumber = widget.user.phoneNumber;
    }
    if (widget.user.phoneCountryCode != null) {
      _phoneCountryCode = widget.user.phoneCountryCode;
    }
    if (widget.user.phoneDialCode != null) {
      _phoneDialCode = widget.user.phoneDialCode;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSetup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_phoneNumber == null || _phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.completeSignup(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneNumber!,
        phoneCountryCode: _phoneCountryCode!,
        phoneDialCode: _phoneDialCode!,
      );

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile setup complete!'),
              backgroundColor: AppTheme.success,
            ),
          );
          // Return true to indicate successful completion
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Profile setup failed'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile setup failed: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
        ),
        title: Text(
          'Complete Profile',
          style: AppTheme.headingMedium,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Section
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.primary,
                            AppTheme.primary.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_add_outlined,
                        color: AppTheme.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Complete Your Profile',
                      style: AppTheme.headingXLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Please provide your full name and phone number',
                      style: AppTheme.textLarge.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Email Display (Read-only)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.email_outlined,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: AppTheme.textSmall.copyWith(
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user.email,
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
                ),
                
                const SizedBox(height: 24),
                
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
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppTheme.primary,
                    ),
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
                    fillColor: AppTheme.background,
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
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
                  onFieldSubmitted: (_) => _handleCompleteSetup(),
                  style: AppTheme.formInput,
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: '5X-XXXXXXX',
                    labelStyle: AppTheme.formLabel,
                    hintStyle: AppTheme.formHint,
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(width: 12),
                        Text(
                          (_phoneDialCode ?? '+972'),
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
                    fillColor: AppTheme.background,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.trim().length < 6) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Complete Setup Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCompleteSetup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
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
                            'Complete Setup',
                            style: AppTheme.buttonLarge.copyWith(color: AppTheme.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
