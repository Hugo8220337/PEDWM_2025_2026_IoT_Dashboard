import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';
import 'package:mobile/config/dependency_injection.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/pages/initial_screen/initial_screen_viewmodel.dart';
import 'package:mobile/pages/initial_screen/widgets/time_series_side_chart/live_time_series_side_chart.dart';
import 'package:mobile/widgets/dialogs/sensor_config_dialog.dart';
import 'package:mobile/widgets/live_sensor_gauge.dart';
import 'package:mobile/widgets/my_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'package:side_panel/side_panel.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
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

      child: Scaffold(appBar: _AppBarWrapper(), body: _PageBody()),
    );
  }
}

class _AppBarWrapper extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InitialScreenViewmodel>();

    return MyAppBar(
      title: AppConstants.appName,
      activeSensors: viewModel.activeSensors,
      onSensorsAdded: (List<SensorInfo> newSensors) {
        viewModel.addSensors(newSensors);
      },
    );
  }
}

class _PageBody extends StatefulWidget {
  const _PageBody();

  @override
  State<_PageBody> createState() => _PageBodyState();
}

class _PageBodyState extends State<_PageBody> {
  final controller = SidePanelController();

  final _isOverlay = false;

  SensorInfo? _selectedSensor;

  void _showSensorConfigDialog(
    SensorInfo sensor,
    InitialScreenViewmodel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return SensorConfigDialog(
          sensor: sensor,
          initialMin: viewModel.customMins[sensor.id],
          initialMax: viewModel.customMaxs[sensor.id],

          onRemove: () {
            setState(() {
              viewModel.activeSensors.removeWhere(
                (s) => s.id == sensor.id,
              );

              viewModel.removeSensor(sensor.id);

              if (_selectedSensor?.id == sensor.id) {
                _selectedSensor = null;
                controller.hideBottomPanel();
              }
            });
          },

          onSave: (min, max) {
            setState(() {
              if (min != null && max != null) {
                viewModel.updateSensorLimits(sensor.id, min, max);
              }
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<InitialScreenViewmodel>();

    return Container(
      margin: EdgeInsets.all(40.0),
      child: SidePanel(
        controller: controller,
        bottom: Panel(
          overlay: _isOverlay,
          child: _selectedSensor == null
              ? const Center(
                  child: Text(
                    "Select a sensor to view its time series data.",
                  ),
                )
              : LiveTimeSeriesChart(
                  key: ValueKey(_selectedSensor!.id),
                  sensor: _selectedSensor!,
                  onClose: () {
                    setState(() {
                      _selectedSensor = null;
                      controller.hideBottomPanel();
                    });
                  },
                ),
        ),

        child: _SensorsData(
          sensors: viewModel.activeSensors,
          customMins: viewModel.customMins,
          customMaxs: viewModel.customMaxs,
          onSensorTap: (SensorInfo clickedSensor) {
            setState(() {
              _selectedSensor = clickedSensor;
              controller.showBottomPanel();
            });
          },
          onConfigTap: (SensorInfo clickedSensor) {
            _showSensorConfigDialog(clickedSensor, viewModel);
          },
        ),
      ),
    );
  }
}

class _SensorsData extends StatefulWidget {
  final List<SensorInfo> sensors;
  final Function(SensorInfo)? onSensorTap;
  final Function(SensorInfo)? onConfigTap;
  final Map<String, double> customMins;
  final Map<String, double> customMaxs;

  const _SensorsData({
    required this.sensors,
    this.onSensorTap,
    this.onConfigTap,
    required this.customMins,
    required this.customMaxs,
  });

  @override
  State<_SensorsData> createState() => _SensorsDataState();
}

class _SensorsDataState extends State<_SensorsData> {
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = widget.sensors.removeAt(oldIndex);
      widget.sensors.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    // If there is no sensorss, show a message instead of the grid
    if (widget.sensors.isEmpty) {
      return const Center(
        child: Text(
          "No sensors available.\nClick the '+' button to add one.",
          textAlign: TextAlign.center,
        ),
      );
    }

    return ReorderableGridView.extent(
      maxCrossAxisExtent: 250,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1,
      onReorder: _onReorder,
      children: widget.sensors.map((sensor) {
        return LiveSensorGauge(
          key: ValueKey(sensor.id),
          sensor: sensor,
          customMin: widget.customMins[sensor.id],
          customMax: widget.customMaxs[sensor.id],
          onSensorTap: () {
            if (widget.onSensorTap != null) {
              widget.onSensorTap!(sensor);
            }
          },
          onConfigTap: () {
            if (widget.onConfigTap != null) {
              widget.onConfigTap!(sensor);
            }
          },
        );
      }).toList(),
    );
  }
}
