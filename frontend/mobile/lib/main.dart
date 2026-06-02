import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/config/dependency_injection.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/pages/initial_screen/initial_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega variáveis de ambiente e configuração de localização antes da app.
  await dotenv.load(fileName: ".env");
  await EasyLocalization.ensureInitialized();

  // Inicializa o GetIt
  DI.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('pt')],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      child: SensorDashboard(),
    ),
  );
}

class SensorDashboard extends StatelessWidget {
  SensorDashboard({super.key});

  final client = ValueNotifier(DI.instance<GraphQLClient>());

  @override
  Widget build(BuildContext context) {
    // Need GraphQLProvider at the root of the app to be able to use GraphQL subscriptions inside SensorGauge (cannot be in the DI).
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        // Estas três linhas ligam o EasyLocalization ao MaterialApp
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        home: const InitialScreen(),
      ),
    );
  }
}
