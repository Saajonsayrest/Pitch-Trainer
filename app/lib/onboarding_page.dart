import 'package:flutter/material.dart';

import 'stats.dart';
import 'theme.dart';
import 'widgets.dart';

/// Short welcome flow shown once. The answers stay on the phone.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.stats});

  final Stats stats;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

enum _Step { welcome, goals, experience, instrument, ear, time, ready }

class _OnboardingPageState extends State<OnboardingPage> {
  _Step _step = _Step.welcome;
  final Set<String> _goals = {};
  String _experience = '';
  String _instrument = '';
  String _ear = '';
  int _minutes = 8;

  bool get _canContinue => switch (_step) {
    _Step.goals => _goals.isNotEmpty,
    _Step.experience => _experience.isNotEmpty,
    _Step.instrument => _instrument.isNotEmpty,
    _Step.ear => _ear.isNotEmpty,
    _ => true,
  };

  void _next() {
    if (_step == _Step.ready) {
      widget.stats.saveProfile(
        goals: _goals,
        experience: _experience,
        instrument: _instrument,
        ear: _ear,
        dailyMinutes: _minutes,
        onboarded: true,
      );
      return;
    }
    setState(() => _step = _Step.values[_step.index + 1]);
  }

  void _back() {
    if (_step.index > 0) {
      setState(() => _step = _Step.values[_step.index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final first = _step == _Step.welcome;
    return PopScope(
      canPop: first,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              if (!first)
                SessionHeader(
                  steps: _Step.values.length - 1,
                  done: _step.index,
                  onBack: _back,
                )
              else
                const SizedBox(height: 44),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: _body(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: PrimaryButton(
                  label: switch (_step) {
                    _Step.welcome => 'Get started',
                    _Step.ready => "Let's go",
                    _ => 'Continue',
                  },
                  onPressed: _canContinue ? _next : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _title(String t, [String? sub]) => Column(
    children: [
      Text(t, textAlign: TextAlign.center, style: Txt.h1),
      if (sub != null) ...[
        const SizedBox(height: 8),
        Text(sub, textAlign: TextAlign.center, style: Txt.body),
      ],
      const SizedBox(height: 28),
    ],
  );

  Widget _single(
    List<(String, String?)> options,
    String value,
    void Function(String) set,
  ) {
    return Column(
      children: [
        for (final (label, sub) in options)
          ChoiceTile(
            label: label,
            sub: sub,
            selected: value == label,
            onTap: () => setState(() => set(label)),
          ),
      ],
    );
  }

  Widget _body() {
    switch (_step) {
      case _Step.welcome:
        return Column(
          children: [
            const SizedBox(height: 40),
            const IconTile(
              icon: Icons.hearing_rounded,
              size: 96,
              color: Pal.blue,
            ),
            const SizedBox(height: 32),
            const Text(
              'Pitch Trainer REA',
              textAlign: TextAlign.center,
              style: Txt.h1,
            ),
            const SizedBox(height: 10),
            const Text(
              'Train your ear with short daily sessions. '
              'No ads, no account, no tracking.',
              textAlign: TextAlign.center,
              style: Txt.body,
            ),
          ],
        );
      case _Step.goals:
        const options = [
          ('Play songs by ear', Icons.music_note_rounded),
          ('Sing in tune', Icons.mic_rounded),
          ('Write my own music', Icons.edit_rounded),
          ('Jam with other players', Icons.groups_rounded),
          ('Prepare for a music exam', Icons.school_rounded),
          ('Just for fun', Icons.emoji_emotions_rounded),
        ];
        return Column(
          children: [
            _title('Select all your goals'),
            for (final (label, icon) in options)
              ChoiceTile(
                label: label,
                icon: icon,
                selected: _goals.contains(label),
                onTap: () => setState(() {
                  if (!_goals.remove(label)) _goals.add(label);
                }),
              ),
          ],
        );
      case _Step.experience:
        return Column(
          children: [
            _title('How much music experience do you have?'),
            _single(
              const [
                ('Just starting', 'I have never studied music'),
                ('Some experience', 'I can read a little or play a bit'),
                ('Experienced', 'I play or sing regularly'),
              ],
              _experience,
              (v) => _experience = v,
            ),
          ],
        );
      case _Step.instrument:
        return Column(
          children: [
            _title('What do you play?'),
            _single(
              const [
                ('Piano or keyboard', null),
                ('Guitar or bass', null),
                ('Voice', null),
                ('Another instrument', null),
                ('Nothing yet', null),
              ],
              _instrument,
              (v) => _instrument = v,
            ),
          ],
        );
      case _Step.ear:
        return Column(
          children: [
            _title('Have you trained your ear before?'),
            _single(
              const [
                ('Never', 'This is my first time'),
                ('A little', 'I tried some apps or classes'),
                ('A lot', 'I want a bigger challenge'),
              ],
              _ear,
              (v) => _ear = v,
            ),
          ],
        );
      case _Step.time:
        return Column(
          children: [
            _title(
              'How much time do you want to practice each day?',
              'Around 8 minutes a day works well for most people.',
            ),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                for (final m in const [3, 5, 8, 12, 15])
                  GestureDetector(
                    onTap: () => setState(() => _minutes = m),
                    child: Container(
                      width: 96,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _minutes == m ? Pal.blueBg : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _minutes == m ? Pal.blue : Pal.line,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$m',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: _minutes == m ? Pal.blue : Pal.slate800,
                            ),
                          ),
                          const Text(
                            'min',
                            style: TextStyle(color: Pal.slate400),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      case _Step.ready:
        return Column(
          children: [
            const SizedBox(height: 24),
            const IconTile(
              icon: Icons.check_rounded,
              size: 96,
              color: Pal.good,
              bg: Pal.goodBg,
            ),
            const SizedBox(height: 28),
            Text('You are all set', textAlign: TextAlign.center, style: Txt.h1),
            const SizedBox(height: 10),
            Text(
              'Your plan: $_minutes minutes a day. '
              'You can change this any time in Settings.',
              textAlign: TextAlign.center,
              style: Txt.body,
            ),
          ],
        );
    }
  }
}
