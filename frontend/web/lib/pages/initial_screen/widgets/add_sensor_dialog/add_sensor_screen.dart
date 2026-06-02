import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';
import 'package:mobile/config/dependency_injection.dart';
import 'package:mobile/pages/initial_screen/widgets/add_sensor_dialog/add_sensor_screen_view_model.dart';
import 'package:provider/provider.dart';

class AddSensorScreen extends StatelessWidget {
  const AddSensorScreen({
    super.key,
    this.initialSelectedSensors = const [],
  });

  final List<SensorInfo> initialSelectedSensors;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewmodel = DI.instance<AddSensorScreenViewModel>();

        // inject already selected sensors to the viewmodel, so they can be shown as selected in the list
        viewmodel.initializeSelection(initialSelectedSensors);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewmodel.getSensors();
        }); // fetch data (cannot put await)

        return viewmodel;
      },
      child: Dialog(child: const AddSensorScreenBody()),
    );
  }
}

class AddSensorScreenBody extends StatelessWidget {
  const AddSensorScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    // Get viewmodel from ChangeNotifierProvider
    final viewModel = context.watch<AddSensorScreenViewModel>();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          if (viewModel.isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),

          if (!viewModel.isLoading && viewModel.error.isEmpty)
            _SensorsList(viewModel: viewModel),

          if (viewModel.error.isNotEmpty)
            _ErrorLabel(message: viewModel.error),

          _ActionButtons(
            onClose: () => Navigator.pop(context),
            // Pass selected sensors back to previous screen!
            onSave: () => Navigator.pop(
              context,
              viewModel.selectedSensors.toList(),
            ),
          ),
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
        child: Center(child: Text("No sensors available.")),
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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onSave, required this.onClose});

  final Function onSave;
  final Function onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                onClose();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Colors.transparent,
                ),
              ),
              child: Text(
                "Close",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          Expanded(
            child: ElevatedButton(
              onPressed: () {
                onSave();
              },
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  Theme.of(context).primaryColor,
                ),
              ),
              child: Text(
                "Save",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ],
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
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }
}
