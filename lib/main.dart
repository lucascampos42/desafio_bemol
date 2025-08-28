import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/services/api_service.dart';
import 'core/utils/performance_metrics.dart';
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
    
    // Inicializa métricas de performance
    PerformanceMetrics.instance.logEvent('app_startup', {'timestamp': DateTime.now().toIso8601String()});
    
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
      // Exemplo de como visualizar métricas de performance
      // Descomente as linhas abaixo para ver relatório no console
      // builder: (context, child) {
      //   WidgetsBinding.instance.addPostFrameCallback((_) {
      //     Future.delayed(const Duration(seconds: 10), () {
      //       final report = PerformanceMetrics.instance.generateReport();
      //       debugPrint('📊 Performance Report:\n$report');
      //     });
      //   });
      //   return child!;
      // },
    );
  }
}
