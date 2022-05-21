import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../build_widget.dart';

void main() {
  testWidgets('Check all components', (WidgetTester tester) async {
    await buildWidget(tester, const Loading());

    expect(find.byType(Center), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(Center),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
  });
}
