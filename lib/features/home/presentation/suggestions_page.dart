import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../data/transaction_template_json.dart';
import '../data/transaction_template_repository.dart';

/// Catálogo de exemplos financeiros; não exibe dados pessoais do SQLite.
class SuggestionsPage extends StatefulWidget {
  const SuggestionsPage({super.key});

  @override
  State<SuggestionsPage> createState() => _SuggestionsPageState();
}

class _SuggestionsPageState extends State<SuggestionsPage> {
  Future<List<TransactionTemplate>>? _templates;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _templates ??= context.read<TransactionTemplateRepository>().getTemplates();
  }

  void _reload() {
    setState(() {
      _templates = context.read<TransactionTemplateRepository>().getTemplates();
    });
  }

  static String _money(int cents) {
    final value = (cents / 100).toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $value';
  }

  void _openDetails(TransactionTemplate item) {
    final repository = context.read<TransactionTemplateRepository>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.75,
          child: FutureBuilder<TransactionTemplate?>(
            future: repository.getTemplateById(item.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Não foi possível carregar os detalhes.'),
                  ),
                );
              }
              final template = snapshot.data;
              if (template == null) {
                return const Center(child: Text('Sugestão não encontrada.'));
              }
              final details = template.details;
              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 30),
                children: [
                  Text(template.title,
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text('Valor ilustrativo: ${_money(template.suggestedAmountCents)}'),
                  const SizedBox(height: 16),
                  if (details != null) ...[
                    Text(details.description),
                    const SizedBox(height: 12),
                    Text('Dica de orçamento: ${details.budgetingTip}'),
                    if (details.exampleNotes != null) ...[
                      const SizedBox(height: 8),
                      Text(details.exampleNotes!),
                    ],
                  ],
                  if (template.tips.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Dicas', style: Theme.of(context).textTheme.titleMedium),
                    for (final tip in template.tips)
                      ListTile(
                        leading: const Icon(Icons.tips_and_updates_outlined),
                        title: Text(tip.tipText),
                      ),
                  ],
                  for (final image in template.images)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Image.network(
                        image.imageUrl,
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sugestões'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _reload,
            tooltip: 'Atualizar sugestões',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<TransactionTemplate>>(
        future: _templates,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_outlined, size: 48),
                    const SizedBox(height: 12),
                    const Text('Não foi possível carregar as sugestões.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }
          final templates = snapshot.data ?? [];
          if (templates.isEmpty) {
            return const Center(
              child: Text('Nenhuma sugestão encontrada no catálogo.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Exemplos para organizar suas finanças',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Valores ilustrativos, não são seus lançamentos.'),
              const SizedBox(height: 14),
              for (final item in templates)
                Card(
                  child: ListTile(
                    leading: item.imageUrl == null
                        ? Icon(
                            item.transactionType == TemplateTransactionType.income
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                          )
                        : Image.network(
                            item.imageUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.receipt_long_outlined),
                          ),
                    title: Text(item.title),
                    subtitle: Text(item.category.name),
                    trailing: Text(_money(item.suggestedAmountCents)),
                    onTap: () => _openDetails(item),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 1,
        onDestinationSelected: (index) {
          if (index == 0) Navigator.of(context).pop();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Sugestões',
          ),
        ],
      ),
    );
  }
}
