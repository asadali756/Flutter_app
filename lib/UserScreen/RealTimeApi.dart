import 'package:flutter/material.dart';
import 'package:project/Components/MyAppBar.dart';
import 'package:project/Components/bottomNav.dart';
import 'package:project/PollutionData/KarachiPollutionWidget%20.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EcoMonitorPage extends StatefulWidget {
  const EcoMonitorPage({Key? key}) : super(key: key);

  @override
  State<EcoMonitorPage> createState() => _EcoMonitorPageState();
}

class _EcoMonitorPageState extends State<EcoMonitorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: MyAppBar(),
      bottomNavigationBar: AppBottomNav(currentIndex: 5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // ====== Pollution Widget Section ======
              Text(
                "📊 Live Air Quality",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 10),
              KarachiPollutionWidget(),
              const SizedBox(height: 20),
              // ====== Theory Section ======
              Text(
                "🌱 Air Pollution & Nature Conservation",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Air pollution is one of the major environmental issues affecting human health, wildlife, and the climate. "
                "It is caused by pollutants like PM2.5, PM10, CO, NO₂, SO₂, and O₃. Conserving nature and adopting eco-friendly habits "
                "can significantly reduce pollution and improve our quality of life.",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              // ====== Methods to Save Nature ======
              Text(
                "💡 Ways to Save Nature",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  methodCard("Plant Trees", LucideIcons.trees, Colors.green.shade400),
                  methodCard("Use Public Transport", LucideIcons.bus, Colors.orange.shade400),
                  methodCard("Reduce Plastic", LucideIcons.trash2, Colors.red.shade400),
                  methodCard("Save Water", LucideIcons.droplet, Colors.blue.shade400),
                  methodCard("Use Renewable Energy", LucideIcons.sun, Colors.yellow.shade700),
                  methodCard("Recycle Waste", LucideIcons.recycle, Colors.purple.shade400),
                ],
              ),
              const SizedBox(height: 20),

              // ====== Summary Section ======
              Text(
                "📌 Summary",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Air pollution impacts health and environment. By planting trees, reducing waste, "
                  "using renewable energy, and conserving water, we can protect nature and improve air quality. "
                  "Monitoring pollution helps take timely actions to reduce risks.",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

             
            ],
          ),
        ),
      ),
    );
  }

  // ====== Method Card Builder ======
  Widget methodCard(String title, IconData icon, Color color) {
    return Container(
      width: 140,
      height: 140,

      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
