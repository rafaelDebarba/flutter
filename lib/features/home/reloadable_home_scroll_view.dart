import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import 'reload_page_stub.dart'
    if (dart.library.js_interop) 'reload_page_web.dart';

class ReloadableHomeScrollView extends StatelessWidget {
  const ReloadableHomeScrollView({
    super.key,
    required this.slivers,
    this.onRefresh,
  });

  final List<Widget> slivers;
  final RefreshCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && onRefresh == null) {
      return CustomScrollView(slivers: slivers);
    }

    final behavior = ScrollConfiguration.of(context);
    return RefreshIndicator(
      semanticsLabel: 'Recarregar página',
      onRefresh: onRefresh ?? reloadPage,
      child: CustomScrollView(
        scrollBehavior: behavior.copyWith(
          dragDevices: {...behavior.dragDevices, PointerDeviceKind.mouse},
        ),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: slivers,
      ),
    );
  }
}
