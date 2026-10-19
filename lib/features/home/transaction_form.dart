import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum TransactionType { income, expense }

class FinanceTransaction {
  const FinanceTransaction({
    required this.title,
    required this.category,
    required this.amountInCents,
    required this.type,
  });

  final String title;
  final String category;
  final int amountInCents;
  final TransactionType type;

  Map<String, Object> toJson() => {
    'title': title,
    'category': category,
    'amountInCents': amountInCents,
    'type': type.name,
  };

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    return FinanceTransaction(
      title: json['title'] as String,
      category: json['category'] as String,
      amountInCents: json['amountInCents'] as int,
      type: TransactionType.values.byName(json['type'] as String),
    );
  }
}

class TransactionForm extends StatefulWidget {
  const TransactionForm({super.key});

  @override
  State<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<TransactionForm> {
  static const _expenseCategories = [
    'Alimentação',
    'Transporte',
    'Lazer',
    'Moradia',
    'Outros',
  ];
  static const _incomeCategories = [
    'Salário',
    'Renda extra',
    'Investimento',
    'Outros',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String _category = _expenseCategories.first;

  List<String> get _categories =>
      _type == TransactionType.income ? _incomeCategories : _expenseCategories;

  static int? _parseAmountInCents(String? input) {
    final value = input?.trim() ?? '';
    if (value.isEmpty) return null;

    final normalized = value.contains(',')
        ? value.replaceAll('.', '').replaceAll(',', '.')
        : value;
    final amount = double.tryParse(normalized);
    if (amount == null || !amount.isFinite || amount <= 0 || amount >= 1e12) {
      return null;
    }
    return (amount * 100).round();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amountInCents = _parseAmountInCents(_amountController.text);
    if (amountInCents == null) return;

    Navigator.of(context).pop(
      FinanceTransaction(
        title: _titleController.text.trim(),
        category: _type == TransactionType.income ? 'Receita' : _category,
        amountInCents: amountInCents,
        type: _type,
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Novo lançamento',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF193B20),
                ),
              ),
              const SizedBox(height: 20),
              SegmentedButton<TransactionType>(
                segments: const [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text('Gasto'),
                    icon: Icon(Icons.arrow_upward_rounded),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text('Receita'),
                    icon: Icon(Icons.arrow_downward_rounded),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (selection) {
                  setState(() {
                    _type = selection.first;
                    _category = _categories.first;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('transaction-description'),
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex.: Mercado, salário...',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Informe uma descrição.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('transaction-amount'),
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                  hintText: '0,00',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _parseAmountInCents(value) == null
                    ? 'Informe um valor válido maior que zero.'
                    : null,
              ),
              if (_type == TransactionType.expense) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    for (final category in _categories)
                      DropdownMenuItem(value: category, child: Text(category)),
                  ],
                  onChanged: (category) {
                    if (category != null) {
                      setState(() => _category = category);
                    }
                  },
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF58),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Salvar lançamento'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
