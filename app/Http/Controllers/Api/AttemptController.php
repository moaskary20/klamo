<?php

namespace App\Http\Controllers\Api;

use App\Enums\AiAnalysisStatus;
use App\Http\Requests\Api\StoreAttemptRequest;
use App\Http\Requests\Api\UpdateAttemptAnalysisRequest;
use App\Http\Resources\AttemptResource;
use App\Jobs\AnalyzePronunciationAttempt;
use App\Models\Activity;
use App\Models\Attempt;
use App\Models\Child;
use App\Services\GeminiService;
use App\Services\LocalPronunciationAnalyzer;
use App\Support\ScopesApiByUserRole;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Throwable;

class AttemptController extends ApiController
{
    public function index(Request $request): JsonResponse
    {
        $query = ScopesApiByUserRole::scopeAttemptsForUser(
            Attempt::query()
                ->with(['child', 'activity.item.world'])
                ->latest(),
            $request->user(),
        );

        if ($request->boolean('has_audio')) {
            $query->whereNotNull('audio_recording_path');
        }

        if ($request->boolean('is_completed')) {
            $query->where('is_completed', true);
        }

        if ($request->filled('child_id')) {
            $child = ScopesApiByUserRole::resolveChild($request->user(), $request->integer('child_id'));
            $query->where('child_id', $child->id);
        }

        if ($request->filled('ai_analysis_status')) {
            $query->where('ai_analysis_status', $request->string('ai_analysis_status'));
        }

        $attempts = $query->paginate(min($request->integer('per_page', 20), 50));

        return $this->success([
            'attempts' => AttemptResource::collection($attempts->getCollection())->resolve(),
            'meta' => [
                'current_page' => $attempts->currentPage(),
                'last_page' => $attempts->lastPage(),
                'total' => $attempts->total(),
            ],
        ]);
    }

    public function show(Request $request, Attempt $attempt): JsonResponse
    {
        $this->authorizeAttempt($request, $attempt);

        $attempt->load(['child', 'activity.item.world']);

        return $this->success([
            'attempt' => new AttemptResource($attempt),
        ]);
    }

    public function updateAnalysis(UpdateAttemptAnalysisRequest $request, Attempt $attempt): JsonResponse
    {
        $this->authorizeAttempt($request, $attempt);

        $attempt->setAnalysisText($request->validated('analysis_text'));
        $attempt->save();
        $attempt->load(['child', 'activity.item.world']);

        return $this->success([
            'attempt' => new AttemptResource($attempt),
        ], 'تم تحديث التحليل بنجاح');
    }

    public function store(StoreAttemptRequest $request, GeminiService $geminiService, LocalPronunciationAnalyzer $localAnalyzer): JsonResponse
    {
        $activity = Activity::query()
            ->with('item')
            ->findOrFail($request->integer('activity_id'));
        $child = ScopesApiByUserRole::resolveChild(
            $request->user(),
            $request->integer('child_id'),
        );
        $hasAudio = $request->hasFile('audio');
        $analyzeSync = $hasAudio && $request->boolean('analyze_sync');
        $audioPath = null;

        if ($hasAudio) {
            $audioPath = $request->file('audio')->store('attempts/recordings', 'public');
        }

        $attempt = $activity->attempts()->create([
            'child_id' => $child->id,
            'stars_earned' => $hasAudio ? 0 : $request->integer('stars_earned'),
            'is_completed' => $analyzeSync ? false : $request->boolean('is_completed', true),
            'audio_recording_path' => $audioPath,
            'ai_analysis_status' => $hasAudio ? AiAnalysisStatus::Pending : null,
        ]);

        if ($analyzeSync) {
            $attempt->update(['ai_analysis_status' => AiAnalysisStatus::Processing]);

            $transcription = $request->string('transcription')->trim()->toString();
            $targetWord = $activity->item->word_name;
            $analyzed = false;

            if ($transcription !== '') {
                try {
                    $analysis = $localAnalyzer->analyze($targetWord, $transcription, $child->age);
                    $analysis['analysis_source'] = 'local';
                    $attempt->applyGeminiAnalysis($analysis);
                    $attempt->update([
                        'is_completed' => $attempt->isPronunciationCorrect(),
                    ]);
                    $analyzed = true;
                } catch (Throwable $localException) {
                    // Continue to Gemini when local text comparison fails.
                }
            }

            if (! $analyzed) {
                try {
                    $analysis = $geminiService->analyzePronunciation(
                        audioPath: $audioPath,
                        targetWord: $targetWord,
                        childAge: $child->age,
                    );

                    $analysis['analysis_source'] = 'gemini';
                    $attempt->applyGeminiAnalysis($analysis);
                    $attempt->refresh();

                    $attempt->update([
                        'is_completed' => $attempt->isPronunciationCorrect(),
                    ]);
                    $analyzed = true;
                } catch (Throwable $exception) {
                    $this->applyAnalysisWithLocalFallback(
                        attempt: $attempt,
                        targetWord: $targetWord,
                        childAge: $child->age,
                        transcription: $transcription,
                        localAnalyzer: $localAnalyzer,
                        geminiError: $exception->getMessage(),
                    );
                }
            }

            $attempt = $attempt->fresh(['child', 'activity.item']);

            return $this->success([
                'attempt' => new AttemptResource($attempt),
            ], $this->syncAnalysisMessage($attempt), 201);
        }

        if ($hasAudio) {
            $failureMessage = $request->string('failure_message')->trim()->toString();

            if ($failureMessage !== '') {
                $attempt->markAnalysisFailed($failureMessage);
            } else {
                AnalyzePronunciationAttempt::dispatch($attempt->id);
            }
        }

        return $this->success([
            'attempt' => new AttemptResource($attempt->fresh(['child', 'activity.item'])),
        ], $hasAudio
            ? 'تم حفظ التسجيل وسيتم تحليله في الخلفية'
            : 'تم حفظ المحاولة بنجاح', 201);
    }

    protected function syncAnalysisMessage(Attempt $attempt): string
    {
        if ($attempt->ai_analysis_status === AiAnalysisStatus::Failed) {
            return 'تعذّر تحليل التسجيل';
        }

        $prefix = match (data_get($attempt->ai_analysis_result, 'analysis_source')) {
            'local' => 'تحليل محلي: ',
            'gemini' => 'تحليل صوتي: ',
            default => '',
        };

        return $prefix.($attempt->isPronunciationCorrect()
            ? 'نطق ممتاز!'
            : 'حاول تحسين النطق مرة أخرى');
    }

    protected function applyAnalysisWithLocalFallback(
        Attempt $attempt,
        string $targetWord,
        int $childAge,
        string $transcription,
        LocalPronunciationAnalyzer $localAnalyzer,
        ?string $geminiError = null,
    ): void {
        if ($transcription !== '') {
            try {
                $analysis = $localAnalyzer->analyze($targetWord, $transcription, $childAge);
                $analysis['analysis_source'] = 'local';
                $analysis['fallback_from_gemini'] = true;
                $analysis['gemini_error'] = $geminiError;

                $attempt->applyGeminiAnalysis($analysis);
                $attempt->update([
                    'is_completed' => $attempt->isPronunciationCorrect(),
                ]);

                return;
            } catch (Throwable $localException) {
                $attempt->markAnalysisFailed(
                    message: $localException->getMessage() ?: 'تعذّر تحليل التسجيل محلياً.',
                    error: $localException->getMessage(),
                );

                return;
            }
        }

        $attempt->markAnalysisFailed(
            message: $geminiError ?: 'تعذّر تحليل التسجيل. حاول مرة أخرى.',
            error: $geminiError,
        );
    }

    protected function authorizeAttempt(Request $request, Attempt $attempt): void
    {
        $attempt->loadMissing('child');

        abort_unless(
            ScopesApiByUserRole::canAccessChild($request->user(), $attempt->child),
            403,
            'غير مصرح بالوصول لهذه المحاولة.',
        );
    }
}
