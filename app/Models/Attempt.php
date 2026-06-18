<?php

namespace App\Models;

use App\Enums\AiAnalysisStatus;
use App\Services\GeminiService;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Attempt extends Model
{
    public const MAX_STARS = GeminiService::MAX_STARS;

    protected $fillable = [
        'child_id',
        'activity_id',
        'stars_earned',
        'is_completed',
        'audio_recording_path',
        'ai_analysis_result',
        'ai_analysis_status',
    ];

    protected function casts(): array
    {
        return [
            'stars_earned' => 'integer',
            'is_completed' => 'boolean',
            'ai_analysis_result' => 'array',
            'ai_analysis_status' => AiAnalysisStatus::class,
        ];
    }

    public function child(): BelongsTo
    {
        return $this->belongsTo(Child::class);
    }

    public function activity(): BelongsTo
    {
        return $this->belongsTo(Activity::class);
    }

    public function getAnalysisText(): ?string
    {
        return data_get($this->ai_analysis_result, 'text');
    }

    public function getAiStarsRating(): ?int
    {
        return data_get($this->ai_analysis_result, 'stars_rating');
    }

    public function isAnalysisPending(): bool
    {
        return $this->ai_analysis_status === AiAnalysisStatus::Pending
            || $this->ai_analysis_status === AiAnalysisStatus::Processing;
    }

    public function getMatchPercentage(): ?int
    {
        $value = data_get($this->ai_analysis_result, 'match_percentage');

        return $value === null ? null : (int) $value;
    }

    public function getErrorPercentage(): ?int
    {
        $match = $this->getMatchPercentage();

        return $match === null ? null : max(0, 100 - $match);
    }

    public function getScoreSummary(): ?string
    {
        return data_get($this->ai_analysis_result, 'score_summary');
    }

    /**
     * @return list<string>
     */
    public function getMissingLetters(): array
    {
        return array_values(data_get($this->ai_analysis_result, 'missing_letters', []));
    }

    public function isPronunciationCorrect(int $threshold = 70): bool
    {
        if ($this->ai_analysis_status !== AiAnalysisStatus::Completed) {
            return false;
        }

        $match = $this->getMatchPercentage();

        if ($match !== null) {
            return $match >= $threshold;
        }

        return ($this->getAiStarsRating() ?? 0) >= 4;
    }

    public function setAnalysisText(?string $text): void
    {
        $this->ai_analysis_result = array_merge($this->ai_analysis_result ?? [], [
            'text' => $text,
            'edited_at' => now()->toIso8601String(),
            'edited_by' => auth()->id(),
        ]);
    }

    public function applyGeminiAnalysis(array $analysis): void
    {
        $this->update([
            'ai_analysis_result' => $analysis,
            'stars_earned' => (int) ($analysis['stars_rating'] ?? $this->stars_earned),
            'ai_analysis_status' => AiAnalysisStatus::Completed,
        ]);
    }

    public function markAnalysisFailed(string $message, ?string $error = null): void
    {
        $this->update([
            'ai_analysis_status' => AiAnalysisStatus::Failed,
            'ai_analysis_result' => array_merge($this->ai_analysis_result ?? [], [
                'text' => $message,
                'analysis_failed' => true,
                'failed_at' => now()->toIso8601String(),
                'error' => $error,
            ]),
        ]);
    }
}
