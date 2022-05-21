import 'package:flutter/material.dart';

class RadioButton<T extends Object?> extends StatelessWidget {
  const RadioButton({
    required this.onChanged,
    required this.groupValue,
    required this.value,
    required this.text,
    super.key,
  });

  final ValueChanged<T?> onChanged;
  final T groupValue;
  final T value;
  final String text;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Radio<T>(
            onChanged: onChanged,
            groupValue: groupValue,
            value: value,
          ),
          Text(text),
        ],
      ),
    );
  }
}
