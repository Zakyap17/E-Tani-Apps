import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../core/constants/api_constants.dart';
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
  bool _isLoadingWeather = true;
  String _currentCity = "Mencari Lokasi...";
  String _temp = "--";
  String _weather = "Memuat...";
  String? _weatherAlert;
  String? _systemNotice;
  String _gpsStatus = "Mencari GPS...";

  @override
  void initState() {
    super.initState();
    _fetchLocationAndWeather();
  }

  Future<void> _fetchLocationAndWeather() async {
    double? latitude;
    double? longitude;

    try {
      setState(() => _gpsStatus = "Mengecek Izin...");
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        setState(() => _gpsStatus = "Mengunci Sinyal...");
        
        // Coba ambil posisi dengan timeout lebih lama dan paksa Android Manager
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: true, // Lebih akurat untuk beberapa HP Android
            timeLimit: const Duration(seconds: 20),
          );
        } catch (e) {
          position = await Geolocator.getLastKnownPosition();
        }

        if (position != null) {
          latitude = position.latitude;
          longitude = position.longitude;
          setState(() => _gpsStatus = "Satelit GPS");
        } else {
          setState(() => _gpsStatus = "IP Internet");
        }
      } else {
        setState(() => _gpsStatus = "Izin Ditolak");
      }
    } catch (e) {
      setState(() => _gpsStatus = "Error GPS");
    }

    try {
      // Kirim koordinat GPS langsung ke backend untuk akurasi maksimal
      String apiUrl = '${ApiConstants.baseUrl}/today';
      if (latitude != null && longitude != null) {
        apiUrl += '?lat=$latitude&lon=$longitude';
      }
      // Jika GPS null, kita biarkan Backend mendeteksi via IP (tidak kirim ?city=Bandung)

      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temp = (data['current']?['temperature'] ?? "22").toString();
          _weather = data['current']?['weather'] ?? "Cerah";
          _currentCity = data['location'] ?? "Bandung";
          _weatherAlert = data['alert'];
          _systemNotice = data['system_notice']; // Ambil notifikasi sistem
        });
      }
    } catch (e) {
      debugPrint("Error weather: $e");
      setState(() {
        if (_currentCity == "Mencari Lokasi...") _currentCity = "Bandung";
      });
    } finally {
      setState(() {
        _isLoadingWeather = false;
      });
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) {
      return "Pagi";
    } else if (hour < 15) {
      return "Siang";
    } else if (hour < 18) {
      return "Sore";
    } else {
      return "Malam";
    }
  }

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
            
            _buildSystemNotice(), // Banner Notifikasi Baru
            
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
                FadeSlideAnimation(
                  child: Text(
                    "Selamat ${_getGreeting()},\nJuragan!",
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1.0),
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
          child: FadeSlideAnimation(
            delay: 400,
            child: _isLoadingWeather 
                ? const _LoadingStats()
                : _StatsContainer(temp: _temp, weather: _weather, city: _currentCity, gpsStatus: _gpsStatus),
          ),
        ),
      ],
    );
  }

  Widget _buildSystemNotice() {
    if (_systemNotice == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: FadeSlideAnimation(
        child: GestureDetector(
          onTap: () {
            // Arahkan ke link download APK dan hapus banner
            const downloadUrl = "http://100.120.62.122/downloads/E-Tani.apk";
            launchUrl(Uri.parse(downloadUrl));
            setState(() => _systemNotice = null);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.download_for_offline_rounded, color: AppColors.secondary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _systemNotice!,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.secondary),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisBanner() {
    // Jika tidak ada alert, kita tampilkan tips default atau sembunyikan
    final hasAlert = _weatherAlert != null;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FadeSlideAnimation(
        delay: 500,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: hasAlert ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9), 
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: hasAlert ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hasAlert ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasAlert ? Icons.warning_amber_rounded : Icons.eco_rounded, 
                  color: hasAlert ? Colors.orange : Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAlert ? "Peringatan Cuaca" : "Tips Lahan Hari Ini",
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.w800, 
                        color: hasAlert ? Colors.orange : AppColors.primary
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _weatherAlert ?? "Kondisi lahan terpantau stabil. Pastikan drainase tetap bersih untuk mengantisipasi perubahan cuaca mendadak.",
                      style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
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
                        widget.onNavigate!(2);
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
                            widget.onNavigate!(1);
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
                            widget.onNavigate!(3);
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
          const SizedBox(height: 16),
          // KARTU BARU: Tani-AI (Lebar Penuh agar menonjol)
          FadeSlideAnimation(
            delay: 500,
            child: BouncingButton(
              onTap: () {
                // Nanti kita buat ChatPage
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6A1B9A), Color(0xFF9C27B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6A1B9A).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tanya Tani-AI",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Konsultasi & Diagnosa Foto Tanaman",
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
          // Tombol Download APK - hanya muncul di web browser
          if (kIsWeb) const SizedBox(height: 20),
          if (kIsWeb) _buildDownloadApkBanner(),
        ],
      ),
    );
  }

  Widget _buildDownloadApkBanner() {
    return FadeSlideAnimation(
      delay: 500,
      child: BouncingButton(
        onTap: () async {
          // Buat URL absolut dari baseUrl (buang /api di akhir)
          final downloadUrl = ApiConstants.baseUrl.replaceAll('/api', '') + '/downloads/E-Tani.apk';
          final uri = Uri.parse(downloadUrl);
          
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.android_rounded, color: Colors.white, size: 36),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Download Aplikasi E-Tani",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Tersedia untuk Android · Gratis",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.download_rounded, color: Colors.white, size: 28),
            ],
          ),
        ),
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

class _LoadingStats extends StatelessWidget {
  const _LoadingStats();

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
      child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
  }
}

class _StatsContainer extends StatelessWidget {
  final String temp;
  final String weather;
  final String city;
  final String gpsStatus;

  const _StatsContainer({
    required this.temp, 
    required this.weather, 
    required this.city,
    required this.gpsStatus,
  });

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
          _buildStatItem(gpsStatus, city.length > 10 ? city.substring(0, 8) + '..' : city, Icons.location_on_rounded, Colors.redAccent),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildStatItem("Suhu", "$temp°C", Icons.thermostat_rounded, Colors.orange),
          Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.2)),
          _buildStatItem("Cuaca", weather, Icons.wb_cloudy_rounded, Colors.blue),
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