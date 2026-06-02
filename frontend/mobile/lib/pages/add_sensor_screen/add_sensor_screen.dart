import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';
import 'package:mobile/config/dependency_injection.dart';
import 'package:mobile/pages/add_sensor_screen/add_sensor_screen_view_model.dart';
import 'package:mobile/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';

class AddSensorScreen extends StatelessWidget {
  final List<SensorInfo> initialSelectedSensors;

  const AddSensorScreen({
    super.key,
    this.initialSelectedSensors = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewmodel = DI.instance<AddSensorScreenViewModel>();

        viewmodel.initializeSelection(initialSelectedSensors);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewmodel.getSensors();
        }); // fetch data (cannot put await)

        return viewmodel;
      },
      child: const AddSensorScreenBody(),
    );
  }
}

class AddSensorScreenBody extends StatelessWidget {
  const AddSensorScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Get viewmodel from ChangeNotifierProvider
    final viewModel = context.watch<AddSensorScreenViewModel>();

    return Scaffold(
      appBar: MyAppBar(appBarTitle: "Add Sensor"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          viewModel.saveSelectedSensors(); // update the preferences with the new selected sensors
          Navigator.pop(context);
        },
        child: const Icon(Icons.check),
      ),

      body: Column(
        children: [
          if (viewModel.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),

          if (!viewModel.isLoading && viewModel.error.isEmpty)
            _SensorsList(viewModel: viewModel),

          if (viewModel.error.isNotEmpty)
            _ErrorLabel(message: viewModel.error),
        ],
      ),
    );
  }
}

class _SensorsList extends StatelessWidget {
  const _SensorsList({required this.viewModel});

  final AddSensorScreenViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.sensors == null || viewModel.sensors!.isEmpty) {
      return const Expanded(
        child: Center(child: Text("No sensors found")),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: viewModel.sensors!.length,
        itemBuilder: (context, index) {
          final sensor = viewModel.sensors![index];
          final isSelected = viewModel.selectedSensors.contains(
            sensor,
          );

          return CheckboxListTile(
            title: Text(sensor.variableName.toUpperCase()),
            subtitle: Text('${sensor.nodeId} - ${sensor.sensorName}'),
            value: isSelected,
            onChanged: (bool? value) {
              viewModel.toggleSensor(sensor);
            },
          );
        },
      ),
    );
  }
}

class _ErrorLabel extends StatelessWidget {
  const _ErrorLabel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }
}
