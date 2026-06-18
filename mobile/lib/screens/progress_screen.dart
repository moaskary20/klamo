import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/child_avatar.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:klamo_mobile/widgets/star_rating.dart';
import 'package:provider/provider.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<ProgressModel> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = context.read<AppState>().loadProgress();
  }

  void _reload() {
    setState(() {
      _progressFuture = context.read<AppState>().loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final child = context.watch<AppState>().selectedChild;

    return Scaffold(
      appBar: const KlamoAppBar(title: Text('تقدم الطفل 🏆')),
      body: FutureBuilder<ProgressModel>(
        future: _progressFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(error: '${snapshot.error}', onRetry: _reload);
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('لا توجد بيانات تقدم'));
          }

          final progress = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _ProfileHeader(child: child, progress: progress),
                const SizedBox(height: 16),
                _SummaryGrid(progress: progress),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'نسبة الإنجاز الكلية',
                  subtitle: 'من الأنشطة المتاحة لمستوى الطفل',
                  child: _CompletionRing(progress: progress),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'الأنشطة حسب النوع',
                  subtitle: 'توزيع ما أنجزه الطفل',
                  child: _ActivityTypeChart(stats: progress.byActivityType),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'التقدم في العوالم',
                  subtitle: 'أنشطة مكتملة في كل عالم',
                  child: _WorldProgressChart(worlds: progress.byWorld),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'توزيع النجوم',
                  subtitle: 'عدد المرات لكل تقييم',
                  child: _StarsDistributionChart(
                    buckets: progress.starsDistribution,
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'نشاط الأسبوع',
                  subtitle: 'عدد الأنشطة المكتملة يومياً',
                  child: _WeeklyActivityChart(days: progress.weeklyActivity),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'آخر الأنشطة',
                  subtitle: 'سجل تعلم الطفل الأخير',
                  child: _RecentActivitiesList(
                    activities: progress.recentActivities,
                    maxStars: progress.maxStarsPerActivity,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              'تعذّر تحميل التقدم',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.child, required this.progress});

  final ChildModel? child;
  final ProgressModel progress;

  @override
  Widget build(BuildContext context) {
    return PlayfulCard(
      accent: AppTheme.purple,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (child != null) ChildAvatar(name: child!.name, imageUrl: child!.avatar, size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child?.name ?? 'الطفل',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.skyDeep,
                      ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _ChipBadge(
                      label: 'المستوى ${progress.level}',
                      color: AppTheme.purple,
                    ),
                    _ChipBadge(
                      label: '${progress.trainedWordsCount} كلمة',
                      color: AppTheme.teal,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                StarRating(
                  stars: progress.averageStars.round().clamp(0, progress.maxStarsPerActivity),
                  maxStars: progress.maxStarsPerActivity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  const _ChipBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.progress});

  final ProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem('أنشطة مكتملة', '${progress.completedActivitiesCount}', Icons.check_circle, AppTheme.grass),
      _SummaryItem('إجمالي النجوم', '${progress.totalStars}', Icons.star, AppTheme.orange),
      _SummaryItem('متوسط الأداء', '${progress.averageStars}', Icons.insights, AppTheme.teal),
      _SummaryItem('نسبة الأداء', '${progress.overallPerformanceScore.toStringAsFixed(0)}%', Icons.speed, AppTheme.purple),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.45,
      children: items.map((item) => _SummaryTile(item: item)).toList(),
    );
  }
}

class _SummaryItem {
  const _SummaryItem(this.title, this.value, this.icon, this.color);

  final String title;
  final String value;
  final IconData icon;
  final Color color;
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.item});

  final _SummaryItem item;

  @override
  Widget build(BuildContext context) {
    return PlayfulCard(
      accent: item.color,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item.icon, color: item.color, size: 26),
          const Spacer(),
          Text(
            item.value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.skyDeep,
                ),
          ),
          Text(
            item.title,
            style: TextStyle(
              color: AppTheme.purpleDeep.withValues(alpha: 0.75),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PlayfulCard(
      accent: AppTheme.teal,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.skyDeep,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _CompletionRing extends StatelessWidget {
  const _CompletionRing({required this.progress});

  final ProgressModel progress;

  @override
  Widget build(BuildContext context) {
    final percent = progress.completionRate.clamp(0, 100) / 100;

    return SizedBox(
      height: 180,
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: percent,
                    strokeWidth: 14,
                    backgroundColor: AppTheme.teal.withValues(alpha: 0.15),
                    color: AppTheme.grass,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${progress.completionRate.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.skyDeep,
                          ),
                    ),
                    const Text('مكتمل', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _LegendRow(
                  color: AppTheme.grass,
                  label: 'أنشطة منجزة',
                  value: '${progress.uniqueActivitiesCount}',
                ),
                const SizedBox(height: 8),
                _LegendRow(
                  color: AppTheme.teal.withValues(alpha: 0.35),
                  label: 'متاحة للمستوى',
                  value: '${progress.availableActivitiesCount}',
                ),
                const SizedBox(height: 8),
                _LegendRow(
                  color: AppTheme.orange,
                  label: 'إجمالي المحاولات',
                  value: '${progress.totalAttemptsCount}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.color, required this.label, required this.value});

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _ActivityTypeChart extends StatelessWidget {
  const _ActivityTypeChart({required this.stats});

  final List<ProgressActivityTypeStat> stats;

  static const _colors = [AppTheme.teal, AppTheme.purple, AppTheme.orange];

  @override
  Widget build(BuildContext context) {
    final active = stats.where((s) => s.count > 0).toList();
    final total = active.fold<int>(0, (sum, s) => sum + s.count);

    if (total == 0) return const _EmptyChart(message: 'لم يكمل الطفل أنشطة بعد');

    return SizedBox(
      height: 220,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: [
                  for (var i = 0; i < active.length; i++)
                    PieChartSectionData(
                      value: active[i].count.toDouble(),
                      color: _colors[i % _colors.length],
                      title: '${((active[i].count / total) * 100).round()}%',
                      radius: 52,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < active.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _LegendRow(
                      color: _colors[i % _colors.length],
                      label: active[i].label,
                      value: '${active[i].count}',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldProgressChart extends StatelessWidget {
  const _WorldProgressChart({required this.worlds});

  final List<ProgressWorldStat> worlds;

  @override
  Widget build(BuildContext context) {
    final active = worlds.where((w) => w.totalAvailable > 0).toList();
    if (active.isEmpty) return const _EmptyChart(message: 'لا توجد عوالم متاحة');

    final maxY = active
        .map((w) => w.totalAvailable.toDouble())
        .fold<double>(0, (a, b) => a > b ? a : b);

    return SizedBox(
      height: 220,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY + 1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppTheme.teal.withValues(alpha: 0.12),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= active.length) return const SizedBox.shrink();
                  final name = active[index].worldName;
                  final short = name.length > 6 ? '${name.substring(0, 6)}…' : name;
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(short, style: const TextStyle(fontSize: 9)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < active.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: active[i].completed.toDouble(),
                    color: AppTheme.worldColors[i % AppTheme.worldColors.length],
                    width: 16,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: active[i].totalAvailable.toDouble(),
                      color: AppTheme.teal.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StarsDistributionChart extends StatelessWidget {
  const _StarsDistributionChart({required this.buckets});

  final List<ProgressStarsBucket> buckets;

  @override
  Widget build(BuildContext context) {
    final maxCount = buckets.fold<int>(0, (max, b) => b.count > max ? b.count : max);
    if (maxCount == 0) return const _EmptyChart(message: 'لا توجد نجوم بعد');

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: maxCount.toDouble() + 1,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= buckets.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 10, color: AppTheme.orange),
                        Text('${buckets[index].stars}', style: const TextStyle(fontSize: 10)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < buckets.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: buckets[i].count.toDouble(),
                    color: AppTheme.orange,
                    width: 18,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyActivityChart extends StatelessWidget {
  const _WeeklyActivityChart({required this.days});

  final List<ProgressDayStat> days;

  @override
  Widget build(BuildContext context) {
    final maxCount = days.fold<int>(0, (max, d) => d.count > max ? d.count : max);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          maxY: (maxCount + 1).toDouble().clamp(1, double.infinity),
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(days[index].label, style: const TextStyle(fontSize: 9)),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: days[i].count.toDouble(),
                    color: AppTheme.teal,
                    width: 14,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitiesList extends StatelessWidget {
  const _RecentActivitiesList({
    required this.activities,
    required this.maxStars,
  });

  final List<ProgressRecentActivity> activities;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const _EmptyChart(message: 'لا يوجد نشاط حديث بعد');
    }

    return Column(
      children: [
        for (final activity in activities)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.teal.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.purple.withValues(alpha: 0.12),
                  child: const Icon(Icons.school, color: AppTheme.purple, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.wordName ?? 'نشاط',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '${activity.activityLabel ?? ''} • ${activity.worldName ?? ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    StarRating(stars: activity.starsEarned, maxStars: maxStars, size: 14),
                    if (activity.completedAt != null)
                      Text(
                        _formatDate(activity.completedAt!),
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                      ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDate(String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      return '${date.day}/${date.month}';
    } catch (_) {
      return '';
    }
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          message,
          style: TextStyle(color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
