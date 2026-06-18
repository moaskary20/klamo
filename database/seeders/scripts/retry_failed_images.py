#!/usr/bin/env python3
"""Download only missing/failed item images."""

from __future__ import annotations

import importlib.util
import os
import sys

SCRIPT_PATH = os.path.join(os.path.dirname(__file__), "download_item_images.py")
spec = importlib.util.spec_from_file_location("downloader", SCRIPT_PATH)
downloader = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(downloader)

RETRY_ONLY = {
    "orange_fruit.jpg": "Orange_fruit.jpg",
    "grapes.jpg": "Grapes.jpg",
    "strawberry.jpg": "Strawberries.jpg",
    "watermelon.jpg": "Watermelon.jpg",
    "carrot.jpg": "Carrots.jpg",
    "tomato.jpg": "Tomato_je.jpg",
    "cucumber.jpg": "Cucumber.jpg",
    "broccoli.jpg": "Broccoli_in_a_basket.jpg",
    "potato.jpg": "Potatoes.jpg",
    "pepper.jpg": "Capsicum_annuum_fruits.jpg",
    "shirt.jpg": "White_t-shirt.jpg",
    "dress.jpg": "Little_red_dress.jpg",
    "pants.jpg": "Jeans.jpg",
    "coat.jpg": "Coat.jpg",
    "car.jpg": "Car_2.jpg",
    "bus.jpg": "Bus_in_Cairo.jpg",
    "airplane.jpg": "Boeing_737-800.jpg",
    "ship.jpg": "Ship.jpg",
    "chair.jpg": "Chair.jpg",
    "table.jpg": "Table_(furniture).jpg",
    "bed.jpg": "Bed.jpg",
    "lamp.jpg": "Lamp.jpg",
    "wardrobe.jpg": "Wardrobe.jpg",
    "sofa.jpg": "Sofa.jpg",
}


def main() -> None:
    import time

    base_dir = downloader.BASE_DIR
    os.makedirs(base_dir, exist_ok=True)
    ok = 0
    fail = 0

    for index, (filename, title) in enumerate(RETRY_ONLY.items()):
        destination = os.path.join(base_dir, filename)

        if index > 0:
            time.sleep(downloader.SLEEP_SECONDS)

        try:
            url = downloader.fetch_thumb_url(title)
            size = downloader.download_file(url, destination)
            print(f"OK  {filename} <- {title} ({size:,} bytes)")
            ok += 1
        except Exception as error:  # noqa: BLE001
            print(f"FAIL {filename} <- {title}: {error}")
            fail += 1

    print(f"\nRetry done: {ok} succeeded, {fail} failed")


if __name__ == "__main__":
    main()
