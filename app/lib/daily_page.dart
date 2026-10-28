import 'package:flutter/material.dart';

import 'intro_page.dart';
import 'lesson_flow.dart';
import 'quiz_page.dart';
import 'stats.dart';
import 'theme.dart';

/// A short mixed session built from what the learner has already passed.
Future<void> startDaily(BuildContext context, Stats stats) async {
  final nav = Navigator.of(context);
  final go = await nav.push<bool>(
    MaterialPageRoute(
      builder: (_) => IntroPage(
        icon: Icons.wb_sunny_rounded,
        pill: 'Daily session',
        title: "Today's session",
        body:
            'A memory check on what you know, mixed up. '
            '${stats.dailyQuestions} questions, about ${stats.dailyMinutes} minutes.',
        color: Pal.orange,
        bg: Pal.orangeBg,
        button: 'Begin',
      ),
    ),
  );
  if (go != true) return;
  final count = stats.dailyQuestions;
  final right = await nav.push<int>(
    MaterialPageRoute(
      builder: (_) => QuizPage(
        title: "Today's session",
        pool: learnedItems(stats),
        stats: stats,
        skillId: 'daily',
        count: count,
        passMark: (count * 0.5).ceil(),
        pill: 'Daily',
      ),
    ),
  );
  if (right != null && right >= (count * 0.5).ceil()) {
    await stats.finishDaily();
  }
}
