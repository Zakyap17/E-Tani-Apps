import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/app_logo.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({super.key});

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
                    children: const [
                      Text("KONDISI SAAT INI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textLight)),
                      Icon(Icons.wb_cloudy_outlined, color: AppColors.primary, size: 32),
                    ],
                  ),
                  const Text("28°C", style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildWeatherChip(Icons.water_drop_outlined, "Kelembaban", "75%"),
                      const SizedBox(width: 12),
                      _buildWeatherChip(Icons.umbrella_outlined, "Peluang Hujan", "40%"),
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
                  const Text(
                    "Cuaca hari ini cukup cerah dengan sedikit kelembaban. Suhu tanah sangat ideal untuk pertumbuhan tunas baru. Namun, perhatikan peluang hujan ringan di sore hari yang dapat membantu kelembaban alami tanah tanpa perlu penyiraman ekstra.",
                    style: TextStyle(fontSize: 13, color: AppColors.textLight, height: 1.5),
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
                    child: const Text("Rekomendasi Utama", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  const Text("Cocok untuk\nMenanam", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
                  const SizedBox(height: 12),
                  const Text(
                    "Kondisi tanah dan suhu saat ini optimal untuk memulai penanaman bibit baru.",
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildCropBtn(Icons.eco_outlined, "Sayuran"),
                      const SizedBox(width: 16),
                      _buildCropBtn(Icons.local_florist_outlined, "Palawija"),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hourly Forecast
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Prakiraan Cuaca Per Jam", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHourlyForecast("08:00", Icons.wb_sunny_outlined, "26°", false),
                      _buildHourlyForecast("10:00", Icons.wb_cloudy_outlined, "28°", false),
                      _buildHourlyForecast("12:00", Icons.wb_cloudy_outlined, "30°", true),
                    ],
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
                          children: const [
                            Text("Penyiraman", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("Setiap 2 hari sekali", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
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