import 'finance_transaction.dart';

enum TransactionKind { all, income, expense }

enum TransactionOrder { newest, highest, lowest }

class TransactionQuery {
  const TransactionQuery({
    this.description = '',
    this.favoritesOnly = false,
    this.kind = TransactionKind.all,
    this.category = '',
    this.order = TransactionOrder.newest,
  });

  final String description;
  final bool favoritesOnly;
  final TransactionKind kind;
  final String category;
  final TransactionOrder order;

  bool get hasFilters =>
      description.trim().isNotEmpty ||
      favoritesOnly ||
      kind != TransactionKind.all ||
      category.isNotEmpty;

  TransactionQuery copyWith({
    String? description,
    bool? favoritesOnly,
    TransactionKind? kind,
    String? category,
    TransactionOrder? order,
  }) => TransactionQuery(
    description: description ?? this.description,
    favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    kind: kind ?? this.kind,
    category: category ?? this.category,
    order: order ?? this.order,
  );

  @override
  bool operator ==(Object other) =>
      other is TransactionQuery &&
      description == other.description &&
      favoritesOnly == other.favoritesOnly &&
      kind == other.kind &&
      category == other.category &&
      order == other.order;

  @override
  int get hashCode =>
      Object.hash(description, favoritesOnly, kind, category, order);
}

List<FinanceTransaction> applyTransactionQuery(
  Iterable<FinanceTransaction> transactions,
  TransactionQuery query,
) {
  final search = _normalize(query.description);
  final type = switch (query.kind) {
    TransactionKind.all => null,
    TransactionKind.income => TransactionType.income,
    TransactionKind.expense => TransactionType.expense,
  };
  return transactions
      .where(
        (item) =>
            (!query.favoritesOnly || item.isFavorite) &&
            (type == null || item.type == type) &&
            (query.category.isEmpty || item.category == query.category) &&
            _normalize(item.title).contains(search),
      )
      .toList()
    ..sort((a, b) {
      final byValue = switch (query.order) {
        TransactionOrder.newest => 0,
        TransactionOrder.highest => b.amountInCents.compareTo(a.amountInCents),
        TransactionOrder.lowest => a.amountInCents.compareTo(b.amountInCents),
      };
      return byValue == 0 ? (b.id ?? 0).compareTo(a.id ?? 0) : byValue;
    });
}

String _normalize(String value) => value
    .trim()
    .toLowerCase()
    .replaceAll(RegExp('[àáâãä]'), 'a')
    .replaceAll(RegExp('[èéêë]'), 'e')
    .replaceAll(RegExp('[ìíîï]'), 'i')
    .replaceAll(RegExp('[òóôõö]'), 'o')
    .replaceAll(RegExp('[ùúûü]'), 'u')
    .replaceAll('ç', 'c')
    .replaceAll(RegExp(r'[̀-ͯ]'), '');
