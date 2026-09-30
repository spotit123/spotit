/// Risposte del quiz di personalizzazione mostrato al primo avvio.
class QuizAnswers {
  final String who; // erasmus | tourist | local | worker
  final String ageGroup; // 18-22 | 23-27 | 28-35 | 36+
  final String company; // solo | couple | friends | group
  final String goal; // drink | eat | rooftop | dance
  final String vibe; // Energetic | Chill | Underground | Neon
  final List<String> music; // indie | jazz | pop | electronic | any
  final int budget; // 1..3

  const QuizAnswers({
    required this.who,
    required this.ageGroup,
    required this.company,
    required this.goal,
    required this.vibe,
    required this.music,
    required this.budget,
  });

  /// Età rappresentativa della fascia scelta, usata per pre-compilare il profilo.
  int get approxAge {
    switch (ageGroup) {
      case '18-22':
        return 20;
      case '23-27':
        return 25;
      case '28-35':
        return 31;
      default:
        return 40;
    }
  }

  Map<String, dynamic> toJson() => {
        'who': who,
        'ageGroup': ageGroup,
        'company': company,
        'goal': goal,
        'vibe': vibe,
        'music': music,
        'budget': budget,
      };

  factory QuizAnswers.fromJson(Map<String, dynamic> json) => QuizAnswers(
        who: json['who'] as String,
        ageGroup: json['ageGroup'] as String,
        company: json['company'] as String,
        goal: json['goal'] as String,
        vibe: json['vibe'] as String,
        music: List<String>.from(json['music'] as List),
        budget: json['budget'] as int,
      );
}
