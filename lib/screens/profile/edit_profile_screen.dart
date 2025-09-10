import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = AuthService.currentUser;
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
    }
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
                      color: AppTheme.black.withOpacity(0.05),
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
                          user.firstName.isNotEmpty && user.lastName.isNotEmpty
                              ? '${user.firstName[0]}${user.lastName[0]}'
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
                      'Personal Information',
                      style: AppTheme.textLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    
                    const SizedBox(height: 20),
                    
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
                          return 'Please enter your last name';
                        }
                        if (value.trim().length < 2) {
                          return 'Last name must be at least 2 characters';
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
