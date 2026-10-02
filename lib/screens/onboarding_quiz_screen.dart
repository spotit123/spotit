import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n.dart';
import '../widgets/lang_button.dart';
import '../models/quiz_answers.dart';

class _Option {
  final String emoji;
  final String label;
  final String value;
  const _Option(this.emoji, this.label, this.value);
}

class _Question {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final List<_Option> options;
  final bool multi;
  const _Question(this.id, this.emoji, this.title, this.subtitle, this.options,
      {this.multi = false});
}

List<_Question> _buildQuestions() {
  _Option o(String emoji, String qid, String value) => _Option(emoji, tr('q.$qid.$value'), value);
  _Question q(String id, String emoji, List<_Option> options, {bool multi = false}) =>
      _Question(id, emoji, tr('q.$id.t'), tr('q.$id.s'), options, multi: multi);
  return [
    q('who', '👋', [o('🎓', 'who', 'erasmus'), o('🧳', 'who', 'tourist'), o('🏠', 'who', 'local'), o('💼', 'who', 'worker')]),
    q('ageGroup', '🎂', [o('🎒', 'ageGroup', '18-22'), o('🎧', 'ageGroup', '23-27'), o('🥂', 'ageGroup', '28-35'), o('🍷', 'ageGroup', '36+')]),
    q('company', '👯', [o('🧍', 'company', 'solo'), o('💑', 'company', 'couple'), o('👫', 'company', 'friends'), o('🎉', 'company', 'group')]),
    q('goal', '🍻', [o('🍺', 'goal', 'drink'), o('🍽️', 'goal', 'eat'), o('🌇', 'goal', 'rooftop'), o('💃', 'goal', 'dance')]),
    q('vibe', '✨', [o('🔥', 'vibe', 'Energetic'), o('🌙', 'vibe', 'Chill'), o('🕵️', 'vibe', 'Underground'), o('💜', 'vibe', 'Neon')]),
    q('music', '🎶', [
      o('🎸', 'music', 'indie'), o('🎷', 'music', 'jazz'), o('🎤', 'music', 'pop'), o('🎧', 'music', 'electronic'), o('🤷', 'music', 'any'),
    ], multi: true),
    q('budget', '💶', [o('💶', 'budget', '1'), o('💶💶', 'budget', '2'), o('💎', 'budget', '3')]),
  ];
}

/// Quiz di personalizzazione a schermate, pensato per il primo avvio.
/// Chiama [onComplete] con le risposte, oppure con `null` se l'utente salta.
class OnboardingQuizScreen extends StatefulWidget {
  final void Function(QuizAnswers? answers) onComplete;

  const OnboardingQuizScreen({super.key, required this.onComplete});

  @override
  State<OnboardingQuizScreen> createState() => _OnboardingQuizScreenState();
}

class _OnboardingQuizScreenState extends State<OnboardingQuizScreen> {
  static const _blue = Color(0xFF0066FF);
  int _step = 0;
  final Map<String, String> _single = {};
  final List<String> _music = [];

  // Ricalcolato a ogni uso, così segue la lingua se cambia durante il quiz
  List<_Question> get _questions => _buildQuestions();

  _Question get _q => _questions[_step];

  void _next() {
    if (_step == _questions.length - 1) {
      widget.onComplete(QuizAnswers(
        who: _single['who']!,
        ageGroup: _single['ageGroup']!,
        company: _single['company']!,
        goal: _single['goal']!,
        vibe: _single['vibe']!,
        music: List.of(_music),
        budget: int.parse(_single['budget']!),
      ));
    } else {
      setState(() => _step++);
    }
  }

  void _pick(_Option o) {
    if (_q.multi) {
      setState(() {
        if (_music.contains(o.value)) {
          _music.remove(o.value);
        } else if (o.value == 'any') {
          _music
            ..clear()
            ..add('any');
        } else {
          _music.remove('any');
          if (_music.length < 3) _music.add(o.value);
        }
      });
      return;
    }
    setState(() => _single[_q.id] = o.value);
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted && _single[_q.id] == o.value) _next();
    });
  }

  bool _selected(_Option o) =>
      _q.multi ? _music.contains(o.value) : _single[_q.id] == o.value;

  @override
  Widget build(BuildContext context) {
    final q = _q;
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _step == 0 ? null : () => setState(() => _step--),
                    icon: Icon(Icons.arrow_back_ios_new,
                        size: 18, color: _step == 0 ? Colors.transparent : Colors.white),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: (_step + 1) / _questions.length,
                        minHeight: 6,
                        backgroundColor: const Color(0xFF1E293B),
                        color: _blue,
                      ),
                    ),
                  ),
                  const LangButton(),
                  TextButton(
                    onPressed: () => widget.onComplete(null),
                    child: Text(tr('quiz.skip'),
                        style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(q.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text(q.title,
                  style: GoogleFonts.poppins(
                      fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(q.subtitle,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500])),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final o in q.options) _optionCard(o),
                    ],
                  ),
                ),
              ),
              if (q.multi)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _music.isEmpty ? null : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF1E293B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(tr('quiz.next'),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionCard(_Option o) {
    final sel = _selected(o);
    final width = (MediaQuery.of(context).size.width - 40 - 12) / 2;
    return GestureDetector(
      onTap: () => _pick(o),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: _q.options.length == 3 ? double.infinity : width,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF1A2B4C) : const Color(0xFF131B2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sel ? _blue : const Color(0xFF1E293B), width: 1.5),
        ),
        child: Column(
          children: [
            Text(o.emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 8),
            Text(o.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: sel ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
