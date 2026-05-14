import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../../core/constants/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/animated_ui.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String? _selectedCategory;
  bool _isSubmitting = false;
  bool _isSuccess = false;
  int? _reportId;

  static const List<String> _categories = [
    'Hama',
    'Penyakit Tanaman',
    'Kekeringan',
    'Irigasi Rusak',
    'Masalah Pupuk',
    'Lainnya',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showSnackbar('Pilih kategori masalah terlebih dahulu', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/report'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'name': _nameCtrl.text.trim(),
              'email': _emailCtrl.text.trim(),
              'category': _selectedCategory,
              'description': _descCtrl.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        setState(() {
          _isSuccess = true;
          _reportId = data['report_id'];
        });
      } else {
        _showSnackbar(data['error'] ?? 'Gagal mengirim laporan', isError: true);
      }
    } catch (e) {
      _showSnackbar('Koneksi gagal. Periksa jaringan Anda.', isError: true);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? Colors.red.shade700 : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _resetForm() {
    _nameCtrl.clear();
    _emailCtrl.clear();
    _descCtrl.clear();
    setState(() {
      _selectedCategory = null;
      _isSuccess = false;
      _reportId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isSuccess ? _buildSuccessView() : _buildFormView(),
    );
  }

  // ==========================================
  // VIEW: SUCCESS
  // ==========================================
  Widget _buildSuccessView() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 72),
              ),
              const SizedBox(height: 32),
              const Text(
                'Laporan Terkirim!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: -0.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Laporan #${_reportId ?? '-'} telah kami terima.\nTim ahli akan segera menindaklanjuti masalah Anda.',
                style: const TextStyle(fontSize: 15, color: AppColors.textLight, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _resetForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Buat Laporan Baru', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW: FORM
  // ==========================================
  Widget _buildFormView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(),
          const SizedBox(height: 80),
          _buildFormSection(),
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
          height: 280,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
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
                    Image.asset('assets/images/logo.png', height: 40),
                    const SizedBox(width: 12),
                    const Text("Laporan", style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
                  ],
                ),
                const SizedBox(height: 8),
                const FadeSlideAnimation(
                  child: Text("Laporkan masalah pada lahan\nagar tim kami bisa membantu.", style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4)),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 24, right: 24, bottom: -50,
          child: FadeSlideAnimation(
            delay: 200,
            child: _HelpCallContainer(),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FadeSlideAnimation(
              delay: 300,
              child: Text("Detail Laporan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5)),
            ),
            const SizedBox(height: 24),

            // Nama
            FadeSlideAnimation(delay: 350, child: _buildLabel("Nama Lengkap")),
            FadeSlideAnimation(
              delay: 380,
              child: _buildTextFormField(
                controller: _nameCtrl,
                hint: 'Masukkan nama Anda',
                icon: Icons.person_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
              ),
            ),
            const SizedBox(height: 20),

            // Email
            FadeSlideAnimation(delay: 400, child: _buildLabel("Email")),
            FadeSlideAnimation(
              delay: 430,
              child: _buildTextFormField(
                controller: _emailCtrl,
                hint: 'contoh@email.com',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Email tidak boleh kosong';
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Format email tidak valid';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),

            // Kategori
            FadeSlideAnimation(delay: 450, child: _buildLabel("Kategori Masalah")),
            FadeSlideAnimation(delay: 480, child: _buildDropdown()),
            const SizedBox(height: 20),

            // Deskripsi
            FadeSlideAnimation(delay: 500, child: _buildLabel("Deskripsi Lengkap")),
            FadeSlideAnimation(
              delay: 530,
              child: _buildTextFormField(
                controller: _descCtrl,
                hint: 'Ceritakan kondisi tanaman atau tanah Anda secara rinci...',
                maxLines: 5,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Deskripsi tidak boleh kosong';
                  if (v.trim().length < 10) return 'Deskripsi terlalu singkat';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 40),

            // Tombol Submit
            FadeSlideAnimation(
              delay: 600,
              child: BouncingButton(
                onTap: _isSubmitting ? null : () => _submitReport(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: _isSubmitting ? Colors.grey.shade400 : AppColors.primary,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: _isSubmitting ? [] : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  alignment: Alignment.center,
                  child: _isSubmitting
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text("Kirim Laporan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w500),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 15),
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(maxLines > 1 ? 20 : 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.greyBackground, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: AppColors.greyBackground, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.red.shade400, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: Colors.red, width: 2)),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _selectedCategory == null ? AppColors.greyBackground : AppColors.primary, width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedCategory,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
          hint: const Text("Pilih kategori...", style: TextStyle(color: Colors.grey, fontSize: 15)),
          items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val),
        ),
      ),
    );
  }
}

class _HelpCallContainer extends StatelessWidget {
  const _HelpCallContainer();

  @override
  Widget build(BuildContext context) {
    return BouncingButton(
      onTap: () async {
        final uri = Uri.parse('mailto:etaniapps26@gmail.com?subject=Bantuan Darurat E-Tani');
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFB300), Color(0xFFFF9800)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Butuh Bantuan Darurat?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text("etaniapps26@gmail.com", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.email_rounded, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}