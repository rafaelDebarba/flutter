import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../profile/financial_profile_provider.dart';
import '../profile/financial_profile_screen.dart';
import 'finance_provider.dart';
import 'transaction_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTransactions());
  }

  Future<void> _loadTransactions() async {
    try {
      await context.read<FinanceProvider>().loadTransactions();
    } on Exception {
      if (mounted) {
        _showMessage('Não foi possível carregar seus lançamentos salvos.');
      }
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

    try {
      await context.read<FinanceProvider>().addTransaction(transaction);
    } on Exception {
      if (mounted) {
        _showMessage('Não foi possível salvar o lançamento. Tente novamente.');
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceProvider>();
    final profile = context.watch<FinancialProfileProvider>();

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
                        IconButton(
                          tooltip: 'Editar perfil financeiro',
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const FinancialProfileScreen(editing: true),
                              ),
                            );
                          },
                          icon: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF193B20),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // SAUDAÇÃO
                    Text(
                      'Olá, ${profile.name.isEmpty ? 'Pessoa' : profile.name} 👋',
                      style: TextStyle(fontSize: 16, color: Color(0xFF718071)),
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
                          colors: [Color(0xFF4CAF58), Color(0xFF78C97D)],
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Saldo disponível',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),

                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            _formatCurrency(finance.balanceInCents),
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
                                _formatCurrency(finance.incomeInCents),
                                Icons.arrow_downward_rounded,
                              ),
                              const SizedBox(width: 28),
                              _balanceInfo(
                                'Despesas',
                                _formatCurrency(finance.expenseInCents),
                                Icons.arrow_upward_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // TRANSAÇÕES
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Últimas transações',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF193B20),
                          ),
                        ),

                      ],
                    ),

                    const SizedBox(height: 4),

                    if (finance.loadError != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(finance.loadError!),
                            TextButton.icon(
                              onPressed: _loadTransactions,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    else if (finance.isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (finance.transactions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Text(
                          'Nenhum lançamento registrado ainda.',
                          style: TextStyle(color: Color(0xFF718071)),
                        ),
                      )
                    else
                      ...finance.transactions.reversed.map(_buildTransaction),

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
        onPressed: _addTransaction,
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
    final color = isIncome
        ? Colors.green
        : _categoryColor(transaction.category);
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

  static Widget _balanceInfo(String title, String value, IconData icon) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 17),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
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
            child: Icon(icon, color: color),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
              color: income ? const Color(0xFF4CAF58) : const Color(0xFF263526),
            ),
          ),
        ],
      ),
    );
  }
}
