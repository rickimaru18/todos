import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            width: double.infinity,
            child: Icon(
              Icons.block_rounded,
              size: 100,
              color: Colors.grey,
            ),
          ),
          Text(
            AppLocalizations.of(context)!.unknownPage,
            style: const TextStyle(
              fontSize: 30,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
