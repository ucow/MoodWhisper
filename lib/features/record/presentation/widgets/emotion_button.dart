import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mood_whisper/core/constants/mood_types.dart';
import 'package:mood_whisper/core/theme/theme.dart';

class EmotionButton extends StatefulWidget {
  final MoodType mood;
  final bool isSelected;
  final VoidCallback onTap;

  const EmotionButton({
    super.key,
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<EmotionButton> createState() => _EmotionButtonState();
}

class _EmotionButtonState extends State<EmotionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  @override
  void didUpdateWidget(EmotionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final colorToken = context.colorToken;
    final brightness = Theme.of(context).brightness;
    final moodLevel = _moodToLevel(widget.mood);
    final moodColor = colorToken.mood.forLevel(moodLevel, brightness);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: widget.isSelected ? 1.0 : 0.4,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? moodColor.withOpacity(0.2)
                      : colorToken.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.isSelected ? moodColor : Colors.transparent,
                    width: 2,
                  ),
                  boxShadow: widget.isSelected
                      ? [
                          BoxShadow(
                            color: moodColor.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    widget.mood.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class EmotionButtonBar extends StatelessWidget {
  final MoodType? selectedMood;
  final ValueChanged<MoodType> onSelected;

  const EmotionButtonBar({
    super.key,
    required this.selectedMood,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: MoodType.values.map((mood) {
        return EmotionButton(
          mood: mood,
          isSelected: selectedMood == mood,
          onTap: () => onSelected(mood),
        );
      }).toList(),
    );
  }
}
