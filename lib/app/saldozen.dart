import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../features/home/finance_provider.dart';
import '../features/profile/financial_profile_provider.dart';
import '../features/startup/presentation/splash_page.dart';

class SaldoZenApp extends StatelessWidget {
  const SaldoZenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
