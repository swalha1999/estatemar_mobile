import 'package:flutter/material.dart';
import 'screens/main_navigation_screen.dart';
import 'theme/app_theme.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estatemar Mobile',
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}


