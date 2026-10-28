/// One thing the learner can hear and name: an interval, chord, scale,
/// scale degree or chord progression.
class Item {
  const Item(
    this.name,
    this.blurb,
    this.steps, {
    this.stepSeconds = 0.6,
    this.canSplit = false,
    this.tip = '',
  });

  final String name;

  /// Short teaching text shown before the quiz.
  final String blurb;

  /// A memory trick, such as a song that starts with this sound. Empty if none.
  final String tip;

  /// Each step is a group of notes (semitones above the root) that sound
  /// together. Steps sound one after another.
  final List<List<int>> steps;
  final double stepSeconds;

  /// True when it also makes sense to hear the notes apart and together.
  final bool canSplit;

  List<int> get _all => [for (final s in steps) ...s];
  List<List<int>> get apart => [
    for (final n in _all) [n],
  ];
  List<List<int>> get together => [_all];
}

/// Songs whose first two notes make the interval going up.
const _intervalTips = {
  'Minor 2nd': 'The "Jaws" shark theme.',
  'Major 2nd': 'The first two notes of "Frère Jacques".',
  'Minor 3rd': 'The first two notes of "Greensleeves".',
  'Major 3rd': 'The start of "When the Saints Go Marching In".',
  'Perfect 4th': 'The first two notes of "Here Comes the Bride".',
  'Tritone': 'The first two notes of "The Simpsons" theme.',
  'Perfect 5th': 'The first two notes of the "Star Wars" main theme.',
  'Minor 6th': 'The first two notes of the "Love Story" theme.',
  'Major 6th': 'The first two notes of "My Bonnie Lies Over the Ocean".',
  'Minor 7th': 'The first two notes of "Somewhere" from West Side Story.',
  'Major 7th': 'The "Take On Me" chorus.',
  'Octave': 'The first two notes of "Somewhere Over the Rainbow".',
};

const _chordTips = {
  'Major': 'Listen for brightness, like a happy ending.',
  'Minor': 'Listen for sadness, like a quiet goodbye.',
  'Diminished': 'Listen for a tight, nervous feeling that wants to move.',
  'Augmented': 'Listen for a dreamy, floating feeling.',
  'Sus4': 'Listen for a question. It wants to settle on a major chord.',
  'Major 7th chord': 'Listen for a major chord with a soft, shiny glow on top.',
  'Minor 7th chord': 'Listen for a minor chord that is calm, not sad.',
  'Dominant 7th chord': 'Listen for a major chord that wants to go somewhere.',
};

Item _interval(String name, String blurb, int semis) => Item(
  name,
  blurb,
  [
    [0],
    [semis],
  ],
  stepSeconds: 0.7,
  canSplit: true,
  tip: _intervalTips[name] ?? '',
);

Item _chord(String name, String blurb, List<int> notes) => Item(
  name,
  blurb,
  [notes],
  stepSeconds: 1.2,
  canSplit: true,
  tip: _chordTips[name] ?? '',
);

Item _scale(String name, String blurb, List<int> notes) => Item(name, blurb, [
  for (final n in notes) [n],
], stepSeconds: 0.35);

const _major = [0, 2, 4, 5, 7, 9, 11];

int _scaleNote(int index) => _major[index % 7] + (index ~/ 7) * 12;

/// Triad built on a major-scale degree (1 to 7).
List<int> _triad(int degree) {
  final d = degree - 1;
  return [_scaleNote(d), _scaleNote(d + 2), _scaleNote(d + 4)];
}

const _solfege = ['Do', 'Re', 'Mi', 'Fa', 'Sol', 'La', 'Ti'];

Item _degree(int degree, String blurb) => Item(
  'Degree $degree',
  blurb,
  [
    [0],
    [_major[degree - 1]],
  ],
  stepSeconds: 0.8,
  tip:
      'Sing "Do Re Mi Fa Sol La Ti". This note is number $degree: '
      '"${_solfege[degree - 1]}". Home is always "Do".',
);

Item _progression(String name, String blurb, List<int> degrees) =>
    Item(name, blurb, [for (final d in degrees) _triad(d)], stepSeconds: 1.0);

final intervals = <Item>[
  _interval('Minor 2nd', 'The smallest step. Tight and tense.', 1),
  _interval(
    'Major 2nd',
    'A whole step. Open and ordinary, like a scale step.',
    2,
  ),
  _interval(
    'Minor 3rd',
    'A soft, sad-leaning gap. The heart of a minor chord.',
    3,
  ),
  _interval('Major 3rd', 'A bright, happy gap. The heart of a major chord.', 4),
  _interval(
    'Perfect 4th',
    'Stable and open, a little like asking a question.',
    5,
  ),
  _interval('Tritone', 'Exactly half an octave. Restless and unsettled.', 6),
  _interval(
    'Perfect 5th',
    'The most stable leap after the octave. Strong and hollow.',
    7,
  ),
  _interval('Minor 6th', 'Wide and wistful, with a dark glow.', 8),
  _interval('Major 6th', 'Wide and warm, with a hopeful lift.', 9),
  _interval('Minor 7th', 'Almost an octave. Bluesy and leaning forward.', 10),
  _interval(
    'Major 7th',
    'A half step below the octave. Dreamy and wanting to resolve.',
    11,
  ),
  _interval(
    'Octave',
    'The same note name, twelve half steps higher. The two notes blend almost into one.',
    12,
  ),
];

final chords = <Item>[
  _chord('Major', 'Bright and happy. A major third under a minor third.', [
    0,
    4,
    7,
  ]),
  _chord('Minor', 'Darker and sadder. A minor third under a major third.', [
    0,
    3,
    7,
  ]),
  _chord('Diminished', 'Tense and cramped. Two minor thirds stacked.', [
    0,
    3,
    6,
  ]),
  _chord('Augmented', 'Strange and floating. Two major thirds stacked.', [
    0,
    4,
    8,
  ]),
  _chord('Sus4', 'Hangs in the air. The fourth takes the place of the third.', [
    0,
    5,
    7,
  ]),
  _chord('Major 7th chord', 'A major chord with a dreamy, jazzy top.', [
    0,
    4,
    7,
    11,
  ]),
  _chord('Minor 7th chord', 'A minor chord that sounds smooth and mellow.', [
    0,
    3,
    7,
    10,
  ]),
  _chord('Dominant 7th chord', 'A major chord with a bluesy pull to move on.', [
    0,
    4,
    7,
    10,
  ]),
];

final scales = <Item>[
  _scale(
    'Major',
    'The bright, familiar scale. Whole and half steps in a happy order.',
    [0, 2, 4, 5, 7, 9, 11, 12],
  ),
  _scale(
    'Natural minor',
    'The sad, serious cousin of major. Lowered 3rd, 6th and 7th.',
    [0, 2, 3, 5, 7, 8, 10, 12],
  ),
  _scale(
    'Harmonic minor',
    'Minor with a raised 7th. Dramatic, with a big gap near the top.',
    [0, 2, 3, 5, 7, 8, 11, 12],
  ),
  _scale('Dorian', 'Minor, but with a bright 6th. Cool and jazzy.', [
    0,
    2,
    3,
    5,
    7,
    9,
    10,
    12,
  ]),
  _scale('Mixolydian', 'Major, but with a flat 7th. Relaxed and rootsy.', [
    0,
    2,
    4,
    5,
    7,
    9,
    10,
    12,
  ]),
  _scale(
    'Major pentatonic',
    'Five notes only. Open, simple and hard to get wrong.',
    [0, 2, 4, 7, 9, 12],
  ),
  _scale('Blues', 'Minor pentatonic plus a blue note. Gritty and expressive.', [
    0,
    3,
    5,
    6,
    7,
    10,
    12,
  ]),
];

final degrees = <Item>[
  _degree(1, 'This is home. Every other note is measured from here.'),
  _degree(
    2,
    'A whole step above home. It sounds unfinished and often resolves down to home.',
  ),
  _degree(
    3,
    'The major third above home. In a minor key it would be lowered, which is what makes minor sound darker.',
  ),
  _degree(4, 'Leans down toward the 3rd. Calm but not finished.'),
  _degree(
    5,
    'Strong and stable. A perfect fifth above home, also called the dominant.',
  ),
  _degree(6, 'Warm and open. The relative minor key starts on this note.'),
  _degree(
    7,
    'The leading note, one half step below home. It pulls strongly up to home.',
  ),
];

final progressions = <Item>[
  _progression(
    'I – IV – V – I',
    'The classic. Leave home, build up, then return.',
    [1, 4, 5, 1],
  ),
  _progression(
    'I – V – vi – IV',
    'Modern and bright. A very common pop loop.',
    [1, 5, 6, 4],
  ),
  _progression(
    'vi – IV – I – V',
    'The same four chords, starting sad and ending open.',
    [6, 4, 1, 5],
  ),
  _progression('I – vi – IV – V', 'A warm, old-fashioned turnaround.', [
    1,
    6,
    4,
    5,
  ]),
  _progression(
    'ii – V – I',
    'The jazz cadence. A smooth three-step landing at home.',
    [2, 5, 1],
  ),
  _progression('I – IV – I – V', 'Relaxed back-and-forth that ends hanging.', [
    1,
    4,
    1,
    5,
  ]),
];
