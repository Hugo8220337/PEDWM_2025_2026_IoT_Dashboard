import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class SensorGauge extends StatelessWidget {
  final String name;
  final double min;
  final double max;
  final double value;
  final String? measureUnit;
  final VoidCallback? onPressed;
  final VoidCallback? onConfigPressed;

  const SensorGauge({
    super.key,
    required this.name,
    required this.value,
    required this.onPressed,
    this.measureUnit,
    this.min = 0.0,
    this.max = 100.0,
    this.onConfigPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _GaugeBody(
                  name: name,
                  min: min,
                  max: max,
                  value: value,
                  measureUnit: measureUnit,
                ),
              ),

              if (onConfigPressed != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 20,
                    ),
                    onPressed: onConfigPressed,
                    tooltip: 'Configurar Sensor',
                    splashRadius: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ... a tua classe _GaugeBody continua aqui para baixo sem alterações!

class _GaugeBody extends StatelessWidget {
  const _GaugeBody({
    required this.name,
    required this.min,
    required this.max,
    required this.value,
    required this.measureUnit,
  });

  final String name;
  final double min;
  final double max;
  final double value;
  final String? measureUnit;

  @override
  Widget build(BuildContext context) {
    var gaugeValue = GaugeAnnotation(
      widget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            measureUnit ?? '',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      angle: 90,
      positionFactor:
          0.75, // make the value appear closer to the center of the gauge
    );

    var ranges = <GaugeRange>[
      GaugeRange(
        startValue: min,
        endValue: max * 0.33,
        // ignore: deprecated_member_use
        color: Colors.green.withOpacity(0.8),
      ),
      GaugeRange(
        startValue: max * 0.33,
        endValue: max * 0.66,
        // ignore: deprecated_member_use
        color: Colors.orange.withOpacity(0.8),
      ),
      GaugeRange(
        startValue: max * 0.66,
        endValue: max,
        // ignore: deprecated_member_use
        color: Colors.red.withOpacity(0.8),
      ),
    ];

    return SfRadialGauge(
      title: GaugeTitle(
        text: name,
        textStyle: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      axes: <RadialAxis>[
        RadialAxis(
          minimum: min,
          maximum: max,
          showTicks:
              false, // Deixa o visual mais limpo para dashboards
          // axisLabelStyle: const GaugeLabelStyle(fontSize: 10),
          ranges: ranges,
          pointers: <GaugePointer>[
            NeedlePointer(
              value: value,
              needleLength: 0.7,
              enableAnimation: true,
              knobStyle: const KnobStyle(knobRadius: 0.08),
            ),
          ],
          annotations: <GaugeAnnotation>[gaugeValue],
        ),
      ],
    );
  }
}
