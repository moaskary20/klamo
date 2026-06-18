import 'package:klamo_mobile/models/models.dart';

class PronunciationAnalysis {
  PronunciationAnalysis({
    required this.isCorrect,
    required this.matchPercentage,
    required this.errorPercentage,
    required this.starsEarned,
    required this.analysisText,
    required this.scoreSummary,
    required this.missingLetters,
    required this.heardTranscription,
    this.analysisSource = 'local',
  });

  final bool isCorrect;
  final int matchPercentage;
  final int errorPercentage;
  final int starsEarned;
  final String analysisText;
  final String scoreSummary;
  final List<String> missingLetters;
  final String heardTranscription;
  final String analysisSource;

  AttemptResultModel toAttemptResult({int id = 0}) {
    return AttemptResultModel(
      id: id,
      starsEarned: starsEarned,
      isCompleted: isCorrect,
      aiAnalysisStatus: 'completed',
      analysisText: analysisText,
      isCorrect: isCorrect,
      matchPercentage: matchPercentage,
      errorPercentage: errorPercentage,
      scoreSummary: scoreSummary,
      missingLetters: missingLetters,
      heardTranscription: heardTranscription,
      analysisSource: analysisSource,
    );
  }
}

/// Offline pronunciation comparison between target word and heard transcription.
class PronunciationMatcher {
  static const correctThreshold = 70;
  static const maxStars = 5;

  static PronunciationAnalysis analyze({
    required String targetWord,
    required String transcription,
    int childAge = 5,
  }) {
    final normalizedTarget = _normalizeArabic(targetWord);
    final normalizedSpoken = _normalizeArabic(transcription);

    if (normalizedTarget.isEmpty) {
      throw Exception('الكلمة المستهدفة غير صالحة للتحليل.');
    }

    if (normalizedSpoken.isEmpty) {
      throw Exception('لم يُتعرّف على أي نطق في التسجيل. حاول التحدث بوضوح أقرب للميكروفون.');
    }

    final matchPercentage = _similarityPercent(normalizedTarget, normalizedSpoken);
    final missingLetters = _findMissingLetters(normalizedTarget, normalizedSpoken);
    final stars = _starsFromPercentage(matchPercentage);
    final isCorrect = matchPercentage >= correctThreshold;
    final heard = transcription.trim();

    return PronunciationAnalysis(
      isCorrect: isCorrect,
      matchPercentage: matchPercentage,
      errorPercentage: 100 - matchPercentage,
      starsEarned: stars,
      heardTranscription: heard,
      analysisText: _buildAssessment(
        targetWord: targetWord,
        heard: heard,
        matchPercentage: matchPercentage,
        missingLetters: missingLetters,
        isCorrect: isCorrect,
        childAge: childAge,
      ),
      scoreSummary: isCorrect
          ? 'نطق صحيح: سمعنا «$heard» مقابل «$targetWord».'
          : 'نطق يحتاج تحسين: سمعنا «$heard» بدلاً من «$targetWord».',
      missingLetters: missingLetters,
    );
  }

  static String _normalizeArabic(String text) {
    var value = text.trim();
    if (value.isEmpty) return '';

    value = value.replaceAll(
      RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
      '',
    );

    const replacements = {
      'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
      'ى': 'ي', 'ئ': 'ي',
      'ة': 'ه',
      'ؤ': 'و',
      'گ': 'ك', 'پ': 'ب', 'چ': 'ج', 'ڤ': 'ف',
    };

    for (final entry in replacements.entries) {
      value = value.replaceAll(entry.key, entry.value);
    }

    return value.replaceAll(RegExp(r'[^ء-ي]'), '');
  }

  static int _similarityPercent(String target, String spoken) {
    if (target == spoken) return 100;
    if (target.isEmpty || spoken.isEmpty) return 0;

    if (spoken.contains(target) || target.contains(spoken)) {
      final shorter = target.length < spoken.length ? target.length : spoken.length;
      final longer = target.length > spoken.length ? target.length : spoken.length;
      return ((shorter / longer) * 100).round();
    }

    final distance = _levenshteinUtf8(target, spoken);
    final maxLen = target.length > spoken.length ? target.length : spoken.length;

    return (100 * (1 - distance / maxLen)).round().clamp(0, 100);
  }

  static List<String> _findMissingLetters(String target, String spoken) {
    final missing = <String>[];
    final spokenPool = spoken.split('');

    for (final char in target.split('')) {
      final index = spokenPool.indexOf(char);
      if (index == -1) {
        if (!missing.contains(char)) missing.add(char);
      } else {
        spokenPool.removeAt(index);
      }
    }

    return missing;
  }

  static int _levenshteinUtf8(String a, String b) {
    final aChars = a.split('');
    final bChars = b.split('');
    final rows = aChars.length + 1;
    final cols = bChars.length + 1;
    final matrix = List.generate(rows, (_) => List.filled(cols, 0));

    for (var i = 0; i < rows; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j < cols; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i < rows; i++) {
      for (var j = 1; j < cols; j++) {
        final cost = aChars[i - 1] == bChars[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
    }

    return matrix[rows - 1][cols - 1];
  }

  static int _starsFromPercentage(int percentage) {
    if (percentage >= 90) return 5;
    if (percentage >= 80) return 4;
    if (percentage >= 70) return 3;
    if (percentage >= 50) return 2;
    return 1;
  }

  static String _buildAssessment({
    required String targetWord,
    required String heard,
    required int matchPercentage,
    required List<String> missingLetters,
    required bool isCorrect,
    required int childAge,
  }) {
    if (isCorrect) {
      return 'نطق جيد! قال الطفل «$heard» وهي قريبة جداً من الكلمة المطلوبة «$targetWord» '
          '(دقة $matchPercentage%). مناسب لعمر $childAge سنوات.';
    }

    final missingText = missingLetters.isNotEmpty
        ? 'الأصوات التي تحتاج تحسين: ${missingLetters.join('، ')}.'
        : 'حاول نطق الكلمة بوضوح أكبر.';

    return 'النطق المسجّل «$heard» يختلف عن الكلمة المطلوبة «$targetWord» '
        '(دقة $matchPercentage%). $missingText';
  }
}
