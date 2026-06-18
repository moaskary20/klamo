<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use RuntimeException;

class GeminiService
{
    public const MAX_STARS = 5;

    /**
     * Analyze child pronunciation audio against the target word using Gemini.
     *
     * @return array{
     *     text: string,
     *     stars_rating: int,
     *     missing_letters: array<int, string>,
     *     match_percentage: int|null,
     *     score_summary: string|null,
     *     target_word: string,
     *     child_age: int,
     *     model: string,
     *     analyzed_at: string,
     *     raw_response: array<string, mixed>
     * }
     */
    public function analyzePronunciation(string $audioPath, string $targetWord, int $childAge): array
    {
        $apiKey = config('gemini.api_key');

        if (blank($apiKey)) {
            throw new RuntimeException('Gemini API key is not configured.');
        }

        $diskPath = Storage::disk('public')->path($audioPath);

        if (! is_file($diskPath)) {
            throw new RuntimeException('Audio file not found for analysis.');
        }

        $mimeType = mime_content_type($diskPath) ?: 'audio/mp4';
        if (str_starts_with($mimeType, 'video/')) {
            $mimeType = 'audio/mp4';
        }
        $audioBase64 = base64_encode((string) file_get_contents($diskPath));

        $response = Http::timeout((int) config('gemini.timeout'))
            ->post(
                sprintf(
                    '%s/models/%s:generateContent?key=%s',
                    rtrim((string) config('gemini.base_url'), '/'),
                    config('gemini.model'),
                    $apiKey,
                ),
                [
                    'contents' => [
                        [
                            'parts' => [
                                [
                                    'inline_data' => [
                                        'mime_type' => $mimeType,
                                        'data' => $audioBase64,
                                    ],
                                ],
                                [
                                    'text' => $this->buildPrompt($targetWord, $childAge),
                                ],
                            ],
                        ],
                    ],
                    'generationConfig' => [
                        'temperature' => 0.2,
                        'responseMimeType' => 'application/json',
                    ],
                ],
            );

        if ($response->failed()) {
            $apiMessage = data_get($response->json(), 'error.message');

            Log::error('Gemini API request failed', [
                'status' => $response->status(),
                'body' => $response->body(),
            ]);

            $message = match ($response->status()) {
                404 => 'نموذج الذكاء الاصطناعي غير متاح. راجع إعداد GEMINI_MODEL في السيرفر.',
                429 => 'تم تجاوز حد استخدام Gemini API. انتظر قليلاً أو فعّل الفوترة في Google AI Studio.',
                403 => 'مفتاح Gemini API غير صالح أو غير مفعّل.',
                default => is_string($apiMessage) && $apiMessage !== ''
                    ? $apiMessage
                    : 'فشل تحليل النطق بواسطة الذكاء الاصطناعي.',
            };

            throw new RuntimeException($message);
        }

        $rawText = data_get($response->json(), 'candidates.0.content.parts.0.text');

        if (! is_string($rawText) || blank($rawText)) {
            throw new RuntimeException('Gemini returned an empty analysis response.');
        }

        $parsed = json_decode($rawText, true);

        if (! is_array($parsed)) {
            $parsed = [
                'assessment' => trim($rawText),
                'stars_rating' => 3,
                'missing_letters' => [],
                'match_percentage' => null,
                'score_summary' => null,
            ];
        }

        $starsRating = $this->normalizeStars(
            (int) ($parsed['stars_rating'] ?? $parsed['stars'] ?? 3)
        );

        $assessment = (string) ($parsed['assessment'] ?? $parsed['text'] ?? $rawText);

        return [
            'text' => $assessment,
            'stars_rating' => $starsRating,
            'missing_letters' => array_values($parsed['missing_letters'] ?? []),
            'match_percentage' => isset($parsed['match_percentage'])
                ? (int) $parsed['match_percentage']
                : null,
            'score_summary' => isset($parsed['score_summary'])
                ? (string) $parsed['score_summary']
                : null,
            'analysis_source' => 'gemini',
            'target_word' => $targetWord,
            'child_age' => $childAge,
            'model' => (string) config('gemini.model'),
            'analyzed_at' => now()->toIso8601String(),
            'raw_response' => $parsed,
        ];
    }

    protected function normalizeStars(int $stars): int
    {
        return max(1, min(self::MAX_STARS, $stars));
    }

    protected function buildPrompt(string $targetWord, int $childAge): string
    {
        $maxStars = self::MAX_STARS;

        return <<<PROMPT
You are a pediatric Arabic speech-language assistant for children aged 5-6.

Analyze the attached audio recording of a child pronouncing a word.
Compare the child's pronunciation quality and accuracy against the correct target word: "{$targetWord}".

Return ONLY valid JSON with this exact shape:
{
  "stars_rating": 4,
  "assessment": "detailed Arabic evaluation for specialist/parent",
  "missing_letters": ["حروف أو أصوات ناقصة أو خاطئة بالعربية"],
  "match_percentage": 80,
  "score_summary": "ملخص قصير بالعربية عن جودة النطق"
}

Rules:
- stars_rating MUST be an integer from 1 to {$maxStars} (5 = excellent pronunciation, 1 = needs significant improvement).
- match_percentage MUST be an integer from 0 to 100 representing how closely the pronunciation matches "{$targetWord}".
- Consider the child's age ({$childAge} years) when evaluating.
- Identify missing or mispronounced Arabic letters/sounds.
- Write assessment and score_summary in clear, encouraging, professional Arabic.
- Do not include markdown or any text outside the JSON object.
PROMPT;
    }
}
