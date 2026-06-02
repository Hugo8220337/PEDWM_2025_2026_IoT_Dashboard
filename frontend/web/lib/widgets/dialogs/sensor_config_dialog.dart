import 'package:common/models/sensor_info.dart';
import 'package:flutter/material.dart';

class SensorConfigDialog extends StatefulWidget {
  final SensorInfo sensor;
  final double? initialMin;
  final double? initialMax;
  final void Function(double? min, double? max) onSave;
  final VoidCallback onRemove;

  const SensorConfigDialog({
    super.key,
    required this.sensor,
    this.initialMin,
    this.initialMax,
    required this.onSave,
    required this.onRemove,
  });

  @override
  State<SensorConfigDialog> createState() =>
      _SensorConfigDialogState();
}

class _SensorConfigDialogState extends State<SensorConfigDialog> {
  late TextEditingController minController;
  late TextEditingController maxController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    minController = TextEditingController(
      text: widget.initialMin?.toString() ?? '',
    );
    maxController = TextEditingController(
      text: widget.initialMax?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    minController.dispose();
    maxController.dispose();
    super.dispose();
  }

  void _validateAndSave() {
    if (_formKey.currentState!.validate()) {
      final minVal = double.tryParse(minController.text);
      final maxVal = double.tryParse(maxController.text);

      widget.onSave(minVal, maxVal);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _DialogTitle(widget: widget),
      content: Form(
        key: _formKey,
        child: _DialogForm(
          minController: minController,
          maxController: maxController,
        ),
      ),
      actions: [
        _RemoveButton(widget: widget),
        TextButton(
          onPressed: _validateAndSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DialogForm extends StatelessWidget {
  const _DialogForm({
    required this.minController,
    required this.maxController,
  });

  final TextEditingController minController;
  final TextEditingController maxController;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormField(
          controller: minController,
          decoration: const InputDecoration(
            labelText: 'Min Value',
            hintText: 'Ex: 0.0',
          ),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a value';
            }
            if (double.tryParse(value) == null) {
              return 'Invalid min value';
            }
            return null;
          },
        ),

        const SizedBox(height: 10),

        TextFormField(
          controller: maxController,
          decoration: const InputDecoration(
            labelText: 'Max Value',
            hintText: 'Ex: 100.0',
          ),
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a value';
            }
            final maxParsed = double.tryParse(value);
            if (maxParsed == null) {
              return 'Invalid max value';
            }

            final minParsed = double.tryParse(minController.text);
            if (minParsed != null && maxParsed <= minParsed) {
              return 'Max must be greater than Min';
            }

            return null;
          },
        ),
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.widget});

  final SensorConfigDialog widget;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        widget
            .onRemove(); // Warns the parent to remove this sensor from the dashboard
        Navigator.pop(context);
      },
      style: TextButton.styleFrom(foregroundColor: Colors.red),
      child: const Text('Remove Sensor'),
    );
  }
}

class _DialogTitle extends StatelessWidget {
  const _DialogTitle({required this.widget});

  final SensorConfigDialog widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Configure ${widget.sensor.variableName.toUpperCase()}'),
        IconButton(
          icon: const Icon(Icons.close),
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
