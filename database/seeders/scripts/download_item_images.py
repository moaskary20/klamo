#!/usr/bin/env python3
"""Download real educational photos from Wikimedia Commons."""

from __future__ import annotations

import json
import os
import ssl
import time
import urllib.parse
import urllib.request

ssl._create_default_https_context = ssl._create_unverified_context

BASE_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "items")
API_URL = "https://commons.wikimedia.org/w/api.php"
HEADERS = {"User-Agent": "KlamoEducationalApp/1.0 (children learning; local-dev)"}
SLEEP_SECONDS = 8.0
MAX_RETRIES = 4

FILES = {
    "cat.jpg": "Cat03.jpg",
    "dog.jpg": "YellowLabradorLooking_new.jpg",
    "rabbit.jpg": "Oryctolagus_cuniculus_Rcdo.jpg",
    "fish.jpg": "Goldfish.jpg",
    "bird.jpg": "Passer_domesticus_male_(15).jpg",
    "lion.jpg": "Lion_waiting_in_Namibia.jpg",
    "horse.jpg": "Nokota_Horses_cropped.jpg",
    "elephant.jpg": "African_Bush_Elephant.jpg",
    "apple.jpg": "Red_Apple.jpg",
    "banana.jpg": "Banana-Single.jpg",
    "orange_fruit.jpg": "Orange_fruit.jpg",
    "grapes.jpg": "Grapes.jpg",
    "strawberry.jpg": "Strawberries.jpg",
    "watermelon.jpg": "Watermelon.jpg",
    "carrot.jpg": "Carrots.jpg",
    "tomato.jpg": "Tomato_je.jpg",
    "cucumber.jpg": "Cucumber.jpg",
    "broccoli.jpg": "Broccoli_and_cross_section_edit.jpg",
    "potato.jpg": "Potatoes.jpg",
    "pepper.jpg": "Green-Yellow-Red-Pepper-2009.jpg",
    "shirt.jpg": "T-shirt.jpg",
    "dress.jpg": "Dress.jpg",
    "pants.jpg": "Jeans.jpg",
    "shoe.jpg": "Sneakers.jpg",
    "hat.jpg": "Baseball_cap.jpg",
    "coat.jpg": "Coat.jpg",
    "car.jpg": "Car_2.jpg",
    "bicycle.jpg": "Left_side_of_Flying_Pigeon.jpg",
    "bus.jpg": "School_bus.jpg",
    "train.jpg": "ICE_3_Oberhaider-Wald-Tunnel.jpg",
    "airplane.jpg": "Boeing_737-800.jpg",
    "ship.jpg": "Ship.jpg",
    "chair.jpg": "Chair.jpg",
    "table.jpg": "Wooden_table.jpg",
    "bed.jpg": "Bed.jpg",
    "lamp.jpg": "Lamp.jpg",
    "wardrobe.jpg": "Wardrobe.jpg",
    "sofa.jpg": "Sofa.jpg",
}


def fetch_thumb_url(file_title: str, width: int = 500) -> str:
    params = urllib.parse.urlencode(
        {
            "action": "query",
            "titles": f"File:{file_title}",
            "prop": "imageinfo",
            "iiprop": "url",
            "iiurlwidth": str(width),
            "format": "json",
        }
    )
    request = urllib.request.Request(f"{API_URL}?{params}", headers=HEADERS)

    for attempt in range(MAX_RETRIES):
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                payload = json.load(response)
            break
        except urllib.error.HTTPError as error:
            if error.code == 429 and attempt < MAX_RETRIES - 1:
                wait = SLEEP_SECONDS * (attempt + 2)
                print(f"  rate limited, waiting {wait:.0f}s...")
                time.sleep(wait)
                continue
            raise

    pages = payload.get("query", {}).get("pages", {})
    for page in pages.values():
        if "missing" in page:
            raise RuntimeError(f"file not found: {file_title}")

        info = page.get("imageinfo", [{}])[0]
        url = info.get("thumburl") or info.get("url", "")
        if not url:
            raise RuntimeError(f"no url for {file_title}")
        return url

    raise RuntimeError(f"no page for {file_title}")


def download_file(url: str, destination: str) -> int:
    for attempt in range(MAX_RETRIES):
        try:
            request = urllib.request.Request(url, headers=HEADERS)
            with urllib.request.urlopen(request, timeout=60) as response:
                data = response.read()
            with open(destination, "wb") as handle:
                handle.write(data)
            return len(data)
        except urllib.error.HTTPError as error:
            if error.code == 429 and attempt < MAX_RETRIES - 1:
                wait = SLEEP_SECONDS * (attempt + 2)
                print(f"  download rate limited, waiting {wait:.0f}s...")
                time.sleep(wait)
                continue
            raise

    raise RuntimeError("download failed")


def main() -> None:
    os.makedirs(BASE_DIR, exist_ok=True)
    ok = 0
    fail = 0

    for index, (filename, title) in enumerate(FILES.items()):
        destination = os.path.join(BASE_DIR, filename)

        if index > 0:
            time.sleep(SLEEP_SECONDS)

        try:
            url = fetch_thumb_url(title)
            size = download_file(url, destination)
            print(f"OK  {filename} <- {title} ({size:,} bytes)")
            ok += 1
        except Exception as error:  # noqa: BLE001
            print(f"FAIL {filename} <- {title}: {error}")
            fail += 1

    print(f"\nDone: {ok} succeeded, {fail} failed")


if __name__ == "__main__":
    main()
