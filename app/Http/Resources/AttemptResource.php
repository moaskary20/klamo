<?php

namespace App\Http\Resources;

use App\Enums\AiAnalysisStatus;
use App\Models\Attempt;
use App\Support\MediaUrl;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AttemptResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'child_id' => $this->child_id,
            'child_name' => $this->when(
                $this->relationLoaded('child') && $this->child,
                fn () => $this->child->name,
            ),
            'word_name' => $this->when(
                $this->relationLoaded('activity') && $this->activity?->relationLoaded('item'),
                fn () => $this->activity?->item?->word_name,
            ),
            'activity_type_label' => $this->when(
                $this->relationLoaded('activity') && $this->activity?->type,
                fn () => $this->activity?->type?->label(),
            ),
            'activity_id' => $this->activity_id,
            'stars_earned' => $this->stars_earned,
            'max_stars' => Attempt::MAX_STARS,
            'is_completed' => $this->is_completed,
            'audio_recording_url' => MediaUrl::fromRequest($request, $this->audio_recording_path),
            'ai_analysis_status' => $this->ai_analysis_status?->value,
            'ai_analysis_status_label' => $this->ai_analysis_status?->label(),
            'ai_analysis' => $this->ai_analysis_result,
            'ai_stars_rating' => $this->getAiStarsRating(),
            'analysis_text' => $this->getAnalysisText(),
            'heard_transcription' => data_get($this->ai_analysis_result, 'heard_transcription'),
            'analysis_source' => data_get($this->ai_analysis_result, 'analysis_source'),
            'match_percentage' => $this->getMatchPercentage(),
            'error_percentage' => $this->getErrorPercentage(),
            'score_summary' => $this->getScoreSummary(),
            'missing_letters' => $this->getMissingLetters(),
            'is_correct' => $this->ai_analysis_status === AiAnalysisStatus::Completed
                && $this->isPronunciationCorrect(),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
