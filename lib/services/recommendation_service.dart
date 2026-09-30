import '../models/bar.dart';
import '../models/quiz_answers.dart';

/// Calcola quanto un locale è adatto alle risposte del quiz (0-100).
class RecommendationService {
  static const _foodWords = ['tapas', 'bistro', 'wine', 'vermut', 'restaurant'];
  static const _drinkWords = ['cocktail', 'bar', 'speakeasy', 'pub', 'mixology'];
  static const _danceTags = ['energetic', 'neon', 'live music'];
  static const _danceMusic = ['pop', 'reggaeton', 'techno', 'electro', 'house'];

  static const _musicKeywords = {
    'indie': ['indie', 'rock'],
    'jazz': ['jazz'],
    'pop': ['pop', 'reggaeton', 'latin'],
    'electronic': ['techno', 'electro', 'house', 'edm'],
  };

  static const _ageKeywords = {
    '18-22': ['gen z', 'student', '20s'],
    '23-27': ['20s', 'gen z'],
    '28-35': ['20s-30s', '30s', 'professional'],
    '36+': ['30s', '40s', '50s', 'professional'],
  };

  static bool _hasAny(String text, List<String> words) {
    final t = text.toLowerCase();
    return words.any(t.contains);
  }

  static int score(Bar bar, QuizAnswers q) {
    final type = bar.type.toLowerCase();
    final tags = bar.vibeTags.map((t) => t.toLowerCase()).toList();
    final music = bar.musicType.toLowerCase();
    var total = 0;

    // Cosa cerchi (30)
    switch (q.goal) {
      case 'eat':
        if (_hasAny(type, _foodWords)) total += 30;
        break;
      case 'rooftop':
        if (tags.contains('rooftop') || type.contains('rooftop')) total += 30;
        break;
      case 'dance':
        if (tags.any(_danceTags.contains) || _hasAny(music, _danceMusic)) total += 30;
        break;
      default: // drink
        if (_hasAny(type, _drinkWords)) total += 30;
    }

    // Vibe (20)
    if (tags.contains(q.vibe.toLowerCase())) total += 20;

    // Musica (15)
    if (q.music.contains('any')) {
      if (bar.hasMusic) total += 10;
    } else if (bar.hasMusic &&
        q.music.any((m) => _hasAny(music, _musicKeywords[m] ?? const []))) {
      total += 15;
    }

    // Età del pubblico (15)
    if (_hasAny(bar.crowdAge, _ageKeywords[q.ageGroup] ?? const [])) total += 15;

    // Budget (10)
    final diff = (bar.priceLevel - q.budget).abs();
    total += diff == 0 ? 10 : (diff == 1 ? 5 : 0);

    // Con chi esci (10)
    switch (q.company) {
      case 'solo': // vuole conoscere gente: serve un locale affollato
        if (bar.crowdDensity >= 60) total += 10;
        break;
      case 'couple':
        if (tags.contains('chill') || tags.contains('jazz') || bar.crowdDensity <= 70) total += 10;
        break;
      case 'group':
        if (bar.crowdDensity >= 60 || tags.contains('energetic')) total += 10;
        break;
      default: // friends
        total += 7;
    }

    // Piccoli bonus per chi sei
    if (q.who == 'tourist' && bar.reviewCount >= 1000) total += 5;
    if (q.who == 'erasmus' && _hasAny(bar.crowdAge, ['gen z', 'student', '20s'])) total += 5;

    return total.clamp(0, 100);
  }

  /// Locali ordinati dal più adatto al meno adatto.
  static List<Bar> rank(List<Bar> bars, QuizAnswers q) {
    final sorted = [...bars];
    sorted.sort((a, b) => score(b, q).compareTo(score(a, q)));
    return sorted;
  }
}
