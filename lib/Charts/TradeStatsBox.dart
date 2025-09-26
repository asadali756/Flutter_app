import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project/Components/AppColors.dart';
import 'dart:async';

class TradeStatsBox extends StatefulWidget {
  const TradeStatsBox({super.key});

  @override
  State<TradeStatsBox> createState() => _TradeStatsBoxState();
}

class _TradeStatsBoxState extends State<TradeStatsBox> {
  int _counter = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startCounter();
  }

  void _startCounter() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_counter < 98) {
        setState(() {
          _counter++;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.softWhite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Text(
            '$_counter',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 44,
              fontWeight: FontWeight.w900,
              color: AppColors.mint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'EcoCycle.pk | Total Trusted Global Trades',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
