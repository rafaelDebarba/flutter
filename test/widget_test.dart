import 'package:app_academia/app/gerenciador_treino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('deve renderizar a splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const GerenciadorTreinoApp());

    expect(find.text('Carregando...'), findsOneWidget);
  });
}

