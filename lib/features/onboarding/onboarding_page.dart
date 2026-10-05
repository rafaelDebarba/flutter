import 'package:flutter/material.dart';

class OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final String assetPath;

  const OnboardingPage({
    super.key,
    required this.data,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Center(
              child: Container(
                width: 250,
                height: 250,
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.07),
                ),
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          Expanded(
            flex: 4,
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    data.icon,
                    color: theme.colorScheme.secondary,
                    size: 28,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  data.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  data.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: 0.68,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}