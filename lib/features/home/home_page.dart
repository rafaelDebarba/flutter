import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'transaction_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _preferencesKey = 'saldozen.transactions';
  static const _startingIncomeInCents = 620000;
  static const _startingExpenseInCents = 135000;
  static const _sampleTransactions = [
    FinanceTransaction(
      title: 'Supermercado',
      category: 'Alimentação',
      amountInCents: 24590,
      type: TransactionType.expense,
    ),
    FinanceTransaction(
      title: 'Combustível',
      category: 'Transporte',
      amountInCents: 12000,
      type: TransactionType.expense,
    ),
    FinanceTransaction(
      title: 'Salário',
      category: 'Salário',
      amountInCents: 450000,
      type: TransactionType.income,
    ),
    FinanceTransaction(
      title: 'Netflix',
      category: 'Lazer',
      amountInCents: 3990,
      type: TransactionType.expense,
    ),
  ];

  SharedPreferences? _preferences;
  final List<FinanceTransaction> _transactions = [];
  bool _loadingTransactions = true;

  int get _incomeInCents =>
      _startingIncomeInCents +
      _transactions
          .where((transaction) => transaction.type == TransactionType.income)
          .fold<int>(0, (sum, transaction) => sum + transaction.amountInCents);

  int get _expenseInCents =>
      _startingExpenseInCents +
      _transactions
          .where((transaction) => transaction.type == TransactionType.expense)
          .fold<int>(0, (sum, transaction) => sum + transaction.amountInCents);

  static String _formatCurrency(int amountInCents) {
    final absoluteAmount = amountInCents.abs();
    final wholePart = (absoluteAmount ~/ 100).toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    final decimalPart = (absoluteAmount % 100).toString().padLeft(2, '0');
    final sign = amountInCents < 0 ? '- ' : '';
    return '${sign}R\$ $wholePart,$decimalPart';
  }

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final encoded = preferences.getStringList(_preferencesKey) ?? [];
      final transactions = encoded
          .map((value) => FinanceTransaction.fromJson(
                jsonDecode(value) as Map<String, dynamic>,
              ))
          .toList();
      if (!mounted) return;
      setState(() {
        _preferences = preferences;
        _transactions.addAll(transactions);
        _loadingTransactions = false;
      });
    } on Exception {
      if (!mounted) return;
      setState(() => _loadingTransactions = false);
      _showMessage('Não foi possível carregar seus lançamentos salvos.');
    }
  }

  Future<void> _addTransaction() async {
    final transaction = await showModalBottomSheet<FinanceTransaction>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const TransactionForm(),
    );
    if (transaction == null || !mounted) return;

    final updatedTransactions = [..._transactions, transaction];
    try {
      final saved = await _preferences!.setStringList(
        _preferencesKey,
        updatedTransactions.map((item) => jsonEncode(item.toJson())).toList(),
      );
      if (!saved) {
        _showMessage('Não foi possível salvar o lançamento. Tente novamente.');
        return;
      }
    } on Exception {
      if (mounted) {
        _showMessage('Não foi possível salvar o lançamento. Tente novamente.');
      }
      return;
    }

    if (!mounted) return;
    setState(() => _transactions.add(transaction));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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

                          Text(
                            _formatCurrency(
                              _incomeInCents - _expenseInCents,
                            ),
                            style: const TextStyle(
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
                                _formatCurrency(_incomeInCents),
                                Icons.arrow_downward_rounded,
                              ),
                              const SizedBox(width: 28),
                              _balanceInfo(
                                'Despesas',
                                _formatCurrency(_expenseInCents),
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
                          Text(
                            _formatCurrency(_expenseInCents),
                            style: const TextStyle(
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

                    ..._transactions.reversed.map(_buildTransaction),
                    ..._sampleTransactions.map(_buildTransaction),

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
        onPressed: _loadingTransactions || _preferences == null
            ? null
            : _addTransaction,
        tooltip: 'Adicionar receita ou gasto',
        backgroundColor: const Color(0xFF4CAF58),
        foregroundColor: Colors.white,
        elevation: 5,
        child: const Icon(Icons.add_rounded, size: 30),
      ),
    );
  }

  Widget _buildTransaction(FinanceTransaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : _categoryColor(transaction.category);
    final icon = isIncome
        ? Icons.work_outline_rounded
        : _categoryIcon(transaction.category);
    final sign = isIncome ? '+ ' : '- ';

    return _transaction(
      icon: icon,
      title: transaction.title,
      category: transaction.category,
      value: '$sign${_formatCurrency(transaction.amountInCents)}',
      color: color,
      income: isIncome,
    );
  }

  static Color _categoryColor(String category) {
    return switch (category) {
      'Alimentação' => Colors.orange,
      'Transporte' => Colors.blue,
      'Lazer' => Colors.red,
      'Moradia' => Colors.deepPurple,
      _ => Colors.teal,
    };
  }

  static IconData _categoryIcon(String category) {
    return switch (category) {
      'Alimentação' => Icons.shopping_cart_outlined,
      'Transporte' => Icons.directions_car_outlined,
      'Lazer' => Icons.movie_outlined,
      'Moradia' => Icons.home_outlined,
      _ => Icons.receipt_long_outlined,
    };
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
