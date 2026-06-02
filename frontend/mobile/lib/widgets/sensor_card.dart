import 'package:flutter/material.dart';

class SensorCard extends StatelessWidget {
  const SensorCard({
    super.key,
    required this.name,
    required this.value,
    required this.measureUnit,
    required this.onPressed,
  });

  final String name;
  final double value;
  final String measureUnit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip
          .antiAlias, // makes the ripple effect from InkWell is clipped to the card's rounded corners
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- TOP: Icon and Status---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sensor_window,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),

                  const Icon(
                    Icons.circle,
                    size: 10,
                    color: Colors.green,
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // Base: Name, Value and Unit
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sensor Name
                  Text(
                    name.toUpperCase(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Sensor Unit and Value
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        value.toStringAsFixed(1),
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  theme.textTheme.bodySmall?.color,
                            ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        measureUnit,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
