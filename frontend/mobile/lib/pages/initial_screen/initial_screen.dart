import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';
import 'package:mobile/config/dependency_injection.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/pages/add_sensor_screen/add_sensor_screen.dart';
import 'package:mobile/pages/initial_screen/initial_screen_viewmodel.dart';
import 'package:mobile/pages/live_time_series_screen/live_time_series_screen.dart';
import 'package:mobile/widgets/live_sensor_wrapper.dart';
import 'package:mobile/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class InitialScreen extends StatelessWidget {
  const InitialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        final viewModel = DI.instance<InitialScreenViewmodel>();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.loadInitialData();
        });
        return viewModel;
      },
      child: Scaffold(
        appBar: MyAppBar(appBarTitle: AppConstants.appName),
        floatingActionButton: _AddSensorButton(),
        body: _Body(),
      ),
    );
  }
}

class _AddSensorButton extends StatelessWidget {
  const _AddSensorButton();


  @override
  Widget build(BuildContext context) {
  final viewModel = context.watch<InitialScreenViewmodel>();

    return FloatingActionButton(
          onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddSensorScreen(
                    initialSelectedSensors: viewModel.activeSensors,
                  ),
                ),
              );

              // update screen when coming back from AddSensorScreen, in case the user added/removed sensors
              viewModel.loadInitialData();
          },
          tooltip: "Add Sensor",
          child: const Icon(Icons.add),
        );
  }
}
class _Body extends StatelessWidget {
  const _Body();


  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InitialScreenViewmodel>();
    
    return Container(
      margin: EdgeInsets.all(50.0),
      child: _SensorsData(sensors: viewModel.activeSensors),
    );
  }
}

class _SensorsData extends StatelessWidget {
  final List<SensorInfo> sensors;

  const _SensorsData({required this.sensors});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cards per line
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.0, // Perfect square cards
      ),
      itemCount: sensors.length,
      itemBuilder: (context, index) {
        final sensor = sensors[index];

        return LiveSensorWrapper(
          sensor: sensor,
          onSensorTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => LiveTimeSeriesScreen(sensor: sensor),
            ),
          ),
        );
      },
    );
  }
}
