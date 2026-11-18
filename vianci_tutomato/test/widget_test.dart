import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutomato/main.dart';

void main() {
  testWidgets('login opens the dashboard and task creation saves locally', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const TutomatoApp());
    expect(find.text('Lock in to ripen up!'), findsOneWidget);
    expect(tester.takeException(), isNull, reason: 'welcome screen layout');

    await tester.tap(find.text('I already have an account'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'login screen layout');
    await tester.enterText(find.byType(TextFormField).at(1), 'password');
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'home screen layout');
    expect(find.text('Hi, alex!'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a task'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).first,
      'Read about plant cells',
    );
    await tester.tap(find.text('Save task'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull, reason: 'task list layout');
    expect(find.text('Read about plant cells'), findsOneWidget);

    await tester.tap(find.text('Pomodori'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'wardrobe layout');
    expect(find.text('PIP’S LITTLE WARDROBE'), findsOneWidget);
    await tester.tap(find.text('Colors'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'wardrobe colors layout');
    expect(find.text('Pick Pip’s color'), findsOneWidget);

    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'records layout');
    expect(find.text('Your records'), findsOneWidget);
    await tester.tap(find.text('Friends'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'friends layout');
    expect(find.text('Better together'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'profile layout');
    expect(find.text('Your profile'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start a focus session'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15 / 3'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'session setup layout');
    await tester.tap(find.text('Start 15:00 focus'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull, reason: 'focus timer layout');
    expect(find.text('Focus session'), findsOneWidget);
    await tester.tap(find.text('End session'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('End session').last);
    await tester.pumpAndSettle();
    expect(find.text('Hi, alex!'), findsOneWidget);
  });
}
