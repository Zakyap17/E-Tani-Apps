import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/animated_ui.dart';
import '../analysis/analysis.dart';
import '../schedule/schedule_page.dart';
import '../report/report_page.dart';

class HomePage extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            const SizedBox(height: 70), // Spacing for overlapping stats
            
            _buildAnalysisBanner(),
            const SizedBox(height: 30),
            
            _buildQuickActions(),
            const SizedBox(height: 40),
            
            _buildHorizontalScrollSection(),
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
        // Curved background
        Container(
          height: 340,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(60),
              bottomRight: Radius.circular(60),
            ),
          ),
        ),
        // Decorative pattern
        Positioned(
          right: -40,
          top: -20,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -30,
          top: 150,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/images/logo.png', height: 55),
                    BouncingButton(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 40),
                const FadeSlideAnimation(
                  child: Text(
                    "Selamat Pagi,\nJuragan!",
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1.0),
                  ),
                ),
                const SizedBox(height: 12),
                const FadeSlideAnimation(
                  delay: 200,
                  child: Text(
                    "Lahanmu terlihat asri hari ini. Yuk cek kondisinya!",
                    style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Overlapping Stats
        Positioned(
          left: 24,
          right: 24,
          bottom: -45,
          child: const FadeSlideAnimation(
            delay: 400,
            child: _StatsContainer(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeSlideAnimation(
        delay: 500,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0), // Light orange warning
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Waspadai Risiko Jamur",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.orange),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Hujan sedang hari ini meningkatkan kelembaban tanah. Pemberian fungisida sebanyak 3 kali diperlukan untuk mencegah pertumbuhan jamur.",
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FadeSlideAnimation(
            child: Text(
              "Aksi Cepat",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FadeSlideAnimation(
                  delay: 200,
                  child: BouncingButton(
                    onTap: () {
                      if (widget.onNavigate != null) {
                        widget.onNavigate!(2); // Navigasi langsung ke tab Analysis
                      } else {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalysisPage()));
                      }
                    },
                    child: Container(
                      height: 190,
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.lightGreen,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                          topRight: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 28),
                          ),
                          const Text(
                            "Analisis\nLahan",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    FadeSlideAnimation(
                      delay: 300,
                      child: BouncingButton(
                        onTap: () {
                          if (widget.onNavigate != null) {
                            widget.onNavigate!(1); // Navigasi langsung ke tab Schedule (Tanam)
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SchedulePage()));
                          }
                        },
                        child: Container(
                          height: 87,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.grass_rounded, color: Colors.orange, size: 28),
                              SizedBox(width: 14),
                              Text("Tanam", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.orange, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeSlideAnimation(
                      delay: 400,
                      child: BouncingButton(
                        onTap: () {
                          if (widget.onNavigate != null) {
                            widget.onNavigate!(3); // Navigasi langsung ke tab Report (Lapor)
                          } else {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportPage()));
                          }
                        },
                        child: Container(
                          height: 87,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE3F2FD),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.assignment_rounded, color: Colors.blue, size: 28),
                              SizedBox(width: 14),
                              Text("Lapor", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.blue, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalScrollSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FadeSlideAnimation(
                child: Text(
                  "Kegiatan Hari Ini",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5),
                ),
              ),
              FadeSlideAnimation(
                child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 185,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            clipBehavior: Clip.none,
            children: [
              _buildPlantItem(
                "Beri Pupuk", 
                "08:00 (1 Sesi)", 
                "Fase vegetatif aktif, pupuk diberikan 1x hari ini.", 
                AppColors.primary, 
                0
              ),
              const SizedBox(width: 20),
              _buildPlantItem(
                "Fungisida", 
                "07:00, 12:00, 17:00", 
                "Risiko jamur tinggi akibat kelembaban.", 
                Colors.orange, 
                100
              ),
              const SizedBox(width: 20),
              _buildPlantItem(
                "Siram Tanaman", 
                "Dilewati", 
                "Hujan hari ini mencukupi kebutuhan air.", 
                Colors.grey, 
                200
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlantItem(String title, String status, String note, Color color, int delay) {
    return FadeSlideAnimation(
      delay: delay,
      child: BouncingButton(
        onTap: () {},
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(40),
              topRight: Radius.circular(40),
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.black.withOpacity(0.02)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 3),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark, height: 1.2)),
                  const SizedBox(height: 8),
                  Text(status, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(note, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLocationInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Analisis Lahan", style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Masukkan koordinat lokasi lahan untuk memperbarui laporan analisis.",
                style: TextStyle(color: AppColors.textLight, height: 1.4),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: "Cth: -6.9175, 107.6191",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AnalysisPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Generate", style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
  }
}

// ----------------------------------------------------------------------------
// Custom UI Components & Animations

class _StatsContainer extends StatelessWidget {
  const _StatsContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("Suhu", "22°C", Icons.thermostat_rounded, Colors.orange),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildStatItem("Lembab", "85%", Icons.water_drop_rounded, Colors.blue),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildStatItem("Hujan", "80%", Icons.cloudy_snowing, Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}