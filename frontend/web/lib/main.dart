import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/config/dependency_injection.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();

  // Initialize GetIt
  DI.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('pt')],
      fallbackLocale: const Locale('en'),
      path: 'assets/translations',
      child: const SensorDashboard(),
    ),
  );
}

class SensorDashboard extends StatelessWidget {
  const SensorDashboard({super.key, this.currentMode});

  final dynamic currentMode;

  @override
  Widget build(BuildContext context) {
    final client = ValueNotifier(DI.instance<GraphQLClient>());

    // Need GraphQLProvider at the root of the app to be able to use GraphQL subscriptions inside SensorGauge (cannot be in the DI).
    return GraphQLProvider(
      client: client,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppTheme.themeNotifier,
        builder: (_, ThemeMode currentMode, _) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: currentMode,

            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,

            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
