import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todos/src/presentation/widgets/widgets.dart';

import '../../build_widget.dart';

void main() {
  testWidgets('Check all components', (WidgetTester tester) async {
    final AppLocalizations appLocalizations = await buildWidget(
      tester,
      TodoFilters(
        onChanged: (bool? value) {
          // Do nothing.
        },
        groupValue: null,
      ),
    );

    expect(find.byType(RadioButton<bool?>), findsNWidgets(3));
    expect(
      find.widgetWithText(RadioButton<bool?>, appLocalizations.all),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(RadioButton<bool?>, appLocalizations.completed),
      findsOneWidget,
    );
    expect(
      find.widgetWithText(RadioButton<bool?>, appLocalizations.todo),
      findsOneWidget,
    );
  });

  testWidgets('Event check', (WidgetTester tester) async {
    bool? selectedValue;

    final AppLocalizations appLocalizations = await buildWidget(
      tester,
      TodoFilters(
        onChanged: (bool? value) => selectedValue = value,
        groupValue: selectedValue,
      ),
    );

    await tester.tap(
      find.widgetWithText(RadioButton<bool?>, appLocalizations.completed),
    );

    expect(selectedValue, true);
  });
}
