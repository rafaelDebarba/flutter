import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'transaction_form.dart';

class FinanceTransactionRepository {
  FinanceTransactionRepository({this.databaseName = 'saldozen.db'});

  static const _legacyTransactionsKey = 'saldozen.transactions';
  static const _migrationKey = 'legacy_transactions_imported';

  final String databaseName;
  Future<Database>? _databaseFuture;

  // Compartilha a abertura entre chamadas concorrentes.
  Future<Database> get _db => _databaseFuture ??= _openDatabase().catchError((
    Object error,
    StackTrace stackTrace,
  ) {
    _databaseFuture = null;
    Error.throwWithStackTrace(error, stackTrace);
  });

  Future<Database> _openDatabase() async {
    final databasesPath = await getDatabasesPath();
    return openDatabase(
      path.join(databasesPath, databaseName),
      version: 2,
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute(
            'ALTER TABLE transactions ADD COLUMN isFavorite INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            amountInCents INTEGER NOT NULL,
            type TEXT NOT NULL,
            isFavorite INTEGER NOT NULL DEFAULT 0
          )
        ''');
        await database.execute('''
          CREATE TABLE metadata (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<FinanceTransaction>> getTransactions() async {
    final database = await _db;
    await _importLegacyTransactions(database);
    final rows = await database.query('transactions', orderBy: 'id ASC');
    return rows.map(_fromRow).toList();
  }

  Future<FinanceTransaction> addTransaction(
    FinanceTransaction transaction,
  ) async {
    final database = await _db;
    final id = await database.insert('transactions', {
      'title': transaction.title,
      'category': transaction.category,
      'amountInCents': transaction.amountInCents,
      'type': transaction.type.name,
      'isFavorite': transaction.isFavorite ? 1 : 0,
    });
    return transaction.withId(id);
  }

  Future<void> setFavorite(int id, bool isFavorite) async {
    final database = await _db;
    final updated = await database.update(
      'transactions',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
    if (updated != 1) throw StateError('Lançamento não encontrado: $id');
  }

  Future<void> _importLegacyTransactions(Database database) async {
    final imported = await database.query(
      'metadata',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [_migrationKey],
      limit: 1,
    );
    if (imported.isNotEmpty) return;

    final preferences = await SharedPreferences.getInstance();
    final encodedTransactions =
        preferences.getStringList(_legacyTransactionsKey) ?? [];
    final legacyTransactions = encodedTransactions
        .map(
          (value) => FinanceTransaction.fromJson(
            jsonDecode(value) as Map<String, dynamic>,
          ),
        )
        .toList();

    await database.transaction((transaction) async {
      for (final item in legacyTransactions) {
        await transaction.insert('transactions', {
          'title': item.title,
          'category': item.category,
          'amountInCents': item.amountInCents,
          'type': item.type.name,
          'isFavorite': item.isFavorite ? 1 : 0,
        });
      }
      await transaction.insert('metadata', {
        'key': _migrationKey,
        'value': 'true',
      });
    });
  }

  FinanceTransaction _fromRow(Map<String, Object?> row) {
    return FinanceTransaction(
      id: row['id'] as int,
      isFavorite: row['isFavorite'] == 1,
      title: row['title'] as String,
      category: row['category'] as String,
      amountInCents: row['amountInCents'] as int,
      type: TransactionType.values.byName(row['type'] as String),
    );
  }

  Future<void> close() async {
    final pending = _databaseFuture;
    _databaseFuture = null;
    if (pending != null) {
      final database = await pending;
      await database.close();
    }
  }
}
