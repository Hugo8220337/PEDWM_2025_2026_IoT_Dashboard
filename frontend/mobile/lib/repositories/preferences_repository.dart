import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:common/models/sensor_info.dart';

class PreferencesRepository {
  static const String _sensorsKey = 'activeSensors';

  Future<List<SensorInfo>> getActiveSensors() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_sensorsKey);
    if (str == null) return [];

    final decoded = jsonDecode(str) as List<dynamic>;
    return decoded.map((s) => SensorInfo.fromJson(s)).toList();
  }

  Future<void> saveActiveSensors(List<SensorInfo> sensors) async {
    final prefs = await SharedPreferences.getInstance();
    final sensorsJson = sensors.map((s) => s.toJson()).toList();
    await prefs.setString(_sensorsKey, jsonEncode(sensorsJson));
  }
}