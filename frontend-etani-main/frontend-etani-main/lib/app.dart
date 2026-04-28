import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'core/widget/bottom_nav.dart';
import 'features/home/home_page.dart';

class ETaniApp extends StatelessWidget {
  const ETaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-Tani',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Poppins',
      ),
      home: const BottomNav(), // Updated from HomePage
    );
  }
}