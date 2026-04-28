import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/app_logo.dart';
import '../../core/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const AppLogo(),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFFC8E6C9), Color(0xFFE8F5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "MUSIM TANAM",
                      style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Rawat lahan\nAnda dengan\nsentuhan\nteknologi.",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Dapatkan analisis mendalam untuk hasil panen yang lebih maksimal.",
                    style: TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Download APK Banner
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white,
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () async {
                    final Uri url = Uri.parse('https://etani.rogersapp.site/etani.apk');
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuka link download')));
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.android, color: AppColors.primary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Aplikasi Android Tersedia", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                              SizedBox(height: 4),
                              Text("Unduh e-Tani versi APK", style: TextStyle(fontSize: 11, color: AppColors.textLight)),
                            ],
                          ),
                        ),
                        const Icon(Icons.download_rounded, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Location Search Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mulai Analisis Lahan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textDark)),
                  const SizedBox(height: 16),
                  const Text("Pilih Lokasi Lahan", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Cari nama desa, kota, atau area...",
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: const Icon(Icons.location_on_outlined, color: Colors.grey),
                      suffixIcon: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                        child: const Icon(Icons.my_location, color: AppColors.primary, size: 18),
                      ),
                      filled: true,
                      fillColor: AppColors.greyBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () async {
                        try {
                          final response = await http.get(Uri.parse('${ApiConstants.baseUrl}/health'));
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Backend Response: ${jsonDecode(response.body)['status']}'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal koneksi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.bar_chart, color: Colors.white, size: 20),
                      label: const Text("Analisis Sekarang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // How to Use
            const Text(
              "Tatacara Penggunaan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            _buildStepCard(
              "LANGKAH 1", "Tentukan Lokasi",
              "Masukkan koordinat lahan atau cari area pertanian Anda melalui fitur peta yang tersedia.",
              Icons.location_on, Color(0xFFFBE9E7), Colors.brown, AppColors.greyBackground,
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              "LANGKAH 2", "Dapatkan Laporan",
              "Sistem akan mengumpulkan data iklim, kelembaban, dan kondisi tanah secara otomatis.",
              Icons.description, Color(0xFFE0E0E0), const Color(0xFF616161), AppColors.greyBackground,
            ),
            const SizedBox(height: 12),
            _buildStepCard(
              "LANGKAH 3", "Terapkan Rekomendasi",
              "Ikuti panduan penanaman dan pemupukan yang disesuaikan khusus untuk lahan Anda.",
              Icons.eco, AppColors.primary, AppColors.primary, AppColors.greyBackground,
              iconColor: Colors.white,
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(String step, String title, String desc, IconData icon, Color iconBgColor, Color stepTextColor, Color bgColor, {Color iconColor = Colors.black54}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: stepTextColor, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                const SizedBox(height: 6),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }
}