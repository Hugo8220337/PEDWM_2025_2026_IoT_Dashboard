import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile/widgets/sensor_card.dart';

class LiveSensorWrapper extends StatelessWidget {
  final SensorInfo sensor;
  final VoidCallback onSensorTap;

  const LiveSensorWrapper({
    super.key,
    required this.sensor,
    required this.onSensorTap,
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

    final measureUnit = _getMeasureUnit(sensor.variableName);

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

            return SensorCard(
              name: sensor.variableName.toUpperCase(),
              value: currentValue,
              measureUnit: measureUnit,
              onPressed: onSensorTap,
            );
          },
    );
  }

  String _getMeasureUnit(String variableName) {
    final name = variableName.toLowerCase();

    if (name.contains('temp')) {
      return 'ºC';
    }

    if (name.contains('hum')) {
      return '%';
    }

    if (name.contains('co2')) {
      return 'ppm';
    }

    if (name.contains('o2')) {
      return '%';
    }

    if (name.contains('heart')) {
      return 'BPM';
    }

    return '';
  }
}
