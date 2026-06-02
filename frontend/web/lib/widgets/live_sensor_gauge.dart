import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/widgets/charts/sensor_gauge.dart';

class SensorConfig {
  final double min;
  final double max;
  final String unit;

  const SensorConfig(this.min, this.max, this.unit);
}

class LiveSensorGauge extends StatelessWidget {
  final SensorInfo sensor;
  final VoidCallback? onSensorTap;
  final double? customMin;
  final double? customMax;
  final VoidCallback? onConfigTap;

  const LiveSensorGauge({
    super.key,
    required this.sensor,
    this.onSensorTap,
    this.customMin,
    this.customMax,
    this.onConfigTap,
  });

  @override
  Widget build(BuildContext context) {
    const String liveReadingsSubscription = r'''
      subscription LiveReadings($sensorId: String!) {
        liveReadings(sensorId: $sensorId) {
          id
          sensorId
          timestamp
          value
        }
      }
    ''';

    final config = _getConfig(sensor.variableName);
    final finalMin = customMin ?? config.min;
    final finalMax = customMax ?? config.max;

    return Subscription(
      options: SubscriptionOptions(
        document: gql(liveReadingsSubscription),
        variables: {'sensorId': sensor.id},
      ),
      builder:
          (
            QueryResult result, {
            VoidCallback? refetch,
            FetchMore? fetchMore,
          }) {
            double currentValue = 0.0;

            // Extract and format value
            if (result.data != null &&
                result.data!['liveReadings'] != null) {
              double rawValue =
                  (result.data!['liveReadings']['value'] as num)
                      .toDouble();

              currentValue = double.parse(
                rawValue.toStringAsFixed(1),
              );
            }

            if (result.hasException) {
              debugPrint(
                "Erro no WebSocket: ${result.exception.toString()}",
              );
            }

            return SensorGauge(
              name: sensor.variableName.toUpperCase(),
              value: currentValue,
              measureUnit: config.unit,
              min: finalMin,
              max: finalMax,
              onPressed: onSensorTap,
              onConfigPressed: onConfigTap,
            );
          },
    );
  }

  SensorConfig _getConfig(String variableName) {
    final name = variableName.toLowerCase();

    if (name.contains('temp')) {
      return const SensorConfig(
        0,
        50,
        'ºC',
      ); // Green in the middle, red at the end
    }

    if (name.contains('hum')) {
      return const SensorConfig(0, 100, '%'); // Green in the middle
    }

    if (name.contains('co2')) {
      return const SensorConfig(
        400,
        2500,
        'ppm',
      ); // Green at the beginning, red at the end
    }

    if (name.contains('o2')) return const SensorConfig(0, 25, '%');

    if (name.contains('heart')) {
      return const SensorConfig(40, 180, 'BPM');
    }

    // Configuração genérica de segurança
    return const SensorConfig(0, 100, '');
  }
}
