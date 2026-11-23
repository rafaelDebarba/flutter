
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/saldozen.dart';
import 'app/config/supabase_config.dart';
import 'core/database/database_factory_setup.dart';

Future<void> main() async {
  // Necessário antes de inicializar plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // Mantém a configuração existente do SQLite.
  configureDatabaseFactory();

  // Carrega as configurações fornecidas pelo arquivo .env.
  final config = SupabaseConfig.fromEnvironment();
  final problems = config.problems;

  if (problems.isNotEmpty) {
    throw StateError(
      'Configuração do Supabase incompleta:\n'
      '- ${problems.join('\n- ')}\n'
      'Rode com: flutter run --dart-define-from-file=.env '
      '(modelo em .env.example).',
    );
  }

  // Inicializa a conexão com o Supabase.
  await Supabase.initialize(
    url: config.normalizedUrl,
    publishableKey: config.publishableKey,
  );

  // Mantém o aplicativo SaldoZen.
  runApp(const SaldoZenApp());
}
