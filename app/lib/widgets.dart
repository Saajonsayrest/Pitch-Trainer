import 'dart:math';

import 'package:flutter/material.dart';

import 'theme.dart';

/// Big orange button with a soft top-to-bottom shine.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final on = onPressed != null;
    return Semantics(
      button: true,
      enabled: on,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 58,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: on
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Pal.orangeTop, Pal.orangeDeep],
                  )
                : null,
            color: on ? null : Pal.line,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: on ? Colors.white : Pal.slate,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

/// White outlined secondary button.
class QuietButton extends StatelessWidget {
  const QuietButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 58,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Pal.line, width: 2),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Pal.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Small rounded back button. Pops by default.
class BackChip extends StatelessWidget {
  const BackChip({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onTap ?? () => Navigator.of(context).maybePop(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Pal.slate100,
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(Icons.chevron_left, color: Pal.slate, size: 24),
        ),
      ),
    );
  }
}

/// Thin rounded progress bar.
class StepBar extends StatelessWidget {
  const StepBar({super.key, required this.value, this.color = Pal.orange});

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: 6,
        color: color,
        backgroundColor: Pal.line,
      ),
    );
  }
}

/// Row of small segments, one per step. Filled up to [done].
class Stepper extends StatelessWidget {
  const Stepper({super.key, required this.steps, required this.done});

  final int steps;
  final int done;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < steps; i++)
          Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: i == steps - 1 ? 0 : 3),
              decoration: BoxDecoration(
                color: i < done ? Pal.orange : Pal.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
      ],
    );
  }
}

/// Top row of a session screen: back button and a stepper.
class SessionHeader extends StatelessWidget {
  const SessionHeader({
    super.key,
    required this.steps,
    required this.done,
    this.onBack,
  });

  final int steps;
  final int done;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Row(
        children: [
          BackChip(onTap: onBack),
          const SizedBox(width: 14),
          Expanded(
            child: Stepper(steps: steps, done: done),
          ),
        ],
      ),
    );
  }
}

/// Title row for a list screen: back chip, centered title, matching space.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        children: [
          Row(
            children: [
              const BackChip(),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Txt.h2,
                ),
              ),
              const SizedBox(width: 36),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(fontSize: 13, color: Pal.slate400),
            ),
          ],
        ],
      ),
    );
  }
}

BoxDecoration cardDecoration({
  double radius = 24,
  Color color = Colors.white,
}) => BoxDecoration(
  color: color,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: const [
    BoxShadow(color: Color(0x0F0F172A), offset: Offset(0, 5), blurRadius: 14),
  ],
);

/// White rounded card with a soft shadow.
class WhiteCard extends StatelessWidget {
  const WhiteCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16),
    this.radius = 24,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: cardDecoration(radius: radius),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Light rounded card without shadow.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Pal.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Tiny uppercase tag such as START or FINAL EXAM.
class Tag extends StatelessWidget {
  const Tag(
    this.text, {
    super.key,
    this.color = Pal.blue,
    this.bg = Pal.blueBg,
  });

  final String text;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Rounded square with an icon, in a soft color.
class IconTile extends StatelessWidget {
  const IconTile({
    super.key,
    required this.icon,
    this.color = Pal.blue,
    this.bg = Pal.blueBg,
    this.size = 52,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Pill with a short label, for streak and points.
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.text,
    this.icon,
    this.color = Pal.blue,
    this.bg = Pal.blueBg,
  });

  final String text;
  final IconData? icon;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

/// Round blue play button.
class PlayCircle extends StatelessWidget {
  const PlayCircle({super.key, required this.onTap, this.size = 96});

  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Play sound',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Pal.blue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Pal.blue.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            Icons.volume_up_rounded,
            color: Colors.white,
            size: size * 0.45,
          ),
        ),
      ),
    );
  }
}

enum OptionState { idle, correct, wrong, dim }

/// One answer choice: letter tile, label and a result mark.
class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.label,
    required this.letter,
    required this.state,
    required this.onTap,
    this.onHear,
  });

  final String label;
  final String letter;
  final OptionState state;
  final VoidCallback onTap;

  /// When set, a speaker button plays an example of this answer.
  final VoidCallback? onHear;

  @override
  Widget build(BuildContext context) {
    final (border, fill, tile, text) = switch (state) {
      OptionState.idle => (Pal.line, Colors.white, Pal.blue, Pal.slate800),
      OptionState.correct => (
        Pal.good200,
        Pal.good50,
        Pal.good400,
        Pal.good700,
      ),
      OptionState.wrong => (Pal.bad200, Pal.bad50, Pal.bad400, Pal.bad700),
      OptionState.dim => (Pal.line, Pal.slate100, Pal.slate300, Pal.slate400),
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tile,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(
                letter,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (state == OptionState.correct)
              const Icon(Icons.check_circle_rounded, color: Pal.good400),
            if (state == OptionState.wrong)
              const Icon(Icons.cancel_rounded, color: Pal.bad400),
            if (onHear != null)
              IconButton(
                tooltip: 'Hear $label',
                onPressed: onHear,
                icon: const Icon(Icons.volume_up_rounded, color: Pal.blue),
              ),
          ],
        ),
      ),
    );
  }
}

/// Selectable card used in onboarding and settings.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.sub,
    this.icon,
  });

  final String label;
  final String? sub;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? Pal.blueBg : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? Pal.blue : Pal.line, width: 1.5),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: selected ? Pal.blue : Pal.slate400),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: selected ? Pal.blue : Pal.slate800,
                    ),
                  ),
                  if (sub != null)
                    Text(
                      sub!,
                      style: const TextStyle(fontSize: 13, color: Pal.slate400),
                    ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: selected ? Pal.blue : Pal.slate300,
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular progress with a number or icon in the middle.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 84,
    this.color = Pal.orange,
    this.child,
  });

  final double value;
  final double size;
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(value.clamp(0.0, 1.0), color),
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color);

  final double value;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 9.0;
    final rect = Offset.zero & size;
    final deflated = rect.deflate(w / 2);
    final base = Paint()
      ..color = Pal.slate100
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;
    canvas.drawArc(deflated, 0, 2 * pi, false, base);
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w;
    canvas.drawArc(deflated, -pi / 2, 2 * pi * value, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}
