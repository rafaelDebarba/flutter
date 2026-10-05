import 'package:flutter/material.dart';

import '../home/home_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  int currentPage = 0;

  final List<Map<String, dynamic>> pages = [
    {
      'icon': Icons.account_balance_wallet_rounded,
      'title': 'Seu dinheiro,\nmais tranquilo.',
      'description':
          'Organize seus gastos e tenha mais controle sobre sua vida financeira.',
    },
    {
      'icon': Icons.bar_chart_rounded,
      'title': 'Entenda para\nonde vai seu dinheiro.',
      'description':
          'Acompanhe seus gastos de forma simples e descubra onde você pode economizar.',
    },
    {
      'icon': Icons.spa_rounded,
      'title': 'Alcance seus\nobjetivos.',
      'description':
          'Crie metas financeiras e acompanhe seu progresso de forma tranquila.',
    },
  ];

  void nextPage() {
    if (currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  void skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),
      body: SafeArea(
        child: Column(
          children: [

            // =========================
            // TOPO
            // =========================

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  Row(
                    children: [

                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF5DBB63),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          color: Colors.white,
                          size: 23,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        'SaldoZen',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF193B20),
                        ),
                      ),
                    ],
                  ),

                  TextButton(
                    onPressed: skip,
                    child: const Text(
                      'Pular',
                      style: TextStyle(
                        color: Color(0xFF718071),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =========================
            // PÁGINAS
            // =========================

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,

                onPageChanged: (index) {
                  setState(() {
                    currentPage = index;
                  });
                },

                itemBuilder: (context, index) {
                  return _buildPage(
                    icon: pages[index]['icon'],
                    title: pages[index]['title'],
                    description:
                        pages[index]['description'],
                  );
                },
              ),
            ),

            // =========================
            // INDICADORES
            // =========================

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) {
                  final selected =
                      index == currentPage;

                  return AnimatedContainer(
                    duration:
                        const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    width: selected ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF5DBB63)
                          : const Color(0xFFD5DED5),
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // BOTÃO
            // =========================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                24,
                0,
                24,
                25,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF5DBB63),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(
                    currentPage == pages.length - 1
                        ? 'Começar agora'
                        : 'Continuar',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // PÁGINA DO ONBOARDING
  // =========================

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE4F2E5),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: const BoxDecoration(
                            color: Color(0xFFBFE5C2),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            icon,
                            size: 52,
                            color: const Color(0xFF5DBB63),
                          ),
                        ),
                        Positioned(
                          top: 24,
                          right: 28,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: Color(0xFF78C97D),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 32,
                          left: 28,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF9AD69E),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 52,
                          left: 18,
                          child: Icon(
                            Icons.star_rounded,
                            size: 20,
                            color: const Color(0xFF78C97D),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF193B20),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF718071),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
