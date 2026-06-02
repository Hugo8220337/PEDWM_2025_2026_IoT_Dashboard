import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';
import 'package:mobile/config/dependency_injection.dart';
import 'package:mobile/pages/live_time_series_screen/live_time_series_view_model.dart';
import 'package:mobile/widgets/my_app_bar.dart';
import 'package:mobile/widgets/time_series_chart.dart';
import 'package:provider/provider.dart';

class LiveTimeSeriesScreen extends StatelessWidget {
  final SensorInfo sensor;
  const LiveTimeSeriesScreen({super.key, required this.sensor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(appBarTitle: sensor.sensorName),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChangeNotifierProvider(
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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (viewModel.chartData.isEmpty) {
                return const Center(
                  child: Text(
                    "No historical data available for this sensor.",
                  ),
                );
              }

              return TimeSeriesChart(
                sensorName: sensor.sensorName.toUpperCase(),
                chartData: viewModel.chartData,
              );
            },
          ),
        ),
      ),
    );
  }
}
