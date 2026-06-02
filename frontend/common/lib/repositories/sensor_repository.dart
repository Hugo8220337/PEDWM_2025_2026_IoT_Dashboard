import 'package:common/models/sensor_data.dart';
import 'package:common/models/sensor_info.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SensorRepository {
  final GraphQLClient client;

  SensorRepository({required this.client});

  Future<List<SensorInfo>> getSensors() async {
    const String readSensorsQuery = r'''
      query {
        nodes {
          nodeId
          isAvailable
          sensors {
            id
            groupId
            nodeId
            sensorName
            variableName
            dataType
            isAvailable
          }
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(readSensorsQuery),
    );
    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    // parse the nested JSON response into a flat list of SensorInfo objects
    final List<dynamic> nodes = result.data?['nodes'] ?? [];
    List<SensorInfo> availableSensors = [];

    for (var node in nodes) {
      final List<dynamic> sensorsData = node['sensors'] ?? [];
      for (var sensorData in sensorsData) {
        availableSensors.add(SensorInfo.fromJson(sensorData));
      }
    }

    return availableSensors;
  }

  Future<List<SensorData>> getHistoricalReadings(
    String sensorId,
    int limit,
  ) async {
    const String query = r'''
      query GetReadings($sensorId: String!, $limit: Int!) {
        readings(sensorId: $sensorId, limit: $limit) {
          id
          timestamp
          value
        }
      }
    ''';

    final result = await client.query(
      QueryOptions(
        document: gql(query),
        variables: {'sensorId': sensorId, 'limit': limit},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List<dynamic> readings = result.data?['readings'] ?? [];
    return readings
        .map(
          (r) => SensorData(
            DateTime.fromMillisecondsSinceEpoch(r['timestamp']),
            (r['value'] as num).toDouble(),
          ),
        )
        .toList();
  }

  Stream<SensorData> subscribeToLiveReadings(String sensorId) {
    const String subscription = r'''
      subscription LiveReadings($sensorId: String!) {
        liveReadings(sensorId: $sensorId) {
          id
          sensorId
          timestamp
          value
        }
      }
    ''';

    // returns a stream that can be easly read by the viewmodel
    return client
        .subscribe(
          SubscriptionOptions(
            document: gql(subscription),
            variables: {'sensorId': sensorId},
          ),
        )
        //  Block every result that is not from the passed sensorId
        .where((QueryResult result) {
          if (result.hasException) return false;

          final data = result.data?['liveReadings'];
          if (data == null) return false;

          return data['sensorId'] == sensorId;
        })
        .map((QueryResult result) {
          final r = result.data!['liveReadings'];
          return SensorData(
            DateTime.fromMillisecondsSinceEpoch(r['timestamp']),
            (r['value'] as num).toDouble(),
          );
        });
  }
}
