import 'package:app_saldozen/app/saldozen.dart';
import 'package:app_saldozen/features/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('deve renderizar a splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SaldoZenApp());

    expect(find.text('Carregando...'), findsOneWidget);
  });

  testWidgets('deve navegar para a home ao finalizar o onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: OnboardingScreen(),
      ),
    );

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pumpAndSettle();

    expect(find.text('Começar agora'), findsOneWidget);

    await tester.tap(find.text('Começar agora'));
    await tester.pumpAndSettle();

    expect(find.text('Saldo disponível'), findsOneWidget);
  });
}

