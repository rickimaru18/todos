import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../widgets.dart';

class TodoFilters extends StatelessWidget {
  const TodoFilters({
    required this.onChanged,
    required this.groupValue,
    super.key,
  });

  final ValueChanged<bool?> onChanged;
  final bool? groupValue;

  /// Build [RadioButton] item.
  Widget _buildRadioItem(bool? value, String text) => RadioButton<bool?>(
        onChanged: onChanged,
        groupValue: groupValue,
        value: value,
        text: text,
      );

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _buildRadioItem(null, appLocalizations.all),
        _buildRadioItem(true, appLocalizations.completed),
        _buildRadioItem(false, appLocalizations.todo),
      ],
    );
  }
}
