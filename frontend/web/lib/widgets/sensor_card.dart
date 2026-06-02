import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.name,
    this.icon = FontAwesomeIcons.exclamation,
    required this.value,
    required this.measureUnit,
    required this.onPressed,
  });

  final String name;
  final String value;
  final FaIconData icon;
  final String measureUnit;
  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const paddingTop = 10.0, paddingBottom = 10.0;
    const paddingLeft = 25.0, paddingRight = 25.0;
    const cardPadding = EdgeInsetsDirectional.fromSTEB(
      paddingLeft,
      paddingTop,
      paddingRight,
      paddingBottom,
    );

    return Card(
      // InkWell Makes the card Clickable
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(name),
              FaIcon(icon, color: Colors.red),
              Text(value, textScaler: TextScaler.linear(3)),
              Text(measureUnit),
            ],
          ),
        ),
      ),
    );
  }
}
