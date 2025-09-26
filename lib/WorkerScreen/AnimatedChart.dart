import 'package:flutter/material.dart';
import 'package:project/Components/AppColors.dart';

class AnimatedTaskChart extends StatefulWidget {
  const AnimatedTaskChart({super.key});

  @override
  State<AnimatedTaskChart> createState() => _AnimatedTaskChartState();
}

class _AnimatedTaskChartState extends State<AnimatedTaskChart> with TickerProviderStateMixin {
  final List<int> taskValues = [2, 4, 10, 8];
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu'];

  final List<Color> barColors = [
    AppColors.peach,
    AppColors.blush,
    AppColors.mint,
    AppColors.cream,
  ];

  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(taskValues.length, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
      );
    });

    _animations = List.generate(taskValues.length, (index) {
      return Tween<double>(begin: 0, end: taskValues[index] * 10.0).animate(
        CurvedAnimation(parent: _controllers[index], curve: Curves.easeOut),
      );
    });

    for (var controller in _controllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(taskValues.length, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    days[index],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.deepTeal,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(149, 213, 233, 237),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _animations[index],
                        builder: (context, child) {
                          return Container(
                            height: 20,
                            width: _animations[index].value,
                            decoration: BoxDecoration(
                              color: barColors[index],
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 6,
                        top: 2,
                        child: Text(
                          '${taskValues[index]}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.deepTeal,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
