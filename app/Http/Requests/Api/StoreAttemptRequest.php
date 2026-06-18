<?php

namespace App\Http\Requests\Api;

use App\Models\Attempt;
use App\Models\Child;
use App\Support\ScopesApiByUserRole;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreAttemptRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'child_id' => [
                'required',
                'integer',
                function (string $attribute, mixed $value, \Closure $fail): void {
                    $child = Child::query()->find($value);

                    if (! $child || ! ScopesApiByUserRole::canAccessChild($this->user(), $child)) {
                        $fail('الطفل غير موجود أو غير تابع لحسابك.');
                    }
                },
            ],
            'activity_id' => ['required', 'integer', 'exists:activities,id'],
            'stars_earned' => [
                Rule::requiredIf(fn (): bool => ! $this->hasFile('audio')),
                'nullable',
                'integer',
                'min:0',
                'max:'.Attempt::MAX_STARS,
            ],
            'audio' => ['nullable', 'file', 'mimes:mp3,wav,ogg,m4a,aac,mp4', 'max:10240'],
            'is_completed' => ['nullable', 'boolean'],
            'analyze_sync' => ['nullable', 'boolean'],
            'transcription' => ['nullable', 'string', 'max:500'],
            'failure_message' => ['nullable', 'string', 'max:500'],
        ];
    }

    public function messages(): array
    {
        return [
            'child_id.required' => 'معرّف الطفل مطلوب.',
            'activity_id.required' => 'معرّف النشاط مطلوب.',
            'stars_earned.required' => 'عدد النجوم مطلوب عند عدم إرفاق تسجيل صوتي.',
        ];
    }
}
