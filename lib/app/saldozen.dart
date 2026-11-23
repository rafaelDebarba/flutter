import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../features/home/finance_provider.dart';
import '../features/home/data/transaction_template_repository.dart';
import '../features/profile/financial_profile_provider.dart';
import '../features/startup/presentation/splash_page.dart';

class SaldoZenApp extends StatelessWidget {
  const SaldoZenApp({super.key, required this.templateRepository});

  final TransactionTemplateRepository templateRepository;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<TransactionTemplateRepository>.value(value: templateRepository),
        ChangeNotifierProvider(create: (_) => FinanceProvider()),
        ChangeNotifierProvider(create: (_) => FinancialProfileProvider()),
      ],
      child: MaterialApp(
        title: 'SaldoZen',
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
      ),
    );
  }
}
