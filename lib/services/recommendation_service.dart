import '../l10n/l10n.dart';
import '../models/bar.dart';
import '../models/quiz_answers.dart';

/// Risultato del confronto tra un locale e le risposte del quiz.
class Match {
  /// Punteggio da 0 a 100.
  final int score;

  /// Motivi per cui il locale è consigliato, dal più importante al meno importante,
  /// già tradotti nella lingua corrente.
  final List<String> reasons;

  const Match(this.score, this.reasons);
}

/// Calcola quanto un locale è adatto alle risposte del quiz (0-100) e perché.
class RecommendationService {
  static const _foodWords = ['tapas', 'bistro', 'wine', 'vermut', 'restaurant', 'taberna', 'enoteca'];
  static const _drinkWords = ['cocktail', 'bar', 'speakeasy', 'pub', 'mixology'];
  static const _danceTags = ['energetic', 'neon', 'live music'];
  static const _danceMusic = ['pop', 'reggaeton', 'techno', 'electro', 'house'];

  static const _musicKeywords = {
    'indie': ['indie', 'rock'],
    'jazz': ['jazz'],
    'pop': ['pop', 'reggaeton', 'latin'],
    'electronic': ['techno', 'electro', 'house', 'edm', 'elettronica'],
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

  /// Punteggio e motivi. Ogni criterio che dà punti aggiunge anche un motivo.
  static Match match(Bar bar, QuizAnswers q) {
    final type = bar.type.toLowerCase();
    final tags = bar.vibeTags.map((t) => t.toLowerCase()).toList();
    final music = bar.musicType.toLowerCase();
    var total = 0;
    final scored = <(int, String)>[]; // (punti, motivo)

    void add(int points, [String? reason]) {
      total += points;
      if (reason != null && points > 0) scored.add((points, reason));
    }

    // Cosa cerchi (30)
    switch (q.goal) {
      case 'eat':
        if (_hasAny(type, _foodWords)) add(30, tr('why.goal.eat'));
        break;
      case 'rooftop':
        if (tags.contains('rooftop') || type.contains('rooftop')) add(30, tr('why.goal.rooftop'));
        break;
      case 'dance':
        if (tags.any(_danceTags.contains) || _hasAny(music, _danceMusic)) add(30, tr('why.goal.dance'));
        break;
      default: // drink
        if (_hasAny(type, _drinkWords)) add(30, tr('why.goal.drink'));
    }

    // Vibe (20)
    if (tags.contains(q.vibe.toLowerCase())) add(20, tr('why.vibe', {'v': trVibe(q.vibe)}));

    // Musica (15)
    if (q.music.contains('any')) {
      if (bar.hasMusic) add(10, tr('why.musicAny'));
    } else if (bar.hasMusic && q.music.any((m) => _hasAny(music, _musicKeywords[m] ?? const []))) {
      add(15, tr('why.music', {'m': trMusic(bar.musicType)}));
    }

    // Età del pubblico (15)
    if (_hasAny(bar.crowdAge, _ageKeywords[q.ageGroup] ?? const [])) add(15, tr('why.age'));

    // Budget (10)
    final diff = (bar.priceLevel - q.budget).abs();
    if (diff == 0) {
      add(10, tr('why.budget', {'b': '€' * q.budget}));
    } else if (diff == 1) {
      add(5, tr('why.budgetNear'));
    }

    // Con chi esci (10)
    switch (q.company) {
      case 'solo': // vuole conoscere gente: serve un locale affollato
        if (bar.crowdDensity >= 60) add(10, tr('why.company.solo'));
        break;
      case 'couple':
        if (tags.contains('chill') || tags.contains('jazz') || bar.crowdDensity <= 70) {
          add(10, tr('why.company.couple'));
        }
        break;
      case 'group':
        if (bar.crowdDensity >= 60 || tags.contains('energetic')) add(10, tr('why.company.group'));
        break;
      default: // friends
        add(7, tr('why.company.friends'));
    }

    // Piccoli bonus per chi sei
    if (q.who == 'tourist' && bar.reviewCount >= 1000) add(5, tr('why.who.tourist'));
    if (q.who == 'erasmus' && _hasAny(bar.crowdAge, ['gen z', 'student', '20s'])) {
      add(5, tr('why.who.erasmus'));
    }

    // Motivi dal più pesante al più leggero (a parità, l'ordine di inserimento)
    final ordered = [...scored]..sort((a, b) => b.$1.compareTo(a.$1));
    return Match(total.clamp(0, 100), [for (final r in ordered) r.$2]);
  }

  static int score(Bar bar, QuizAnswers q) => match(bar, q).score;

  /// Locali ordinati dal più adatto al meno adatto.
  static List<Bar> rank(List<Bar> bars, QuizAnswers q) {
    final sorted = [...bars];
    sorted.sort((a, b) => score(b, q).compareTo(score(a, q)));
    return sorted;
  }
}
