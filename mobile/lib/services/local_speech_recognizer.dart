import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Arabic speech-to-text — one speak session.
class LocalSpeechRecognizer {
  LocalSpeechRecognizer() : _speech = SpeechToText();

  final SpeechToText _speech;
  bool _initialized = false;
  bool _isLiveCapture = false;
  String _transcription = '';
  String? _lastError;
  List<String> _localeIds = [];

  String get transcription => _transcription.trim();
  String? get lastError => _lastError;
  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_initialized) return true;

    _lastError = null;
    _initialized = await _speech.initialize(
      onError: _handleError,
      onStatus: (status) {
        if (status == 'notListening' &&
            _isLiveCapture &&
            _transcription.isEmpty) {
          _lastError ??= 'لم يُسمع أي صوت. حاول التحدث بوضوح.';
        }
      },
    );

    if (!_initialized) {
      _lastError ??=
          'تعذّر تفعيل التعرف على الكلام. تأكد من صلاحية الميكروفون وتطبيق Google.';
      return false;
    }

    _localeIds = await _availableArabicLocales();
    return true;
  }

  Future<bool> beginLiveCapture({
    Duration listenFor = const Duration(seconds: 20),
  }) async {
    if (!await initialize()) return false;

    await cancel();
    _transcription = '';
    _lastError = null;
    _isLiveCapture = true;

    final locales = _localeIds.isNotEmpty ? _localeIds : <String?>[null];
    for (final locale in locales) {
      if (await _startListen(
        localeId: locale,
        listenFor: listenFor,
      )) {
        return true;
      }
      await _stopListening();
    }

    _isLiveCapture = false;
    return false;
  }

  Future<String> endLiveCapture() async {
    _isLiveCapture = false;
    await _stopListening();
    return transcription;
  }

  Future<bool> _startListen({
    required String? localeId,
    required Duration listenFor,
  }) async {
    final started = await _speech.listen(
      onResult: _onResult,
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenMode: ListenMode.dictation,
        cancelOnError: false,
        partialResults: true,
        listenFor: listenFor,
        pauseFor: const Duration(seconds: 3),
      ),
    );

    if (started != true && !_speech.isListening) {
      _lastError ??= 'لم يبدأ الاستماع للصوت.';
      return false;
    }

    return true;
  }

  Future<void> _stopListening() async {
    try {
      if (_speech.isListening) {
        await _speech.stop();
      }
    } catch (_) {}

    try {
      await _speech.cancel();
    } catch (_) {}

    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  Future<void> cancel() async {
    _isLiveCapture = false;
    await _stopListening();
    _transcription = '';
  }

  void dispose() {
    _isLiveCapture = false;
    _speech.stop();
  }

  void _handleError(SpeechRecognitionError error) {
    final msg = error.errorMsg.toLowerCase();

    if (msg.contains('no_match') ||
        msg.contains('no speech') ||
        msg.contains('timeout')) {
      return;
    }

    _lastError = error.errorMsg;
  }

  void _onResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords.trim();
    if (words.isEmpty) return;

    if (result.finalResult || words.length >= _transcription.length) {
      _transcription = words;
    }
  }

  Future<List<String>> _availableArabicLocales() async {
    final locales = await _speech.locales();
    final picked = <String>[];

    const preferred = ['ar-EG', 'ar_EG', 'ar-SA', 'ar_SA', 'ar'];

    for (final code in preferred) {
      for (final locale in locales) {
        if (locale.localeId == code && !picked.contains(locale.localeId)) {
          picked.add(locale.localeId);
        }
      }
    }

    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith('ar') &&
          !picked.contains(locale.localeId)) {
        picked.add(locale.localeId);
      }
    }

    if (picked.isEmpty) {
      return [];
    }

    return picked;
  }
}
