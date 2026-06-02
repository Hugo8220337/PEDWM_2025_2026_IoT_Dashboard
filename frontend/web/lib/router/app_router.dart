import 'package:go_router/go_router.dart';
import 'package:mobile/core/constants/routes_constants.dart';
import 'package:mobile/pages/initial_screen/widgets/add_sensor_dialog/add_sensor_screen.dart';
import 'package:mobile/pages/initial_screen/initial_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RoutesConstants.initialScreenRoute,
    routes: [
      GoRoute(
        name: RoutesConstants.initialScreen,
        path: RoutesConstants.initialScreenRoute,
        builder: (context, state) => const InitialScreen(),
      ),

      GoRoute(
        name: RoutesConstants.addSensorScreen,
        path: RoutesConstants.addSensorScreenRoute,
        builder: (context, state) => const AddSensorScreen(),
      ),
    ],
  );
}
