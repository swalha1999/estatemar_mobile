import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  
  const ProfileScreen({super.key, this.onLogout});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    
    // Wait a bit to show loading state
    await Future.delayed(const Duration(milliseconds: 500));
    
    setState(() {
      _currentUser = AuthService.currentUser;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService.logout();
      if (mounted) {
        widget.onLogout?.call();
        // Don't call Navigator.pop here as it's already called in the dialog
      }
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );

    if (result == true && mounted) {
      _loadUserData(); // Refresh user data
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.grey400,
              ),
              const SizedBox(height: 16),
              Text(
                'No user logged in',
                style: AppTheme.headingLarge.copyWith(color: AppTheme.grey600),
              ),
              const SizedBox(height: 8),
              Text(
                'Please login to view your profile',
                style: AppTheme.textMedium.copyWith(color: AppTheme.grey500),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text('Profile', style: AppTheme.headingMedium),
        actions: [
          IconButton(
            onPressed: _navigateToEditProfile,
            icon: const Icon(Icons.edit, color: AppTheme.textPrimary),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                        _currentUser!.firstName.isNotEmpty && _currentUser!.lastName.isNotEmpty
                            ? '${_currentUser!.firstName[0]}${_currentUser!.lastName[0]}'
                            : _currentUser!.email[0].toUpperCase(),
                        style: AppTheme.textXLarge.copyWith(color: AppTheme.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Name
                  Text(
                    _currentUser!.fullName.isNotEmpty 
                        ? _currentUser!.fullName 
                        : 'Complete your profile',
                    style: AppTheme.headingXLarge,
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Email
                  Text(
                    _currentUser!.email,
                    style: AppTheme.textMedium.copyWith(color: AppTheme.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Edit Profile Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _navigateToEditProfile,
                      icon: const Icon(Icons.edit, size: 18),
                      label: Text('Edit Profile', style: AppTheme.buttonMedium.copyWith(color: AppTheme.primary)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primary,
                        side: const BorderSide(color: AppTheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Account Information Card
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
                    'Account Information',
                    style: AppTheme.textLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: _currentUser!.email,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'First Name',
                    value: _currentUser!.firstName.isNotEmpty 
                        ? _currentUser!.firstName 
                        : 'Not set',
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Last Name',
                    value: _currentUser!.lastName.isNotEmpty 
                        ? _currentUser!.lastName 
                        : 'Not set',
                  ),
                  
                  if (_currentUser!.createdAt != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      label: 'Member Since',
                      value: _formatDate(_currentUser!.createdAt!),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: Text('Logout', style: AppTheme.buttonMedium.copyWith(color: AppTheme.error)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorLight,
                  foregroundColor: AppTheme.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.textSmall.copyWith(color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTheme.textMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
