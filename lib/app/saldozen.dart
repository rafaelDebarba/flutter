import 'package:flutter/material.dart';
import '../features/startup/presentation/splash_page.dart';

class SaldoZenApp extends StatelessWidget {
  const SaldoZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaldoZen',
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
