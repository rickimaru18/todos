import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'src/presentation/app.dart';

void main() {
  runZonedGuarded(
    () async {
      await Hive.initFlutter();

      runApp(const MyApp());
    },
    (Object error, StackTrace stackTrace) {
      debugPrint('runZonedGuarded: $error');
      debugPrint('runZonedGuarded: $stackTrace');
    },
  );
}
