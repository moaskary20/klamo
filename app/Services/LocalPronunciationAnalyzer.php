<?php

namespace App\Services;

use RuntimeException;

class LocalPronunciationAnalyzer
{
    public const CORRECT_THRESHOLD = 70;

    public const MAX_STARS = GeminiService::MAX_STARS;

    /**
     * Compare spoken transcription against the target Arabic word.
     *
     * @return array{
     *     text: string,
     *     stars_rating: int,
     *     missing_letters: array<int, string>,
     *     match_percentage: int,
     *     score_summary: string,
     *     heard_transcription: string,
     *     analysis_source: string,
     *     target_word: string,
     *     analyzed_at: string
     * }
     */
    public function analyze(string $targetWord, string $transcription, int $childAge = 5): array
    {
        $normalizedTarget = $this->normalizeArabic($targetWord);
        $normalizedSpoken = $this->normalizeArabic($transcription);

        if ($normalizedTarget === '') {
            throw new RuntimeException('الكلمة المستهدفة غير صالحة للتحليل.');
        }

        if ($normalizedSpoken === '') {
            throw new RuntimeException('لم يُتعرّف على أي نطق في التسجيل. حاول التحدث بوضوح أقرب للميكروفون.');
        }

        $matchPercentage = $this->similarityPercent($normalizedTarget, $normalizedSpoken);
        $missingLetters = $this->findMissingLetters($normalizedTarget, $normalizedSpoken);
        $starsRating = $this->starsFromPercentage($matchPercentage);
        $isCorrect = $matchPercentage >= self::CORRECT_THRESHOLD;

        $heard = trim($transcription);

        return [
            'text' => $this->buildAssessment(
                targetWord: $targetWord,
                heard: $heard,
                matchPercentage: $matchPercentage,
                missingLetters: $missingLetters,
                isCorrect: $isCorrect,
                childAge: $childAge,
            ),
            'stars_rating' => $starsRating,
            'missing_letters' => $missingLetters,
            'match_percentage' => $matchPercentage,
            'score_summary' => $this->buildScoreSummary($matchPercentage, $heard, $targetWord),
            'heard_transcription' => $heard,
            'analysis_source' => 'local',
            'target_word' => $targetWord,
            'child_age' => $childAge,
            'analyzed_at' => now()->toIso8601String(),
        ];
    }

    public function normalizeArabic(string $text): string
    {
        $text = trim($text);

        if ($text === '') {
            return '';
        }

        // Remove tashkeel and Quranic marks.
        $text = preg_replace('/[\x{0610}-\x{061A}\x{064B}-\x{065F}\x{0670}\x{06D6}-\x{06ED}]/u', '', $text) ?? $text;

        $replacements = [
            'أ' => 'ا', 'إ' => 'ا', 'آ' => 'ا', 'ٱ' => 'ا',
            'ى' => 'ي', 'ئ' => 'ي',
            'ة' => 'ه',
            'ؤ' => 'و',
            'گ' => 'ك', 'پ' => 'ب', 'چ' => 'ج', 'ڤ' => 'ف',
        ];

        $text = strtr($text, $replacements);
        $text = preg_replace('/[^\p{Arabic}]/u', '', $text) ?? $text;

        return $text;
    }

    public function similarityPercent(string $target, string $spoken): int
    {
        if ($target === $spoken) {
            return 100;
        }

        if ($target === '' || $spoken === '') {
            return 0;
        }

        if (str_contains($spoken, $target) || str_contains($target, $spoken)) {
            $shorter = min(mb_strlen($target), mb_strlen($spoken));
            $longer = max(mb_strlen($target), mb_strlen($spoken));

            return (int) round(($shorter / $longer) * 100);
        }

        $distance = $this->levenshteinUtf8($target, $spoken);
        $maxLen = max(mb_strlen($target), mb_strlen($spoken));

        return (int) max(0, round((1 - ($distance / $maxLen)) * 100));
    }

    /**
     * @return list<string>
     */
    public function findMissingLetters(string $target, string $spoken): array
    {
        $missing = [];
        $spokenChars = preg_split('//u', $spoken, -1, PREG_SPLIT_NO_EMPTY) ?: [];
        $spokenPool = $spokenChars;

        foreach (preg_split('//u', $target, -1, PREG_SPLIT_NO_EMPTY) ?: [] as $char) {
            $index = array_search($char, $spokenPool, true);

            if ($index === false) {
                if (! in_array($char, $missing, true)) {
                    $missing[] = $char;
                }
            } else {
                unset($spokenPool[$index]);
                $spokenPool = array_values($spokenPool);
            }
        }

        return $missing;
    }

    protected function levenshteinUtf8(string $a, string $b): int
    {
        $aChars = preg_split('//u', $a, -1, PREG_SPLIT_NO_EMPTY) ?: [];
        $bChars = preg_split('//u', $b, -1, PREG_SPLIT_NO_EMPTY) ?: [];

        $rows = count($aChars) + 1;
        $cols = count($bChars) + 1;
        $matrix = array_fill(0, $rows, array_fill(0, $cols, 0));

        for ($i = 0; $i < $rows; $i++) {
            $matrix[$i][0] = $i;
        }

        for ($j = 0; $j < $cols; $j++) {
            $matrix[0][$j] = $j;
        }

        for ($i = 1; $i < $rows; $i++) {
            for ($j = 1; $j < $cols; $j++) {
                $cost = $aChars[$i - 1] === $bChars[$j - 1] ? 0 : 1;
                $matrix[$i][$j] = min(
                    $matrix[$i - 1][$j] + 1,
                    $matrix[$i][$j - 1] + 1,
                    $matrix[$i - 1][$j - 1] + $cost,
                );
            }
        }

        return $matrix[$rows - 1][$cols - 1];
    }

    protected function starsFromPercentage(int $percentage): int
    {
        return match (true) {
            $percentage >= 90 => 5,
            $percentage >= 80 => 4,
            $percentage >= 70 => 3,
            $percentage >= 50 => 2,
            default => 1,
        };
    }

    /**
     * @param  list<string>  $missingLetters
     */
    protected function buildAssessment(
        string $targetWord,
        string $heard,
        int $matchPercentage,
        array $missingLetters,
        bool $isCorrect,
        int $childAge,
    ): string {
        if ($isCorrect) {
            return "نطق جيد! قال الطفل «{$heard}» وهي قريبة جداً من الكلمة المطلوبة «{$targetWord}» "
                ."(دقة {$matchPercentage}%). مناسب لعمر {$childAge} سنوات.";
        }

        $missingText = $missingLetters !== []
            ? 'الأصوات التي تحتاج تحسين: '.implode('، ', $missingLetters).'.'
            : 'حاول نطق الكلمة بوضوح أكبر.';

        return "النطق المسجّل «{$heard}» يختلف عن الكلمة المطلوبة «{$targetWord}» "
            ."(دقة {$matchPercentage}%). {$missingText}";
    }

    protected function buildScoreSummary(int $matchPercentage, string $heard, string $targetWord): string
    {
        if ($matchPercentage >= self::CORRECT_THRESHOLD) {
            return "نطق صحيح: سمعنا «{$heard}» مقابل «{$targetWord}».";
        }

        return "نطق يحتاج تحسين: سمعنا «{$heard}» بدلاً من «{$targetWord}».";
    }
}
