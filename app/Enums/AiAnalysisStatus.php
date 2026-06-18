<?php

namespace App\Enums;

enum AiAnalysisStatus: string
{
    case Pending = 'pending';
    case Processing = 'processing';
    case Completed = 'completed';
    case Failed = 'failed';

    public function label(): string
    {
        return match ($this) {
            self::Pending => 'قيد الانتظار',
            self::Processing => 'جاري التحليل',
            self::Completed => 'مكتمل',
            self::Failed => 'فشل التحليل',
        };
    }
}
