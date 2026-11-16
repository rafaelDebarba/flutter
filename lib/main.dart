import 'package:material_ui/material_ui.dart';

import 'app/saldozen.dart';
import 'core/database/database_factory_setup.dart';

void main() {
  configureDatabaseFactory();
  runApp(const SaldoZenApp());
}
