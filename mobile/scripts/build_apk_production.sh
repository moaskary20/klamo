#!/usr/bin/env bash
set -euo pipefail

API_URL="${1:-}"

if [[ -z "$API_URL" ]]; then
  echo "Usage: ./scripts/build_apk_production.sh https://your-domain.com/api"
  exit 1
fi

cd "$(dirname "$0")/.."

flutter pub get
flutter build apk --release --dart-define="API_BASE_URL=${API_URL}"

echo ""
echo "APK: build/app/outputs/flutter-apk/app-release.apk"
