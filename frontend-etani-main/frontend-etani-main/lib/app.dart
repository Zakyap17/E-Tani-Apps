import 'package:flutter/material.dart';
import 'core/constants/colors.dart';
import 'core/widget/bottom_nav.dart';
import 'core/state/text_scale_state.dart';

class ETaniApp extends StatelessWidget {
  const ETaniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: TextScaleState.scaleNotifier,
      builder: (context, scale, child) {
        return MaterialApp(
          title: 'e-Tani',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'Poppins',
          ),
          // Mengatur skala font global
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(scale),
              ),
              child: child!,
            );
          },
          home: const BottomNav(),
        );
      },
    );
  }
}