import 'dart:async';
import 'package:common/models/sensor_data.dart';
import 'package:common/repositories/sensor_repository.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LiveTimeSeriesViewModel extends ChangeNotifier {
  final SensorRepository sensorRepository;
  final Logger logger;

  LiveTimeSeriesViewModel({
    required this.sensorRepository,
    required this.logger,
  });

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel(); // avoid memmory leaks
    super.dispose();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  List<SensorData> chartData = [];
  StreamSubscription? _subscription;

  Future<void> loadSensorData(String sensorId) async {
    isLoading = true;
    notifyListeners();

    try {
      final history = await sensorRepository.getHistoricalReadings(
        sensorId,
        30,
      );
      history.sort(
        (a, b) => a.time.compareTo(b.time),
      ); // Order Cronologically
      chartData = history;

      isLoading = false;

      // Turn on the WebSocket for future data
      _subscription = sensorRepository
          .subscribeToLiveReadings(sensorId)
          .listen((newData) {
            chartData.add(newData);
            chartData.sort((a, b) => a.time.compareTo(b.time));

            if (chartData.length > 30) {
              chartData.removeAt(0); // Limit to 30 pointns
            }

            notifyListeners();
          });
    } catch (e) {
      logger.e("Error while loading the chart data: $e");
      isLoading = false;
    }
  }
}
