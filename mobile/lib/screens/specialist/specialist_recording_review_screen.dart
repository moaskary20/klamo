import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:provider/provider.dart';

class SpecialistRecordingReviewScreen extends StatefulWidget {
  const SpecialistRecordingReviewScreen({super.key, required this.attempt});

  final AttemptListItemModel attempt;

  @override
  State<SpecialistRecordingReviewScreen> createState() =>
      _SpecialistRecordingReviewScreenState();
}

class _SpecialistRecordingReviewScreenState extends State<SpecialistRecordingReviewScreen> {
  late final TextEditingController _analysisController;
  final _player = AudioPlayer();
  bool _saving = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _analysisController = TextEditingController(text: widget.attempt.analysisText ?? '');
  }

  @override
  void dispose() {
    _analysisController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await context.read<AppState>().updateAttemptAnalysis(
            attemptId: widget.attempt.id,
            analysisText: _analysisController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ التحليل')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _playAudio() async {
    final url = widget.attempt.audioRecordingUrl;
    if (url == null || url.isEmpty) return;

    setState(() => _playing = true);
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
    } finally {
      if (mounted) setState(() => _playing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final attempt = widget.attempt;

    return Scaffold(
      appBar: const KlamoAppBar(title: Text('مراجعة التسجيل')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          PlayfulCard(
            accent: AppTheme.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${attempt.childName ?? 'طفل'} • ${attempt.wordName ?? '—'}'),
                Text(attempt.activityTypeLabel ?? ''),
                const SizedBox(height: 8),
                Text('الحالة: ${attempt.aiAnalysisStatusLabel ?? '—'}'),
                Text('التقييم: ${attempt.starsEarned} / ${attempt.maxStars}'),
                if (attempt.hasAudio) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _playing ? null : _playAudio,
                    icon: _playing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.play_arrow),
                    label: Text(_playing ? 'جاري التشغيل...' : 'تشغيل التسجيل'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _analysisController,
            decoration: const InputDecoration(
              labelText: 'تحليل Gemini (قابل للتعديل)',
              alignLabelWithHint: true,
            ),
            maxLines: 8,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('حفظ مراجعة التحليل'),
          ),
        ],
      ),
    );
  }
}
