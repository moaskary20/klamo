import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_edge_tts/flutter_edge_tts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';

/// Speaks Arabic words using Egyptian neural voice when online,
/// with on-device TTS as offline fallback.
class SpeechService {
  SpeechService()
      : _deviceTts = FlutterTts(),
        _edgeTts = FlutterEdgeTts(
          voice: _egyptianVoice,
          voiceLocale: 'ar-EG',
          outputFormat: EdgeTtsOutputFormat.audio24Khz96KbitrateMonoMp3,
        ),
        _player = AudioPlayer();

  static const _egyptianVoice = 'ar-EG-SalmaNeural';

  final FlutterTts _deviceTts;
  final FlutterEdgeTts _edgeTts;
  final AudioPlayer _player;

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _deviceTts.setSpeechRate(0.45);
    await _deviceTts.setPitch(1.0);
    await _deviceTts.setVolume(1.0);
    await _deviceTts.awaitSpeakCompletion(true);

    final languages = await _deviceTts.getLanguages;
    final languageList = languages is List
        ? languages.map((e) => e.toString()).toList()
        : <String>[];

    if (languageList.any((lang) => lang.startsWith('ar-EG'))) {
      await _deviceTts.setLanguage('ar-EG');
    } else {
      await _deviceTts.setLanguage('ar');
    }

    _initialized = true;
  }

  Future<void> speak(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    await initialize();
    await stop();

    final spokeOnline = await _speakWithEdgeTts(trimmed);
    if (spokeOnline) return;

    await _deviceTts.speak(trimmed);
  }

  Future<bool> _speakWithEdgeTts(String text) async {
    try {
      final result = await _edgeTts.synthesize(
        text,
        prosody: const EdgeTtsProsody(
          rate: '0.92',
          pitch: '+4Hz',
          volume: '100',
        ),
      );

      if (result.audioBytes.isEmpty) return false;

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/edge_tts_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );
      await file.writeAsBytes(result.audioBytes);
      await _player.play(DeviceFileSource(file.path));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    await _deviceTts.stop();
  }

  void dispose() {
    _player.dispose();
    _deviceTts.stop();
    _edgeTts.close();
  }
}
