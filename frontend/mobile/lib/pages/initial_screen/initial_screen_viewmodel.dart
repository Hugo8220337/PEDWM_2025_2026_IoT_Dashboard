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

  List<SensorInfo> _activeSensors = [];
  List<SensorInfo> get activeSensors => _activeSensors;

  Future<void> loadInitialData() async {
    try {
      _activeSensors = await preferencesRepository.getActiveSensors();
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
        _activeSensors.add(sensor);
      }
    }
    notifyListeners();
    await preferencesRepository.saveActiveSensors(_activeSensors);
  }

  Future<void> removeSensor(String sensorId) async {
    _activeSensors.removeWhere((s) => s.id == sensorId);

    notifyListeners();

    await Future.wait([
      preferencesRepository.saveActiveSensors(_activeSensors),
    ]);
  }
}