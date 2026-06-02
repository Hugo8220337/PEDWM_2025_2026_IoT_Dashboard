import 'package:common/models/sensor_info.dart';
import 'package:common/repositories/sensor_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';

class AddSensorScreenViewModel extends ChangeNotifier {
  AddSensorScreenViewModel({
    required this.sensorRepository,
    required this.logger,
  });

  final SensorRepository sensorRepository;
  final Logger logger;

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
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

  String _error = "";
  String get error => _error;
  set error(String value) {
    _error = value;
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Store real objects
  List<SensorInfo>? _sensors;
  List<SensorInfo>? get sensors => _sensors;

  // List to mantain the state of what's selected
  final Set<SensorInfo> _selectedSensors = {};
  Set<SensorInfo> get selectedSensors => _selectedSensors;

  void toggleSensor(SensorInfo sensor) {
    if (_selectedSensors.contains(sensor)) {
      _selectedSensors.remove(sensor);
    } else {
      _selectedSensors.add(sensor);
    }
    if (!_isDisposed) notifyListeners();
  }

  void initializeSelection(List<SensorInfo> alreadySelected) {
    _selectedSensors.clear();
    _selectedSensors.addAll(alreadySelected);
  }

  Future<void> getSensors() async {
    isLoading = true;
    error = "";

    try {
      _sensors = await sensorRepository.getSensors();
    } catch (e) {
      logger.e("An error occured while fetching sensors: $e");
      error = "Erro ao carregar sensores: $e";
    } finally {
      isLoading = false;
    }
  }
}
