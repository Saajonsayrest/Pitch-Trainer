import 'package:flutter/material.dart';

import 'stats.dart';
import 'theme.dart';
import 'widgets.dart';

/// Settings. There is no account, so everything here is local.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.stats});

  final Stats stats;

  Future<void> _confirmReset(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Reset progress?'),
        content: const Text(
          'This clears your lessons, points, streak and stats. It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (ok == true) await stats.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pal.bg,
      body: SafeArea(
        child: Column(
          children: [
            const ScreenHeader(
              title: 'Settings',
              subtitle: 'Customize your experience',
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: stats,
                builder: (context, _) => ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  children: [
                    WhiteCard(
                      child: Row(
                        children: [
                          const IconTile(
                            icon: Icons.phone_android_rounded,
                            color: Pal.orange,
                            bg: Pal.orangeBg,
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Saved on this phone', style: Txt.h3),
                                SizedBox(height: 2),
                                Text(
                                  'No account needed. Nothing is sent anywhere.',
                                  style: TextStyle(
                                    color: Pal.slate400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text('DAILY GOAL', style: Txt.label),
                    ),
                    WhiteCard(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final m in const [3, 5, 8, 12, 15])
                            GestureDetector(
                              onTap: () => stats.saveProfile(dailyMinutes: m),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: stats.dailyMinutes == m
                                      ? Pal.blue
                                      : Pal.slate100,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  '$m min',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: stats.dailyMinutes == m
                                        ? Colors.white
                                        : Pal.slate600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text('SOUND', style: Txt.label),
                    ),
                    const WhiteCard(
                      child: Row(
                        children: [
                          IconTile(icon: Icons.graphic_eq_rounded, size: 48),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Warm tone', style: Txt.h3),
                                Text(
                                  'Notes use equal temperament, A = 440 Hz, like a piano.',
                                  style: TextStyle(
                                    color: Pal.slate400,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 10),
                      child: Text('DATA', style: Txt.label),
                    ),
                    WhiteCard(
                      onTap: () => _confirmReset(context),
                      child: const Row(
                        children: [
                          IconTile(
                            icon: Icons.delete_outline_rounded,
                            color: Pal.bad,
                            bg: Pal.badBg,
                            size: 48,
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              'Reset progress',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Pal.bad,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
