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

class WordRecognitionScreen extends StatefulWidget {
  const WordRecognitionScreen({super.key, required this.activityId});

  final int activityId;

  @override
  State<WordRecognitionScreen> createState() => _WordRecognitionScreenState();
}

class _WordRecognitionScreenState extends State<WordRecognitionScreen> {
  late Future<ActivitySessionModel> _sessionFuture;
  final _player = AudioPlayer();
  final _speech = SpeechService();
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

  Future<void> _playWord(ItemModel item) async {
    if (_isPlaying) return;

    setState(() => _isPlaying = true);

    try {
      final resolved = ApiConstants.resolveMediaUrl(item.audioUrl);

      if (resolved != null) {
        await _speech.stop();
        await _player.stop();
        await _player.play(UrlSource(resolved));
        return;
      }

      final text = item.wordName.trim();
      if (text.isEmpty) {
        _showMessage('لا يوجد صوت متاح لهذه الكلمة');
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

  Future<void> _complete(ItemModel item) async {
    final result = await context.read<AppState>().submitAttempt(
          activityId: widget.activityId,
          starsEarned: 3,
        );

    if (mounted) {
      context.push('/rewards', extra: result.starsEarned);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KlamoAppBar(title: Text('تعرف على الكلمة 📖')),
      body: FutureBuilder<ActivitySessionModel>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final session = snapshot.data!;
          final item = session.item;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ItemImage(imageUrl: item.imageUrl, word: item.wordName),
                      const SizedBox(height: 24),
                      Text(
                        item.wordName,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isPlaying ? null : () => _playWord(item),
                        icon: Icon(
                          _isPlaying ? Icons.volume_up : Icons.volume_up_outlined,
                          color: AppTheme.tealDeep,
                        ),
                        label: Text(
                          _isPlaying ? 'جاري التشغيل...' : 'استمع للكلمة',
                          style: const TextStyle(color: AppTheme.tealDeep),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _complete(item),
                    child: const Text('أنا تعرفت على الكلمة!'),
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
