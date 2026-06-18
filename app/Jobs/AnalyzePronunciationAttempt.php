<?php

namespace App\Jobs;

use App\Enums\AiAnalysisStatus;
use App\Models\Attempt;
use App\Services\GeminiService;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\Log;
use Throwable;

class AnalyzePronunciationAttempt implements ShouldQueue
{
    use Queueable;

    public int $tries = 3;

    public int $timeout = 120;

    public function __construct(public int $attemptId)
    {
        $this->onQueue('ai');
    }

    public function handle(GeminiService $geminiService): void
    {
        $attempt = Attempt::query()
            ->with(['child', 'activity.item'])
            ->find($this->attemptId);

        if (! $attempt || blank($attempt->audio_recording_path)) {
            return;
        }

        $targetWord = $attempt->activity?->item?->word_name;

        if (blank($targetWord)) {
            Log::warning('Skipping Gemini analysis: missing target word.', [
                'attempt_id' => $attempt->id,
            ]);

            $attempt->markAnalysisFailed('الكلمة المستهدفة غير متوفرة للتحليل.');

            return;
        }

        $attempt->update([
            'ai_analysis_status' => AiAnalysisStatus::Processing,
        ]);

        $analysis = $geminiService->analyzePronunciation(
            audioPath: $attempt->audio_recording_path,
            targetWord: $targetWord,
            childAge: $attempt->child->age,
        );

        $attempt->applyGeminiAnalysis($analysis);
    }

    public function failed(?Throwable $exception): void
    {
        Log::error('Gemini pronunciation analysis failed.', [
            'attempt_id' => $this->attemptId,
            'message' => $exception?->getMessage(),
        ]);

        $attempt = Attempt::find($this->attemptId);

        if (! $attempt) {
            return;
        }

        $attempt->markAnalysisFailed(
            message: 'تعذّر إكمال التحليل الآلي. يرجى مراجعة التسجيل يدوياً.',
            error: $exception?->getMessage(),
        );
    }
}
