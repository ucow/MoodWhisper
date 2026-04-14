import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/theme/theme.dart';

class ParticleAnimation extends StatefulWidget {
  final MoodType moodType;
  final VoidCallback? onComplete;
  final bool shouldDegrade;

  const ParticleAnimation({
    super.key,
    required this.moodType,
    this.onComplete,
    this.shouldDegrade = false,
  });

  @override
  State<ParticleAnimation> createState() => _ParticleAnimationState();
}

class _ParticleAnimationState extends State<ParticleAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  Stopwatch? _stopwatch;
  bool _degraded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.5).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _stopwatch = Stopwatch()..start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkPerformance();
  }

  void _checkPerformance() {
    if (_stopwatch != null) {
      _stopwatch!.stop();
      final elapsed = _stopwatch!.elapsedMicroseconds;
      if (elapsed > 16000) {
        _degraded = true;
      }
    }
    _stopwatch = null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getMoodColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final moodLevel = _moodToLevel(widget.moodType);
    return context.colorToken.mood.forLevel(moodLevel, brightness);
  }

  MoodLevel _moodToLevel(MoodType type) {
    switch (type) {
      case MoodType.great:
        return MoodLevel.veryGood;
      case MoodType.good:
        return MoodLevel.good;
      case MoodType.neutral:
        return MoodLevel.neutral;
      case MoodType.bad:
        return MoodLevel.bad;
      case MoodType.terrible:
        return MoodLevel.veryBad;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shouldDegrade || _degraded) {
      return _DegradedAnimation(
        controller: _controller,
        scaleAnimation: _scaleAnimation,
        opacityAnimation: _opacityAnimation,
        moodColor: _getMoodColor(context),
        emoji: widget.moodType.emoji,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            progress: _controller.value,
            color: _getMoodColor(context),
            emoji: widget.moodType.emoji,
          ),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class _DegradedAnimation extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;
  final Color moodColor;
  final String emoji;

  const _DegradedAnimation({
    required this.controller,
    required this.scaleAnimation,
    required this.opacityAnimation,
    required this.moodColor,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Opacity(
            opacity: opacityAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: moodColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final String emoji;

  _ParticlePainter({
    required this.progress,
    required this.color,
    required this.emoji,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final random = Random(42);

    final particleCount = 20;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi + random.nextDouble() * 0.5;
      final distance = progress * 80 + random.nextDouble() * 20;
      final particleProgress = (progress - i * 0.02).clamp(0.0, 1.0);

      if (particleProgress <= 0) continue;

      final x = center.dx + cos(angle) * distance;
      final y = center.dy + sin(angle) * distance;

      final paint = Paint()
        ..color = color.withOpacity(particleProgress * 0.8)
        ..style = PaintingStyle.fill;

      final particleSize = (1 - particleProgress) * 8 + 4;
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }

    final centerProgress = (1 - progress * 2).clamp(0.0, 1.0);
    if (centerProgress > 0) {
      final centerPaint = Paint()
        ..color = color.withOpacity(centerProgress)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 24 * centerProgress, centerPaint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class SaveAnimationOverlay extends StatelessWidget {
  final bool isPlaying;
  final MoodType? moodType;
  final VoidCallback? onComplete;
  final bool shouldDegrade;

  const SaveAnimationOverlay({
    super.key,
    required this.isPlaying,
    required this.moodType,
    this.onComplete,
    this.shouldDegrade = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPlaying || moodType == null) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: ParticleAnimation(
            moodType: moodType!,
            onComplete: onComplete,
          ),
        ),
      ),
    );
  }
}
