import 'package:app_saldozen/features/home/finance_transaction.dart';
import 'package:app_saldozen/features/home/transaction_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const transactions = [
    FinanceTransaction(
      id: 1,
      title: 'Pão',
      category: 'Alimentação',
      amountInCents: 500,
      type: TransactionType.expense,
      isFavorite: true,
    ),
    FinanceTransaction(
      id: 2,
      title: 'Pão integral',
      category: 'Alimentação',
      amountInCents: 500,
      type: TransactionType.expense,
    ),
    FinanceTransaction(
      id: 3,
      title: 'Venda de pão',
      category: 'Renda extra',
      amountInCents: 2000,
      type: TransactionType.income,
      isFavorite: true,
    ),
  ];

  test('combina busca sem acentos, tipo, categoria e favoritos', () {
    const query = TransactionQuery(
      description: ' PAO ',
      kind: TransactionKind.expense,
      category: 'Alimentação',
      favoritesOnly: true,
    );

    expect(applyTransactionQuery(transactions, query).map((item) => item.id), [
      1,
    ]);
    expect(query.copyWith(), query);
    expect(query.copyWith().hashCode, query.hashCode);
  });

  test('ordena pelo valor com desempate por ID e preserva a fonte', () {
    final source = [...transactions];
    final results = applyTransactionQuery(
      source,
      const TransactionQuery(order: TransactionOrder.lowest),
    );
    expect(results.map((item) => item.id), [2, 1, 3]);
    expect(source.map((item) => item.id), [1, 2, 3]);
  });
}
