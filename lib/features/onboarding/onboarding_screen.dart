import 'package:flutter/material.dart';

import '../home/home_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Treine com foco',
      description:
          'Organize seus treinos, acompanhe o progresso e mantenha consistência todos os dias.',
      icon: Icons.fitness_center,
      color: Color(0xFF7C3AED),
    ),
    _OnboardingSlide(
      title: 'Acompanhe sua evolução',
      description:
          'Veja seu desempenho, metas e hábitos em um só lugar para evoluir com mais clareza.',
      icon: Icons.insights,
      color: Color(0xFF06B6D4),
    ),
    _OnboardingSlide(
      title: 'Comece hoje',
      description:
          'Entre na sua rotina e transforme sua disciplina em resultados reais com o app.',
      icon: Icons.flag,
      color: Color(0xFF22C55E),
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  void _nextPage() {
    if (_isLastPage) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  },
                  child: const Text('Pular'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _slides.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              color: slide.color.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              slide.icon,
                              size: 90,
                              color: slide.color,
                            ),
                          ),
                          const SizedBox(height: 36),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              slide.description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: _currentPage == index ? 24 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _isLastPage ? 'Começar' : 'Próximo',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
