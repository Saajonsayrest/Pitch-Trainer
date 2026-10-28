import 'package:flutter/material.dart';

import 'theme.dart';
import 'widgets.dart';

/// Full-screen opener for a lesson, checkpoint, exam or daily session.
class IntroPage extends StatelessWidget {
  const IntroPage({
    super.key,
    required this.icon,
    required this.pill,
    required this.title,
    required this.body,
    this.color = Pal.blue,
    this.bg = Pal.blueBg,
    this.button = 'Continue',
  });

  final IconData icon;
  final String pill;
  final String title;
  final String body;
  final Color color;
  final Color bg;
  final String button;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: BackChip(onTap: () => Navigator.of(context).pop(false)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconTile(icon: icon, color: color, bg: bg, size: 88),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        pill.toUpperCase(),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(title, textAlign: TextAlign.center, style: Txt.h1),
                    const SizedBox(height: 8),
                    Text(body, textAlign: TextAlign.center, style: Txt.body),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: PrimaryButton(
                label: button,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
