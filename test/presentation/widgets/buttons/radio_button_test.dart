import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../build_widget.dart';

void main() {
  testWidgets('Check all components', (WidgetTester tester) async {
    final RadioButton<bool?> radioButton = RadioButton<bool?>(
      onChanged: (bool? value) {
        // Do nothing.
      },
      groupValue: null,
      value: null,
      text: 'Sample',
    );

    await buildWidget(tester, radioButton);

    expect(find.byType(GestureDetector), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Radio<bool?>),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GestureDetector),
        matching: find.text(radioButton.text),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Check with different type', (WidgetTester tester) async {
    final RadioButton<int> radioButton = RadioButton<int>(
      onChanged: (int? value) {
        // Do nothing.
      },
      groupValue: 0,
      value: 0,
      text: 'Sample',
    );

    await buildWidget(tester, radioButton);

    expect(find.byType(GestureDetector), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Radio<int>),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byType(GestureDetector),
        matching: find.text(radioButton.text),
      ),
      findsOneWidget,
    );

    // Check if there's no [Radio] with type [bool].
    expect(
      find.descendant(
        of: find.byType(GestureDetector),
        matching: find.byType(Radio<bool?>),
      ),
      findsNothing,
    );
  });

  testWidgets('Event check for "Radio" widget', (WidgetTester tester) async {
    int groupValue = 100;

    final RadioButton<int> radioButton = RadioButton<int>(
      onChanged: (int? value) => groupValue = value!,
      groupValue: groupValue,
      value: 0,
      text: 'Sample',
    );

    await buildWidget(tester, radioButton);
    await tester.tap(find.byType(Radio<int>));

    expect(groupValue, radioButton.value);
  });

  testWidgets('Event check for "Text" widget', (WidgetTester tester) async {
    int groupValue = 100;

    final RadioButton<int> radioButton = RadioButton<int>(
      onChanged: (int? value) => groupValue = value!,
      groupValue: groupValue,
      value: 0,
      text: 'Sample',
    );

    await buildWidget(tester, radioButton);
    await tester.tap(find.byType(Text));

    expect(groupValue, radioButton.value);
  });
}
