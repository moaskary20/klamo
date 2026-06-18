import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/services/api_service.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistReportsScreen extends StatefulWidget {
  const SpecialistReportsScreen({super.key});

  @override
  State<SpecialistReportsScreen> createState() => _SpecialistReportsScreenState();
}

class _SpecialistReportsScreenState extends State<SpecialistReportsScreen> {
  List<ChildReportModel> _reports = [];
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
      final reports = await context.read<AppState>().loadChildReports();
      if (!mounted) return;
      setState(() {
        _reports = reports;
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

  Color _performanceColor(double score) {
    if (score >= 70) return AppTheme.grass;
    if (score >= 40) return AppTheme.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KlamoAppBar(title: Text('تقارير الأداء')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reports.length,
                    itemBuilder: (context, index) {
                      final report = _reports[index];
                      final child = report.child;
                      final metrics = report.metrics;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => context.push('/specialist/child/${child.id}'),
                            child: PlayfulCard(
                              accent: _performanceColor(metrics.overallPerformanceScore),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  if (child.parent != null)
                                    Text('ولي الأمر: ${child.parent!.name}'),
                                  const SizedBox(height: 8),
                                  Text('نسبة الإنجاز: ${metrics.completionRate.toStringAsFixed(1)}%'),
                                  Text('الأداء العام: ${metrics.overallPerformanceScore.toStringAsFixed(1)}%'),
                                  Text('كلمات مُدرَّب عليها: ${metrics.trainedWordsCount}'),
                                  Text('محاولات: ${metrics.totalAttemptsCount}'),
                                  Text(
                                    'متوسط النجوم: ${metrics.averageStars.toStringAsFixed(1)}',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
