import 'package:flutter/material.dart';

import 'course.dart';
import 'intro_page.dart';
import 'practice_page.dart';
import 'quiz_page.dart';
import 'stats.dart';
import 'teach_page.dart';
import 'theme.dart';
import 'theory.dart';

/// Intro, then teaching and guided practice (for learn lessons), then the
/// scored quiz. Saves the result of the quiz only.
Future<void> startLesson(
  BuildContext context,
  Skill skill,
  CourseModule module,
  int index,
  Stats stats,
) async {
  final lesson = module.lessons[index];
  final nav = Navigator.of(context);
  final isLearn = lesson.type == LessonType.learn;
  final (icon, pill) = switch (lesson.type) {
    LessonType.learn => (Icons.music_note_rounded, 'New lesson'),
    LessonType.checkpoint => (Icons.flag_rounded, 'Checkpoint'),
    LessonType.exam => (Icons.workspace_premium_rounded, 'Final exam'),
  };
  final body = switch (lesson.type) {
    LessonType.learn =>
      'Meet ${lesson.items.length == 1 ? 'a new sound' : '${lesson.items.length} new sounds'}, '
          'practise with help, then take a short test of ${lesson.questions} questions.',
    LessonType.checkpoint =>
      'A mixed check of what you have learned so far. Get '
          '${lesson.passMark} of ${lesson.questions} right to pass.',
    LessonType.exam =>
      'Everything in this part, mixed together. Get '
          '${lesson.passMark} of ${lesson.questions} right to pass.',
  };
  final go = await nav.push<bool>(
    MaterialPageRoute(
      builder: (_) => IntroPage(
        icon: icon,
        pill: pill,
        title: lesson.title,
        body: body,
        color: isLearn ? Pal.blue : Pal.orange,
        bg: isLearn ? Pal.blueBg : Pal.orangeBg,
      ),
    ),
  );
  if (go != true) return;
  if (isLearn) {
    final ready = await nav.push<bool>(
      MaterialPageRoute(
        builder: (_) => TeachPage(title: lesson.title, items: lesson.items),
      ),
    );
    if (ready != true) return;
    final practised = await nav.push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            PracticePage(focus: lesson.items, pool: module.poolFor(index)),
      ),
    );
    if (practised != true) return;
  }
  final right = await nav.push<int>(
    MaterialPageRoute(
      builder: (_) => QuizPage(
        title: lesson.title,
        pool: module.poolFor(index),
        focus: lesson.items,
        stats: stats,
        skillId: skill.id,
        count: lesson.questions,
        passMark: lesson.passMark,
        pill: pill,
      ),
    ),
  );
  if (right != null) {
    await stats.finishLesson(lesson.id, right >= lesson.passMark);
  }
}

/// Free practice with no end.
void startPractice(BuildContext context, Skill skill, Stats stats) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => QuizPage(
        title: skill.title,
        pool: skill.items,
        stats: stats,
        skillId: skill.id,
      ),
    ),
  );
}

/// Items from every lesson the learner has passed. Falls back to the first
/// lesson so a new learner can still try a daily session.
List<Item> learnedItems(Stats stats) {
  final out = <Item>[];
  for (final s in skills) {
    for (final m in s.modules) {
      for (final l in m.lessons) {
        if (stats.done.contains(l.id)) out.addAll(l.items);
      }
    }
  }
  if (out.isEmpty) out.addAll(course.first.lessons.first.items);
  return out.toSet().toList();
}
