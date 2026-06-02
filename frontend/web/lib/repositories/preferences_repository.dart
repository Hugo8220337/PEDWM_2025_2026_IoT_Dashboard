import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:common/models/sensor_info.dart';

class PreferencesRepository {
  static const String _minsKey = 'customMins';
  static const String _maxsKey = 'customMaxs';
  static const String _sensorsKey = 'activeSensors';

  Future<Map<String, double>> getCustomMins() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_minsKey);
    if (str == null) return {};

    final decoded = jsonDecode(str) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
  }

  Future<Map<String, double>> getCustomMaxs() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_maxsKey);
    if (str == null) return {};

    final decoded = jsonDecode(str) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );
  }

  Future<List<SensorInfo>> getActiveSensors() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_sensorsKey);
    if (str == null) return [];

    final decoded = jsonDecode(str) as List<dynamic>;
    return decoded.map((s) => SensorInfo.fromJson(s)).toList();
  }

  Future<void> saveCustomMins(Map<String, double> mins) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_minsKey, jsonEncode(mins));
  }

  Future<void> saveCustomMaxs(Map<String, double> maxs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_maxsKey, jsonEncode(maxs));
  }

  Future<void> saveActiveSensors(List<SensorInfo> sensors) async {
    final prefs = await SharedPreferences.getInstance();
    final sensorsJson = sensors.map((s) => s.toJson()).toList();
    await prefs.setString(_sensorsKey, jsonEncode(sensorsJson));
  }
}
