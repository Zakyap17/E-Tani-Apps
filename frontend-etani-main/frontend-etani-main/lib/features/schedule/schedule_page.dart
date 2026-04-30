import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/animated_ui.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

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
            const SizedBox(height: 80), // Spacing for floating date selector
            _buildTimelineSection(),
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
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60)),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Jadwal", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                          child: const Text("3 Tugas Tersisa", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 16),
                        Image.asset('assets/images/logo.png', height: 55),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const FadeSlideAnimation(
                  child: Text("Tetap pada jalurnya untuk\nhasil panen optimal.", style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4)),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0, right: 0, bottom: -45,
          child: FadeSlideAnimation(
            delay: 200,
            child: SizedBox(
              height: 95,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                clipBehavior: Clip.none,
                children: [
                  _dateItem("Sen", "12", false),
                  const SizedBox(width: 12),
                  _dateItem("Sel", "13", true),
                  const SizedBox(width: 12),
                  _dateItem("Rab", "14", false),
                  const SizedBox(width: 12),
                  _dateItem("Kam", "15", false),
                  const SizedBox(width: 12),
                  _dateItem("Jum", "16", false),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateItem(String day, String date, bool isSelected) {
    return BouncingButton(
      onTap: () {},
      child: Container(
        width: 75,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
          border: isSelected ? null : Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(day, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isSelected ? Colors.white70 : AppColors.textLight)),
            const SizedBox(height: 6),
            Text(date, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: isSelected ? Colors.white : AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildTaskTimelineItem(
            delay: 300, timeLabel: "Pagi", timeIcon: Icons.water_drop_rounded, timeColor: const Color(0xFFE3F2FD), timeTextColor: const Color(0xFF1E88E5), title: "Siram Tanaman", subtitle: "Blok A - Tomat Cherry", buttonText: "Selesai", isSession: false
          ),
          const SizedBox(height: 16),
          _buildTaskTimelineItem(
            delay: 400, timeLabel: "Siang", timeIcon: Icons.wb_sunny_rounded, timeColor: const Color(0xFFFFF8E1), timeTextColor: const Color(0xFFFFB300), title: "Beri Pupuk", subtitle: "Blok B - Cabai Merah (NPK)", buttonText: "Selesai", isSession: false
          ),
          const SizedBox(height: 16),
          _buildTaskTimelineItem(
            delay: 500, timeLabel: "Sore", timeIcon: Icons.eco_rounded, timeColor: AppColors.lightGreen, timeTextColor: AppColors.primary, title: "Pemberian Obat", subtitle: "Pestisida Organik - Blok C", buttonText: "Selesaikan Sesi 1", isSession: true, isLast: true
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTimelineItem({required int delay, required String timeLabel, required IconData timeIcon, required Color timeColor, required Color timeTextColor, required String title, required String subtitle, required String buttonText, required bool isSession, bool isLast = false}) {
    return FadeSlideAnimation(
        delay: delay,
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Column(
                    children: [
                        Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: timeColor, shape: BoxShape.circle),
                            child: Icon(timeIcon, color: timeTextColor, size: 22)
                        ),
                        if (!isLast)
                        Container(width: 3, height: isSession ? 180 : 100, color: AppColors.greyBackground, margin: const EdgeInsets.symmetric(vertical: 8))
                    ]
                ),
                const SizedBox(width: 20),
                Expanded(
                    child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40), bottomLeft: Radius.circular(12), bottomRight: Radius.circular(40)),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                            border: Border.all(color: Colors.black.withOpacity(0.02))
                        ),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                                Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: timeColor.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                                    child: Text(timeLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: timeTextColor))
                                ),
                                const SizedBox(height: 16),
                                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5)),
                                const SizedBox(height: 6),
                                Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w600)),
                                if (isSession) ...[
                                    const SizedBox(height: 24),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: const [
                                            Text("Sesi 1 dari 4", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                            Text("25%", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textLight))
                                        ]
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                        children: [
                                            Expanded(child: Container(height: 8, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)))),
                                            const SizedBox(width: 6),
                                            Expanded(child: Container(height: 8, decoration: BoxDecoration(color: AppColors.greyBackground, borderRadius: BorderRadius.circular(4)))),
                                            const SizedBox(width: 6),
                                            Expanded(child: Container(height: 8, decoration: BoxDecoration(color: AppColors.greyBackground, borderRadius: BorderRadius.circular(4)))),
                                            const SizedBox(width: 6),
                                            Expanded(child: Container(height: 8, decoration: BoxDecoration(color: AppColors.greyBackground, borderRadius: BorderRadius.circular(4)))),
                                        ]
                                    )
                                ],
                                const SizedBox(height: 24),
                                BouncingButton(
                                    onTap: () {},
                                    child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5)),
                                        alignment: Alignment.center,
                                        child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                                const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                                                const SizedBox(width: 8),
                                                Text(buttonText, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16))
                                            ]
                                        )
                                    )
                                )
                            ]
                        )
                    )
                )
            ]
        )
    );
  }
}