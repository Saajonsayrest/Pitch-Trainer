import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitch_trainer_rea/main.dart';
import 'package:pitch_trainer_rea/stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

Stats _ready() => Stats()..onboarded = true;

void main() {
  // Saving goes to phone storage. Tests use an in-memory copy.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('a new learner sees the welcome flow, then home', (tester) async {
    final stats = Stats();
    await tester.pumpWidget(PitchTrainerApp(stats: stats));
    expect(find.text('Get started'), findsOneWidget);

    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Select all your goals'), findsOneWidget);
    // Continue is off until a goal is picked.
    await tester.tap(find.text('Just for fun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Just starting'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Voice'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Never'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('5'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Let's go"));
    await tester.pumpAndSettle();
    expect(stats.onboarded, isTrue);
    expect(stats.dailyMinutes, 5);
    expect(find.text('Pitch Trainer REA'), findsOneWidget);
  });

  testWidgets('home shows the daily card and skill cards', (tester) async {
    await tester.pumpWidget(PitchTrainerApp(stats: _ready()));
    expect(find.text("Today's session"), findsOneWidget);
    expect(find.text('Interval trainer'), findsOneWidget);
    expect(find.text('Chord recognition'), findsOneWidget);
  });

  testWidgets('a skill opens and lists its lessons', (tester) async {
    await tester.pumpWidget(PitchTrainerApp(stats: _ready()));
    await tester.tap(find.text('Interval trainer'));
    await tester.pumpAndSettle();
    expect(find.text('Free practice'), findsOneWidget);
    expect(find.text('Fifth and octave'), findsOneWidget);
    expect(find.text('START'), findsWidgets);
  });

  testWidgets('a lesson opens its intro page', (tester) async {
    await tester.pumpWidget(PitchTrainerApp(stats: _ready()));
    await tester.tap(find.text('Interval trainer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fifth and octave'));
    await tester.pumpAndSettle();
    expect(find.text('NEW LESSON'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('a learn lesson teaches, then practises, then tests', (
    tester,
  ) async {
    final stats = _ready();
    await tester.pumpWidget(PitchTrainerApp(stats: stats));
    await tester.tap(find.text('Interval trainer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fifth and octave'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Teaching: meet, two ways, other notes, for each of two items, then
    // the side-by-side step. The song tip is shown.
    expect(find.text('REMEMBER IT LIKE THIS'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
    }
    expect(find.text('SIDE BY SIDE'), findsOneWidget);
    await tester.tap(find.text('Practise'));
    await tester.pumpAndSettle();

    // Practice: no score, speaker buttons on answers.
    expect(find.text('PRACTICE · NO SCORE'), findsOneWidget);
    expect(find.byTooltip('Hear Perfect 5th'), findsOneWidget);
    await tester.tap(find.text('Octave'));
    await tester.pumpAndSettle();
    expect(find.textContaining('It was'), findsOneWidget);
    expect(stats.total, 0);
  });

  testWidgets('stats tab is locked until the first answer', (tester) async {
    await tester.pumpWidget(PitchTrainerApp(stats: _ready()));
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('Your progress so far'), findsOneWidget);
    expect(find.text('Unlock your stats in 3 steps'), findsOneWidget);
  });

  testWidgets('stats tab shows totals after practice', (tester) async {
    final stats = _ready();
    await stats.record(true, skillId: 'intervals');
    await tester.pumpWidget(PitchTrainerApp(stats: stats));
    await tester.tap(find.text('Stats'));
    await tester.pumpAndSettle();
    expect(find.text('MASTERY'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('By trainer'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('By trainer'), findsOneWidget);
  });

  testWidgets('settings opens from home', (tester) async {
    await tester.pumpWidget(PitchTrainerApp(stats: _ready()));
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Customize your experience'), findsOneWidget);
    expect(find.text('Reset progress'), findsOneWidget);
  });
}
