import 'package:common/models/sensor_data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // Para formatar as datas

class TimeSeriesChart extends StatelessWidget {
  final String sensorName;
  final List<SensorData> chartData;

  const TimeSeriesChart({
    super.key,
    required this.sensorName,
    required this.chartData,
  });

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Histórico - $sensorName'),

      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
      ),

      // Activate "crosshair" to see exact values on hover
      crosshairBehavior: CrosshairBehavior(
        enable: true,
        lineType: CrosshairLineType.vertical,
        activationMode: ActivationMode.singleTap,
      ),

      // X Axis
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Hm(), // Format: Hour:Minute
        intervalType: DateTimeIntervalType.minutes,
        majorGridLines: const MajorGridLines(width: 0),
      ),

      // Y Axis
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),

      series: <CartesianSeries<SensorData, DateTime>>[
        AreaSeries<SensorData, DateTime>(
          name: sensorName,
          dataSource: chartData,
          xValueMapper: (SensorData data, _) => data.time,
          yValueMapper: (SensorData data, _) => data.value,
          // ignore: deprecated_member_use
          color: Colors.blue.withOpacity(0.3),
          borderColor: Colors.blue,
          borderWidth: 2,
          animationDuration: 1500,
        ),
      ],
    );
  }
}
