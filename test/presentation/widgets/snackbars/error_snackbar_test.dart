import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../build_widget.dart';

void main() {
  const String error1 = 'Test error 1';
  const String error2 = 'Test error 2';

  final Widget showButton = Builder(
    builder: (BuildContext context) {
      int tapCnt = 0;

      return TextButton(
        onPressed: () {
          showErrorSnackBar(context, tapCnt == 0 ? error1 : error2);
          tapCnt++;
        },
        child: const Text('Show'),
      );
    },
  );

  testWidgets('Display snackbar', (WidgetTester tester) async {
    await buildWidget(tester, showButton);

    expect(find.widgetWithText(SnackBar, error1), findsNothing);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SnackBar, error1), findsOneWidget);

    final SnackBar snackBar =
        tester.widget(find.widgetWithText(SnackBar, error1)) as SnackBar;

    expect(snackBar.backgroundColor, Colors.red);

    await tester.pumpAndSettle(const Duration(milliseconds: 4000));

    expect(find.widgetWithText(SnackBar, error1), findsNothing);
  });

  testWidgets('Redisplay snackbar', (WidgetTester tester) async {
    await buildWidget(tester, showButton);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SnackBar, error1), findsOneWidget);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SnackBar, error1), findsNothing);
    expect(find.widgetWithText(SnackBar, error2), findsOneWidget);

    final SnackBar snackBar =
        tester.widget(find.widgetWithText(SnackBar, error2)) as SnackBar;

    expect(snackBar.backgroundColor, Colors.red);

    await tester.pumpAndSettle(const Duration(milliseconds: 4000));

    expect(find.widgetWithText(SnackBar, error2), findsNothing);
  });
}
