import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'profile_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  
  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.loginWithEmail(_emailController.text.trim());
      
      if (result.isSuccess && result.user != null) {
        if (result.isNewUser) {
          // Navigate to profile setup for new users
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSetupScreen(
                  user: result.user!,
                  onSetupComplete: widget.onLoginSuccess,
                ),
              ),
            );
          }
        } else {
          // Navigate back to main screen for existing users
          if (mounted) {
            widget.onLoginSuccess?.call();
            Navigator.pop(context, true); // Return true to indicate successful login
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.errorMessage ?? 'Login failed'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                
                // Logo/Title Section
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
                        Icons.home_outlined,
                        color: AppTheme.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome to EstateMar',
                      style: AppTheme.headingXLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Sign in to manage your properties',
                      style: AppTheme.textLarge.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Email Input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  style: AppTheme.formInput,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'Enter your email',
                    labelStyle: AppTheme.formLabel,
                    hintStyle: AppTheme.formHint,
                    prefixIcon: const Icon(
                      Icons.email_outlined,
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
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Login Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
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
                            'Sign In',
                            style: AppTheme.buttonLarge.copyWith(color: AppTheme.white),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Demo Info
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.infoLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.info.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.info,
                        size: 24,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Demo Mode',
                        style: AppTheme.textMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.info,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter any valid email address to sign in. New users will be prompted to set up their profile.',
                        style: AppTheme.textSmall.copyWith(
                          color: AppTheme.info,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
