import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';

class PieChartWidget extends StatelessWidget {
  const PieChartWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double radius = width * 0.15; // dynamically sized radius
        final double fontSize = width * 0.035; // scales with width
        final double titleFontSize = width * 0.04;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.softWhite,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Worker Attendance',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: titleFontSize.clamp(12, 20),
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepTeal,
                ),
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: width * 0.08,
                    borderData: FlBorderData(show: false),
                    sections: _getSections(radius, fontSize),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildLegend(fontSize),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _getSections(double radius, double fontSize) {
    return [
      PieChartSectionData(
        color: AppColors.mint,
        value: 60,
        title: '60%',
        titleStyle: GoogleFonts.spaceGrotesk(
          fontSize: fontSize.clamp(8, 14),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: radius,
      ),
      PieChartSectionData(
        color: AppColors.peach,
        value: 25,
        title: '25%',
        titleStyle: GoogleFonts.spaceGrotesk(
          fontSize: fontSize.clamp(8, 14),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: radius,
      ),
      PieChartSectionData(
        color: AppColors.blush,
        value: 15,
        title: '15%',
        titleStyle: GoogleFonts.spaceGrotesk(
          fontSize: fontSize.clamp(8, 14),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        radius: radius,
      ),
    ];
  }

  Widget _buildLegend(double fontSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(AppColors.mint, 'Present', fontSize),
        _legendItem(AppColors.peach, 'Absent', fontSize),
        _legendItem(AppColors.blush, 'On Leave', fontSize),
      ],
    );
  }

  Widget _legendItem(Color color, String text, double fontSize) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            fontSize: fontSize.clamp(8, 12),
            color: AppColors.deepTeal,
          ),
        ),
      ],
    );
  }
}
