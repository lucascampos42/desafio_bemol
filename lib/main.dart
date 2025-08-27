import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'ui/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeServices();
  
  runApp(const DesafioBemolApp());
}

Future<void> _initializeServices() async {
  try {
    await SharedPreferences.getInstance();
    
    ApiService.instance;
    
    debugPrint('✅ Services initialized successfully');
  } catch (e) {
    debugPrint('❌ Error initializing services: $e');
  }
}

class DesafioBemolApp extends StatelessWidget {
  const DesafioBemolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bemol Challenge',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
