import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/reward_service.dart';
import '../../core/services/report_service.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _rewardService = RewardService();
  final _reportService = ReportService();

  List<Map<String, dynamic>> _allRewards = [];
  List<Map<String, dynamic>> _myRewards = [];
  int _myPoints = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _rewardService.getAllRewards(),
        _rewardService.getMyRewards(),
        _reportService.getMySummary(),
      ]);
      setState(() {
        _allRewards = results[0] as List<Map<String, dynamic>>;
        _myRewards = results[1] as List<Map<String, dynamic>>;
        _myPoints = ((results[2] as Map<String, dynamic>)['totalPoints'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {
      // silently fail; user can pull to refresh
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _claim(Map<String, dynamic> reward) async {
    final id = reward['id'] as int;
    final required = (reward['requiredPoints'] as num).toInt();
    if (_myPoints < required) {
      _showSnack('❌ Yeterli puanın yok! Gerekli: $required pt', Colors.red);
      return;
    }
    try {
      await _rewardService.claimReward(id);
      _showSnack('🎉 Ödül alındı!', AppColors.success);
      _loadData();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] as String? ?? 'Hata oluştu.';
      _showSnack('❌ $msg', Colors.red);
    }
  }

  void _showSnack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Points banner
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withOpacity(0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFFFD700), size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mevcut Puanın',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text(
                    '$_myPoints pt',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.eco_rounded, color: Colors.white30, size: 36),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            indicator: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: '🛒  Mağaza'),
              Tab(text: '🎁  Ödüllerim'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadData,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildShopTab(),
                      _buildMyRewardsTab(),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildShopTab() {
    if (_allRewards.isEmpty) {
      return const Center(child: Text('Ödül bulunamadı.', style: TextStyle(color: AppColors.textSecondary)));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: _allRewards.length,
      itemBuilder: (_, i) => _rewardCard(_allRewards[i]),
    );
  }

  Widget _buildMyRewardsTab() {
    if (_myRewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.card_giftcard_outlined, size: 52, color: AppColors.textSecondary),
            const SizedBox(height: 10),
            const Text('Henüz ödül almadın.', style: TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text('Puan kazanıp mağazadan ödül al!',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: _myRewards.length,
      itemBuilder: (_, i) => _myRewardCard(_myRewards[i]),
    );
  }

  Widget _rewardCard(Map<String, dynamic> r) {
    final req = (r['requiredPoints'] as num).toInt();
    final canClaim = _myPoints >= req;
    final alreadyClaimed = _myRewards.any(
      (mr) => (mr['reward']?['id'] as int?) == (r['id'] as int?),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: canClaim
                    ? [const Color(0xFF2E7D32), const Color(0xFF66BB6A)]
                    : [Colors.grey.shade200, Colors.grey.shade300],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _rewardIcon(r['name']?.toString() ?? ''),
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r['name']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14),
                ),
                const SizedBox(height: 3),
                Text(
                  r['description']?.toString() ?? '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded, size: 14, color: Color(0xFFFFD700)),
                    const SizedBox(width: 3),
                    Text('$req pt',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppColors.textPrimary)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          alreadyClaimed
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Alındı ✓',
                      style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
                )
              : FilledButton(
                  onPressed: canClaim ? () => _claim(r) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey.shade200,
                    minimumSize: const Size(72, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('Al', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ),
        ],
      ),
    );
  }

  Widget _myRewardCard(Map<String, dynamic> ur) {
    final reward = ur['reward'] as Map<String, dynamic>?;
    final usedAt = ur['usedAt'];
    final isUsed = usedAt != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUsed ? Colors.grey.shade200 : AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isUsed ? Icons.check_circle_outline : Icons.card_giftcard_outlined,
              color: isUsed ? Colors.grey : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward?['name']?.toString() ?? '',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isUsed ? AppColors.textSecondary : AppColors.textPrimary,
                    decoration: isUsed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isUsed ? 'Kullanıldı' : 'Kullanılabilir',
                  style: TextStyle(
                    fontSize: 12,
                    color: isUsed ? Colors.grey : AppColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (!isUsed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Aktif',
                  style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
        ],
      ),
    );
  }

  IconData _rewardIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('bisiklet') || n.contains('bike')) return Icons.directions_bike;
    if (n.contains('toplu') || n.contains('taşıma') || n.contains('ulaşım')) return Icons.directions_bus;
    if (n.contains('fidan') || n.contains('ağaç') || n.contains('tree')) return Icons.park;
    if (n.contains('premium')) return Icons.workspace_premium;
    return Icons.eco;
  }
}
