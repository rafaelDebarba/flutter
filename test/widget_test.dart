import 'package:app_saldozen/app/saldozen.dart';
import 'package:app_saldozen/features/home/home_page.dart';
import 'package:app_saldozen/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

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
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Começar agora'), findsOneWidget);

    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();

    expect(find.text('Saldo disponível'), findsOneWidget);
  });

  testWidgets('deve ir para a home ao pular o onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();

    expect(find.text('Saldo disponível'), findsOneWidget);
  });

  testWidgets('deve adicionar e manter receitas e gastos salvos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Adicionar receita ou gasto'));
    await tester.pumpAndSettle();

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

    expect(find.text('- R\$ 25,50'), findsOneWidget);
    expect(find.text('R\$ 1.375,50'), findsAtLeastNWidgets(1));
    expect(find.text('R\$ 4.824,50'), findsOneWidget);

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
      '1.000,00',
    );
    await tester.tap(find.text('Salvar lançamento'));
    await tester.pumpAndSettle();

    expect(find.text('+ R\$ 1.000,00'), findsOneWidget);
    expect(find.text('R\$ 7.200,00'), findsOneWidget);
    expect(find.text('R\$ 5.824,50'), findsOneWidget);

    await tester.pumpWidget(const MaterialApp(home: HomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Farmácia'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
    expect(find.text('R\$ 5.824,50'), findsOneWidget);
  });
}
