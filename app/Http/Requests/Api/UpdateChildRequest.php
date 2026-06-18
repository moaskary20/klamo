<?php

namespace App\Http\Requests\Api;

use App\Enums\Gender;
use App\Enums\UserRole;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateChildRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $isSpecialist = $this->user()?->isSpecialist() ?? false;

        return [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'age' => ['sometimes', 'required', 'integer', 'min:1', 'max:18'],
            'gender' => ['sometimes', 'required', Rule::enum(Gender::class)],
            'avatar' => ['nullable', 'image', 'max:5120'],
            'level' => ['sometimes', 'required', 'integer', 'min:1'],
            'user_id' => [
                Rule::requiredIf($isSpecialist && $this->isMethod('POST')),
                'nullable',
                'integer',
                Rule::exists('users', 'id')->where(fn ($query) => $query->where('role', UserRole::Parent)),
            ],
        ];
    }
}
