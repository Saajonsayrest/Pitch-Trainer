import 'theory.dart';

enum LessonType { learn, checkpoint, exam }

class Lesson {
  const Lesson(this.id, this.title, this.type, this.items);

  final String id;
  final String title;
  final LessonType type;

  /// New items taught in this lesson. Empty for checkpoints and exams.
  final List<Item> items;

  int get questions => switch (type) {
    LessonType.learn => 8,
    LessonType.checkpoint => 10,
    LessonType.exam => 12,
  };

  /// Correct answers needed to pass.
  int get passMark => (questions * 0.8).ceil();
}

class CourseModule {
  const CourseModule(this.title, this.subtitle, this.lessons, this.review);

  final String title;
  final String subtitle;
  final List<Lesson> lessons;

  /// Items from earlier modules that checkpoints and exams also use.
  final List<Item> review;

  /// Everything a lesson can ask about.
  List<Item> poolFor(int lessonIndex) {
    final lesson = lessons[lessonIndex];
    final upTo = lesson.type == LessonType.exam
        ? lessons.length
        : lessonIndex + 1;
    final pool = <Item>[
      if (lesson.type != LessonType.learn) ...review,
      for (var i = 0; i < upTo; i++) ...lessons[i].items,
    ];
    return pool;
  }
}

List<Item> _pick(List<Item> all, List<String> names) => [
  for (final n in names) all.firstWhere((i) => i.name == n),
];

Lesson _learn(String id, String title, List<Item> all, List<String> names) =>
    Lesson(id, title, LessonType.learn, _pick(all, names));

const _check = LessonType.checkpoint;
const _exam = LessonType.exam;

final List<CourseModule> course = _build();

List<CourseModule> _build() {
  final intervalsOne = [
    _learn('i1', 'Fifth and octave', intervals, ['Perfect 5th', 'Octave']),
    _learn('i2', 'Thirds', intervals, ['Major 3rd', 'Minor 3rd']),
    _learn('i3', 'The fourth', intervals, ['Perfect 4th']),
    _learn('i4', 'Seconds', intervals, ['Major 2nd', 'Minor 2nd']),
    const Lesson('i5', 'Checkpoint', _check, []),
  ];
  final firstItems = [for (final l in intervalsOne) ...l.items];

  final intervalsTwo = [
    _learn('j1', 'Sixths', intervals, ['Major 6th', 'Minor 6th']),
    _learn('j2', 'Sevenths', intervals, ['Major 7th', 'Minor 7th']),
    _learn('j3', 'The tritone', intervals, ['Tritone']),
    const Lesson('j4', 'Exam: all intervals', _exam, []),
  ];

  final chordLessons = [
    _learn('c1', 'Major and minor', chords, ['Major', 'Minor']),
    _learn('c2', 'Diminished and augmented', chords, [
      'Diminished',
      'Augmented',
    ]),
    const Lesson('c3', 'Checkpoint', _check, []),
    _learn('c4', 'Suspended', chords, ['Sus4']),
    _learn('c5', 'Seventh chords', chords, [
      'Major 7th chord',
      'Minor 7th chord',
      'Dominant 7th chord',
    ]),
    const Lesson('c6', 'Exam: all chords', _exam, []),
  ];

  final scaleLessons = [
    _learn('s1', 'Major and natural minor', scales, ['Major', 'Natural minor']),
    _learn('s2', 'Harmonic minor', scales, ['Harmonic minor']),
    const Lesson('s3', 'Checkpoint', _check, []),
    _learn('s4', 'Dorian and Mixolydian', scales, ['Dorian', 'Mixolydian']),
    _learn('s5', 'Pentatonic and blues', scales, ['Major pentatonic', 'Blues']),
    const Lesson('s6', 'Exam: all scales', _exam, []),
  ];

  final homeLessons = [
    _learn('d1', 'Home and the 5th', degrees, ['Degree 1', 'Degree 5']),
    _learn('d2', 'The 3rd and 4th', degrees, ['Degree 3', 'Degree 4']),
    _learn('d3', 'The 2nd and 6th', degrees, ['Degree 2', 'Degree 6']),
    _learn('d4', 'The leading note', degrees, ['Degree 7']),
    const Lesson('d5', 'Exam: all degrees', _exam, []),
  ];

  final progressionLessons = [
    _learn('p1', 'Pop starters', progressions, [
      'I – IV – V – I',
      'I – V – vi – IV',
    ]),
    _learn('p2', 'Turnarounds', progressions, [
      'vi – IV – I – V',
      'I – vi – IV – V',
    ]),
    _learn('p3', 'Jazz and rest', progressions, [
      'ii – V – I',
      'I – IV – I – V',
    ]),
    const Lesson('p4', 'Exam: all progressions', _exam, []),
  ];

  return [
    CourseModule('Intervals 1', 'Close and common gaps', intervalsOne, []),
    CourseModule(
      'Intervals 2',
      'Wide and tense gaps',
      intervalsTwo,
      firstItems,
    ),
    CourseModule('Chords', 'Triads and seventh chords', chordLessons, []),
    CourseModule('Scales', 'Major, minor, modes and blues', scaleLessons, []),
    CourseModule('Home note', 'Hear each note against home', homeLessons, []),
    CourseModule(
      'Progressions',
      'Name the chord journey',
      progressionLessons,
      [],
    ),
  ];
}

int get lessonCount => course.fold(0, (a, m) => a + m.lessons.length);

/// A trainer on the home screen. It groups one or more course modules.
class Skill {
  const Skill(this.id, this.title, this.blurb, this.modules, this.items);

  final String id;
  final String title;
  final String blurb;
  final List<CourseModule> modules;

  /// Everything in this skill, for free practice.
  final List<Item> items;

  int get lessonTotal => modules.fold(0, (a, m) => a + m.lessons.length);
}

final List<Skill> skills = [
  Skill('intervals', 'Interval trainer', 'Name the gap between two notes', [
    course[0],
    course[1],
  ], intervals),
  Skill('chords', 'Chord recognition', 'Tell chord types apart', [
    course[2],
  ], chords),
  Skill('scales', 'Scale detection', 'Hear which scale is playing', [
    course[3],
  ], scales),
  Skill('degrees', 'Home note', 'Hear each note against home', [
    course[4],
  ], degrees),
  Skill('progressions', 'Chord progressions', 'Name the chord journey', [
    course[5],
  ], progressions),
];
