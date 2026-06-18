<?php

namespace App\Enums;

enum ActivityType: string
{
    case WordRecognition = 'word_recognition';
    case AuditoryDiscrimination = 'auditory_discrimination';
    case PronunciationRecording = 'pronunciation_recording';

    public function label(): string
    {
        return match ($this) {
            self::WordRecognition => 'تعرف على الكلمة',
            self::AuditoryDiscrimination => 'تمييز سمعي',
            self::PronunciationRecording => 'تسجيل نطق',
        };
    }
}
