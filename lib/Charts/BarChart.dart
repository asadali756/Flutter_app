import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';

class VerticalBarChart extends StatelessWidget {
  const VerticalBarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double fontSize = width * 0.035; // scales with width
        final double headingSize = width * 0.045;
        final double barWidth = width * 0.045;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.softWhite,
            borderRadius: BorderRadius.circular(6),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sales Analytics',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepTeal,
                ),
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 1.1,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 80,
                    minY: 0,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: AppColors.deepTeal.withOpacity(0.8),
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${_labels[group.x.toInt()]}: ${rod.toY.toInt()} items',
                            GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: fontSize.clamp(10, 14),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          interval: 20,
                          getTitlesWidget: (value, meta) =>
                              _getLeftTitles(value, meta, fontSize),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 32,
                          getTitlesWidget: (value, meta) =>
                              _getBottomTitles(value, meta, fontSize),
                        ),
                      ),
                      topTitles: AxisTitles(),
                      rightTitles: AxisTitles(),
                    ),
                    gridData: FlGridData(
                      show: true,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey.shade700,
                        strokeWidth: 0.5,
                      ),
                      drawVerticalLine: false,
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade700, width: 1),
                        bottom: BorderSide(color: Colors.grey.shade700, width: 1),
                      ),
                    ),
                    barGroups: _barData(barWidth),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> get _labels => ['Mon', 'Tue', 'Wed', 'Thu'];

  List<BarChartGroupData> _barData(double barWidth) => [
        _barGroup(0, 75, AppColors.peach, barWidth),
        _barGroup(1, 62, AppColors.mint, barWidth),
        _barGroup(2, 85, AppColors.blush, barWidth),
        _barGroup(3, 50, AppColors.cream, barWidth),
      ];

  BarChartGroupData _barGroup(int x, double y, Color color, double width) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: width.clamp(12, 22),
          borderRadius: BorderRadius.circular(1),
          color: color,
        ),
      ],
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta, double fontSize) {
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 6,
      child: Text(
        _labels[value.toInt()],
        style: GoogleFonts.spaceGrotesk(
          fontSize: fontSize.clamp(9, 13),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta, double fontSize) {
    return Text(
      '${value.toInt()}',
      style: GoogleFonts.spaceGrotesk(
        fontSize: fontSize.clamp(9, 13),
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
      textAlign: TextAlign.left,
    );
  }
}
