import 'package:flutter/foundation.dart';

import 'finance_transaction_repository.dart';
import 'transaction_form.dart';

class FinanceProvider extends ChangeNotifier {
  FinanceProvider({FinanceTransactionRepository? repository})
    : _repository = repository ?? FinanceTransactionRepository();

  final FinanceTransactionRepository _repository;
  List<FinanceTransaction> _transactions = [];
  final Set<int> _pendingFavorites = {};
  bool _disposed = false;
  bool _isLoading = true;
  bool _hasLoaded = false;
  String? _loadError;
  Future<void>? _loadingFuture;

  List<FinanceTransaction> get transactions => List.unmodifiable(_transactions);
  List<FinanceTransaction> get favoriteTransactions =>
      List.unmodifiable(_transactions.where((item) => item.isFavorite));

  bool isUpdatingFavorite(int id) => _pendingFavorites.contains(id);

  bool get isLoading => _isLoading;
  String? get loadError => _loadError;

  int get incomeInCents => _transactions
      .where((item) => item.type == TransactionType.income)
      .fold<int>(0, (sum, item) => sum + item.amountInCents);

  int get expenseInCents => _transactions
      .where((item) => item.type == TransactionType.expense)
      .fold<int>(0, (sum, item) => sum + item.amountInCents);

  int get balanceInCents => incomeInCents - expenseInCents;

  Future<void> loadTransactions() {
    if (_hasLoaded) return Future<void>.value();
    final pendingLoad = _loadingFuture;
    if (pendingLoad != null) return pendingLoad;

    _isLoading = true;
    _loadError = null;
    notifyListeners();
    final loading = _loadTransactions();
    _loadingFuture = loading;
    return loading;
  }

  Future<void> _loadTransactions() async {
    try {
      _transactions = await _repository.getTransactions();
      _hasLoaded = true;
    } catch (_) {
      _loadError = 'Não foi possível carregar seus lançamentos.';
      rethrow;
    } finally {
      _isLoading = false;
      _loadingFuture = null;
      notifyListeners();
    }
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    await loadTransactions();
    final savedTransaction = await _repository.addTransaction(transaction);
    _transactions = [..._transactions, savedTransaction];
    notifyListeners();
  }

  Future<void> toggleFavorite(int id) async {
    if (!_pendingFavorites.add(id)) return;

    try {
      final index = _transactions.indexWhere((item) => item.id == id);
      if (index == -1) throw StateError('Lançamento não encontrado: $id');
      final current = _transactions[index];
      final updated = current.withFavorite(!current.isFavorite);
      notifyListeners();
      await _repository.setFavorite(id, updated.isFavorite);
      _transactions[index] = updated;
    } finally {
      _pendingFavorites.remove(id);
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.close();
    super.dispose();
  }
}
