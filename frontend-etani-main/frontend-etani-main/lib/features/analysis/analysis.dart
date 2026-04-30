import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/animated_ui.dart';

class AnalysisPage extends StatefulWidget {
  final String? initialLocation;

  const AnalysisPage({super.key, this.initialLocation});

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  bool _showResult = false;
  
  // Data input
  final TextEditingController _lokasiCtrl = TextEditingController();
  final TextEditingController _suhuCtrl = TextEditingController();
  final TextEditingController _kelembapanCtrl = TextEditingController();
  String _selectedCuaca = 'Cerah'; // 'Cerah', 'Berawan', 'Hujan'

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _lokasiCtrl.text = widget.initialLocation!;
    }
  }

  @override
  void dispose() {
    _lokasiCtrl.dispose();
    _suhuCtrl.dispose();
    _kelembapanCtrl.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Validasi sederhana atau langsung lanjut
    setState(() {
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _showResult ? _buildResultView() : _buildInputView(),
    );
  }

  // ==========================================
  // VIEW: FORM INPUT
  // ==========================================
  Widget _buildInputView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInputHeroSection(),
          const SizedBox(height: 70), // Spacing for overlapping card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField("Lokasi Lahan", Icons.location_on_rounded, "Cth: Lahan Blok A", _lokasiCtrl),
                const SizedBox(height: 16),
                
                // Opsi Gunakan GPS
                GestureDetector(
                  onTap: () {
                    // Simulasi ambil lokasi
                    setState(() {
                      _lokasiCtrl.text = "Lokasi Saya Saat Ini";
                    });
                  },
                  child: Row(
                    children: const [
                      Icon(Icons.my_location_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Gunakan lokasi Anda saat ini (GPS)",
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text("Lihat Hasil Analisis", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputHeroSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Curved background seperti Home Page
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
                  children: [
                    Image.asset('assets/images/logo.png', height: 40),
                    const SizedBox(width: 12),
                    const Text("Analisis Lahan", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  ],
                ),
                SizedBox(height: 40),
                FadeSlideAnimation(
                  child: Text("Input Data", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1.0)),
                ),
                SizedBox(height: 12),
                FadeSlideAnimation(
                  delay: 200,
                  child: Text("Tentukan lokasi lahan untuk memantau\nkondisi aktual hari ini.", style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4)),
                ),
              ],
            ),
          ),
        ),
        // Overlapping Stats Card untuk Data Cuaca Otomatis
        Positioned(
          left: 24,
          right: 24,
          bottom: -45,
          child: const FadeSlideAnimation(
            delay: 400,
            child: _AutoWeatherContainer(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, IconData icon, String hint, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primary),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
        ),
      ],
    );
  }


  // ==========================================
  // VIEW: HASIL ANALISIS
  // ==========================================
  Widget _buildResultView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          const SizedBox(height: 100), // offset for overlapping card
          _buildSmartAnalysis(),
          const SizedBox(height: 40),
          _buildHourlyForecastCard(),
          const SizedBox(height: 40),
          _buildRecommendationCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 320,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(80),
            ),
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
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showResult = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Image.asset('assets/images/logo.png', height: 40),
                    const SizedBox(width: 12),
                    const Text(
                      "Analisis",
                      style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const FadeSlideAnimation(
                  child: Text(
                    "Pantau kondisi rill lahanmu hari ini.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 24,
          right: 24,
          bottom: -60,
          child: const FadeSlideAnimation(
            delay: 200,
            child: _CurrentConditionContainer(),
          ),
        ),
      ],
    );
  }

  Widget _buildSmartAnalysis() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeSlideAnimation(
          delay: 300,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(50),
                topLeft: Radius.circular(50),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Color(0xFFFFF8E1), shape: BoxShape.circle),
                      child: const Icon(Icons.lightbulb_rounded, color: Color(0xFFFFB300), size: 24),
                    ),
                    const SizedBox(width: 16),
                    const Text("Analisis Cerdas", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  "Cuaca hari ini cukup cerah dengan sedikit kelembaban. Suhu tanah sangat ideal untuk pertumbuhan tunas baru. Perhatikan peluang hujan ringan di sore hari yang dapat membantu kelembaban alami tanah secara gratis.",
                  style: TextStyle(fontSize: 14, color: AppColors.textLight, height: 1.6),
                ),
              ],
            ),
          ),
        ),
    );
  }

  Widget _buildHourlyForecastCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: FadeSlideAnimation(
            delay: 400,
            child: Text(
              "Prakiraan Cuaca",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 140,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            clipBehavior: Clip.none,
            children: [
              _buildHourlyItem("08:00", Icons.wb_sunny_rounded, "26°", false, 450),
              const SizedBox(width: 16),
              _buildHourlyItem("10:00", Icons.cloud_rounded, "28°", false, 500),
              const SizedBox(width: 16),
              _buildHourlyItem("12:00", Icons.cloud_rounded, "30°", true, 550),
              const SizedBox(width: 16),
              _buildHourlyItem("14:00", Icons.wb_cloudy_rounded, "29°", false, 600),
              const SizedBox(width: 16),
              _buildHourlyItem("16:00", Icons.water_drop_rounded, "27°", false, 650),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyItem(String time, IconData icon, String temp, bool isHighlighted, int delay) {
    return FadeSlideAnimation(
      delay: delay,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isHighlighted ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(40),
          boxShadow: isHighlighted ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 8))] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
          border: isHighlighted ? null : Border.all(color: AppColors.greyBackground),
        ),
        child: Column(
          children: [
            Text(time, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isHighlighted ? Colors.white70 : AppColors.textLight)),
            const Spacer(),
            Icon(icon, color: isHighlighted ? Colors.white : AppColors.secondary, size: 28),
            const Spacer(),
            Text(temp, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isHighlighted ? Colors.white : AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return FadeSlideAnimation(
      delay: 500,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(50), bottomRight: Radius.circular(50), topRight: Radius.circular(16), bottomLeft: Radius.circular(16)),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.star_rounded, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text("REKOMENDASI UTAMA", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("Perawatan &\nPemberian Obat", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5)),
              const SizedBox(height: 12),
              Text("Kelembapan tanah cukup tinggi. Untuk mencegah jamur dan hama, disarankan memberikan fungisida/obat:", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, height: 1.5)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medication_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("2 Kali Sehari", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        Text("Pagi (07:00) & Sore (16:00)", style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
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
}

class _AutoWeatherContainer extends StatelessWidget {
  const _AutoWeatherContainer();

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
          _buildStatItem("Suhu", "28°C", Icons.thermostat_rounded, Colors.orange),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildStatItem("Cuaca", "Cerah", Icons.wb_sunny_rounded, Colors.amber),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildStatItem("Lembab", "75%", Icons.water_drop_rounded, Colors.blue),
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

class _CurrentConditionContainer extends StatelessWidget {
  const _CurrentConditionContainer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.wb_sunny_rounded, size: 32, color: Colors.amber),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Cerah", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      Text("Kondisi Saat Ini", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textLight)),
                    ],
                  ),
                ],
              ),
              const Text("28°", style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary, height: 1.0, letterSpacing: -2.0)),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: AppColors.lightGreen.withOpacity(0.5), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: const [
                      Icon(Icons.water_drop_rounded, size: 28, color: AppColors.secondary),
                      SizedBox(height: 8),
                      Text("75%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      Text("Kelembaban", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(color: AppColors.lightGreen.withOpacity(0.5), borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: const [
                      Icon(Icons.umbrella_rounded, size: 28, color: AppColors.secondary),
                      SizedBox(height: 8),
                      Text("40%", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                      Text("Peluang Hujan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textLight)),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}