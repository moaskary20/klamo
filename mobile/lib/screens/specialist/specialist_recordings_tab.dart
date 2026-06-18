import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/services/api_service.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistRecordingsTab extends StatefulWidget {
  const SpecialistRecordingsTab({super.key});

  @override
  State<SpecialistRecordingsTab> createState() => _SpecialistRecordingsTabState();
}

class _SpecialistRecordingsTabState extends State<SpecialistRecordingsTab> {
  List<AttemptListItemModel> _attempts = [];
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
      final attempts = await context.read<AppState>().loadAttempts(hasAudio: true);
      if (!mounted) return;
      setState(() {
        _attempts = attempts;
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

  Color _statusColor(String? status) {
    return switch (status) {
      'completed' => AppTheme.grass,
      'processing' => AppTheme.teal,
      'pending' => AppTheme.orange,
      'failed' => Colors.red,
      _ => Colors.grey,
    };
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

    return RefreshIndicator(
      onRefresh: _load,
      child: _attempts.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 80),
                Center(child: Text('لا توجد تسجيلات صوتية بعد.')),
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _attempts.length,
              itemBuilder: (context, index) {
                final attempt = _attempts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push(
                        '/specialist/recording/${attempt.id}',
                        extra: attempt,
                      ),
                      child: PlayfulCard(
                        accent: _statusColor(attempt.aiAnalysisStatus),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    attempt.childName ?? 'طفل',
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                Chip(
                                  label: Text(
                                    attempt.aiAnalysisStatusLabel ?? '—',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  backgroundColor:
                                      _statusColor(attempt.aiAnalysisStatus).withValues(alpha: 0.15),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('${attempt.wordName ?? '—'} • ${attempt.activityTypeLabel ?? ''}'),
                            if (attempt.heardTranscription != null &&
                                attempt.heardTranscription!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'سمعنا: «${attempt.heardTranscription}»'
                                '${attempt.matchPercentage != null ? ' • دقة ${attempt.matchPercentage}%' : ''}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              attempt.analysisText ?? 'لا يوجد تحليل بعد',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${attempt.starsEarned} / ${attempt.maxStars} نجوم',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
