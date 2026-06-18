<?php

namespace App\Enums;

enum UserRole: string
{
    case Specialist = 'specialist';
    case Parent = 'parent';

    public function label(): string
    {
        return match ($this) {
            self::Specialist => 'أخصائي',
            self::Parent => 'ولي أمر',
        };
    }
}
