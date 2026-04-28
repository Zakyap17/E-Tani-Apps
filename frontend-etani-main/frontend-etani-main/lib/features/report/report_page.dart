import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/app_logo.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

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
              "Laporan Kendala",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sampaikan masalah atau kendala yang Anda hadapi di lahan. Tim ahli kami siap membantu mencarikan solusi terbaik untuk panen Anda.",
              style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.5),
            ),
            const SizedBox(height: 24),
            
            // Form Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputLabel("Nama Lengkap"),
                  _buildTextField("Misal: Budi Santoso"),
                  const SizedBox(height: 16),
                  
                  _buildInputLabel("Alamat Email"),
                  _buildTextField("budi@petani.id"),
                  const SizedBox(height: 16),
                  
                  _buildInputLabel("Deskripsi Kendala"),
                  _buildTextField("Jelaskan secara singkat kendala yang dialami, misalnya: 'Daun padi menguning pada usia 30 hari...'", maxLines: 4),
                  const SizedBox(height: 16),
                  
                  const Text(
                    "Mohon berikan detail yang jelas agar kami dapat memberikan solusi yang tepat.",
                    style: TextStyle(fontSize: 10, color: AppColors.textLight),
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      label: const Text("Kirim Laporan", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Help Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0EAE6), // Light brownish grey
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5D3C8), // Peachy color
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent, color: Colors.brown, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Butuh bantuan langsung?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(height: 6),
                        Text(
                          "Jika kendala bersifat mendesak, Anda dapat menghubungi layanan pelanggan kami melalui telepon di hari kerja.",
                          style: TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.4),
                        ),
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

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildTextField(String hint, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true,
        fillColor: AppColors.greyBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}