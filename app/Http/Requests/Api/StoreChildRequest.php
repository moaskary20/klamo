<?php

namespace App\Http\Requests\Api;

use App\Enums\Gender;
use App\Enums\UserRole;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class StoreChildRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $isSpecialist = $this->user()?->isSpecialist() ?? false;

        return [
            'name' => ['required', 'string', 'max:255'],
            'age' => ['required', 'integer', 'min:1', 'max:18'],
            'gender' => ['required', Rule::enum(Gender::class)],
            'avatar' => ['nullable', 'image', 'max:5120'],
            'level' => ['nullable', 'integer', 'min:1'],
            'user_id' => [
                Rule::requiredIf($isSpecialist),
                'integer',
                Rule::exists('users', 'id')->where(fn ($query) => $query->where('role', UserRole::Parent)),
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'name.required' => 'اسم الطفل مطلوب.',
            'age.required' => 'عمر الطفل مطلوب.',
            'gender.required' => 'جنس الطفل مطلوب.',
        ];
    }
}
