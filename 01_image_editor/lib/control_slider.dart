import 'package:flutter/material.dart';

class ControlsSlider extends StatelessWidget {
  const ControlsSlider({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
  });
  final String title;
  final double value;
  final double? min;
  final double? max;
  final Function(double) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Slider(
            min: min ?? 0,
            max: max ?? 1,
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
