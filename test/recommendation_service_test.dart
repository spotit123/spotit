import 'package:flutter_test/flutter_test.dart';
import 'package:spotit/data/mock_data.dart';
import 'package:spotit/models/quiz_answers.dart';
import 'package:spotit/services/recommendation_service.dart';

QuizAnswers quiz({
  String goal = 'drink',
  String vibe = 'Chill',
  List<String> music = const ['any'],
  String ageGroup = '23-27',
  String company = 'friends',
  int budget = 2,
  String who = 'local',
}) =>
    QuizAnswers(
      who: who,
      ageGroup: ageGroup,
      company: company,
      goal: goal,
      vibe: vibe,
      music: music,
      budget: budget,
    );

void main() {
  test('score is always within 0..100', () {
    for (final bar in mockBars) {
      for (final goal in ['drink', 'eat', 'rooftop', 'dance']) {
        final s = RecommendationService.score(bar, quiz(goal: goal, who: 'tourist'));
        expect(s, inInclusiveRange(0, 100));
      }
    }
  });

  test('rooftop seekers get the rooftop bar first', () {
    final ranked = RecommendationService.rank(
      mockBars,
      quiz(goal: 'rooftop', vibe: 'Chill', music: ['jazz'], ageGroup: '36+'),
    );
    expect(ranked.first.vibeTags, contains('Rooftop'));
  });

  test('dancers get an energetic bar first', () {
    final ranked = RecommendationService.rank(
      mockBars,
      quiz(goal: 'dance', vibe: 'Energetic', music: ['pop'], ageGroup: '18-22', company: 'group', budget: 1),
    );
    expect(ranked.first.vibeTags, contains('Energetic'));
  });

  test('quiz answers survive a JSON round trip', () {
    final q = quiz(music: ['indie', 'jazz'], budget: 3);
    final back = QuizAnswers.fromJson(q.toJson());
    expect(back.music, ['indie', 'jazz']);
    expect(back.budget, 3);
    expect(back.approxAge, 25);
  });
}
