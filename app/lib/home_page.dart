import 'package:flutter/material.dart';

import 'course.dart';
import 'daily_page.dart';
import 'settings_page.dart';
import 'skill_page.dart';
import 'stats.dart';
import 'stats_tab.dart';
import 'theme.dart';
import 'widgets.dart';

/// Two tabs: Home and Stats.
class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.stats});

  final Stats stats;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pal.bg,
      body: SafeArea(
        child: IndexedStack(
          index: _tab,
          children: [
            HomeTab(stats: widget.stats),
            StatsTab(stats: widget.stats),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 18) return 'Good afternoon';
  return 'Good evening';
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.stats});

  final Stats stats;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: stats,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Pal.slate400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text('Pitch Trainer REA', style: Txt.h1),
                    ],
                  ),
                ),
                Pill(
                  text: '${stats.streak}',
                  icon: Icons.local_fire_department_rounded,
                  color: Pal.orange,
                  bg: Pal.orangeBg,
                ),
                IconButton(
                  tooltip: 'Settings',
                  icon: const Icon(Icons.settings_outlined, color: Pal.slate),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => SettingsPage(stats: stats),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _daily(context),
            const Padding(
              padding: EdgeInsets.only(top: 28, bottom: 12, left: 4),
              child: Text('TRAIN A SKILL', style: Txt.label),
            ),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [for (final s in skills) _skillCard(context, s)],
            ),
          ],
        );
      },
    );
  }

  Widget _daily(BuildContext context) {
    final done = stats.dailyDoneToday;
    return WhiteCard(
      onTap: () => startDaily(context, stats),
      child: Row(
        children: [
          IconTile(
            icon: done ? Icons.check_rounded : Icons.wb_sunny_rounded,
            color: done ? Pal.good : Pal.orange,
            bg: done ? Pal.goodBg : Pal.orangeBg,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Today's session", style: Txt.h3),
                Text(
                  done
                      ? 'Done for today. Come back tomorrow.'
                      : 'A memory check, ${stats.dailyMinutes} minutes',
                  style: const TextStyle(color: Pal.slate400, fontSize: 14),
                ),
              ],
            ),
          ),
          Tag(
            done ? 'Again' : 'Begin',
            color: done ? Pal.good : Pal.orange,
            bg: done ? Pal.goodBg : Pal.orangeBg,
          ),
        ],
      ),
    );
  }

  Widget _skillCard(BuildContext context, Skill s) {
    final done = [
      for (final m in s.modules)
        for (final l in m.lessons)
          if (stats.done.contains(l.id)) l,
    ].length;
    final width = (MediaQuery.sizeOf(context).width - 40 - 12) / 2;
    return SizedBox(
      width: width,
      child: WhiteCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SkillPage(skill: s, stats: stats),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon: skillIcon(s.id)),
            const SizedBox(height: 14),
            Text(s.title, style: Txt.h3),
            const SizedBox(height: 2),
            Text(
              s.blurb,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Pal.slate400, fontSize: 13),
            ),
            const SizedBox(height: 12),
            StepBar(value: done / s.lessonTotal),
            const SizedBox(height: 6),
            Text(
              '$done of ${s.lessonTotal} lessons',
              style: const TextStyle(color: Pal.slate400, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
