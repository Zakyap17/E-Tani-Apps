import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../core/constants/api_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/widget/animated_ui.dart';

// ─────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────
class CropBlock {
  final int id;
  final String name;
  final String cropType;
  final String plantingDate;
  final String status;

  CropBlock({
    required this.id,
    required this.name,
    required this.cropType,
    required this.plantingDate,
    required this.status,
  });

  factory CropBlock.fromJson(Map<String, dynamic> json) => CropBlock(
        id: json['id'],
        name: json['name'],
        cropType: json['crop_type'],
        plantingDate: json['planting_date'].toString().substring(0, 10),
        status: json['status'] ?? 'active',
      );
}

// ─────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  String _locationName = '';
  Map<String, dynamic>? _weatherCurrent;
  String? _weatherAlert;
  List<Map<String, dynamic>> _schedule = [];
  int _selectedBlockIndex = 0;

  late TabController _tabController;

  // Untuk filter tab hari ini/semua
  static const List<String> _dayNames = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
  ];
  late int _selectedDayIndex;
  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _dates = List.generate(7, (i) => today.add(Duration(days: i)));
    _selectedDayIndex = 0;
    _tabController = TabController(length: 0, vsync: this);
    _loadSchedule();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─── Helpers ───────────────────────────────

  String _dayAbbr(DateTime date) => _dayNames[date.weekday - 1];

  String _formatDate(String isoDate) {
    // isoDate: YYYY-MM-DD
    final parts = isoDate.split('-');
    if (parts.length < 3) return isoDate;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  int _calcHST(String plantingDate) {
    final planted = DateTime.tryParse(plantingDate) ?? DateTime.now();
    final today = DateTime.now();
    return today.difference(planted).inDays.clamp(0, 9999);
  }

  Color _phaseColor(String phase) {
    if (phase.contains('Perkecambahan')) return Colors.teal;
    if (phase.contains('Vegetatif Awal')) return Colors.green;
    if (phase.contains('Vegetatif Akhir')) return Colors.lightGreen;
    if (phase.contains('Generatif')) return Colors.orange;
    if (phase.contains('Panen')) return Colors.red;
    return AppColors.primary;
  }

  // ─── Data Fetching ─────────────────────────

  Future<void> _loadSchedule() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      double? lat, lon;
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (serviceEnabled) {
          LocationPermission perm = await Geolocator.checkPermission();
          if (perm == LocationPermission.denied) {
            perm = await Geolocator.requestPermission();
          }
          if (perm == LocationPermission.whileInUse ||
              perm == LocationPermission.always) {
            final pos = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 10),
            );
            lat = pos.latitude;
            lon = pos.longitude;
          }
        }
      } catch (_) {}

      String url = '${ApiConstants.baseUrl}/schedule';
      if (lat != null && lon != null) url += '?lat=$lat&lon=$lon';

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rawSchedule =
            List<Map<String, dynamic>>.from(data['schedule'] ?? []);
        setState(() {
          _locationName = data['location'] ?? '';
          _weatherCurrent = data['weather'];
          _weatherAlert = data['alert'];
          _schedule = rawSchedule;
          _tabController.dispose();
          _tabController = TabController(
              length: rawSchedule.length, vsync: this);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Gagal memuat jadwal (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Tidak dapat terhubung ke server.\n$e';
        _isLoading = false;
      });
    }
  }

  // ─── CRUD Blocks ───────────────────────────

  Future<List<CropBlock>> _fetchBlocks() async {
    final response = await http
        .get(Uri.parse('${ApiConstants.baseUrl}/blocks'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => CropBlock.fromJson(e)).toList();
    }
    throw Exception('Gagal memuat blok');
  }

  Future<void> _addBlock(
      String name, String cropType, String plantingDate) async {
    await http.post(
      Uri.parse('${ApiConstants.baseUrl}/blocks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'crop_type': cropType,
        'planting_date': plantingDate,
      }),
    );
    await _loadSchedule();
  }

  Future<void> _editBlock(int id, String name, String cropType,
      String plantingDate, String status) async {
    await http.put(
      Uri.parse('${ApiConstants.baseUrl}/blocks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'crop_type': cropType,
        'planting_date': plantingDate,
        'status': status,
      }),
    );
    await _loadSchedule();
  }

  Future<void> _deleteBlock(int id) async {
    await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/blocks/$id'));
    await _loadSchedule();
  }

  // ─── Dialogs ───────────────────────────────

  void _showManageBlocksSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ManageBlocksSheet(
        onAdd: _addBlock,
        onEdit: _editBlock,
        onDelete: _deleteBlock,
        fetchBlocks: _fetchBlocks,
      ),
    );
  }

  void _showAddEditBlockDialog({CropBlock? block}) {
    final nameCtrl =
        TextEditingController(text: block?.name ?? '');
    final cropCtrl =
        TextEditingController(text: block?.cropType ?? '');
    DateTime? selectedDate =
        block != null ? DateTime.tryParse(block.plantingDate) : null;
    String currentStatus = block?.status ?? 'active';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            block == null ? '➕ Tambah Blok Baru' : '✏️ Edit Blok',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _inputField(nameCtrl, 'Nama Blok', 'contoh: Blok A Utara',
                    Icons.grid_view_rounded),
                const SizedBox(height: 16),
                _inputField(cropCtrl, 'Jenis Tanaman',
                    'contoh: Tomat Cherry', Icons.eco_rounded),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      helpText: 'Pilih Tanggal Tanam',
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: AppColors.primary),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) setDState(() => selectedDate = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate == null
                              ? 'Pilih Tanggal Tanam'
                              : _formatDate(
                                  selectedDate!.toIso8601String().substring(0, 10)),
                          style: TextStyle(
                            color: selectedDate == null
                                ? Colors.grey
                                : AppColors.textDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (block != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Status: ',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Aktif'),
                        selected: currentStatus == 'active',
                        selectedColor: AppColors.lightGreen,
                        onSelected: (_) =>
                            setDState(() => currentStatus = 'active'),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Panen'),
                        selected: currentStatus == 'harvested',
                        selectedColor: Colors.orange.shade100,
                        onSelected: (_) =>
                            setDState(() => currentStatus = 'harvested'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                if (nameCtrl.text.isEmpty ||
                    cropCtrl.text.isEmpty ||
                    selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Semua kolom wajib diisi!')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                final dateStr =
                    selectedDate!.toIso8601String().substring(0, 10);
                if (block == null) {
                  await _addBlock(
                      nameCtrl.text, cropCtrl.text, dateStr);
                } else {
                  await _editBlock(block.id, nameCtrl.text,
                      cropCtrl.text, dateStr, currentStatus);
                }
              },
              child: Text(block == null ? 'Tambahkan' : 'Simpan',
                  style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, String label, String hint,
      IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  // ─── UI Build ──────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? _buildLoading()
          : _error != null
              ? _buildError()
              : _schedule.isEmpty
                  ? _buildEmptyState()
                  : _buildScheduleView(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditBlockDialog(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Tambah Blok',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Memuat jadwal lahan...',
              style: TextStyle(color: AppColors.textLight)),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadSchedule,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                  color: AppColors.lightGreen, shape: BoxShape.circle),
              child: const Icon(Icons.grass_rounded,
                  size: 64, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text('Belum Ada Blok Lahan',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const SizedBox(height: 12),
            const Text(
              'Tambahkan blok lahan pertama Anda untuk mulai menerima jadwal kegiatan otomatis berbasis cuaca dan umur tanaman.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textLight, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            BouncingButton(
              onTap: () => _showAddEditBlockDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8))
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Tambah Blok Pertama',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleView() {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxScrolled) => [
        SliverToBoxAdapter(child: _buildHeroSection()),
        SliverToBoxAdapter(child: _buildDatePicker()),
        if (_schedule.isNotEmpty)
          SliverToBoxAdapter(child: _buildBlockTabs()),
      ],
      body: _schedule.isEmpty
          ? const SizedBox()
          : TabBarView(
              controller: _tabController,
              children: _schedule
                  .map((blockSched) =>
                      _buildBlockScheduleBody(blockSched))
                  .toList(),
            ),
    );
  }

  Widget _buildHeroSection() {
    final completedCount =
        _schedule.fold<int>(0, (sum, b) => sum + (b['tasks'] as List).length);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 240,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(60),
              bottomRight: Radius.circular(60),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Jadwal Lahan',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1)),
                    Row(
                      children: [
                        BouncingButton(
                          onTap: _showManageBlocksSheet,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.dashboard_customize_rounded,
                                    color: Colors.white, size: 18),
                                SizedBox(width: 6),
                                Text('Kelola',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        BouncingButton(
                          onTap: _loadSchedule,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.refresh_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _locationName.isNotEmpty
                      ? '📍 $_locationName'
                      : '📍 Lokasi tidak terdeteksi',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                if (_weatherCurrent != null)
                  Row(
                    children: [
                      _weatherChip(
                          '🌡️ ${_weatherCurrent!['temperature']}°C',
                          Colors.orange.withOpacity(0.3)),
                      const SizedBox(width: 8),
                      _weatherChip(
                          '☁️ ${_weatherCurrent!['weather']}',
                          Colors.white.withOpacity(0.15)),
                      const SizedBox(width: 8),
                      _weatherChip(
                          '💧 ${_weatherCurrent!['humidity']}%',
                          Colors.blue.withOpacity(0.3)),
                    ],
                  ),
                if (_weatherAlert != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.orange.withOpacity(0.4)),
                      ),
                      child: Text(
                        _weatherAlert!,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${_schedule.length} Blok Aktif  ·  $completedCount Tugas Hari Ini',
                  style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _weatherChip(String label, Color bg) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      );

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: SizedBox(
        height: 82,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          clipBehavior: Clip.none,
          itemCount: _dates.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final date = _dates[index];
            final isSelected = index == _selectedDayIndex;
            return BouncingButton(
              onTap: () => setState(() => _selectedDayIndex = index),
              child: Container(
                width: 66,
                decoration: BoxDecoration(
                  color:
                      isSelected ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: isSelected ? 16 : 8,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_dayAbbr(date),
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white70
                                : AppColors.textLight)),
                    const SizedBox(height: 4),
                    Text(date.day.toString(),
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textDark)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlockTabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      indicatorColor: AppColors.primary,
      labelColor: AppColors.primary,
      unselectedLabelColor: AppColors.textLight,
      labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
      tabs: _schedule.map((b) => Tab(text: b['block_name'])).toList(),
    );
  }

  Widget _buildBlockScheduleBody(Map<String, dynamic> blockSched) {
    final tasks = List<Map<String, dynamic>>.from(blockSched['tasks'] ?? []);
    final hst = blockSched['hst'] ?? 0;
    final phase = blockSched['phase'] ?? '-';
    final phaseDesc = blockSched['phase_description'] ?? '';
    final cropType = blockSched['crop_type'] ?? '-';
    final blockId = blockSched['block_id'];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        // Block Header Card
        FadeSlideAnimation(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _phaseColor(phase).withOpacity(0.15),
                  _phaseColor(phase).withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: _phaseColor(phase).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _phaseColor(phase).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.eco_rounded,
                      color: _phaseColor(phase), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cropType,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: _phaseColor(phase),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(phase,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(width: 8),
                          Text('HST $hst',
                              style: TextStyle(
                                  color: _phaseColor(phase),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(phaseDesc,
                          style: const TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  ),
                ),
                BouncingButton(
                  onTap: () async {
                    // Fetch block detail untuk form edit
                    try {
                      final blocks = await _fetchBlocks();
                      final block = blocks.firstWhere(
                          (b) => b.id == blockId,
                          orElse: () => throw Exception('Not found'));
                      if (mounted) {
                        _showAddEditBlockDialog(block: block);
                      }
                    } catch (_) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Gagal memuat detail blok')),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Tasks
        ...tasks.asMap().entries.map((entry) {
          final i = entry.key;
          final task = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTaskCard(task, i, isLast: i == tasks.length - 1),
          );
        }),
      ],
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, int index,
      {bool isLast = false}) {
    final title = task['title'] ?? '';
    final time = task['time'] ?? '';
    final reason = task['reason'] ?? '';
    final iconType = task['iconType'] ?? 'leaf';
    final status = task['status'] ?? 'action';

    Color iconColor;
    IconData iconData;
    switch (iconType) {
      case 'water':
        iconColor = Colors.blue;
        iconData = Icons.water_drop_rounded;
        break;
      case 'bug':
        iconColor = Colors.red;
        iconData = Icons.pest_control_rounded;
        break;
      case 'sun':
        iconColor = Colors.orange;
        iconData = Icons.wb_sunny_rounded;
        break;
      default:
        iconColor = AppColors.primary;
        iconData = Icons.eco_rounded;
    }

    final isSkip = status == 'skip';

    return FadeSlideAnimation(
      delay: index * 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSkip
                      ? Colors.grey.shade100
                      : iconColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(isSkip ? Icons.skip_next_rounded : iconData,
                    color: isSkip ? Colors.grey : iconColor, size: 22),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 80,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iconColor.withOpacity(0.3),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isSkip ? Colors.grey.shade50 : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(32),
                ),
                border: Border.all(
                  color: isSkip
                      ? Colors.grey.shade200
                      : iconColor.withOpacity(0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isSkip
                                    ? Colors.grey
                                    : AppColors.textDark)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSkip
                              ? Colors.grey.shade100
                              : iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          time,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isSkip ? Colors.grey : iconColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(reason,
                      style: TextStyle(
                          fontSize: 13,
                          color: isSkip
                              ? Colors.grey.shade400
                              : AppColors.textLight,
                          height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Manage Blocks Bottom Sheet
// ─────────────────────────────────────────────
class _ManageBlocksSheet extends StatefulWidget {
  final Future<void> Function(String, String, String) onAdd;
  final Future<void> Function(int, String, String, String, String) onEdit;
  final Future<void> Function(int) onDelete;
  final Future<List<CropBlock>> Function() fetchBlocks;

  const _ManageBlocksSheet({
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.fetchBlocks,
  });

  @override
  State<_ManageBlocksSheet> createState() => _ManageBlocksSheetState();
}

class _ManageBlocksSheetState extends State<_ManageBlocksSheet> {
  late Future<List<CropBlock>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.fetchBlocks();
  }

  void _reload() => setState(() => _future = widget.fetchBlocks());

  String _formatDate(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length < 3) return isoDate;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  int _calcHST(String plantingDate) {
    final planted = DateTime.tryParse(plantingDate) ?? DateTime.now();
    return DateTime.now().difference(planted).inDays.clamp(0, 9999);
  }

  void _showEditDialog(CropBlock block) {
    final nameCtrl = TextEditingController(text: block.name);
    final cropCtrl = TextEditingController(text: block.cropType);
    DateTime? selectedDate = DateTime.tryParse(block.plantingDate);
    String currentStatus = block.status;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24)),
          title: const Text('✏️ Edit Blok',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nama Blok',
                    prefixIcon: const Icon(Icons.grid_view_rounded,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cropCtrl,
                  decoration: InputDecoration(
                    labelText: 'Jenis Tanaman',
                    prefixIcon: const Icon(Icons.eco_rounded,
                        color: AppColors.primary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, child) => Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                              primary: AppColors.primary),
                        ),
                        child: child!,
                      ),
                    );
                    if (picked != null) {
                      setDState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          selectedDate == null
                              ? 'Pilih Tanggal Tanam'
                              : _formatDate(selectedDate!
                                  .toIso8601String()
                                  .substring(0, 10)),
                          style: TextStyle(
                              color: selectedDate == null
                                  ? Colors.grey
                                  : AppColors.textDark,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Status: ',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Aktif'),
                      selected: currentStatus == 'active',
                      selectedColor: AppColors.lightGreen,
                      onSelected: (_) =>
                          setDState(() => currentStatus = 'active'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Panen'),
                      selected: currentStatus == 'harvested',
                      selectedColor: Colors.orange.shade100,
                      onSelected: (_) =>
                          setDState(() => currentStatus = 'harvested'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                if (nameCtrl.text.isEmpty ||
                    cropCtrl.text.isEmpty ||
                    selectedDate == null) return;
                Navigator.pop(ctx);
                await widget.onEdit(
                  block.id,
                  nameCtrl.text,
                  cropCtrl.text,
                  selectedDate!.toIso8601String().substring(0, 10),
                  currentStatus,
                );
                _reload();
              },
              child: const Text('Simpan',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(CropBlock block) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24)),
        title: const Text('🗑️ Hapus Blok?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Yakin ingin menghapus "${block.name} - ${block.cropType}"? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await widget.onDelete(block.id);
              _reload();
            },
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Row(
                children: [
                  const Text('Kelola Blok Lahan',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<CropBlock>>(
                future: _future,
                builder: (ctx, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primary));
                  }
                  if (snap.hasError) {
                    return Center(
                        child: Text('Error: ${snap.error}'));
                  }
                  final blocks = snap.data ?? [];
                  if (blocks.isEmpty) {
                    return const Center(
                        child: Text('Belum ada blok lahan.',
                            style:
                                TextStyle(color: AppColors.textLight)));
                  }
                  return ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                    itemCount: blocks.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final block = blocks[i];
                      final hst = _calcHST(block.plantingDate);
                      final isHarvested =
                          block.status == 'harvested';
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isHarvested
                              ? Colors.grey.shade50
                              : AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isHarvested
                                ? Colors.grey.shade200
                                : AppColors.primary.withOpacity(0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isHarvested
                                    ? Colors.grey.shade200
                                    : AppColors.primary
                                        .withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isHarvested
                                    ? Icons.inventory_2_rounded
                                    : Icons.eco_rounded,
                                color: isHarvested
                                    ? Colors.grey
                                    : AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(block.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: AppColors.textDark)),
                                  Text(block.cropType,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textLight)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                          '📅 ${_formatDate(block.plantingDate)}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color:
                                                  AppColors.textLight)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isHarvested
                                              ? Colors.grey.shade200
                                              : AppColors.primary
                                                  .withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isHarvested
                                              ? 'Panen'
                                              : 'HST $hst',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isHarvested
                                                ? Colors.grey
                                                : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showEditDialog(block),
                              icon: const Icon(Icons.edit_rounded,
                                  color: AppColors.primary, size: 20),
                            ),
                            IconButton(
                              onPressed: () =>
                                  _confirmDelete(block),
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Colors.red, size: 20),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}