import 'package:flutter/material.dart';

import 'home_page.dart';
import 'onboarding_page.dart';
import 'stats.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final stats = Stats();
  await stats.load();
  runApp(PitchTrainerApp(stats: stats));
}

class PitchTrainerApp extends StatelessWidget {
  const PitchTrainerApp({super.key, required this.stats});

  final Stats stats;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pitch Trainer REA',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: ListenableBuilder(
        listenable: stats,
        builder: (context, _) => stats.onboarded
            ? HomePage(stats: stats)
            : OnboardingPage(stats: stats),
      ),
    );
  }
}
