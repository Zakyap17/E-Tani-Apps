import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/app_logo.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

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
              "Jadwal Hari Ini",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 20),
            _buildDateSelector(),
            const SizedBox(height: 30),
            _buildTaskCard(
              context,
              timeLabel: "Pagi",
              timeIcon: Icons.water_drop_outlined,
              timeColor: const Color(0xFFFBE9E7),
              timeTextColor: Colors.deepOrange,
              title: "Siram Tanaman",
              subtitle: "Blok A - Tomat Cherry",
              borderColor: Colors.lightGreenAccent.shade400,
              buttonText: "Selesai",
            ),
            const SizedBox(height: 20),
            _buildTaskCard(
              context,
              timeLabel: "Siang",
              timeIcon: Icons.wb_sunny_outlined,
              timeColor: const Color(0xFFEFEBE9),
              timeTextColor: Colors.brown,
              title: "Beri Pupuk",
              subtitle: "Blok B - Cabai Merah (NPK)",
              borderColor: Colors.brown.shade400,
              buttonText: "Selesai",
            ),
            const SizedBox(height: 20),
            _buildTaskCard(
              context,
              timeLabel: "Sore",
              timeIcon: Icons.eco_outlined,
              timeColor: const Color(0xFFEEEEEE),
              timeTextColor: const Color(0xFF616161),
              title: "Pemberian Obat",
              subtitle: "Pestisida Organik - Blok C",
              borderColor: Colors.grey.shade600,
              buttonText: "Selesaikan Sesi 1",
              isSession: true,
            ),
            const SizedBox(height: 80), // Padding for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _dateItem("Sen", "12", false),
        _dateItem("Sel", "13", true),
        _dateItem("Rab", "14", false),
        _dateItem("Kam", "15", false),
      ],
    );
  }

  Widget _dateItem(String day, String date, bool isSelected) {
    return Container(
      width: 65,
      height: 85,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(40),
        boxShadow: isSelected
            ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white70 : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context, {
    required String timeLabel,
    required IconData timeIcon,
    required Color timeColor,
    required Color timeTextColor,
    required String title,
    required String subtitle,
    required Color borderColor,
    required String buttonText,
    bool isSession = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: timeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(timeIcon, size: 14, color: timeTextColor),
                          const SizedBox(width: 4),
                          Text(
                            timeLabel,
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: timeTextColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 16),
                    if (isSession) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("Progres Sesi", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          Text("Sesi 1 dari 4", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: Container(height: 6, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(3)))),
                          const SizedBox(width: 4),
                          Expanded(child: Container(height: 6, decoration: BoxDecoration(color: AppColors.greyBackground, borderRadius: BorderRadius.circular(3)))),
                          const SizedBox(width: 4),
                          Expanded(child: Container(height: 6, decoration: BoxDecoration(color: AppColors.greyBackground, borderRadius: BorderRadius.circular(3)))),
                          const SizedBox(width: 4),
                          Expanded(child: Container(height: 6, decoration: BoxDecoration(color: AppColors.greyBackground, borderRadius: BorderRadius.circular(3)))),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {},
                        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                        label: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}