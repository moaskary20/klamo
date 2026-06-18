import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/services/api_service.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistDashboardTab extends StatefulWidget {
  const SpecialistDashboardTab({super.key});

  @override
  State<SpecialistDashboardTab> createState() => _SpecialistDashboardTabState();
}

class _SpecialistDashboardTabState extends State<SpecialistDashboardTab> {
  DashboardStatsModel? _stats;
  List<RecentSessionModel> _sessions = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final appState = context.read<AppState>();
      final stats = await appState.loadDashboardStats();
      final sessions = await appState.loadRecentSessions();

      if (!mounted) return;
      setState(() {
        _stats = stats;
        _sessions = sessions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException ? e.message : e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }

    final stats = _stats!;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(child: _statCard('الأطفال', '${stats.childrenCount}', AppTheme.purple)),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(
                  'أنشطة مكتملة',
                  '${stats.completedActivitiesCount}',
                  AppTheme.grass,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _statCard(
            'متوسط الأداء',
            '${stats.averagePerformancePercent.toStringAsFixed(1)}%',
            AppTheme.orange,
            subtitle:
                'متوسط النجوم: ${stats.averageStars.toStringAsFixed(1)} / ${stats.maxStars}',
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'تقارير الأداء',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
            ),
            trailing: TextButton(
              onPressed: () => context.push('/specialist/reports'),
              child: const Text('عرض الكل'),
            ),
          ),
          PlayfulCard(
            accent: AppTheme.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'آخر الجلسات المكتملة',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (_sessions.isEmpty)
                  const Text('لا توجد جلسات مكتملة بعد.')
                else
                  ..._sessions.map(_sessionTile),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color accent, {String? subtitle}) {
    return PlayfulCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: accent.withValues(alpha: 0.9))),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _sessionTile(RecentSessionModel session) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppTheme.teal.withValues(alpha: 0.15),
        child: Text('${session.starsEarned}'),
      ),
      title: Text(session.childName ?? 'طفل'),
      subtitle: Text(
        '${session.wordName ?? '—'} • ${session.activityLabel ?? ''}',
      ),
      trailing: Text(session.worldName ?? ''),
    );
  }
}
