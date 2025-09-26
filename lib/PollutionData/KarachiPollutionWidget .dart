import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:project/Service/pollution_service.dart';

class KarachiPollutionWidget extends StatefulWidget {
  const KarachiPollutionWidget({super.key});

  @override
  State<KarachiPollutionWidget> createState() => _KarachiPollutionWidgetState();
}

class _KarachiPollutionWidgetState extends State<KarachiPollutionWidget> {
  Map<String, dynamic>? pollutionData;
  String selectedCity = 'karachi';

  final List<String> cities = [
    'karachi',
    'lahore',
    'islamabad',
    // 'quetta',
    'peshawar',
    // 'multan',
  ];

  final Map<String, String> cityImages = {
    'karachi': 'assets/images/karachi.png',
    'lahore': 'assets/images/lahore.png',
    'islamabad': 'assets/images/faisal.png',
    // 'quetta': 'assets/images/Quetta.png',
    'peshawar': 'assets/images/peshawar.png',
    // 'multan': 'assets/images/multan.png',
  };

  @override
  void initState() {
    super.initState();
    fetchPollution();
  }

  Future<void> fetchPollution() async {
    final service = PollutionService();
    final data = await service.getCityAQI(selectedCity);
    setState(() {
      pollutionData = data;
    });
  }

  void onCitySelected(String city) {
    setState(() {
      selectedCity = city;
      pollutionData = null;
    });
    fetchPollution();
  }

  Map<String, dynamic> getAQICategory(int aqi) {
    if (aqi <= 50) {
      return {
        'label': 'Good',
        'description': 'Air quality is satisfactory.',
        'color': Colors.green,
        'icon': LucideIcons.smile
      };
    } else if (aqi <= 100) {
      return {
        'label': 'Moderate',
        'description': 'Acceptable, but may affect sensitive people.',
        'color': Colors.yellow,
        'icon': LucideIcons.alertTriangle
      };
    } else if (aqi <= 150) {
      return {
        'label': 'Unhealthy for Sensitive Groups',
        'description': 'Children and elderly may feel effects.',
        'color': Colors.orange,
        'icon': LucideIcons.shieldAlert
      };
    } else if (aqi <= 200) {
      return {
        'label': 'Unhealthy',
        'description': 'Everyone may experience health effects.',
        'color': Colors.red,
        'icon': LucideIcons.thermometerSun
      };
    } else if (aqi <= 300) {
      return {
        'label': 'Very Unhealthy',
        'description': 'Serious risk to health.',
        'color': Colors.purple,
        'icon': LucideIcons.biohazard
      };
    } else {
      return {
        'label': 'Hazardous',
        'description': 'Avoid going outside.',
        'color': Colors.brown,
        'icon': LucideIcons.skull
      };
    }
  }

  String getPollutantName(String key) {
    switch (key.toLowerCase()) {
      case 'pm25':
        return 'Fine Dust (PM2.5)';
      case 'pm10':
        return 'Dust (PM10)';
      case 'no2':
        return 'Nitrogen Dioxide (NO₂)';
      case 'o3':
        return 'Ozone (O₃)';
      case 'co':
        return 'Carbon Monoxide (CO)';
      case 'so2':
        return 'Sulfur Dioxide (SO₂)';
      default:
        return key.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: Row(
    children: cities.map((city) {
      final isSelected = selectedCity == city;
      return GestureDetector(
        onTap: () => onCitySelected(city),
        child: Container(
          width: 90,
          height: 110,
          margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 5,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  cityImages[city]!,
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                city[0].toUpperCase() + city.substring(1),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.green.shade700 : Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList(),
  ),
),

        const SizedBox(height: 12),
        pollutionData == null
            ? const Center(child: CircularProgressIndicator())
            : buildPollutionCard(),
      ],
    );
  }

  Widget buildPollutionCard() {
    final aqi = pollutionData!['aqi'];
    final city = pollutionData!['city']['name'];
    final time = pollutionData!['time']['s'];
    final pollutant = pollutionData!['dominentpol'];

    final category = getAQICategory(aqi);
    final friendlyPollutant = getPollutantName(pollutant);

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(LucideIcons.leaf, color: Colors.green.shade700, size: 20),
                const SizedBox(width: 6),
                Text(
                  "Eco Monitor",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Air Quality in $city",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(category['icon'], size: 20, color: category['color']),
                const SizedBox(width: 8),
                Text(
                  "AQI: $aqi (${category['label']})",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: category['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              category['description'],
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.wind, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  "Dominant Pollutant: $friendlyPollutant",
                  style: GoogleFonts.plusJakartaSans(fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.clock, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  "Last Updated: $time",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
