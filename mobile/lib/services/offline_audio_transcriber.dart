import 'dart:io';

import 'package:whisper_ggml_plus/whisper_ggml_plus.dart';

/// On-device speech-to-text via Whisper.cpp — runs after recording ends.
class OfflineAudioTranscriber {
  OfflineAudioTranscriber._();

  static final instance = OfflineAudioTranscriber._();

  final WhisperController _controller = WhisperController();
  static const WhisperModel model = WhisperModel.tiny;

  Future<void>? _readyFuture;

  /// Downloads the GGML model once (needs internet on first run).
  Future<void> ensureReady() {
    _readyFuture ??= _prepareModel();
    return _readyFuture!;
  }

  Future<void> _prepareModel() async {
    final path = await _controller.getPath(model);
    if (!File(path).existsSync()) {
      await _controller.downloadModel(model);
    }
  }

  Future<String> transcribe(String audioPath) async {
    await ensureReady();

    final result = await _controller.transcribe(
      model: model,
      audioPath: audioPath,
      lang: 'ar',
      withTimestamps: false,
      convert: false,
      threads: 4,
    );

    return result?.transcription.text.trim() ?? '';
  }
}
