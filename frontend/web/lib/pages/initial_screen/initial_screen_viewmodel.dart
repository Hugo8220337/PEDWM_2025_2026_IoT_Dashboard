import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:mobile/repositories/preferences_repository.dart';

class InitialScreenViewmodel extends ChangeNotifier {
  final PreferencesRepository preferencesRepository;
  final Logger logger;

  InitialScreenViewmodel({
    required this.preferencesRepository,
    required this.logger,
  });

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    _isLoading = value;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  List<SensorInfo> activeSensors = [];
  Map<String, double> customMins = {};
  Map<String, double> customMaxs = {};

  Future<void> loadInitialData() async {
    try {
      activeSensors = await preferencesRepository.getActiveSensors();
      customMins = await preferencesRepository.getCustomMins();
      customMaxs = await preferencesRepository.getCustomMaxs();
    } catch (e) {
      logger.e("Error while loading initial data: $e");
    } finally {
      isLoading = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  Future<void> addSensors(List<SensorInfo> newSensors) async {
    for (var sensor in newSensors) {
      if (!activeSensors.any((s) => s.id == sensor.id)) {
        activeSensors.add(sensor);
      }
    }
    notifyListeners();
    await preferencesRepository.saveActiveSensors(activeSensors);
  }

  Future<void> removeSensor(String sensorId) async {
    activeSensors.removeWhere((s) => s.id == sensorId);
    customMins.remove(sensorId);
    customMaxs.remove(sensorId);

    notifyListeners();

    await Future.wait([
      preferencesRepository.saveActiveSensors(activeSensors),
      preferencesRepository.saveCustomMins(customMins),
      preferencesRepository.saveCustomMaxs(customMaxs),
    ]);
  }

  Future<void> updateSensorLimits(
    String sensorId,
    double? min,
    double? max,
  ) async {
    if (min != null) customMins[sensorId] = min;
    if (max != null) customMaxs[sensorId] = max;

    notifyListeners();

    await Future.wait([
      preferencesRepository.saveCustomMins(customMins),
      preferencesRepository.saveCustomMaxs(customMaxs),
    ]);
  }
}
