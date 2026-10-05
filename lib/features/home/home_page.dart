import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF5DBB63),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.spa_rounded,
                                color: Colors.white,
                                size: 27,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'SaldoZen',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF193B20),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Color(0xFF193B20),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // SAUDAÇÃO
                    const Text(
                      'Olá, João 👋',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF718071),
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Como estão suas finanças?',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF193B20),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // CARD DO SALDO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4CAF58),
                            Color(0xFF78C97D),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF58)
                                .withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Saldo disponível',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.18),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '+8,4%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'R\$ 4.850,00',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              _balanceInfo(
                                'Receitas',
                                'R\$ 6.200,00',
                                Icons.arrow_downward_rounded,
                              ),
                              const SizedBox(width: 28),
                              _balanceInfo(
                                'Despesas',
                                'R\$ 1.350,00',
                                Icons.arrow_upward_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // TÍTULO
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Visão geral',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF193B20),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Este mês',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF506050),
                                ),
                              ),
                              SizedBox(width: 5),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 17,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // GRÁFICO
                    Container(
                      height: 190,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Gastos',
                            style: TextStyle(
                              color: Color(0xFF788578),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'R\$ 1.350,00',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF193B20),
                            ),
                          ),

                          const SizedBox(height: 18),

                          Expanded(
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.end,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _bar('Seg', 0.45),
                                _bar('Ter', 0.65),
                                _bar('Qua', 0.35),
                                _bar('Qui', 0.80),
                                _bar('Sex', 0.55),
                                _bar('Sáb', 0.90),
                                _bar('Dom', 0.30),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // TRANSAÇÕES
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Últimas transações',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF193B20),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Ver todas',
                            style: TextStyle(
                              color: Color(0xFF4CAF58),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    _transaction(
                      icon: Icons.shopping_cart_outlined,
                      title: 'Supermercado',
                      category: 'Alimentação',
                      value: '- R\$ 245,90',
                      color: Colors.orange,
                    ),

                    _transaction(
                      icon: Icons.directions_car_outlined,
                      title: 'Combustível',
                      category: 'Transporte',
                      value: '- R\$ 120,00',
                      color: Colors.blue,
                    ),

                    _transaction(
                      icon: Icons.work_outline_rounded,
                      title: 'Salário',
                      category: 'Receita',
                      value: '+ R\$ 4.500,00',
                      color: Colors.green,
                      income: true,
                    ),

                    _transaction(
                      icon: Icons.movie_outlined,
                      title: 'Netflix',
                      category: 'Lazer',
                      value: '- R\$ 39,90',
                      color: Colors.red,
                    ),

                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // BOTÃO ADICIONAR
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF4CAF58),
        foregroundColor: Colors.white,
        elevation: 5,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  static Widget _balanceInfo(
    String title,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 17,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Widget _bar(String day, double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 25,
              height: 85 * height,
              decoration: BoxDecoration(
                color: const Color(0xFF70C477),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: const TextStyle(
            color: Color(0xFF879287),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  static Widget _transaction({
    required IconData icon,
    required String title,
    required String category,
    required String value,
    required Color color,
    bool income = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF263526),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF899289),
                  ),
                ),
              ],
            ),
          ),

          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: income
                  ? const Color(0xFF4CAF58)
                  : const Color(0xFF263526),
            ),
          ),
        ],
      ),
    );
  }
}
