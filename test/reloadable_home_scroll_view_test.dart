import 'dart:ui' show PointerDeviceKind;

import 'package:app_saldozen/features/home/reloadable_home_scroll_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('arrastar com o mouse recarrega mesmo com lista curta', (
    tester,
  ) async {
    var refreshCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReloadableHomeScrollView(
            onRefresh: () async {
              refreshCount++;
            },
            slivers: const [SliverToBoxAdapter(child: Text('Transações'))],
          ),
        ),
      ),
    );

    await tester.dragFrom(
      const Offset(250, 100),
      const Offset(0, -250),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(refreshCount, 0);

    await tester.dragFrom(
      const Offset(250, 100),
      const Offset(0, 300),
      kind: PointerDeviceKind.mouse,
    );
    await tester.pumpAndSettle();
    expect(refreshCount, 1);
  });
}
