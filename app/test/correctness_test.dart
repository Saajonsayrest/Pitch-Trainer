import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:pitch_trainer_rea/course.dart';
import 'package:pitch_trainer_rea/practice_page.dart';
import 'package:pitch_trainer_rea/synth.dart';
import 'package:pitch_trainer_rea/theory.dart';

/// Loudness of [samples] at [hz], via the Goertzel method.
double _power(List<double> samples, double hz) {
  final w = 2 * pi * hz / wavSampleRate;
  final c = 2 * cos(w);
  var s1 = 0.0, s2 = 0.0;
  for (final x in samples) {
    final s = x + c * s1 - s2;
    s2 = s1;
    s1 = s;
  }
  return s1 * s1 + s2 * s2 - c * s1 * s2;
}

List<double> _samples(Uint8List wav) {
  final d = ByteData.sublistView(wav);
  return [
    for (var i = 44; i < wav.length; i += 2)
      d.getInt16(i, Endian.little) / 32768,
  ];
}

/// Strongest frequency near [guess], searched in 0.05 Hz steps.
double _peak(List<double> samples, double guess) {
  var best = guess, bestPower = -1.0;
  for (var hz = guess - 3; hz <= guess + 3; hz += 0.05) {
    final p = _power(samples, hz);
    if (p > bestPower) {
      bestPower = p;
      best = hz;
    }
  }
  return best;
}

List<int> _gaps(List<int> notes) => [
  for (var i = 1; i < notes.length; i++) notes[i] - notes[i - 1],
];

void main() {
  group('tuning', () {
    test('A4 is 440 Hz and middle C is 261.63 Hz', () {
      expect(midiToHz(69), closeTo(440.0, 1e-9));
      expect(midiToHz(60), closeTo(261.6256, 1e-3));
    });

    test('every octave doubles the pitch', () {
      for (var m = 40; m < 80; m++) {
        expect(midiToHz(m + 12) / midiToHz(m), closeTo(2.0, 1e-9));
      }
    });

    test('the audio really sounds at the requested pitch', () {
      for (final midi in [48, 53, 60, 64, 69, 76]) {
        final wav = buildWav(midi, [
          [0],
        ], 1.5);
        final heard = _peak(_samples(wav), midiToHz(midi));
        expect(
          (heard - midiToHz(midi)).abs(),
          lessThan(0.3),
          reason: 'midi $midi heard at $heard Hz',
        );
      }
    });

    test('every interval has the right frequency ratio', () {
      for (final i in intervals) {
        final semis = i.steps[1][0];
        final low = _peak(
          _samples(
            buildWav(57, [
              [0],
            ], 1.5),
          ),
          midiToHz(57),
        );
        final high = _peak(
          _samples(
            buildWav(57, [
              [semis],
            ], 1.5),
          ),
          midiToHz(57 + semis),
        );
        final cents = 1200 * log(high / low) / ln2;
        expect(
          (cents - semis * 100).abs(),
          lessThan(3),
          reason: '${i.name}: $cents cents',
        );
      }
    });

    test('a chord contains every one of its notes', () {
      for (final c in chords) {
        final s = _samples(buildWav(60, [c.steps[0]], 1.5));
        for (final n in c.steps[0]) {
          final hz = midiToHz(60 + n);
          expect(
            _power(s, hz),
            greaterThan(_power(s, hz * 1.03) * 5),
            reason: '${c.name} note +$n',
          );
        }
      }
    });

    test('audio is not clipped and has the right length', () {
      for (final i in [...intervals, ...chords, ...scales, ...progressions]) {
        final wav = buildWav(64, i.steps, i.stepSeconds);
        final peak = _samples(wav).map((x) => x.abs()).reduce(max);
        expect(peak, lessThan(0.95), reason: i.name);
        final expected =
            i.steps.length * (i.stepSeconds * wavSampleRate).round() * 2 + 44;
        expect(wav.length, expected, reason: i.name);
      }
    });
  });

  group('music theory', () {
    test(
      'intervals are 1 to 12 half steps, in order, with the right names',
      () {
        expect(
          [for (final i in intervals) i.steps[1][0]],
          [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        );
        expect(
          [for (final i in intervals) i.name],
          [
            'Minor 2nd',
            'Major 2nd',
            'Minor 3rd',
            'Major 3rd',
            'Perfect 4th',
            'Tritone',
            'Perfect 5th',
            'Minor 6th',
            'Major 6th',
            'Minor 7th',
            'Major 7th',
            'Octave',
          ],
        );
      },
    );

    test('chords are built from the right stacked thirds', () {
      final built = {for (final c in chords) c.name: c.steps[0]};
      expect(built['Major'], [0, 4, 7]);
      expect(built['Minor'], [0, 3, 7]);
      expect(built['Diminished'], [0, 3, 6]);
      expect(built['Augmented'], [0, 4, 8]);
      expect(built['Sus4'], [0, 5, 7]);
      expect(built['Major 7th chord'], [0, 4, 7, 11]);
      expect(built['Minor 7th chord'], [0, 3, 7, 10]);
      expect(built['Dominant 7th chord'], [0, 4, 7, 10]);
    });

    test('scales follow the right pattern of steps', () {
      final gaps = {
        for (final s in scales) s.name: _gaps([for (final x in s.steps) x[0]]),
      };
      expect(gaps['Major'], [2, 2, 1, 2, 2, 2, 1]);
      expect(gaps['Natural minor'], [2, 1, 2, 2, 1, 2, 2]);
      expect(gaps['Harmonic minor'], [2, 1, 2, 2, 1, 3, 1]);
      expect(gaps['Dorian'], [2, 1, 2, 2, 2, 1, 2]);
      expect(gaps['Mixolydian'], [2, 2, 1, 2, 2, 1, 2]);
      expect(gaps['Major pentatonic'], [2, 2, 3, 2, 3]);
      expect(gaps['Blues'], [3, 2, 1, 1, 3, 2]);
    });

    test('every scale spans exactly one octave', () {
      for (final s in scales) {
        expect(s.steps.last[0] - s.steps.first[0], 12, reason: s.name);
      }
    });

    test('degrees sit on the major scale', () {
      expect([for (final d in degrees) d.steps[1][0]], [0, 2, 4, 5, 7, 9, 11]);
      expect(
        [for (final d in degrees) d.name],
        [for (var n = 1; n <= 7; n++) 'Degree $n'],
      );
    });

    String quality(List<int> triad) {
      final g = _gaps(triad);
      if (g[0] == 4 && g[1] == 3) return 'major';
      if (g[0] == 3 && g[1] == 4) return 'minor';
      if (g[0] == 3 && g[1] == 3) return 'diminished';
      return 'other';
    }

    test('progression chords have the right quality for their numeral', () {
      // Capital numerals are major, lower case are minor.
      const numerals = {'I': 0, 'ii': 1, 'IV': 3, 'V': 4, 'vi': 5};
      const scaleNotes = [0, 2, 4, 5, 7, 9, 11];
      for (final p in progressions) {
        final names = p.name.split(' – ');
        expect(names.length, p.steps.length, reason: p.name);
        for (var i = 0; i < names.length; i++) {
          final n = names[i];
          final degree = numerals[n]!;
          expect(
            p.steps[i].first,
            scaleNotes[degree],
            reason: '${p.name} chord $n root',
          );
          expect(
            quality(p.steps[i]),
            n == n.toLowerCase() ? 'minor' : 'major',
            reason: '${p.name} chord $n',
          );
        }
      }
    });
  });

  group('course', () {
    test('every lesson id is unique', () {
      final ids = [
        for (final m in course)
          for (final l in m.lessons) l.id,
      ];
      expect(ids.toSet().length, ids.length);
    });

    test(
      'every lesson can be asked and every learn lesson teaches something',
      () {
        for (final m in course) {
          for (var i = 0; i < m.lessons.length; i++) {
            expect(m.poolFor(i), isNotEmpty, reason: m.lessons[i].title);
            if (m.lessons[i].type == LessonType.learn) {
              expect(m.lessons[i].items, isNotEmpty);
            }
          }
        }
      },
    );

    test('answer buttons never show the same name twice', () {
      for (final m in course) {
        for (var i = 0; i < m.lessons.length; i++) {
          final names = [for (final it in m.poolFor(i)) it.name];
          expect(
            names.toSet().length,
            names.length,
            reason: '${m.title} / ${m.lessons[i].title}',
          );
        }
      }
    });

    test('every item in the app is taught exactly once', () {
      final taught = [
        for (final m in course)
          for (final l in m.lessons) ...l.items.map((e) => e.name),
      ];
      final all = [
        ...intervals,
        ...chords,
        ...scales,
        ...degrees,
        ...progressions,
      ];
      expect(taught.length, all.length);
    });

    test('intervals, chords and degrees all have a memory tip', () {
      for (final it in [...intervals, ...chords, ...degrees]) {
        expect(it.tip, isNotEmpty, reason: it.name);
      }
    });
  });

  group('guided practice', () {
    final rng = Random(1);

    test('asks every new item at least twice', () {
      for (final m in course) {
        for (var i = 0; i < m.lessons.length; i++) {
          final l = m.lessons[i];
          if (l.type != LessonType.learn) continue;
          final plan = practicePlan(l.items, m.poolFor(i), rng);
          for (final it in l.items) {
            expect(
              plan.where((p) => p.name == it.name).length,
              greaterThanOrEqualTo(2),
              reason: '${l.title}: ${it.name}',
            );
          }
        }
      }
    });

    test('a lesson with one new item is topped up with older ones', () {
      final m = course[0];
      final i = m.lessons.indexWhere((l) => l.id == 'i3');
      final plan = practicePlan(m.lessons[i].items, m.poolFor(i), rng);
      expect(plan.length, 5);
      expect(plan.map((p) => p.name).toSet().length, greaterThan(1));
    });
  });
}
