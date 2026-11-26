import 'package:material_ui/material_ui.dart';

import 'transaction_query.dart';

class TransactionFilters extends StatelessWidget {
  const TransactionFilters({
    super.key,
    required this.query,
    required this.categories,
    required this.searchController,
    required this.onSearch,
    required this.onChanged,
    required this.onClear,
  });

  final TransactionQuery query;
  final List<String> categories;
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final ValueChanged<TransactionQuery> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearch,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search_rounded),
            labelText: 'Buscar por descrição',
            border: OutlineInputBorder(),
            isDense: true,
          ),
        ),
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: const Icon(Icons.tune_rounded),
          title: const Text('Filtros e ordenação'),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                DropdownButton<TransactionKind>(
                  value: query.kind,
                  onChanged: (value) => onChanged(query.copyWith(kind: value)),
                  items: const [
                    DropdownMenuItem(
                      value: TransactionKind.all,
                      child: Text('Todos os tipos'),
                    ),
                    DropdownMenuItem(
                      value: TransactionKind.income,
                      child: Text('Receitas'),
                    ),
                    DropdownMenuItem(
                      value: TransactionKind.expense,
                      child: Text('Despesas'),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: query.category,
                  onChanged: (value) =>
                      onChanged(query.copyWith(category: value)),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Todas as categorias'),
                    ),
                    for (final category in categories)
                      DropdownMenuItem(value: category, child: Text(category)),
                  ],
                ),
                DropdownButton<TransactionOrder>(
                  value: query.order,
                  onChanged: (value) => onChanged(query.copyWith(order: value)),
                  items: const [
                    DropdownMenuItem(
                      value: TransactionOrder.newest,
                      child: Text('Mais recentes'),
                    ),
                    DropdownMenuItem(
                      value: TransactionOrder.highest,
                      child: Text('Maior valor'),
                    ),
                    DropdownMenuItem(
                      value: TransactionOrder.lowest,
                      child: Text('Menor valor'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        if (query.hasFilters || query.order != TransactionOrder.newest)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton(
              onPressed: onClear,
              child: const Text('Limpar filtros'),
            ),
          ),
      ],
    );
  }
}
