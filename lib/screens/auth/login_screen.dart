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
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isSignUp = false; // Toggle between sign in and sign up

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final AuthResult result;
      
      if (_isSignUp) {
        // Sign up with full name
        result = await AuthService.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
        );
      } else {
        // Sign in
        result = await AuthService.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      
      if (result.isSuccess && result.user != null) {
        // Check if user needs to add phone number
        if (result.isNewUser || !result.user!.isProfileComplete) {
          // Navigate to profile setup to collect phone number
          if (mounted) {
            final completed = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSetupScreen(
                  user: result.user!,
                  onSetupComplete: widget.onLoginSuccess,
                ),
              ),
            );
            
            // If setup was completed, navigate to main app
            if (completed == true && mounted) {
              widget.onLoginSuccess?.call();
              // Pop all auth screens and return to main navigation
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (mounted) {
              // If user cancelled, just go back to login
              setState(() {
                _isLoading = false;
              });
            }
          }
        } else {
          // User already has complete profile, go to main app
          if (mounted) {
            widget.onLoginSuccess?.call();
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        }
      } else {
        if (mounted) {
          // Show detailed error message
          final errorMsg = result.errorMessage ?? 'Authentication failed';
          print('🚨 Auth Error: $errorMsg');
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: AppTheme.error,
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'OK',
                textColor: AppTheme.white,
                onPressed: () {},
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication failed: ${e.toString()}'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
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
                        Icons.home_outlined,
                        color: AppTheme.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Welcome to Estatemar',
                      style: AppTheme.headingXLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _isSignUp ? 'Create your account to get started' : 'Sign in to manage your properties',
                      style: AppTheme.textLarge.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Full Name Input (only for sign up)
                if (_isSignUp) ...[
                  TextFormField(
                    controller: _fullNameController,
                    textInputAction: TextInputAction.next,
                    style: AppTheme.formInput,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
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
                      if (_isSignUp) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.trim().length < 3) {
                          return 'Name must be at least 3 characters';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Email Input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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
                
                const SizedBox(height: 16),
                
                // Password Input
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleAuth(),
                  style: AppTheme.formInput,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    labelStyle: AppTheme.formLabel,
                    hintStyle: AppTheme.formHint,
                    prefixIcon: const Icon(
                      Icons.lock_outlined,
                      color: AppTheme.primary,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondary,
                      ),
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
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (_isSignUp && value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Auth Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
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
                            _isSignUp ? 'Sign Up' : 'Sign In',
                            style: AppTheme.buttonLarge.copyWith(color: AppTheme.white),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Toggle Sign In / Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUp ? 'Already have an account?' : 'Don\'t have an account?',
                      style: AppTheme.textMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUp = !_isSignUp;
                          _formKey.currentState?.reset();
                        });
                      },
                      child: Text(
                        _isSignUp ? 'Sign In' : 'Sign Up',
                        style: AppTheme.textMedium.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

