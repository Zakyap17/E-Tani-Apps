import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/animated_ui.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: 80), // Spacing for floating card
            _buildFormSection(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 280,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset('assets/images/logo.png', height: 40),
                    const SizedBox(width: 12),
                    const Text("Laporan", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
                  ],
                ),
                const SizedBox(height: 8),
                const FadeSlideAnimation(
                  child: Text("Laporkan masalah pada lahan\nagar tim kami bisa membantu.", style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4)),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 24, right: 24, bottom: -50,
          child: const FadeSlideAnimation(
            delay: 200,
            child: _HelpCallContainer(),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FadeSlideAnimation(
            delay: 300,
            child: Text("Detail Masalah", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5)),
          ),
          const SizedBox(height: 24),
          FadeSlideAnimation(
            delay: 400,
            child: _buildInputLabel("Kategori Masalah"),
          ),
          FadeSlideAnimation(
            delay: 450,
            child: _buildDropdown(),
          ),
          const SizedBox(height: 24),
          FadeSlideAnimation(
            delay: 500,
            child: _buildInputLabel("Deskripsi Lengkap"),
          ),
          FadeSlideAnimation(
            delay: 550,
            child: _buildTextField(hint: "Ceritakan kondisi tanaman atau tanah Anda secara rinci...", maxLines: 4),
          ),
          const SizedBox(height: 24),
          FadeSlideAnimation(
            delay: 600,
            child: _buildInputLabel("Foto Kondisi Lahan (Opsional)"),
          ),
          FadeSlideAnimation(
            delay: 650,
            child: _buildPhotoUploadBox(),
          ),
          const SizedBox(height: 40),
          FadeSlideAnimation(
            delay: 700,
            child: BouncingButton(
                onTap: () {},
                child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]),
                    alignment: Alignment.center,
                    child: const Text("Kirim Laporan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16))
                )
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.greyBackground, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          hint: const Text("Pilih kategori...", style: TextStyle(color: Colors.grey, fontSize: 15)),
          items: ["Hama", "Penyakit Tanaman", "Kekeringan", "Irigasi Rusak"]
              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600))))
              .toList(),
          onChanged: (val) {},
        ),
      ),
    );
  }

  Widget _buildTextField({required String hint, int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      style: const TextStyle(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.greyBackground, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.greyBackground, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }

  Widget _buildPhotoUploadBox() {
    return BouncingButton(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30),
        decoration: BoxDecoration(
          color: AppColors.lightGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2, style: BorderStyle.none),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
              child: const Icon(Icons.cloud_upload_rounded, color: AppColors.primary, size: 28),
            ),
            const SizedBox(height: 12),
            const Text("Tap untuk unggah foto", style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
            const SizedBox(height: 4),
            const Text("Maks. 5MB (JPG, PNG)", style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
      ),
    );
  }
}

class _HelpCallContainer extends StatelessWidget {
  const _HelpCallContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF9800)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Butuh Bantuan Darurat?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 4),
                Text("Tim ahli kami siap memandu.", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}