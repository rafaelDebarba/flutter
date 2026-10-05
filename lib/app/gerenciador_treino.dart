import 'package:flutter/material.dart';
import '../features/startup/presentation/splash_page.dart';

class GerenciadorTreinoApp extends StatelessWidget {
  const GerenciadorTreinoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CeliLac',
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
    );
  }
}
