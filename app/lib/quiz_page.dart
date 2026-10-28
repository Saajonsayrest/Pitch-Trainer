import 'dart:math';

import 'package:flutter/material.dart';

import 'stats.dart';
import 'synth.dart';
import 'theme.dart';
import 'theory.dart';
import 'widgets.dart';

/// Plays a sound and asks the learner to name it.
///
/// With [count] set, it runs that many questions, shows a result page and
/// pops the number of correct answers. Without it, it runs until the learner
/// leaves.
class QuizPage extends StatefulWidget {
  const QuizPage({
    super.key,
    required this.title,
    required this.pool,
    required this.stats,
    required this.skillId,
    this.focus = const [],
    this.count,
    this.passMark,
    this.pill = 'Practice',
  });

  final String title;
  final List<Item> pool;
  final Stats stats;
  final String skillId;

  /// Items to ask about more often, such as the ones just taught.
  final List<Item> focus;
  final int? count;
  final int? passMark;
  final String pill;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final _rng = Random();
  late final List<Item> _choices = widget.pool.toSet().toList();
  late Item _answer;
  int _root = 60;
  String? _picked;
  int _asked = 0;
  int _right = 0;
  int _earned = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _next();
  }

  Item _draw() {
    if (widget.focus.isNotEmpty && _rng.nextBool()) {
      return widget.focus[_rng.nextInt(widget.focus.length)];
    }
    return widget.pool[_rng.nextInt(widget.pool.length)];
  }

  void _next() {
    setState(() {
      _answer = _draw();
      _root = 53 + _rng.nextInt(12);
      _picked = null;
      _asked++;
    });
    _play();
  }

  void _restart() {
    setState(() {
      _asked = 0;
      _right = 0;
      _earned = 0;
      _finished = false;
    });
    _next();
  }

  void _play() =>
      appSynth.play(_root, _answer.steps, stepSeconds: _answer.stepSeconds);

  void _pick(Item e) {
    if (_picked != null) return;
    final ok = e.name == _answer.name;
    setState(() {
      _picked = e.name;
      if (ok) {
        _right++;
        _earned += 10;
      }
    });
    widget.stats.record(ok, skillId: widget.skillId);
  }

  void _advance() {
    final count = widget.count;
    if (count != null && _asked >= count) {
      setState(() => _finished = true);
    } else {
      _next();
    }
  }

  OptionState _stateOf(Item e) {
    if (_picked == null) return OptionState.idle;
    if (e.name == _answer.name) return OptionState.correct;
    if (e.name == _picked) return OptionState.wrong;
    return OptionState.dim;
  }

  Future<void> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Leave this lesson?'),
        content: const Text('Your answers in this lesson will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _result(context);
    final done = _picked != null;
    final count = widget.count;
    final last = count != null && _asked >= count;
    final wrong = done && _picked != _answer.name;
    return PopScope(
      canPop: count == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SessionHeader(
                steps: count ?? 10,
                done: count == null ? min(_asked, 10) : _asked - (done ? 0 : 1),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  children: [
                    Center(
                      child: Text(
                        'What do you hear?',
                        style: Txt.h2.copyWith(fontSize: 24),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Text(
                        count == null
                            ? 'Question $_asked'
                            : 'Question $_asked of $count',
                        style: const TextStyle(color: Pal.slate400),
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
                      ),
                    if (wrong)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Pal.bad50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Not quite. It was ${_answer.name}. ${_answer.blurb}',
                          style: const TextStyle(
                            color: Pal.bad700,
                            height: 1.4,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    if (done && !wrong)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Pal.good50,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Correct. +10 XP',
                          style: TextStyle(
                            color: Pal.good700,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: PrimaryButton(
                  label: !done
                      ? 'Choose an answer'
                      : (last ? 'See result' : 'Continue'),
                  onPressed: done ? _advance : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _result(BuildContext context) {
    final count = widget.count!;
    final need = widget.passMark ?? 0;
    final passed = _right >= need;
    final color = passed ? Pal.good : Pal.blue;
    final bg = passed ? Pal.goodBg : Pal.blueBg;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 118,
                      height: 118,
                      child: Stack(
                        children: [
                          Container(
                            width: 118,
                            height: 118,
                            decoration: BoxDecoration(
                              color: bg,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              passed
                                  ? Icons.emoji_events_rounded
                                  : Icons.replay_rounded,
                              size: 54,
                              color: color,
                            ),
                          ),
                          if (passed)
                            Positioned(
                              right: 6,
                              bottom: 6,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Pal.good400,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${widget.pill} · ${passed ? 'passed' : 'keep going'}'
                            .toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      passed ? 'Well done' : 'Almost there',
                      textAlign: TextAlign.center,
                      style: Txt.h1,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      passed
                          ? '$_right of $count correct. You earned $_earned XP.'
                          : '$_right of $count correct. You need $need to pass, '
                                'so give it another go.',
                      textAlign: TextAlign.center,
                      style: Txt.body,
                    ),
                  ],
                ),
              ),
              if (!passed) ...[
                PrimaryButton(label: 'Try again', onPressed: _restart),
                const SizedBox(height: 10),
                QuietButton(
                  label: 'Leave lesson',
                  onPressed: () => Navigator.of(context).pop(_right),
                ),
              ] else
                PrimaryButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(context).pop(_right),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
