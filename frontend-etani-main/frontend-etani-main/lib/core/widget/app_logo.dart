import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan Transform.scale untuk membesarkan logo
    // dan secara visual "memotong" bagian transparan yang berlebihan.
    return Transform.scale(
      scale: 1.8, // Sesuaikan angka ini (misal 1.5 - 2.5) untuk membesarkannya
      child: Image.asset(
        'assets/images/logo.png',
        height: 60, // Tinggi dasar sebelum di-scale
        fit: BoxFit.contain,
      ),
    );
  }
}

