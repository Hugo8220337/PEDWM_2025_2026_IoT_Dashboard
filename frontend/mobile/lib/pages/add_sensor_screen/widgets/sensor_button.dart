import 'package:flutter/material.dart';

class SensorButton extends StatelessWidget {
  const SensorButton({
    super.key,
    required this.name,
    required this.onPressed,
  });

  final String name;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.all(10.0),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name),

            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
