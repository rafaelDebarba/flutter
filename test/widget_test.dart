import 'dart:async';
import 'dart:convert';

import 'package:app_saldozen/app/saldozen.dart';
import 'package:app_saldozen/features/home/home_page.dart';
import 'package:app_saldozen/features/home/finance_provider.dart';
import 'package:app_saldozen/features/home/finance_transaction_repository.dart';
import 'package:app_saldozen/features/onboarding/onboarding_screen.dart';
import 'package:app_saldozen/features/home/transaction_form.dart';
import 'package:app_saldozen/features/profile/financial_profile_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  var databaseNumber = 0;
  String nextDatabaseName() =>
      'saldozen_test_${DateTime.now().microsecondsSinceEpoch}_${databaseNumber++}.db';

  Widget withProviders(
    Widget child,
    String databaseName, {
    FinanceProvider? financeProvider,
  }) {
    return MultiProvider(
      providers: [
        if (financeProvider == null)
          ChangeNotifierProvider(
            create: (_) => FinanceProvider(
              repository: _MemoryFinanceTransactionRepository(databaseName),
            ),
          )
        else
          ChangeNotifierProvider<FinanceProvider>.value(value: financeProvider),
        ChangeNotifierProvider(create: (_) => FinancialProfileProvider()),
      ],
      child: MaterialApp(home: child),
    );
  }

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('migra os lançamentos legados para SQLite apenas uma vez', () async {
    final transaction = FinanceTransaction(
      title: 'Conta de luz',
      category: 'Moradia',
      amountInCents: 15990,
      type: TransactionType.expense,
    );
    SharedPreferences.setMockInitialValues({
      'saldozen.transactions': [jsonEncode(transaction.toJson())],
    });
    final databaseName = nextDatabaseName();

    final firstRepository = FinanceTransactionRepository(
      databaseName: databaseName,
    );
    expect(await firstRepository.getTransactions(), hasLength(1));
    await firstRepository.close();

    final reopenedRepository = FinanceTransactionRepository(
      databaseName: databaseName,
    );
    final loaded = await reopenedRepository.getTransactions();
    expect(loaded, hasLength(1));
    expect(loaded.single.title, 'Conta de luz');
    await reopenedRepository.close();
  });

  test('salva e recupera lançamentos do SQLite', () async {
    final databaseName = nextDatabaseName();
    final repository = FinanceTransactionRepository(databaseName: databaseName);
    await repository.getTransactions();
    final saved = await repository.addTransaction(
      const FinanceTransaction(
        title: 'Freelance',
        category: 'Receita',
        amountInCents: 100000,
        type: TransactionType.income,
      ),
    );
    expect(saved.id, isNotNull);
    await repository.close();

    final reopenedRepository = FinanceTransactionRepository(
      databaseName: databaseName,
    );
    final loaded = await reopenedRepository.getTransactions();
    expect(loaded, hasLength(1));
    expect(loaded.single.title, 'Freelance');
    expect(loaded.single.amountInCents, 100000);
    await reopenedRepository.close();
  });

  testWidgets('deve renderizar a splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SaldoZenApp());

    expect(find.byType(Image), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(
      image.image,
      isA<AssetImage>().having(
        (asset) => asset.assetName,
        'assetName',
        'assets/images/app_icon.png',
      ),
    );
    expect(image.width, 220);
    expect(find.text('Carregando...'), findsOneWidget);
  });

  testWidgets('deve navegar para a home ao finalizar o onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      withProviders(OnboardingScreen(), nextDatabaseName()),
    );

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Começar agora'), findsOneWidget);

    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('profile-name')), 'Ana');
    await tester.tap(find.byKey(const Key('profile-financial-focus')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Economizar'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byType(SwitchListTile));
    await tester.tap(find.byType(SwitchListTile));
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Saldo disponível'), findsOneWidget);
    expect(find.text('Olá, Ana 👋'), findsOneWidget);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('saldozen.profile.focus'), 'Economizar');
    expect(preferences.getBool('saldozen.profile.reminders'), isFalse);
  });

  testWidgets('deve ir para a home ao pular o onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      withProviders(OnboardingScreen(), nextDatabaseName()),
    );

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('profile-name')), 'Joana');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Saldo disponível'), findsOneWidget);
  });

  testWidgets('permite abrir o formulário durante o carregamento', (
    WidgetTester tester,
  ) async {
    final databaseName = nextDatabaseName();
    final repository = _PendingLoadRepository(databaseName);
    final financeProvider = FinanceProvider(repository: repository);
    await tester.pumpWidget(
      withProviders(
        const HomePage(),
        databaseName,
        financeProvider: financeProvider,
      ),
    );

    expect(financeProvider.isLoading, isTrue);
    expect(
      tester
          .widget<FloatingActionButton>(find.byType(FloatingActionButton))
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.byTooltip('Adicionar receita ou gasto'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Novo lançamento'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('transaction-description')),
      'Durante o carregamento',
    );
    await tester.enterText(
      find.byKey(const Key('transaction-amount')),
      '12,00',
    );
    await tester.ensureVisible(find.text('Salvar lançamento'));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Salvar lançamento'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(repository.savedTransaction, isNull);

    repository.completeLoad();
    await tester.pumpAndSettle();
    expect(repository.savedTransaction?.title, 'Durante o carregamento');
    expect(financeProvider.balanceInCents, -1200);
    await tester.pumpWidget(const SizedBox.shrink());
    financeProvider.dispose();
  });

  testWidgets('deve adicionar e manter receitas e gastos salvos', (
    WidgetTester tester,
  ) async {
    final databaseName = nextDatabaseName();
    final financeProvider = FinanceProvider(
      repository: _MemoryFinanceTransactionRepository(databaseName),
    );
    await tester.pumpWidget(
      withProviders(
        const HomePage(),
        databaseName,
        financeProvider: financeProvider,
      ),
    );
    await tester.pumpAndSettle();
    expect(financeProvider.isLoading, isFalse);

    await tester.tap(find.byTooltip('Adicionar receita ou gasto'));
    await tester.pumpAndSettle();
    expect(find.text('Novo lançamento'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('transaction-description')),
      'Farmácia',
    );
    await tester.enterText(
      find.byKey(const Key('transaction-amount')),
      '25,50',
    );
    await tester.tap(find.text('Salvar lançamento'));
    await tester.pumpAndSettle();

    expect(financeProvider.incomeInCents, 0);
    expect(financeProvider.expenseInCents, 2550);
    expect(financeProvider.balanceInCents, -2550);
    expect(find.text('- R\$ 25,50'), findsAtLeastNWidgets(2));
    expect(find.text('R\$ 25,50'), findsAtLeastNWidgets(1));

    await tester.tap(find.byTooltip('Adicionar receita ou gasto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Receita'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('transaction-description')),
      'Freelance',
    );
    await tester.enterText(
      find.byKey(const Key('transaction-amount')),
      '1.000',
    );
    await tester.tap(find.text('Salvar lançamento'));
    await tester.pumpAndSettle();

    expect(financeProvider.incomeInCents, 100000);
    expect(financeProvider.expenseInCents, 2550);
    expect(financeProvider.balanceInCents, 97450);
    expect(find.text('+ R\$ 1.000,00'), findsOneWidget);
    expect(find.text('R\$ 1.000,00'), findsAtLeastNWidgets(1));
    expect(find.text('R\$ 974,50'), findsOneWidget);

    final reopenedFinanceProvider = FinanceProvider(
      repository: _MemoryFinanceTransactionRepository(databaseName),
    );
    await tester.pumpWidget(
      withProviders(
        const HomePage(key: ValueKey('reopened-home')),
        databaseName,
        financeProvider: reopenedFinanceProvider,
      ),
    );
    await tester.pumpAndSettle();

    expect(reopenedFinanceProvider.transactions, hasLength(2));
    expect(find.text('Farmácia'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
    expect(find.text('R\$ 974,50'), findsOneWidget);
  });
}

class _MemoryFinanceTransactionRepository extends FinanceTransactionRepository {
  _MemoryFinanceTransactionRepository(String databaseName)
    : _storedTransactions = _transactionsByDatabase.putIfAbsent(
        databaseName,
        () => [],
      ),
      super(databaseName: databaseName);

  static final Map<String, List<FinanceTransaction>> _transactionsByDatabase =
      {};
  final List<FinanceTransaction> _storedTransactions;

  @override
  Future<List<FinanceTransaction>> getTransactions() async =>
      List.of(_storedTransactions);

  @override
  Future<FinanceTransaction> addTransaction(
    FinanceTransaction transaction,
  ) async {
    final savedTransaction = transaction.withId(_storedTransactions.length + 1);
    _storedTransactions.add(savedTransaction);
    return savedTransaction;
  }

  @override
  Future<void> close() async {}
}

class _PendingLoadRepository extends FinanceTransactionRepository {
  _PendingLoadRepository(String databaseName)
    : super(databaseName: databaseName);

  final _loadedTransactions = Completer<List<FinanceTransaction>>();
  FinanceTransaction? savedTransaction;

  @override
  Future<List<FinanceTransaction>> getTransactions() =>
      _loadedTransactions.future;

  void completeLoad() => _loadedTransactions.complete([]);

  @override
  Future<FinanceTransaction> addTransaction(
    FinanceTransaction transaction,
  ) async {
    savedTransaction = transaction.withId(1);
    return savedTransaction!;
  }

  @override
  Future<void> close() async {}
}
