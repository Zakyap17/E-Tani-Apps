import 'package:flutter/material.dart';
import '../../features/home/home_page.dart';
import '../../features/schedule/schedule_page.dart';
import '../../features/analysis/analysis.dart';
import '../../features/report/report_page.dart';
import '../constants/colors.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int index = 0;

  final pages = [
    const HomePage(),
    const SchedulePage(),
    const AnalysisPage(),
    const ReportPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 0.05),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey<int>(index), // Penting agar animasi dipicu
          child: pages[index],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: (i) => setState(() => index = i),
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home, "Home", 0),
              _buildNavItem(Icons.calendar_today_outlined, Icons.calendar_month, "Schedule", 1),
              _buildNavItem(Icons.analytics_outlined, Icons.analytics, "Analysis", 2),
              _buildNavItem(Icons.receipt_long_outlined, Icons.receipt_long, "Report", 3),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData iconDataOutline, IconData iconDataSolid, String label, int itemIndex) {
    final isSelected = index == itemIndex;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(isSelected ? iconDataSolid : iconDataOutline),
      ),
      label: label,
    );
  }
}