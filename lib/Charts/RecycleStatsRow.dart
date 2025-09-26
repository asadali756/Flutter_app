import 'package:flutter/material.dart';
import 'package:project/Components/AppColors.dart';

class RecycleStatsRow extends StatelessWidget {
  const RecycleStatsRow({super.key});

  final List<Map<String, dynamic>> materialStats = const [
    {'label': 'Plastic', 'percent': 0.6},
    {'label': 'Steels', 'percent': 0.8},
    {'label': 'Wood', 'percent': 0.4},
    {'label': 'Paper', 'percent': 0.7},
    {'label': 'Extra', 'percent': 0.85},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: materialStats.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(
                    item['label'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepTeal,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: item['percent'],
                      minHeight: 14,
                      backgroundColor: AppColors.iceBlue,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.peach,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${(item['percent'] * 100).toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.paleGreen,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
