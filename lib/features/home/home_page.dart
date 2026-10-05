import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final todayWorkouts = [
      {
        'title': 'Peito e triceps',
        'time': '45 min',
        'color': const Color(0xFF7C3AED),
      },
      {
        'title': 'Corrida leve',
        'time': '20 min',
        'color': const Color(0xFF06B6D4),
      },
      {
        'title': 'Mobilidade',
        'time': '10 min',
        'color': const Color(0xFF22C55E),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Academia',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bom dia,',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Guilherme',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Meta atual',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '75% concluído',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.75,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Você está no caminho certo para alcançar sua meta de 4 treinos por semana.',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Treinos',
                    value: '4/5',
                    icon: Icons.fitness_center,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Calorias',
                    value: '680',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFFB923C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Hoje',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 14),
            ListView.builder(
              itemCount: todayWorkouts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final workout = todayWorkouts[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: (workout['color'] as Color).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: workout['color'] as Color,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workout['time'] as String,
                              style: TextStyle(
                                color: Colors.black.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Novo treino'),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
