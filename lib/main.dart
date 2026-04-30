import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/garagem/controller/garagem_controller.dart';
import 'features/servicos/controller/servicos_controller.dart';
import 'features/abastecimentos/controller/abastecimentos_controller.dart';
import 'features/dashboard/controller/dashboard_controller.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GaragemController()),
        ChangeNotifierProvider(create: (_) => ServicosController()),
        ChangeNotifierProvider(create: (_) => AbastecimentosController()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
      ],
      child: MaterialApp.router(
        title: 'Controle Veicular',
        theme: buildAppTheme(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        locale: const Locale('pt', 'BR'),
      ),
    );
  }
}
