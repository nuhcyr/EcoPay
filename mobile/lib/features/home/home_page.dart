import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/activity_service.dart';
import '../../core/services/report_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _activityService = ActivityService();
  final _reportService = ReportService();

  Map<String, dynamic>? _summary;
  List<Map<String, dynamic>> _activities = [];
  Map<String, dynamic>? _weekly;
  bool _loadingData = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool fullScreenLoader = true}) async {
    if (fullScreenLoader) {
      setState(() {
        _loadingData = true;
        _error = null;
      });
    } else if (mounted) {
      setState(() => _error = null);
    }
    try {
      final results = await Future.wait([
        _reportService.getMySummary(),
        _activityService.getMyActivities(),
        _reportService.getMyWeekly(),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as Map<String, dynamic>;
        _activities = results[1] as List<Map<String, dynamic>>;
        _weekly = results[2] as Map<String, dynamic>;
      });
    } on DioException catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Veriler yüklenemedi.';
          _weekly = null;
        });
      }
    } finally {
      if (mounted && fullScreenLoader) {
        setState(() => _loadingData = false);
      }
    }
  }

  Future<void> _showAddActivitySheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddActivitySheet(
        onSubmit: (type, distance) async {
          Navigator.pop(ctx);
          try {
            await _activityService.createActivity(type: type, distance: distance);
            await _loadData(fullScreenLoader: false);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Aktivite kaydedildi!'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          } catch (_) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('❌ Aktivite kaydedilemedi.'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => _loadData(fullScreenLoader: false),
      child: _loadingData
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Eco Card
                _buildEcoCard(),
                const SizedBox(height: 20),
                // Stats Row
                if (_summary != null) _buildStatsRow(),
                const SizedBox(height: 20),
                if (_weekly != null) _buildWeeklyPulseSection(),
                if (_weekly != null) const SizedBox(height: 20),
                // Log Activity Button
                _buildLogButton(),
                const SizedBox(height: 20),
                // Activities
                _buildActivitiesSection(),
              ],
            ),
    );
  }

  Widget _buildEcoCard() {
    final points = _summary?['totalPoints'] ?? 0;
    final level = _summary?['level'] ?? 'GREEN_STARTER';
    final levelLabel = _levelLabel(level.toString());
    final levelColor = _levelColor(level.toString());

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Eco Kart',
                style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  children: [
                    Icon(Icons.military_tech_rounded, size: 14, color: levelColor),
                    const SizedBox(width: 4),
                    Text(
                      levelLabel,
                      style: TextStyle(color: levelColor, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 6),
                child: Text(
                  'Yeşil Puan',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.verified_rounded, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                _summary?['email'] ?? 'eco.user@ecopay.app',
                style: const TextStyle(color: Colors.white, fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalActivities = _summary?['totalActivities'] ?? 0;
    final totalCarbon = _summary?['totalCarbonEmissionKg'] ?? _summary?['totalCarbonEmission'] ?? 0.0;

    return Row(
      children: [
        Expanded(child: _statCard('Aktivite', '$totalActivities', Icons.directions_run_rounded, AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(
          child: _statCard(
            'CO₂ Emisyon',
            '${(totalCarbon is num ? totalCarbon.toStringAsFixed(1) : totalCarbon)} kg',
            Icons.co2_rounded,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyPulseSection() {
    final w = _weekly!;
    final streak = (w['streakDays'] as num?)?.toInt() ?? 0;
    final count = (w['weeklyActivityCount'] as num?)?.toInt() ?? 0;
    final goal = (w['weeklyGoal'] as num?)?.toInt() ?? 3;
    final met = w['weeklyGoalMet'] == true;
    final days = (w['lastSevenDays'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];
    var maxC = 0.01;
    for (final d in days) {
      final c = (d['carbonKg'] as num?)?.toDouble() ?? 0;
      if (c > maxC) maxC = c;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Son 7 gün • hedef & seri',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: met ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  met ? 'Hedef OK' : '$count / $goal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: met ? AppColors.success : Colors.orange.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Seri: $streak gün (ardışık yeşil gün) • Haftalık hedef: $goal aktivite',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 92,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final c = (d['carbonKg'] as num?)?.toDouble() ?? 0;
                final n = (d['activityCount'] as num?)?.toInt() ?? 0;
                final ratio = maxC > 0 ? c / maxC : 0.0;
                final h = 10.0 + (70 * ratio);
                final dateStr = d['date']?.toString() ?? '';
                final dayLabel = dateStr.length >= 10 ? dateStr.substring(8, 10) : '?';
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (n > 0)
                          Text(
                            '$n',
                            style: const TextStyle(fontSize: 9, color: AppColors.textSecondary),
                          ),
                        const SizedBox(height: 2),
                        Container(
                          height: h.clamp(10.0, 80.0),
                          decoration: BoxDecoration(
                            color: c > 0 ? AppColors.primary : const Color(0xFFE0E8DC),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(dayLabel, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Çubuklar günlük CO₂ (kg). Özet Europe/Istanbul gününe göre.',
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showAddActivitySheet,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_road_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktivite ekle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Ulaşımını kaydet, puan ve CO₂ özeti güncellensin',
                        style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.25),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivitiesSection() {
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary)));
    }
    if (_activities.isEmpty) {
      return Center(
        child: Column(
          children: [
            const Icon(Icons.directions_bike_outlined, size: 48, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            const Text('Henüz aktivite yok.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text('Bir ulaşım ekleyerek puan kazan!', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Son Aktiviteler', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ..._activities.take(10).map((a) => _activityTile(a)),
      ],
    );
  }

  Widget _activityTile(Map<String, dynamic> a) {
    final type = a['type']?.toString() ?? 'WALK';
    final distance = a['distance'];
    final carbon = a['carbonEmission'];
    final points = a['earnedPoints'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _typeColor(type).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_typeIcon(type), color: _typeColor(type), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_typeLabel(type), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(
                  '${distance} km • CO₂: ${carbon} kg',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+$points pt',
              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  String _levelLabel(String level) {
    switch (level) {
      case 'ECO_HERO': return 'Eco Hero';
      case 'ECO_RISER': return 'Eco Riser';
      default: return 'Green Starter';
    }
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'ECO_HERO': return const Color(0xFFFFD700);
      case 'ECO_RISER': return const Color(0xFF80CBC4);
      default: return Colors.white;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'CAR':
        return Icons.directions_car_outlined;
      case 'BUS':
        return Icons.directions_bus_outlined;
      case 'BIKE':
        return Icons.directions_bike_outlined;
      case 'WALK':
        return Icons.directions_walk_outlined;
      case 'METRO':
        return Icons.train_outlined;
      case 'TRAIN':
        return Icons.tram_outlined;
      case 'E_SCOOTER':
        return Icons.electric_scooter_outlined;
      case 'EV_CAR':
        return Icons.electric_car_outlined;
      default:
        return Icons.directions_outlined;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'CAR':
        return Colors.orange;
      case 'BUS':
        return Colors.blue;
      case 'BIKE':
        return AppColors.primary;
      case 'WALK':
        return AppColors.success;
      case 'METRO':
        return const Color(0xFF1565C0);
      case 'TRAIN':
        return const Color(0xFF00695C);
      case 'E_SCOOTER':
        return const Color(0xFF7B1FA2);
      case 'EV_CAR':
        return const Color(0xFF00838F);
      default:
        return AppColors.textSecondary;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'CAR':
        return 'Benzinli araç';
      case 'BUS':
        return 'Otobüs';
      case 'BIKE':
        return 'Bisiklet';
      case 'WALK':
        return 'Yürüyüş';
      case 'METRO':
        return 'Metro';
      case 'TRAIN':
        return 'Tren';
      case 'E_SCOOTER':
        return 'E-scooter';
      case 'EV_CAR':
        return 'Elektrikli araç';
      default:
        return type;
    }
  }
}

// ── Add Activity Bottom Sheet ─────────────────────────────────────────────────

class _AddActivitySheet extends StatefulWidget {
  const _AddActivitySheet({required this.onSubmit});
  final Future<void> Function(String type, double distance) onSubmit;

  @override
  State<_AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<_AddActivitySheet> {
  String _selectedType = 'WALK';
  final _distanceCtrl = TextEditingController(text: '3');
  bool _loading = false;
  double _sliderKm = 3;

  static const _quickKm = [1.0, 2.0, 5.0, 10.0];

  final _types = [
    {'value': 'WALK', 'label': 'Yürüyüş', 'hint': 'Kısa mesafe; CO₂ hesabı 0 (demo).', 'icon': Icons.directions_walk_outlined, 'color': AppColors.success},
    {'value': 'BIKE', 'label': 'Bisiklet', 'hint': 'Aktif ulaşım; CO₂ 0 (demo).', 'icon': Icons.directions_bike_outlined, 'color': AppColors.primary},
    {'value': 'BUS', 'label': 'Otobüs', 'hint': 'Toplu taşıma; kişi başı düşük emisyon.', 'icon': Icons.directions_bus_outlined, 'color': Colors.blue},
    {'value': 'METRO', 'label': 'Metro', 'hint': 'Raylı toplu taşıma; trafikten daha verimli.', 'icon': Icons.train_outlined, 'color': Color(0xFF1565C0)},
    {'value': 'TRAIN', 'label': 'Tren', 'hint': 'Orta/uzun mesafe için düşük katsayı (örnek).', 'icon': Icons.tram_outlined, 'color': Color(0xFF00695C)},
    {'value': 'E_SCOOTER', 'label': 'E-scooter', 'hint': 'Elektrikli hafif araç; düşük katsayı.', 'icon': Icons.two_wheeler, 'color': Color(0xFF7B1FA2)},
    {'value': 'EV_CAR', 'label': 'EV araç', 'hint': 'Şarjlı araç; benzinliden düşük (örnek).', 'icon': Icons.electric_car_outlined, 'color': Color(0xFF00838F)},
    {'value': 'CAR', 'label': 'Benzinli', 'hint': 'İçten yanmalı; en yüksek katsayı (örnek).', 'icon': Icons.directions_car_outlined, 'color': Colors.orange},
  ];

  Map<String, dynamic> get _selectedMeta =>
      _types.firstWhere((t) => t['value'] == _selectedType, orElse: () => _types.first);

  @override
  void dispose() {
    _distanceCtrl.dispose();
    super.dispose();
  }

  void _setDistanceKm(double km) {
    final rounded = double.parse(km.toStringAsFixed(1));
    setState(() {
      _sliderKm = rounded.clamp(0.1, 50.0);
      _distanceCtrl.text = _sliderKm == _sliderKm.roundToDouble()
          ? _sliderKm.toInt().toString()
          : _sliderKm.toStringAsFixed(1);
    });
  }

  void _applyQuickKm(double km) => _setDistanceKm(km);

  @override
  Widget build(BuildContext context) {
    final selectedColor = _selectedMeta['color'] as Color;
    return Container(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    selectedColor.withValues(alpha: 0.18),
                    const Color(0xFFF6F8F5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selectedColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_selectedMeta['icon'] as IconData, color: selectedColor, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bugün ne yaptın?',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedMeta['hint'] as String,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Ulaşım türü', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(
              'Katsayılar gösterim içindir; gerçek karbon farklı olabilir.',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.25),
            ),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.75,
              children: _types.map((t) {
                final selected = _selectedType == t['value'];
                final color = t['color'] as Color;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => setState(() => _selectedType = t['value'] as String),
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: selected ? color.withValues(alpha: 0.12) : const Color(0xFFF6F8F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected ? color : const Color(0xFFE0E8DC),
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            t['icon'] as IconData,
                            color: selected ? color : AppColors.textSecondary,
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            t['label'] as String,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                              color: selected ? color : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 22),
            const Text('Mesafe', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Hızlı seç', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickKm.map((km) {
                final label = km == km.roundToDouble() ? '${km.toInt()} km' : '$km km';
                return ActionChip(
                  label: Text(label),
                  side: BorderSide(color: AppColors.primary.withValues(alpha: 0.35)),
                  onPressed: () => setState(() => _applyQuickKm(km)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text('${_sliderKm.toStringAsFixed(1)} km', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const Spacer(),
                Text('0–50 km', style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: selectedColor,
                thumbColor: selectedColor,
                overlayColor: selectedColor.withValues(alpha: 0.15),
                inactiveTrackColor: const Color(0xFFE0E8DC),
              ),
              child: Slider(
                value: _sliderKm.clamp(0.1, 50.0),
                min: 0.1,
                max: 50,
                divisions: 499,
                onChanged: (v) => setState(() => _setDistanceKm(v)),
              ),
            ),
            TextField(
              controller: _distanceCtrl,
              onChanged: (s) {
                final v = double.tryParse(s.replaceAll(',', '.'));
                if (v != null && v > 0 && v <= 50) {
                  setState(() => _sliderKm = v);
                }
              },
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Mesafe (elle)',
                hintText: 'Örn. 2,5',
                prefixIcon: const Icon(Icons.straighten_rounded, color: AppColors.textSecondary, size: 20),
                filled: true,
                fillColor: const Color(0xFFF6F8F5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE0E8DC)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.eco_rounded, color: selectedColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Kaydettiğinde özet kartın ve “Son aktiviteler” listesi güncellenir; puanlar sunucu kurallarına göre hesaplanır.',
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 12, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _loading
                    ? null
                    : () async {
                        final dist = double.tryParse(_distanceCtrl.text.replaceAll(',', '.'));
                        if (dist == null || dist <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Geçerli bir mesafe girin')),
                          );
                          return;
                        }
                        setState(() => _loading = true);
                        await widget.onSubmit(_selectedType, dist);
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _loading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Kaydet ve puana ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
