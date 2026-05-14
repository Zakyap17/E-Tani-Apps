import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/animated_ui.dart';

enum _TaskStatus { upcoming, active, done }

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late int _selectedIndex;
  late List<DateTime> _dates;
  final Set<String> _completedTasks = {};

  static const List<String> _dayNames = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  // Period: [startHour (inclusive), endHour (exclusive)]
  static const Map<String, List<int>> _periodHours = {
    'Pagi':  [5, 11],
    'Siang': [11, 15],
    'Sore':  [15, 19],
  };

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(7, (i) => today.add(Duration(days: i)));
    _selectedIndex = 0;
  }

  String _dayAbbr(DateTime date) => _dayNames[date.weekday - 1];

  String _taskKey(String period) {
    final date = _dates[_selectedIndex];
    return '${date.year}-${date.month}-${date.day}_$period';
  }

  _TaskStatus _getTaskStatus(String period) {
    if (_selectedIndex > 0) return _TaskStatus.upcoming;
    if (_completedTasks.contains(_taskKey(period))) return _TaskStatus.done;
    final now = DateTime.now();
    final hours = _periodHours[period]!;
    if (now.hour < hours[0]) return _TaskStatus.upcoming;
    if (now.hour >= hours[1]) return _TaskStatus.done;
    return _TaskStatus.active;
  }

  void _markDone(String period) => setState(() => _completedTasks.add(_taskKey(period)));

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
            const SizedBox(height: 80),
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
                          child: const Text("3 Tugas Hari Ini", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                clipBehavior: Clip.none,
                itemCount: _dates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final date = _dates[index];
                  return _dateItem(
                    _dayAbbr(date),
                    date.day.toString(),
                    index == _selectedIndex,
                    onTap: () => setState(() => _selectedIndex = index),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _dateItem(String day, String date, bool isSelected, {VoidCallback? onTap}) {
    return BouncingButton(
      onTap: onTap ?? () {},
      child: Container(
        width: 75,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))]
              : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 5))],
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
          _buildTaskItem(
            delay: 300,
            timeLabel: "Pagi",
            timeIcon: Icons.water_drop_rounded,
            timeColor: const Color(0xFFE3F2FD),
            timeTextColor: const Color(0xFF1E88E5),
            title: "Siram Tanaman",
            subtitle: "Blok A - Tomat Cherry",
            period: "Pagi",
          ),
          const SizedBox(height: 16),
          _buildTaskItem(
            delay: 400,
            timeLabel: "Siang",
            timeIcon: Icons.wb_sunny_rounded,
            timeColor: const Color(0xFFFFF8E1),
            timeTextColor: const Color(0xFFFFB300),
            title: "Beri Pupuk",
            subtitle: "Blok B - Cabai Merah (NPK)",
            period: "Siang",
          ),
          const SizedBox(height: 16),
          _buildTaskItem(
            delay: 500,
            timeLabel: "Sore",
            timeIcon: Icons.eco_rounded,
            timeColor: AppColors.lightGreen,
            timeTextColor: AppColors.primary,
            title: "Pemberian Obat",
            subtitle: "Pestisida Organik - Blok C",
            period: "Sore",
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(_TaskStatus status) {
    switch (status) {
      case _TaskStatus.upcoming:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
          child: const Text('Akan Datang', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey)),
        );
      case _TaskStatus.active:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: const Text('Sedang Berjalan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.orange)),
        );
      case _TaskStatus.done:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
          child: const Text('✓ Selesai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
        );
    }
  }

  Widget _buildTaskItem({
    required int delay,
    required String timeLabel,
    required IconData timeIcon,
    required Color timeColor,
    required Color timeTextColor,
    required String title,
    required String subtitle,
    required String period,
    bool isLast = false,
  }) {
    final status = _getTaskStatus(period);

    Widget actionButton;
    if (status == _TaskStatus.done) {
      actionButton = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Selesai', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 16)),
          ],
        ),
      );
    } else if (status == _TaskStatus.upcoming) {
      actionButton = Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.schedule_rounded, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Text('Akan Datang', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      );
    } else {
      actionButton = BouncingButton(
        onTap: () => _markDone(period),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
          ),
          alignment: Alignment.center,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Tandai Selesai', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return FadeSlideAnimation(
      delay: delay,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: status == _TaskStatus.done ? AppColors.primary.withOpacity(0.15) : timeColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  status == _TaskStatus.done ? Icons.check_rounded : timeIcon,
                  color: status == _TaskStatus.done ? AppColors.primary : timeTextColor,
                  size: 22,
                ),
              ),
              if (!isLast)
                Container(width: 3, height: 120, color: AppColors.greyBackground, margin: const EdgeInsets.symmetric(vertical: 8)),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: status == _TaskStatus.done ? AppColors.primary.withOpacity(0.03) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(40),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
                border: Border.all(color: Colors.black.withOpacity(0.02)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: timeColor.withOpacity(0.5), borderRadius: BorderRadius.circular(12)),
                        child: Text(timeLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: timeTextColor)),
                      ),
                      const Spacer(),
                      _statusBadge(status),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.textLight, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  actionButton,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}