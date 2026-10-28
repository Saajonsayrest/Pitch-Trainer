import 'package:flutter/material.dart';

import 'course.dart';
import 'skill_page.dart';
import 'stats.dart';
import 'theme.dart';
import 'widgets.dart';

/// The Stats tab. Before any practice it shows three steps to unlock it.
class StatsTab extends StatelessWidget {
  const StatsTab({super.key, required this.stats});

  final Stats stats;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stats,
      builder: (context, _) {
        final unlocked = stats.total > 0;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            const Text('Stats', style: Txt.h1),
            const SizedBox(height: 2),
            const Text(
              'Your progress so far',
              style: TextStyle(color: Pal.slate400),
            ),
            const SizedBox(height: 20),
            if (!unlocked) _locked() else ..._unlocked(),
          ],
        );
      },
    );
  }

  Widget _locked() {
    final steps = [
      ('Finish a lesson', stats.done.isNotEmpty),
      ('Answer your first question', stats.total > 0),
      ('Practice 2 days in a row', stats.streak >= 2),
    ];
    return WhiteCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Unlock your stats in 3 steps', style: Txt.h3),
          const SizedBox(height: 14),
          for (final (label, ok) in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(
                    ok
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked,
                    color: ok ? Pal.good400 : Pal.slate300,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 16, color: Pal.slate600),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _unlocked() {
    final pct = (100 * stats.correct / stats.total).round();
    final lessonsDone = stats.done.length;
    final week = stats.weekPips;
    const names = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return [
      WhiteCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            ProgressRing(
              value: lessonsDone / lessonCount,
              child: Text(
                '${(100 * lessonsDone / lessonCount).round()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MASTERY', style: Txt.label),
                  Text(
                    '$lessonsDone of $lessonCount',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: Pal.slate800,
                    ),
                  ),
                  const Text(
                    'lessons passed',
                    style: TextStyle(color: Pal.slate400, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _tile(
              Icons.bolt_rounded,
              '${stats.xp}',
              'Total XP',
              Pal.blue,
              Pal.blueBg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _tile(
              Icons.check_circle_rounded,
              '$pct%',
              'Accuracy',
              Pal.good,
              Pal.goodBg,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      WhiteCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: Text('This week', style: Txt.h3)),
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Pal.orange,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  '${stats.streak} day streak',
                  style: const TextStyle(
                    color: Pal.orange,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 7; i++)
                  Column(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: week[i] ? Pal.orange : Pal.slate100,
                          shape: BoxShape.circle,
                        ),
                        child: week[i]
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 18,
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        names[i],
                        style: const TextStyle(
                          color: Pal.slate400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 24, bottom: 12, left: 4),
        child: Text('By trainer', style: Txt.h2),
      ),
      for (final s in skills)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WhiteCard(
            child: Row(
              children: [
                IconTile(icon: skillIcon(s.id), size: 44),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title, style: Txt.h3),
                      Text(
                        _summary(s),
                        style: const TextStyle(
                          color: Pal.slate400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  stats.skill[s.id] == null
                      ? '–'
                      : '${(100 * stats.accuracyOf(s.id)).round()}%',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Pal.slate600,
                  ),
                ),
              ],
            ),
          ),
        ),
    ];
  }

  String _summary(Skill s) {
    final done = [
      for (final m in s.modules)
        for (final l in m.lessons)
          if (stats.done.contains(l.id)) l,
    ].length;
    final answered = stats.skill[s.id]?[1] ?? 0;
    return '$done of ${s.lessonTotal} lessons · $answered answers';
  }

  Widget _tile(
    IconData icon,
    String value,
    String label,
    Color color,
    Color bg,
  ) {
    return WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: icon, color: color, bg: bg, size: 40),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Pal.slate800,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Pal.slate400, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
