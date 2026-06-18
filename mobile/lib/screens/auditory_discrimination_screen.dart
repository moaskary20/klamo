import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/constants/api_constants.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/services/speech_service.dart';
import 'package:klamo_mobile/widgets/item_image.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:provider/provider.dart';

class AuditoryDiscriminationScreen extends StatefulWidget {
  const AuditoryDiscriminationScreen({super.key, required this.activityId});

  final int activityId;

  @override
  State<AuditoryDiscriminationScreen> createState() =>
      _AuditoryDiscriminationScreenState();
}

class _AuditoryDiscriminationScreenState
    extends State<AuditoryDiscriminationScreen> {
  late Future<ActivitySessionModel> _sessionFuture;
  final _player = AudioPlayer();
  final _speech = SpeechService();
  int? _selectedItemId;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _sessionFuture = context.read<AppState>().loadActivity(widget.activityId);
    _speech.initialize();
  }

  @override
  void dispose() {
    _player.dispose();
    _speech.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _playQuestion(ActivitySessionModel session) async {
    if (_isPlaying) return;

    setState(() => _isPlaying = true);

    try {
      final resolved = ApiConstants.resolveMediaUrl(session.questionAudioUrl);

      if (resolved != null) {
        await _speech.stop();
        await _player.stop();
        await _player.play(UrlSource(resolved));
        return;
      }

      final text = session.item.wordName.trim();
      if (text.isEmpty) {
        _showMessage('لا يوجد صوت متاح لهذا السؤال');
        return;
      }

      await _player.stop();
      await _speech.speak(text);
    } catch (_) {
      _showMessage('تعذّر تشغيل الصوت');
    } finally {
      if (mounted) setState(() => _isPlaying = false);
    }
  }

  Future<void> _submit(ActivitySessionModel session) async {
    final isCorrect = _selectedItemId == session.item.id;
    final stars = isCorrect ? 3 : 1;

    final result = await context.read<AppState>().submitAttempt(
          activityId: widget.activityId,
          starsEarned: stars,
        );

    if (mounted) {
      context.push('/rewards', extra: result.starsEarned);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KlamoAppBar(title: Text('تمييز سمعي 👂')),
      body: FutureBuilder<ActivitySessionModel>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = snapshot.data!;
          final choices = session.choices.isNotEmpty
              ? session.choices
              : [session.item];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: ListTile(
                    title: Text(
                      session.questionText ?? 'استمع واختر الصورة الصحيحة',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    trailing: IconButton(
                      onPressed: _isPlaying
                          ? null
                          : () => _playQuestion(session),
                      icon: Icon(
                        _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                        size: 32,
                        color: AppTheme.tealDeep,
                      ),
                      tooltip: 'استمع للسؤال',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: choices.length,
                    itemBuilder: (context, index) {
                      final choice = choices[index];
                      final selected = _selectedItemId == choice.id;

                      return InkWell(
                        onTap: () => setState(() => _selectedItemId = choice.id),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.grass
                                  : AppTheme.teal.withValues(alpha: 0.25),
                              width: selected ? 3 : 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ItemImage(
                                  imageUrl: choice.imageUrl,
                                  word: choice.wordName,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(choice.wordName),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedItemId == null
                        ? null
                        : () => _submit(session),
                    child: const Text('تأكيد الإجابة'),
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
