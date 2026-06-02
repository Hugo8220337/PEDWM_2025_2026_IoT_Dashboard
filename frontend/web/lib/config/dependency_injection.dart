import 'package:common/config/graphql_config.dart';
import 'package:common/repositories/sensor_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:mobile/pages/initial_screen/widgets/add_sensor_dialog/add_sensor_screen_view_model.dart';
import 'package:mobile/pages/initial_screen/initial_screen_viewmodel.dart';
import 'package:mobile/pages/initial_screen/widgets/time_series_side_chart/live_time_series_view_model.dart';
import 'package:mobile/repositories/preferences_repository.dart';

class DI {
  static late GetIt instance;

  static void initialize() {
    instance = GetIt.instance;

    // --- Core Services ---
    instance.registerSingleton<GraphQLClient>(
      GraphQLConfig.initializeClient(), // avoided lazySingleton because this takes a while to initialize
    );
    instance.registerSingleton(Logger());

    // --- Repositories ---
    instance.registerLazySingleton(
      () => SensorRepository(client: instance<GraphQLClient>()),
    );
    instance.registerLazySingleton(() => PreferencesRepository());

    // --- ViewModels ---
    // Uso o factory para criar uma nova instância sempre que pedir, invés de colocar um singleton e estar sempre em memória
    instance.registerFactory(
      () => InitialScreenViewmodel(
        preferencesRepository: instance<PreferencesRepository>(),
        logger: instance<Logger>(),
      ),
    );
    instance.registerFactory(
      () => AddSensorScreenViewModel(
        sensorRepository: instance<SensorRepository>(),
        logger: instance<Logger>(),
      ),
    );
    instance.registerFactory(
      () => LiveTimeSeriesViewModel(
        sensorRepository: instance<SensorRepository>(),
        logger: instance<Logger>(),
      ),
    );
  }
}
