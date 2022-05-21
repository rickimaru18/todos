import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({
    this.size = 40,
    this.color,
    super.key,
  });

  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color finalColor = color ?? Theme.of(context).primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.assignment,
          size: size,
          color: finalColor,
        ),
        Text(
          AppLocalizations.of(context)!.appTitle,
          style: TextStyle(
            fontSize: size / 2,
            color: finalColor,
          ),
        )
      ],
    );
  }
}
