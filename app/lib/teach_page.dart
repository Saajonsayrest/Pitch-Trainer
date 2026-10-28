import 'package:flutter/material.dart';

import 'synth.dart';
import 'theme.dart';
import 'theory.dart';
import 'widgets.dart';

enum _Part { character, compare, play, contrast }

class _Step {
  const _Step(this.item, this.part);

  final Item item;
  final _Part part;
}

/// Teaches the new items of a lesson. Each item has up to three steps:
/// meet it, hear it apart and together, then hear it from other starting notes.
/// A lesson with several items ends with one side-by-side step.
class TeachPage extends StatefulWidget {
  const TeachPage({super.key, required this.title, required this.items});

  final String title;
  final List<Item> items;

  @override
  State<TeachPage> createState() => _TeachPageState();
}

class _TeachPageState extends State<TeachPage> {
  late final List<_Step> _steps = [
    for (final i in widget.items) ...[
      _Step(i, _Part.character),
      if (i.canSplit) _Step(i, _Part.compare),
      _Step(i, _Part.play),
    ],
    if (widget.items.length > 1) _Step(widget.items.first, _Part.contrast),
  ];
  int _at = 0;

  _Step get _step => _steps[_at];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _hear());
  }

  void _hear() {
    final i = _step.item;
    appSynth.play(60, i.steps, stepSeconds: i.stepSeconds);
  }

  void _next() {
    if (_at + 1 >= _steps.length) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _at++);
      if (_step.part == _Part.character) _hear();
    }
  }

  void _back() {
    if (_at == 0) {
      Navigator.of(context).pop(false);
    } else {
      setState(() => _at--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final last = _at + 1 >= _steps.length;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              SessionHeader(steps: _steps.length, done: _at + 1, onBack: _back),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                  child: switch (_step.part) {
                    _Part.character => _character(_step.item),
                    _Part.compare => _compare(_step.item),
                    _Part.play => _play(_step.item),
                    _Part.contrast => _contrast(),
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: PrimaryButton(
                  label: last ? 'Practise' : 'Continue',
                  onPressed: _next,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _character(Item item) {
    return Column(
      children: [
        const Text('MEET', style: Txt.label),
        const SizedBox(height: 6),
        Text(item.name, textAlign: TextAlign.center, style: Txt.h1),
        const SizedBox(height: 24),
        PlayCircle(onTap: _hear),
        const SizedBox(height: 8),
        const Text('Tap to hear it', style: TextStyle(color: Pal.slate400)),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Pal.bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Pal.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('HOW IT SOUNDS', style: Txt.label),
              const SizedBox(height: 6),
              Text(item.blurb, style: Txt.bodyDark.copyWith(fontSize: 17)),
            ],
          ),
        ),
        if (item.tip.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Pal.blueBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('REMEMBER IT LIKE THIS', style: Txt.label),
                const SizedBox(height: 6),
                Text(item.tip, style: Txt.bodyDark.copyWith(fontSize: 17)),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _contrast() {
    return Column(
      children: [
        const Text('SIDE BY SIDE', style: Txt.label),
        const SizedBox(height: 6),
        const Text(
          'Hear them one after another',
          textAlign: TextAlign.center,
          style: Txt.h1,
        ),
        const SizedBox(height: 8),
        const Text(
          'Telling sounds apart is the skill. Tap each one a few times.',
          textAlign: TextAlign.center,
          style: Txt.body,
        ),
        const SizedBox(height: 24),
        for (final item in widget.items) ...[
          GestureDetector(
            onTap: () =>
                appSynth.play(60, item.steps, stepSeconds: item.stepSeconds),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Pal.blueBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volume_up_rounded, color: Pal.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: Txt.h3),
                        const SizedBox(height: 2),
                        Text(item.blurb, style: Txt.bodyDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _compare(Item item) {
    return Column(
      children: [
        const Text('HEAR IT TWO WAYS', style: Txt.label),
        const SizedBox(height: 6),
        Text(item.name, textAlign: TextAlign.center, style: Txt.h1),
        const SizedBox(height: 8),
        const Text(
          'Notes can sound one after another or all at once. Hear both.',
          textAlign: TextAlign.center,
          style: Txt.body,
        ),
        const SizedBox(height: 28),
        _bigAction('One by one', Icons.east_rounded, () {
          appSynth.play(60, item.apart, stepSeconds: item.stepSeconds * 0.7);
        }),
        const SizedBox(height: 12),
        _bigAction('Together', Icons.unfold_less_rounded, () {
          appSynth.play(60, item.together, stepSeconds: item.stepSeconds * 1.5);
        }),
      ],
    );
  }

  Widget _play(Item item) {
    const roots = [('C', 60), ('E', 64), ('G', 67), ('B♭', 70), ('D', 62)];
    return Column(
      children: [
        const Text('TRY OTHER STARTING NOTES', style: Txt.label),
        const SizedBox(height: 6),
        Text(item.name, textAlign: TextAlign.center, style: Txt.h1),
        const SizedBox(height: 8),
        Text(
          'Same sound, different starting note. Tap a few, then continue '
          'when it feels familiar.',
          textAlign: TextAlign.center,
          style: Txt.body,
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final (name, midi) in roots)
              GestureDetector(
                onTap: () => appSynth.play(
                  midi,
                  item.steps,
                  stepSeconds: item.stepSeconds,
                ),
                child: Container(
                  constraints: const BoxConstraints(minWidth: 64),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Pal.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'From $name',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _bigAction(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Pal.blueBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Pal.blue),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Pal.blue,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
