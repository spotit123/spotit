import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
