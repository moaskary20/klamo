import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:klamo_mobile/core/theme/app_theme.dart';
import 'package:klamo_mobile/models/models.dart';
import 'package:klamo_mobile/providers/app_state.dart';
import 'package:klamo_mobile/services/offline_audio_transcriber.dart';
import 'package:klamo_mobile/services/pronunciation_matcher.dart';
import 'package:klamo_mobile/services/speech_service.dart';
import 'package:klamo_mobile/widgets/gradient_button.dart';
import 'package:klamo_mobile/widgets/item_image.dart';
import 'package:klamo_mobile/widgets/klamo_app_bar.dart';
import 'package:klamo_mobile/widgets/playful_card.dart';
import 'package:klamo_mobile/widgets/star_rating.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

enum _PronunciationPhase {
  idle,
  recording,
  analyzing,
  correct,
  wrong,
  failed,
}

class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key, required this.activityId});

  final int activityId;

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen>
    with SingleTickerProviderStateMixin {
  late Future<ActivitySessionModel> _sessionFuture;
  final _recorder = AudioRecorder();
  final _speechService = SpeechService();
  late final AnimationController _recordPulse;

  _PronunciationPhase _phase = _PronunciationPhase.idle;
  String? _recordingPath;
  String? _activeRecordingPath;
  String _transcription = '';
  AttemptResultModel? _analysisResult;
  bool _usedLocalFallback = false;
  bool _audioRecordActive = false;
  bool _isStopping = false;

  int _recordingSeconds = 0;
  double _amplitude = 0;
  Timer? _recordingTimer;
  StreamSubscription<Amplitude>? _amplitudeSub;

  final List<String> _analysisSteps = [];
  String? _analysisSourceLabel;

  static const _minRecordingSeconds = 1;
  static const _maxRecordingSeconds = 20;
  static const _minFileBytes = 800;

  @override
  void initState() {
    super.initState();
    _recordPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sessionFuture = context.read<AppState>().loadActivity(widget.activityId);
    unawaited(OfflineAudioTranscriber.instance.ensureReady());
  }

  @override
  void dispose() {
    _recordPulse.dispose();
    _recordingTimer?.cancel();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    _speechService.dispose();
    super.dispose();
  }

  bool get _isRecording => _phase == _PronunciationPhase.recording;
  bool get _isAnalyzing => _phase == _PronunciationPhase.analyzing;
  bool get _canStartHold =>
      !_isRecording && !_isAnalyzing && !_isStopping && !_hasResult;
  bool get _hasResult =>
      _phase == _PronunciationPhase.correct ||
      _phase == _PronunciationPhase.wrong ||
      _phase == _PronunciationPhase.failed;

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _addAnalysisStep(String step) {
    if (!mounted) return;
    setState(() => _analysisSteps.add(step));
  }

  Future<void> _onHoldStart() async {
    if (!_canStartHold) return;

    try {
      await _speechService.stop();

      if (!await _recorder.hasPermission()) {
        _showMessage('يُرجى السماح باستخدام الميكروفون من إعدادات التطبيق');
        return;
      }

      _transcription = '';
      _recordingSeconds = 0;
      _amplitude = 0;
      _recordingPath = null;
      _activeRecordingPath = null;
      _audioRecordActive = false;

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
      _activeRecordingPath = path;

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
        ),
        path: path,
      );
      _audioRecordActive = await _recorder.isRecording();

      if (!_audioRecordActive) {
        _activeRecordingPath = null;
        _showMessage('تعذّر بدء تسجيل الصوت.');
        return;
      }

      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted || !_isRecording) {
          timer.cancel();
          return;
        }
        setState(() => _recordingSeconds++);
        if (_recordingSeconds >= _maxRecordingSeconds) {
          timer.cancel();
          unawaited(_onHoldEnd());
        }
      });

      _amplitudeSub?.cancel();
      _amplitudeSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 120))
          .listen((amp) {
        if (!mounted) return;
        final level = ((amp.current + 60) / 60).clamp(0.0, 1.0);
        setState(() => _amplitude = level);
      });

      if (!mounted) return;
      setState(() {
        _phase = _PronunciationPhase.recording;
        _analysisResult = null;
        _analysisSteps.clear();
        _analysisSourceLabel = null;
        _usedLocalFallback = false;
      });
      _recordPulse.repeat(reverse: true);
    } catch (_) {
      _audioRecordActive = false;
      _showMessage('تعذّر بدء التسجيل. حاول مرة أخرى.');
    }
  }

  Future<void> _onHoldEnd() async {
    if (_isStopping || !_isRecording) return;

    _isStopping = true;
    _recordingTimer?.cancel();
    _amplitudeSub?.cancel();
    _recordPulse.stop();
    _recordPulse.reset();

    if (!mounted) return;
    setState(() => _phase = _PronunciationPhase.analyzing);

    try {
      String? savedPath;
      if (_audioRecordActive && await _recorder.isRecording()) {
        savedPath = await _recorder.stop();
      }
      _audioRecordActive = false;
      savedPath ??= _activeRecordingPath;
      _activeRecordingPath = null;

      final session = await _sessionFuture;
      if (!mounted) return;
      final targetWord = session.item.wordName;

      if (_recordingSeconds < _minRecordingSeconds) {
        setState(() => _phase = _PronunciationPhase.idle);
        _showMessage('المدة قصيرة. اضغط مع الاستمرار لثانية على الأقل.');
        return;
      }

      var hasAudio = false;
      int? fileBytes;
      if (savedPath != null && File(savedPath).existsSync()) {
        fileBytes = await File(savedPath).length();
        hasAudio = fileBytes >= _minFileBytes;
        if (hasAudio) _recordingPath = savedPath;
      }

      if (!hasAudio) {
        setState(() => _phase = _PronunciationPhase.failed);
        _analysisResult = AttemptResultModel(
          id: 0,
          starsEarned: 0,
          isCompleted: false,
          aiAnalysisStatus: 'failed',
          analysisText: 'لم يُحفظ الصوت. تأكد من الميكروفون وحاول مرة أخرى.',
        );
        return;
      }

      _addAnalysisStep(
        '✓ تم حفظ الصوت ($_recordingSeconds ث، ${(fileBytes! / 1024).toStringAsFixed(1)} كيلوبايت)',
      );

      _addAnalysisStep('⟳ جاري التعرف على الكلام محلياً (Whisper)...');

      try {
        _transcription =
            await OfflineAudioTranscriber.instance.transcribe(savedPath!);
      } catch (_) {
        _transcription = '';
        _addAnalysisStep('⚠ تعذّر تشغيل محرك التعرف المحلي');
      }

      if (_transcription.isEmpty) {
        _addAnalysisStep('⚠ لم نتعرّف على الكلمات');
        setState(() => _phase = _PronunciationPhase.failed);
        _analysisResult = AttemptResultModel(
          id: 0,
          starsEarned: 0,
          isCompleted: false,
          aiAnalysisStatus: 'failed',
          analysisText:
              'تم حفظ الصوت لكن لم نتعرّف على النطق. انطق «$targetWord» بوضوح أثناء الضغط.\n'
              'في أول استخدام يحتاج التطبيق إنترنت لتحميل نموذج التعرف (~75 ميجابايت).',
        );
        unawaited(_saveAudioOnly(session));
        return;
      }

      _addAnalysisStep('✓ سمعنا: «$_transcription»');
      await _startAnalysis(targetWord);
    } finally {
      _isStopping = false;
    }
  }

  Future<void> _saveAudioOnly(ActivitySessionModel session) async {
    if (_recordingPath == null) return;
    final targetWord = session.item.wordName;
    try {
      await context.read<AppState>().submitAttempt(
            activityId: widget.activityId,
            audioPath: _recordingPath,
            starsEarned: 0,
            isCompleted: false,
            failureMessage:
                'تم حفظ الصوت لكن لم نتعرّف على النطق. انطق «$targetWord» بوضوح أثناء الضغط.',
          );
      if (mounted) _addAnalysisStep('✓ تم حفظ التسجيل الصوتي على السيرفر');
    } catch (_) {}
  }

  Future<void> _startAnalysis(String targetWord) async {
    final appState = context.read<AppState>();

    try {
      final result = await _runLocalAnalysis(targetWord, appState);
      if (!mounted) return;
      await _handleAnalysisResult(result);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _PronunciationPhase.failed;
        _analysisResult = AttemptResultModel(
          id: 0,
          starsEarned: 0,
          isCompleted: false,
          aiAnalysisStatus: 'failed',
          analysisText: e.toString().replaceFirst('Exception: ', ''),
        );
      });
    }
  }

  Future<AttemptResultModel> _runLocalAnalysis(
    String targetWord,
    AppState appState,
  ) async {
    _addAnalysisStep('⟳ جاري مقارنة «$_transcription» مع «$targetWord»...');

    final local = _analyzeLocally(targetWord);
    _analysisSourceLabel = 'Whisper + مقارنة محلية';
    _addAnalysisStep(
      local.isCorrect == true
          ? '✓ نطق صحيح (دقة ${local.matchPercentage}%)'
          : '✓ تم التحليل (دقة ${local.matchPercentage}%)',
    );

    try {
      final saved = await appState.analyzePronunciation(
        activityId: widget.activityId,
        audioPath: _recordingPath!,
        transcription: _transcription,
      );
      if (mounted) {
        _addAnalysisStep('✓ تم حفظ الصوت والنتيجة على السيرفر (محاولة #${saved.id})');
      }
      return saved;
    } catch (_) {
      if (mounted) {
        _addAnalysisStep('⚠ تم التحليل لكن تعذّر الحفظ على السيرفر');
      }
      return local;
    }
  }

  AttemptResultModel _analyzeLocally(String targetWord, [int attemptId = 0]) {
    final childAge = context.read<AppState>().selectedChild?.age ?? 5;
    final analysis = PronunciationMatcher.analyze(
      targetWord: targetWord,
      transcription: _transcription,
      childAge: childAge,
    );

    _usedLocalFallback = true;
    return analysis.toAttemptResult(id: attemptId);
  }

  Future<void> _handleAnalysisResult(AttemptResultModel result) async {
    setState(() {
      _analysisResult = result;
      if (result.isAnalysisFailed) {
        _phase = _PronunciationPhase.failed;
        return;
      }
      _phase = result.isCorrect == true
          ? _PronunciationPhase.correct
          : _PronunciationPhase.wrong;
    });

    if (result.isCorrect == true) {
      await Future<void>.delayed(const Duration(seconds: 1));
      if (mounted) context.push('/rewards', extra: result);
    }
  }

  Future<void> _playReference(ItemModel item) async {
    try {
      await _speechService.speak(item.wordName);
    } catch (_) {
      _showMessage('تعذّر تشغيل نطق الكلمة');
    }
  }

  void _retry() {
    _recordingTimer?.cancel();
    _amplitudeSub?.cancel();
    _recordPulse.stop();
    _recordPulse.reset();
    setState(() {
      _phase = _PronunciationPhase.idle;
      _recordingPath = null;
      _activeRecordingPath = null;
      _transcription = '';
      _analysisResult = null;
      _analysisSteps.clear();
      _analysisSourceLabel = null;
      _recordingSeconds = 0;
      _amplitude = 0;
      _usedLocalFallback = false;
      _audioRecordActive = false;
      _isStopping = false;
    });
  }

  void _continueToRewards() {
    if (_analysisResult != null) {
      context.push('/rewards', extra: _analysisResult);
    }
  }

  String _statusText(ItemModel item) {
    return switch (_phase) {
      _PronunciationPhase.recording =>
          'جاري التسجيل... استمر بالضغط وانطق «${item.wordName}» ($_recordingSeconds ث)',
      _PronunciationPhase.analyzing => 'جاري تحليل النطق...',
      _PronunciationPhase.correct => 'ممتاز! نطق صحيح 🌟',
      _PronunciationPhase.wrong => 'قريب! حاول مرة أخرى',
      _PronunciationPhase.failed => 'تعذّر التحليل، حاول من جديد',
      _ => 'اضغط الزر بالأسفل مع الاستمرار، انطق الكلمة، ثم ارفع إصبعك',
    };
  }

  Color _statusColor() {
    return switch (_phase) {
      _PronunciationPhase.recording => const Color(0xFFD81B60),
      _PronunciationPhase.analyzing => AppTheme.purpleDeep,
      _PronunciationPhase.correct => AppTheme.grassDark,
      _PronunciationPhase.wrong => AppTheme.orange,
      _PronunciationPhase.failed => const Color(0xFFE53935),
      _ => AppTheme.skyDeep,
    };
  }

  Color _statusBackgroundColor() {
    return switch (_phase) {
      _PronunciationPhase.recording => AppTheme.pink,
      _PronunciationPhase.analyzing => AppTheme.purple,
      _PronunciationPhase.correct => AppTheme.grass,
      _PronunciationPhase.wrong => AppTheme.orangeWarm,
      _PronunciationPhase.failed => Colors.redAccent,
      _ => AppTheme.teal,
    };
  }

  Widget _buildStatusBanner(ItemModel item) {
    final color = _statusColor();
    final bg = _statusBackgroundColor();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
      ),
      child: Text(
        _statusText(item),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 15,
          height: 1.45,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildListenButton(ItemModel item) {
    final disabled = _isRecording || _isAnalyzing;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : () => _playReference(item),
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: disabled
                  ? [Colors.grey.shade400, Colors.grey.shade500]
                  : [AppTheme.purpleDeep, AppTheme.purple],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: disabled
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.purple.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.volume_up_rounded,
                  color: Colors.white.withValues(alpha: disabled ? 0.7 : 1),
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  'استمع للكلمة الصحيحة',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: disabled ? 0.7 : 1),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const KlamoAppBar(title: Text('تسجيل النطق 🎙️')),
      body: FutureBuilder<ActivitySessionModel>(
        future: _sessionFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final item = snapshot.data!.item;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: Column(
                    children: [
                      ItemImage(imageUrl: item.imageUrl, word: item.wordName),
                      const SizedBox(height: 16),
                      Text(
                        item.wordName,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildListenButton(item),
                      const SizedBox(height: 12),
                      _buildStatusBanner(item),
                      const SizedBox(height: 16),
                      if (_hasResult)
                        _buildResultCard(item)
                      else
                        _buildRecorderArea(),
                      if (_analysisSteps.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildAnalysisStepsCard(),
                      ],
                      if (_phase == _PronunciationPhase.wrong ||
                          _phase == _PronunciationPhase.failed) ...[
                        const SizedBox(height: 12),
                        GradientButton(
                          width: double.infinity,
                          onPressed: _retry,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.mic, color: Colors.white),
                              SizedBox(width: 8),
                              Text('إعادة المحاولة'),
                            ],
                          ),
                        ),
                      ],
                      if (_phase == _PronunciationPhase.correct) ...[
                        const SizedBox(height: 12),
                        GradientButton(
                          width: double.infinity,
                          onPressed: _continueToRewards,
                          child: const Text('متابعة'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!_isAnalyzing && !_hasResult) _buildFixedHoldBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFixedHoldBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: Border(
          top: BorderSide(color: AppTheme.teal.withValues(alpha: 0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyDeep.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: _buildHoldButton(),
    );
  }

  Widget _buildHoldButton() {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        if (_canStartHold) unawaited(_onHoldStart());
      },
      onPointerUp: (_) => unawaited(_onHoldEnd()),
      onPointerCancel: (_) => unawaited(_onHoldEnd()),
      child: AnimatedBuilder(
        animation: _recordPulse,
        builder: (context, child) {
          final pulse = _isRecording ? _recordPulse.value : 0.0;

          return Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isRecording
                    ? [
                        Color.lerp(AppTheme.pink, const Color(0xFFD81B60), pulse)!,
                        Color.lerp(AppTheme.orange, AppTheme.pink, pulse)!,
                      ]
                    : [AppTheme.teal, AppTheme.tealDeep],
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _isRecording
                    ? Colors.white.withValues(alpha: 0.55 + pulse * 0.35)
                    : Colors.white.withValues(alpha: 0.25),
                width: _isRecording ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? AppTheme.pink : AppTheme.teal)
                      .withValues(alpha: _isRecording ? 0.35 + pulse * 0.2 : 0.3),
                  blurRadius: _isRecording ? 18 + pulse * 8 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRecording) ...[
              AnimatedBuilder(
                animation: _recordPulse,
                builder: (context, _) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsetsDirectional.only(start: 8),
                    decoration: BoxDecoration(
                      color: Colors.white
                          .withValues(alpha: 0.65 + _recordPulse.value * 0.35),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
            ],
            Icon(
              _isRecording ? Icons.fiber_manual_record : Icons.touch_app_rounded,
              color: Colors.white,
              size: _isRecording ? 22 : 28,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isRecording ? 'جاري التسجيل...' : 'اضغط مع الاستمرار وانطق',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  if (_isRecording)
                    Text(
                      'ارفع إصبعك للتحليل ($_recordingSeconds ث)',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    )
                  else
                    Text(
                      'أبقِ إصبعك على الزر أثناء النطق',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisStepsCard() {
    return PlayfulCard(
      accent: AppTheme.purple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'خطوات التحليل',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          if (_analysisSourceLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              'المصدر: $_analysisSourceLabel',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ],
          const SizedBox(height: 8),
          ..._analysisSteps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(step, style: const TextStyle(height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecorderArea() {
    if (_isAnalyzing) {
      return const Column(
        children: [
          SizedBox(height: 24),
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('نحلّل نطقك بالتعرف المحلي...'),
        ],
      );
    }

    return Column(
      children: [
        Icon(
          _isRecording ? Icons.mic : Icons.mic_none,
          size: 88,
          color: _isRecording ? AppTheme.pink : AppTheme.orange,
        ),
        if (_isRecording) ...[
          const SizedBox(height: 12),
          Text(
            '${_recordingSeconds}s',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppTheme.pink,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 180,
            child: LinearProgressIndicator(
              value: _amplitude,
              minHeight: 8,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: AppTheme.pink.withValues(alpha: 0.2),
              color: AppTheme.pink,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _amplitude > 0.08 ? 'يتم التقاط الصوت ✓' : 'تحدث بوضوح...',
            style: TextStyle(
              color: _amplitude > 0.08 ? AppTheme.grass : AppTheme.orange,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResultCard(ItemModel item) {
    final result = _analysisResult;
    if (result == null) return const SizedBox.shrink();

    final isCorrect = _phase == _PronunciationPhase.correct;
    final isFailed = _phase == _PronunciationPhase.failed;
    final isLocal = result.analysisSource == 'local' || _usedLocalFallback;

    return PlayfulCard(
      accent: isCorrect ? AppTheme.grass : AppTheme.orange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle
                    : isFailed
                        ? Icons.error_outline
                        : Icons.info_outline,
                color: isCorrect ? AppTheme.grass : AppTheme.orange,
                size: 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isCorrect
                      ? 'إجابة صحيحة'
                      : isFailed
                          ? 'فشل التحليل'
                          : 'إجابة تحتاج تحسيناً',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          if (isFailed && result.analysisText != null) ...[
            const SizedBox(height: 12),
            Text(result.analysisText!, style: const TextStyle(height: 1.5)),
          ],
          if (isLocal && !isFailed) ...[
            const SizedBox(height: 8),
            Text(
              'تم التحليل بمقارنة نطقك مع «${item.wordName}»',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
            ),
          ],
          if (!isFailed && result.matchPercentage != null) ...[
            const SizedBox(height: 12),
            Text(
              isCorrect
                  ? 'نسبة الدقة: ${result.matchPercentage}%'
                  : 'نسبة الخطأ: ${result.errorPercentage ?? (100 - result.matchPercentage!)}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.purpleDeep,
              ),
            ),
          ],
          if (_transcription.isNotEmpty) Text('سمعنا: «$_transcription»'),
          Text('المطلوب: «${item.wordName}»'),
          if (isCorrect) ...[
            const SizedBox(height: 12),
            StarRating(stars: result.starsEarned),
          ],
          if (result.scoreSummary != null && result.scoreSummary!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(result.scoreSummary!, style: const TextStyle(height: 1.5)),
          ] else if (result.analysisText != null && !isFailed) ...[
            const SizedBox(height: 12),
            Text(result.analysisText!, style: const TextStyle(height: 1.5)),
          ],
          if (!isCorrect &&
              !isFailed &&
              result.missingLetters.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'أصوات تحتاج تحسين: ${result.missingLetters.join('، ')}',
              style: TextStyle(
                color: AppTheme.orange.withValues(alpha: 0.95),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
