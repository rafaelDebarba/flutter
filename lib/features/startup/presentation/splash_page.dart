import 'dart:async';

import 'package:flutter/material.dart';

import '../../onboarding/onboarding_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/app_icon.png',
              width: 220,
              height: 220,
              fit: BoxFit.contain,
              semanticLabel: 'Logo do SaldoZen',
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text('Carregando...', style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
