import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/report_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/company_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.onLogoutTap});
  final VoidCallback onLogoutTap;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _reportService = ReportService();
  final _leaderboardService = LeaderboardService();
  final _authService = AuthService();
  final _companyService = CompanyService();

  Map<String, dynamic>? _summary;
  Map<String, dynamic>? _company;
  List<Map<String, dynamic>> _leaderboard = [];
  List<Map<String, dynamic>> _companyMembers = [];
  List<Map<String, dynamic>> _companyStandings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _reportService.getMySummary(),
        _leaderboardService.getTopUsers(limit: 10),
        _companyService.getMyCompany(),
      ]);
      setState(() {
        _summary = results[0] as Map<String, dynamic>;
        _leaderboard = results[1] as List<Map<String, dynamic>>;
        _company = results[2] as Map<String, dynamic>?;
      });
      if (_company != null) {
        final nested = await Future.wait([
          _companyService.members(),
          _companyService.standings(),
        ]);
        if (!mounted) return;
        setState(() {
          _companyMembers = nested[0];
          _companyStandings = nested[1];
        });
      } else if (mounted) {
        setState(() {
          _companyMembers = [];
          _companyStandings = [];
        });
      }
    } on DioException catch (_) {
      // silently fail
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final msg = data['message'];
      if (msg is String) return msg;
    }
    return 'İşlem başarısız';
  }

  Future<void> _showCreateCompanySheet() async {
    final nameCtrl = TextEditingController();
    final domainCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Şirket oluştur',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hesabındaki e-posta ile aynı alan olmalı (örn: acme.com).',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Şirket adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: domainCtrl,
                decoration: const InputDecoration(
                  labelText: 'E-posta alanı',
                  hintText: 'sirket.com',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  try {
                    final c = await _companyService.create(
                      name: nameCtrl.text.trim(),
                      emailDomain: domainCtrl.text.trim(),
                    );
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    setState(() => _company = c);
                    final messenger = ScaffoldMessenger.of(context);
                    await _loadData();
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Şirket oluşturuldu')),
                      );
                    }
                  } on DioException catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(_dioMessage(e))),
                      );
                    }
                  }
                },
                child: const Text('Oluştur'),
              ),
            ],
          ),
        );
      },
    );
    nameCtrl.dispose();
    domainCtrl.dispose();
  }

  Future<void> _showJoinCompanySheet() async {
    final codeCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Davet kodu ile katıl',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'E-postanız şirketin izin verdiği alanla eşleşmeli.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Davet kodu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () async {
                  try {
                    final c = await _companyService.join(codeCtrl.text);
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    setState(() => _company = c);
                    final messenger = ScaffoldMessenger.of(context);
                    await _loadData();
                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Şirkete katıldınız')),
                      );
                    }
                  } on DioException catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(_dioMessage(e))),
                      );
                    }
                  }
                },
                child: const Text('Katıl'),
              ),
            ],
          ),
        );
      },
    );
    codeCtrl.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Çıkış Yap', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Hesabından çıkmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _authService.logout();
      widget.onLogoutTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final email = _summary?['email']?.toString() ?? 'kullanici@ecopay.app';
    final points = (_summary?['totalPoints'] as num?)?.toInt() ?? 0;
    final level = _summary?['level']?.toString() ?? 'GREEN_STARTER';
    final totalActivities = (_summary?['totalActivities'] as num?)?.toInt() ?? 0;
    final carbonRaw = _summary?['totalCarbonEmissionKg'] ?? _summary?['totalCarbonEmission'];
    final totalCarbon = (carbonRaw is num) ? carbonRaw.toDouble() : 0.0;

    // Find rank in leaderboard
    final myRank = _leaderboard.indexWhere((u) => u['email'] == email);
    final rankText = myRank >= 0 ? '#${myRank + 1}' : '-';

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
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
              children: [
                // Avatar
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white38, width: 2),
                  ),
                  child: const Icon(Icons.person_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                _levelBadge(level),
                const SizedBox(height: 18),
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _profileStat('$points', 'Puan', Icons.stars_rounded),
                    _vDivider(),
                    _profileStat('$totalActivities', 'Aktivite', Icons.directions_run_rounded),
                    _vDivider(),
                    _profileStat(rankText, 'Sıralama', Icons.leaderboard_rounded),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Carbon savings card
          _infoCard(
            icon: Icons.co2_rounded,
            iconColor: Colors.orange,
            title: 'Toplam CO₂ Emisyonu',
            value: '${totalCarbon.toStringAsFixed(2)} kg',
            subtitle: totalCarbon == 0
                ? '🌱 Harika! Hiç emisyon yok.'
                : '🔄 Bisiklet & yürüyüş ile azaltabilirsin.',
          ),
          const SizedBox(height: 12),
          // Level progress card
          _levelProgressCard(level, points),
          const SizedBox(height: 20),
          _companySection(email),
          const SizedBox(height: 20),
          // Leaderboard section
          if (_leaderboard.isNotEmpty) ...[
            const Text(
              '🏆 Liderlik Tablosu',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            ..._leaderboard.asMap().entries.map(
              (e) => _leaderboardTile(e.key, e.value, email),
            ),
            const SizedBox(height: 20),
          ],
          // Logout button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Çıkış Yap', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _companySection(String userEmail) {
    final c = _company;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Şirket',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 10),
        if (c == null) ...[
          const Text(
            'Şirket yetkilisi oda açar; davet kodu ile ekibinizi ekleyin. E-posta alanı (@sirket.com) doğrulanır.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _showCreateCompanySheet,
                  child: const Text('Şirket oluştur'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: _showJoinCompanySheet,
                  child: const Text('Kod ile katıl'),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.apartment_rounded, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        c['name']?.toString() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (c['owner'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Yetkili',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '@${c['emailDomain']}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 14),
                const Text('Davet kodu', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        c['inviteCode']?.toString() ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          letterSpacing: 1.2,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Kopyala',
                      onPressed: () {
                        final code = c['inviteCode']?.toString() ?? '';
                        Clipboard.setData(ClipboardData(text: code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Davet kodu kopyalandı')),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Paylaşılabilir metin: EcoPay → Profil → Kod ile katıl → ${c['inviteCode']}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
              ],
            ),
          ),
          if (_companyMembers.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Şirket içi sıra',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ..._companyMembers.take(8).toList().asMap().entries.map((e) {
              final m = e.value;
              final mail = m['email']?.toString() ?? '';
              final pts = (m['totalPoints'] as num?)?.toInt() ?? 0;
              final isMe = mail == userEmail;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Text(
                  '#${e.key + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isMe ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                title: Text(
                  mail,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                    color: isMe ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                trailing: Text('$pts', style: const TextStyle(fontWeight: FontWeight.w700)),
              );
            }),
          ],
          if (_companyStandings.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Şirketler arası',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            ..._companyStandings.take(8).toList().asMap().entries.map((e) {
              final s = e.value;
              final id = (s['companyId'] as num?)?.toInt();
              final myId = (c['id'] as num?)?.toInt();
              final isMine = id != null && myId != null && id == myId;
              final sum = (s['totalPointsSum'] as num?)?.toInt() ?? 0;
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Text(
                  '#${e.key + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isMine ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
                title: Text(
                  s['companyName']?.toString() ?? '',
                  style: TextStyle(
                    fontWeight: isMine ? FontWeight.w700 : FontWeight.w500,
                    color: isMine ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                ),
                trailing: Text('$sum', style: const TextStyle(fontWeight: FontWeight.w700)),
              );
            }),
          ],
        ],
      ],
    );
  }

  Widget _levelBadge(String level) {
    final map = {
      'ECO_HERO': ('Eco Hero 🥇', const Color(0xFFFFD700)),
      'ECO_RISER': ('Eco Riser 🌿', const Color(0xFF80CBC4)),
      'GREEN_STARTER': ('Green Starter 🌱', Colors.white70),
    };
    final (label, color) = map[level] ?? ('Green Starter 🌱', Colors.white70);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }

  Widget _profileStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _vDivider() => Container(width: 1, height: 40, color: Colors.white24);

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
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
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                Text(value,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelProgressCard(String level, int points) {
    final thresholds = {'GREEN_STARTER': 0, 'ECO_RISER': 300, 'ECO_HERO': 1000};
    final nextThresholds = {'GREEN_STARTER': 300, 'ECO_RISER': 1000, 'ECO_HERO': 1000};
    final current = thresholds[level] ?? 0;
    final next = nextThresholds[level] ?? 1000;
    final progress = level == 'ECO_HERO' ? 1.0 : ((points - current) / (next - current)).clamp(0.0, 1.0);
    final nextLevel = {'GREEN_STARTER': 'Eco Riser', 'ECO_RISER': 'Eco Hero', 'ECO_HERO': 'MAX'}[level]!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Seviye İlerlemesi',
                  style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontSize: 14)),
              Text(
                level == 'ECO_HERO' ? 'MAX SEVİYE 🥇' : 'Sonraki: $nextLevel',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            level == 'ECO_HERO'
                ? '🎉 En yüksek seviyedesin!'
                : '$points / $next puan  (${(progress * 100).toStringAsFixed(0)}%)',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _leaderboardTile(int index, Map<String, dynamic> user, String myEmail) {
    final email = user['email']?.toString() ?? '';
    final pts = (user['totalPoints'] as num?)?.toInt() ?? 0;
    final isMe = email == myEmail;
    final rank = index + 1;

    Color rankColor;
    Widget rankWidget;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      rankWidget = const Text('🥇', style: TextStyle(fontSize: 20));
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      rankWidget = const Text('🥈', style: TextStyle(fontSize: 20));
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      rankWidget = const Text('🥉', style: TextStyle(fontSize: 20));
    } else {
      rankColor = AppColors.textSecondary;
      rankWidget = Text(
        '#$rank',
        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textSecondary),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? AppColors.primary.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: rank <= 3
            ? Border.all(color: rankColor.withOpacity(0.35))
            : (isMe ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: 32, child: Center(child: rankWidget)),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 18,
            backgroundColor: isMe ? AppColors.primary : Colors.grey.shade200,
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : '?',
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  email,
                  style: TextStyle(
                    fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                    color: isMe ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (isMe)
                  const Text('Sen', style: TextStyle(color: AppColors.primary, fontSize: 11)),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(Icons.stars_rounded, size: 14, color: Color(0xFFFFD700)),
              const SizedBox(width: 3),
              Text(
                '$pts',
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
