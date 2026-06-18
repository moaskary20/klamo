#!/usr/bin/env python3
"""Generate colorful item images with Arabic words for Klamo seeder."""

from __future__ import annotations

import math
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

BASE_DIR = Path(__file__).resolve().parents[1] / "assets" / "items"
FONT_PATH = "/usr/share/fonts/truetype/noto/NotoNaskhArabicUI-Bold.ttf"

WORLD_PALETTES = {
    "animals": [(46, 125, 50), (129, 199, 132)],
    "fruits": [(230, 81, 0), (255, 183, 77)],
    "vegetables": [(56, 142, 60), (174, 213, 129)],
    "clothes": [(94, 53, 177), (206, 147, 216)],
    "transport": [(21, 101, 192), (79, 195, 247)],
    "furniture": [(109, 76, 65), (255, 204, 128)],
}

ITEMS = {
    "cat.jpg": ("قطة", "animals"),
    "dog.jpg": ("كلب", "animals"),
    "rabbit.jpg": ("أرنب", "animals"),
    "fish.jpg": ("سمكة", "animals"),
    "bird.jpg": ("عصفور", "animals"),
    "lion.jpg": ("أسد", "animals"),
    "horse.jpg": ("حصان", "animals"),
    "elephant.jpg": ("فيل", "animals"),
    "apple.jpg": ("تفاحة", "fruits"),
    "banana.jpg": ("موزة", "fruits"),
    "orange_fruit.jpg": ("برتقالة", "fruits"),
    "grapes.jpg": ("عنب", "fruits"),
    "strawberry.jpg": ("فراولة", "fruits"),
    "watermelon.jpg": ("بطيخ", "fruits"),
    "carrot.jpg": ("جزر", "vegetables"),
    "tomato.jpg": ("طماطم", "vegetables"),
    "cucumber.jpg": ("خيار", "vegetables"),
    "potato.jpg": ("بطاطس", "vegetables"),
    "broccoli.jpg": ("بروكلي", "vegetables"),
    "pepper.jpg": ("فلفل", "vegetables"),
    "shirt.jpg": ("قميص", "clothes"),
    "dress.jpg": ("فستان", "clothes"),
    "pants.jpg": ("بنطال", "clothes"),
    "shoe.jpg": ("حذاء", "clothes"),
    "hat.jpg": ("قبعة", "clothes"),
    "coat.jpg": ("معطف", "clothes"),
    "car.jpg": ("سيارة", "transport"),
    "bicycle.jpg": ("دراجة", "transport"),
    "bus.jpg": ("حافلة", "transport"),
    "train.jpg": ("قطار", "transport"),
    "airplane.jpg": ("طائرة", "transport"),
    "ship.jpg": ("سفينة", "transport"),
    "chair.jpg": ("كرسي", "furniture"),
    "table.jpg": ("طاولة", "furniture"),
    "bed.jpg": ("سرير", "furniture"),
    "lamp.jpg": ("مصباح", "furniture"),
    "wardrobe.jpg": ("خزانة", "furniture"),
    "sofa.jpg": ("أريكة", "furniture"),
}


def draw_gradient(size: int, top: tuple[int, int, int], bottom: tuple[int, int, int]) -> Image.Image:
    image = Image.new("RGB", (size, size), top)
    draw = ImageDraw.Draw(image)

    for y in range(size):
        ratio = y / size
        color = tuple(
            int(top[i] + (bottom[i] - top[i]) * ratio)
            for i in range(3)
        )
        draw.line([(0, y), (size, y)], fill=color)

    return image


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, max_width: int) -> str:
    words = text.split()
    if not words:
        return text

    lines: list[str] = []
    current = words[0]

    for word in words[1:]:
        candidate = f"{current} {word}"
        if draw.textlength(candidate, font=font) <= max_width:
            current = candidate
        else:
            lines.append(current)
            current = word

    lines.append(current)
    return "\n".join(lines)


def generate_image(filename: str, word: str, palette_key: str, size: int = 480) -> None:
    top, bottom = WORLD_PALETTES[palette_key]
    image = draw_gradient(size, top, bottom)
    draw = ImageDraw.Draw(image)

    for index in range(6):
        x = int(size * (0.15 + index * 0.14))
        y = int(size * (0.12 + (index % 2) * 0.08))
        radius = 18 + index * 4
        alpha = 40 + index * 8
        draw.ellipse(
            [(x - radius, y - radius), (x + radius, y + radius)],
            fill=(255, 255, 255, alpha),
        )

    font_size = 72 if len(word) <= 6 else 58
    font = ImageFont.truetype(FONT_PATH, font_size)
    wrapped = wrap_text(draw, word, font, int(size * 0.82))
    bbox = draw.multiline_textbbox((0, 0), wrapped, font=font, align="center", spacing=8)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    position = ((size - text_width) / 2, (size - text_height) / 2)

    draw.multiline_text(
        (position[0] + 3, position[1] + 3),
        wrapped,
        font=font,
        fill=(0, 0, 0, 80),
        align="center",
        spacing=8,
    )
    draw.multiline_text(
        position,
        wrapped,
        font=font,
        fill=(255, 255, 255),
        align="center",
        spacing=8,
    )

    output = BASE_DIR / filename
    image.save(output, "JPEG", quality=92)
    print(f"generated {filename}")


def main() -> None:
    BASE_DIR.mkdir(parents=True, exist_ok=True)

    for filename, (word, palette_key) in ITEMS.items():
        generate_image(filename, word, palette_key)

    print(f"Done: {len(ITEMS)} images in {BASE_DIR}")


if __name__ == "__main__":
    main()
