class SensorInfo {
  final String id;
  final String nodeId;
  final String sensorName;
  final String variableName;

  SensorInfo({
    required this.id,
    required this.nodeId,
    required this.sensorName,
    required this.variableName,
  });

  factory SensorInfo.fromJson(Map<String, dynamic> json) {
    return SensorInfo(
      id: json['id'] ?? '',
      nodeId: json['nodeId'] ?? '',
      sensorName: json['sensorName'] ?? '',
      variableName: json['variableName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nodeId': nodeId,
      'sensorName': sensorName,
      'variableName': variableName,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SensorInfo &&
          runtimeType == other.runtimeType &&
          id == other.id;
  @override
  int get hashCode => id.hashCode;
}
