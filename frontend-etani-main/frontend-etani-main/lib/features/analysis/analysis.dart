import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/app_logo.dart';

class AnalysisPage extends StatelessWidget {
  final Map<String, dynamic> weatherData;

  const AnalysisPage({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AppLogo(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Analisis Pertanian",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              "Berdasarkan kondisi cuaca dan tanah hari ini.",
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            const SizedBox(height: 20),
            
            // Current Condition Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("KONDISI SAAT INI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                      Icon(
                        weatherData['current']['weather'].toString().toLowerCase().contains('hujan') ? Icons.water_drop_outlined : Icons.wb_sunny_outlined, 
                        color: AppColors.primary, size: 32
                      ),
                    ],
                  ),
                  Text("${weatherData['current']['temperature']}°C", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildWeatherChip(Icons.thermostat_outlined, "Cuaca", weatherData['current']['weather']),
                      const SizedBox(width: 12),
                      _buildWeatherChip(Icons.location_on_outlined, "Lahan", weatherData['location']),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Smart Analysis Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.lightbulb_outline, color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 12),
                      const Text("Analisis Cerdas", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${weatherData['insight']}. ${weatherData['action_plan']}",
                    style: const TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Recommendation Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Tindakan Segera", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Text(weatherData['recommendation']['action'].toString(), style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                  const SizedBox(height: 12),
                  Text(
                    weatherData['recommendation']['note'].toString(),
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Daily Forecast
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Prakiraan Cuaca 3 Hari", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      (weatherData['forecast'] as List).length,
                      (index) {
                        final fd = weatherData['forecast'][index];
                        return _buildHourlyForecast(
                          fd['day'], 
                          fd['weather'].toString().toLowerCase().contains('hujan') ? Icons.water_drop_outlined : Icons.wb_sunny_outlined, 
                          "${fd['temperature']}°", 
                          index == 0
                        );
                      }
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Maintenance Action
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tindakan Perawatan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Color(0xFFFBE9E7), shape: BoxShape.circle),
                          child: const Icon(Icons.water_drop_outlined, color: Colors.deepOrange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Penyiraman", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Frekuensi: ${weatherData['recommendation']['frequency']}x dalam ${weatherData['recommendation']['interval_hours']} jam", style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherChip(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.greyBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.textLight),
                const SizedBox(width: 4),
                Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textLight, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCropBtn(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildHourlyForecast(String time, IconData icon, String temp, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isHighlighted ? AppColors.greyBackground : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isHighlighted ? AppColors.textDark : AppColors.textLight)),
          const SizedBox(height: 8),
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(temp, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}