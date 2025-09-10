import 'package:flutter/material.dart';
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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile setup complete!'),
              backgroundColor: AppTheme.success,
            ),
          );
          widget.onSetupComplete?.call();
          // Navigate back to the main screen since we used pushReplacement from LoginScreen
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
          'Profile Setup',
          style: AppTheme.headingMedium,
        ),
      ),
      body: SafeArea(
        child: Padding(
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
                            AppTheme.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.3),
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
                      'Tell us a bit about yourself to get started',
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
                        color: AppTheme.black.withOpacity(0.05),
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
                
                // First Name Input
                TextFormField(
                  controller: _firstNameController,
                  textInputAction: TextInputAction.next,
                  style: AppTheme.formInput,
                  decoration: InputDecoration(
                    labelText: 'First Name *',
                    hintText: 'Enter your first name',
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
                      return 'Please enter your first name';
                    }
                    if (value.trim().length < 2) {
                      return 'First name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Last Name Input
                TextFormField(
                  controller: _lastNameController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSaveProfile(),
                  style: AppTheme.formInput,
                  decoration: InputDecoration(
                    labelText: 'Last Name *',
                    hintText: 'Enter your last name',
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
                      return 'Please enter your last name';
                    }
                    if (value.trim().length < 2) {
                      return 'Last name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Save Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSaveProfile,
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
                
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
