enum TransactionType { income, expense }

class FinanceTransaction {
  const FinanceTransaction({
    this.id,
    this.isFavorite = false,
    required this.title,
    required this.category,
    required this.amountInCents,
    required this.type,
  });

  final int? id;
  final bool isFavorite;
  final String title;
  final String category;
  final int amountInCents;
  final TransactionType type;

  FinanceTransaction withId(int id) => FinanceTransaction(
    id: id,
    isFavorite: isFavorite,
    title: title,
    category: category,
    amountInCents: amountInCents,
    type: type,
  );

  FinanceTransaction withFavorite(bool isFavorite) => FinanceTransaction(
    id: id,
    title: title,
    category: category,
    amountInCents: amountInCents,
    type: type,
    isFavorite: isFavorite,
  );

  Map<String, Object> toJson() => {
    'title': title,
    'category': category,
    'amountInCents': amountInCents,
    'type': type.name,
    'isFavorite': isFavorite,
  };

  factory FinanceTransaction.fromJson(Map<String, dynamic> json) {
    return FinanceTransaction(
      isFavorite: json['isFavorite'] == true,
      title: json['title'] as String,
      category: json['category'] as String,
      amountInCents: json['amountInCents'] as int,
      type: TransactionType.values.byName(json['type'] as String),
    );
  }
}
