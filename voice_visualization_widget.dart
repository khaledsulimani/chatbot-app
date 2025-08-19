import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class VoiceVisualizationWidget extends StatefulWidget {
  const VoiceVisualizationWidget({super.key});

  @override
  State<VoiceVisualizationWidget> createState() => _VoiceVisualizationWidgetState();
}

class _VoiceVisualizationWidgetState extends State<VoiceVisualizationWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _barControllers;
  final int _barCount = 20;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _barControllers = List.generate(
      _barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 50)),
        vsync: this,
      ),
    );

    _startAnimation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startAnimation() {
    _animationController.repeat();
    for (int i = 0; i < _barControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _barControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_barCount, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  child: AnimatedBuilder(
                    animation: _barControllers[index],
                    builder: (context, child) {
                      final height = 4 + (30 * _barControllers[index].value);
                      return Container(
                        width: 3,
                        height: height,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(
                            0.5 + (0.5 * _barControllers[index].value),
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController.value * 2 * math.pi,
                child: Icon(
                  Icons.graphic_eq,
                  color: theme.colorScheme.primary.withOpacity(0.7),
                  size: 20,
                ),
              );
            },
          ),
        ],
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms)
        .then()
        .fadeIn(duration: 300.ms);
  }
}
