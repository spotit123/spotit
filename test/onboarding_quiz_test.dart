import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spotit/l10n/l10n.dart';
import 'package:spotit/models/quiz_answers.dart';
import 'package:spotit/screens/onboarding_quiz_screen.dart';

void main() {
  testWidgets('completing all 7 questions returns the answers', (tester) async {
    QuizAnswers? result;
    var called = false;
    await tester.pumpWidget(MaterialApp(
      home: OnboardingQuizScreen(onComplete: (a) {
        result = a;
        called = true;
      }),
    ));

    Future<void> tap(String label) async {
      await tester.tap(find.text(label));
      await tester.pump(const Duration(milliseconds: 400));
    }

    await tap('Erasmus');
    await tap('23 – 27');
    await tap('2 o 3 amici');
    await tap('Ballare e far festa');
    await tap('Energia alta');
    await tap('Pop / Reggaeton');
    await tap('Avanti');
    await tap('Nella media  €€');

    expect(called, isTrue);
    expect(result!.who, 'erasmus');
    expect(result!.company, 'friends');
    expect(result!.goal, 'dance');
    expect(result!.vibe, 'Energetic');
    expect(result!.music, ['pop']);
    expect(result!.budget, 2);
  });

  testWidgets('skip returns null', (tester) async {
    var called = false;
    QuizAnswers? result;
    await tester.pumpWidget(MaterialApp(
      home: OnboardingQuizScreen(onComplete: (a) {
        called = true;
        result = a;
      }),
    ));
    await tester.tap(find.text('Salta'));
    expect(called, isTrue);
    expect(result, isNull);
  });

  for (final lang in AppLang.values) {
    testWidgets('quiz shows every question translated in ${lang.name} (no raw keys)', (tester) async {
      L10n.lang.value = lang;
      addTearDown(() => L10n.lang.value = AppLang.it);
      await tester.pumpWidget(MaterialApp(home: OnboardingQuizScreen(onComplete: (_) {})));
      for (var i = 0; i < 7; i++) {
        final raw = find.byWidgetPredicate((w) => w is Text && (w.data ?? '').startsWith('q.'));
        expect(raw, findsNothing, reason: 'question ${i + 1}');
        if (i == 5) {
          await tester.ensureVisible(find.text(tr('q.music.any')));
          await tester.pump();
          await tester.tap(find.text(tr('q.music.any')));
          await tester.pump();
          await tester.tap(find.text(tr('quiz.next')));
        } else {
          final options = ['who', 'ageGroup', 'company', 'goal', 'vibe', '', 'budget'];
          final first = {
            'who': 'erasmus', 'ageGroup': '18-22', 'company': 'solo', 'goal': 'drink', 'vibe': 'Energetic', 'budget': '1',
          }[options[i]]!;
          await tester.tap(find.text(tr('q.${options[i]}.$first')));
        }
        await tester.pump(const Duration(milliseconds: 400));
      }
    });
  }
}
