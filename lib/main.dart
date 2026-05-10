import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/ads_service.dart';
import 'services/purchase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PurchaseService.instance.initialize();
  AdsService.instance.initialize();
  runApp(const SolitaireApp());
}

class SolitaireApp extends StatelessWidget {
  const SolitaireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Solitaire',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1B5E20),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.dark,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
