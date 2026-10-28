import 'dart:math';

import 'package:flutter/material.dart';

import 'synth.dart';
import 'theme.dart';
import 'theory.dart';
import 'widgets.dart';

/// The questions for a guided practice: each new item twice, topped up with
/// older items so a lesson with one new item still has a few questions.
List<Item> practicePlan(List<Item> focus, List<Item> pool, Random rng) {
  final out = [...focus, ...focus];
  final others = pool.where((i) => !focus.contains(i)).toList()..shuffle(rng);
  for (var k = 0; out.length < 5 && k < others.length; k++) {
    out.add(others[k]);
  }
  return out..shuffle(rng);
}

/// Practice between teaching and the test. Nothing is scored: a wrong answer
/// only comes back once later. Every answer has a speaker button, so the
/// learner can compare the mystery sound with each choice.
class PracticePage extends StatefulWidget {
  const PracticePage({super.key, required this.focus, required this.pool});

  final List<Item> focus;
  final List<Item> pool;

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final _rng = Random();
  late final List<Item> _choices = widget.pool.toSet().toList();
  late final List<Item> _queue = practicePlan(widget.focus, widget.pool, _rng);
  final Set<String> _retried = {};
  int _at = 0;
  int _root = 60;
  String? _picked;

  Item get _answer => _queue[_at];

  @override
  void initState() {
    super.initState();
    _newRoot();
    WidgetsBinding.instance.addPostFrameCallback((_) => _play());
  }

  void _newRoot() => _root = 53 + _rng.nextInt(12);

  void _play() =>
      appSynth.play(_root, _answer.steps, stepSeconds: _answer.stepSeconds);

  void _hear(Item item) =>
      appSynth.play(_root, item.steps, stepSeconds: item.stepSeconds);

  void _pick(Item e) {
    if (_picked != null) return;
    setState(() {
      _picked = e.name;
      if (e.name != _answer.name && _retried.add(_answer.name)) {
        _queue.add(_answer);
      }
    });
  }

  void _advance() {
    if (_at + 1 >= _queue.length) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _at++;
      _picked = null;
      _newRoot();
    });
    _play();
  }

  OptionState _stateOf(Item e) {
    if (_picked == null) return OptionState.idle;
    if (e.name == _answer.name) return OptionState.correct;
    if (e.name == _picked) return OptionState.wrong;
    return OptionState.dim;
  }

  @override
  Widget build(BuildContext context) {
    final done = _picked != null;
    final wrong = done && _picked != _answer.name;
    final last = _at + 1 >= _queue.length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SessionHeader(
              steps: _queue.length,
              done: _at + (done ? 1 : 0),
              onBack: () => Navigator.of(context).pop(false),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                children: [
                  const Center(
                    child: Text('PRACTICE · NO SCORE', style: Txt.label),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'What do you hear?',
                      style: Txt.h2.copyWith(fontSize: 24),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(
                    child: Text(
                      'Tap the small speaker on an answer to hear it, '
                      'then compare.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Pal.slate400),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(child: PlayCircle(onTap: _play, size: 88)),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Tap to replay',
                      style: TextStyle(color: Pal.slate400, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 22),
                  for (var i = 0; i < _choices.length; i++)
                    OptionCard(
                      label: _choices[i].name,
                      letter: String.fromCharCode(65 + i % 26),
                      state: _stateOf(_choices[i]),
                      onTap: () => _pick(_choices[i]),
                      onHear: () => _hear(_choices[i]),
                    ),
                  if (done) _feedback(wrong),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                label: !done
                    ? 'Choose an answer'
                    : (last ? 'Start the test' : 'Continue'),
                onPressed: done ? _advance : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _feedback(bool wrong) {
    final item = _answer;
    final text = [
      wrong
          ? 'Not quite. It was ${item.name}.'
          : 'Correct. It was ${item.name}.',
      item.blurb,
      if (item.tip.isNotEmpty) item.tip,
      if (wrong) 'You will get this one again.',
    ].join(' ');
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: wrong ? Pal.bad50 : Pal.good50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: wrong ? Pal.bad700 : Pal.good700,
          height: 1.4,
          fontSize: 15,
        ),
      ),
    );
  }
}
