import 'package:flutter/material.dart';

import 'course.dart';
import 'lesson_flow.dart';
import 'stats.dart';
import 'theme.dart';
import 'widgets.dart';

IconData skillIcon(String id) => switch (id) {
  'intervals' => Icons.swap_vert_rounded,
  'chords' => Icons.piano_rounded,
  'scales' => Icons.stairs_rounded,
  'degrees' => Icons.home_rounded,
  _ => Icons.route_rounded,
};

/// The lessons of one skill, with free practice on top.
class SkillPage extends StatelessWidget {
  const SkillPage({super.key, required this.skill, required this.stats});

  final Skill skill;
  final Stats stats;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pal.bg,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: stats,
          builder: (context, _) {
            final done = [
              for (final m in skill.modules)
                for (final l in m.lessons)
                  if (stats.done.contains(l.id)) l,
            ].length;
            return Column(
              children: [
                ScreenHeader(
                  title: skill.title,
                  subtitle: '$done of ${skill.lessonTotal} lessons done',
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    children: [
                      WhiteCard(
                        onTap: () => startPractice(context, skill, stats),
                        child: Row(
                          children: [
                            const IconTile(
                              icon: Icons.all_inclusive_rounded,
                              color: Pal.orange,
                              bg: Pal.orangeBg,
                              size: 48,
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Free practice', style: Txt.h3),
                                  Text(
                                    'Unlimited questions',
                                    style: TextStyle(
                                      color: Pal.slate400,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Tag(
                              'Play',
                              color: Pal.orange,
                              bg: Pal.orangeBg,
                            ),
                          ],
                        ),
                      ),
                      for (final m in skill.modules) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 10),
                          child: Text(m.title.toUpperCase(), style: Txt.label),
                        ),
                        for (var i = 0; i < m.lessons.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _row(context, m, i),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _row(BuildContext context, CourseModule m, int i) {
    final lesson = m.lessons[i];
    final isDone = stats.done.contains(lesson.id);
    final isTried = stats.tried.contains(lesson.id);
    final (label, color, bg) = isDone
        ? ('Review', Pal.good, Pal.goodBg)
        : isTried
        ? ('Try again', Pal.bad, Pal.badBg)
        : ('Start', Pal.blue, Pal.blueBg);
    final body = switch (lesson.type) {
      LessonType.learn => lesson.items.map((e) => e.name).join(' · '),
      LessonType.checkpoint => 'Mixed check of this part so far',
      LessonType.exam => 'Everything in this part, mixed',
    };
    final special = lesson.type != LessonType.learn;
    return WhiteCard(
      onTap: () => startLesson(context, skill, m, i, stats),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (special) ...[
                  Tag(
                    lesson.type == LessonType.exam
                        ? 'Final exam'
                        : 'Checkpoint',
                    color: Pal.orange,
                    bg: Pal.orangeBg,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  lesson.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Txt.h3,
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Pal.slate400, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Tag(label, color: color, bg: bg),
        ],
      ),
    );
  }
}
