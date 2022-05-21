import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../build_widget.dart';

void main() {
  const String success1 = 'Test success 1';
  const String success2 = 'Test success 2';

  final Widget showButton = Builder(
    builder: (BuildContext context) {
      int tapCnt = 0;

      return TextButton(
        onPressed: () {
          showSuccessSnackBar(context, tapCnt == 0 ? success1 : success2);
          tapCnt++;
        },
        child: const Text('Show'),
      );
    },
  );

  testWidgets('Display snackbar', (WidgetTester tester) async {
    await buildWidget(tester, showButton);

    expect(find.widgetWithText(SnackBar, success1), findsNothing);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SnackBar, success1), findsOneWidget);

    final SnackBar snackBar =
        tester.widget(find.widgetWithText(SnackBar, success1)) as SnackBar;

    expect(snackBar.backgroundColor, Colors.green);

    await tester.pumpAndSettle(const Duration(milliseconds: 4000));

    expect(find.widgetWithText(SnackBar, success1), findsNothing);
  });

  testWidgets('Redisplay snackbar', (WidgetTester tester) async {
    await buildWidget(tester, showButton);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SnackBar, success1), findsOneWidget);

    await tester.tap(find.text('Show'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(SnackBar, success1), findsNothing);
    expect(find.widgetWithText(SnackBar, success2), findsOneWidget);

    final SnackBar snackBar =
        tester.widget(find.widgetWithText(SnackBar, success2)) as SnackBar;

    expect(snackBar.backgroundColor, Colors.green);

    await tester.pumpAndSettle(const Duration(milliseconds: 4000));

    expect(find.widgetWithText(SnackBar, success2), findsNothing);
  });
}
