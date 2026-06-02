import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';
import 'package:mobile/config/dependency_injection.dart';
import 'package:mobile/pages/initial_screen/widgets/time_series_side_chart/live_time_series_view_model.dart';
import 'package:mobile/widgets/charts/time_series_chart.dart';
import 'package:provider/provider.dart';

class LiveTimeSeriesChart extends StatelessWidget {
  final SensorInfo sensor;
  final VoidCallback onClose;

  const LiveTimeSeriesChart({
    super.key,
    required this.sensor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = DI.instance<LiveTimeSeriesViewModel>();

        // get the historical data and start the WebSocket subscription
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.loadSensorData(sensor.id);
        });

        return viewModel;
      },
      child: Consumer<LiveTimeSeriesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.chartData.isEmpty) {
            return const Center(
              child: Text("No historical data available."),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              TimeSeriesChart(
                sensorName: sensor.variableName.toUpperCase(),
                chartData: viewModel.chartData,
              ),

              _CloseButton(onClose: onClose),
            ],
          );
        },
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      right: 0,
      child: IconButton(
        onPressed: onClose,
        icon: Icon(Icons.close),
        tooltip: 'Close Chart',
        splashRadius: 20,
      ),
    );
  }
}
