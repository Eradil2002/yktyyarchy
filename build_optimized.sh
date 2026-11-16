#!/usr/bin/env bash
# build_optimized.sh — Flutter optimised release build (#88)
# Usage:
#   bash build_optimized.sh android   → APK + App Bundle
#   bash build_optimized.sh ios        → IPA
#   bash build_optimized.sh web        → Web with code splitting
#   bash build_optimized.sh all        → All targets

set -euo pipefail

TARGET="${1:-android}"

echo "🔧  Cleaning previous build artifacts..."
flutter clean
flutter pub get

# ---------------------------------------------------------------------------
# Common optimisation flags
# ---------------------------------------------------------------------------
# --tree-shake-icons  → removes unused Material/Cupertino icons (~200 KB savings)
# --split-debug-info  → moves debug symbols out of the binary (smaller APK/IPA)
# --obfuscate         → obfuscates Dart identifiers (requires split-debug-info)
# --no-sound-null-safety is NOT used — project is already null-safe

COMMON_FLAGS=(
  "--tree-shake-icons"
  "--split-debug-info=build/debug-info"
  "--obfuscate"
)

build_android() {
  echo ""
  echo "📦  Building Android App Bundle (release)..."
  flutter build appbundle \
    --release \
    "${COMMON_FLAGS[@]}"

  echo ""
  echo "📦  Building Android APK (release, split per ABI)..."
  flutter build apk \
    --release \
    --split-per-abi \
    "${COMMON_FLAGS[@]}"

  echo ""
  echo "✅  Android build complete."
  echo "    App Bundle : build/app/outputs/bundle/release/app-release.aab"
  echo "    APKs       : build/app/outputs/flutter-apk/"
}

build_ios() {
  echo ""
  echo "📦  Building iOS (release, no codesign)..."
  flutter build ios \
    --release \
    --no-codesign \
    "${COMMON_FLAGS[@]}"

  echo ""
  echo "✅  iOS build complete. Archive with Xcode or fastlane."
}

build_web() {
  echo ""
  echo "🌐  Building Flutter Web (release, deferred loading)..."
  # --web-renderer canvaskit → best visual fidelity; swap to 'html' for smaller initial bundle
  # Deferred imports (code splitting) are activated automatically when
  # the app uses `deferred as` in Dart — see lib/web_deferred_routes.dart
  flutter build web \
    --release \
    --web-renderer canvaskit \
    --pwa-strategy offline-first \
    "${COMMON_FLAGS[@]}"

  echo ""
  echo "✅  Web build complete: build/web/"
}

analyze_size() {
  echo ""
  echo "📊  Analysing APK size..."
  flutter build apk \
    --release \
    --analyze-size \
    --target-platform android-arm64 \
    "${COMMON_FLAGS[@]}" \
    2>&1 | tee build/size-analysis-android.txt || true

  echo ""
  echo "    Size report: build/size-analysis-android.txt"
}

case "$TARGET" in
  android) build_android ;;
  ios)     build_ios ;;
  web)     build_web ;;
  analyze) analyze_size ;;
  all)
    build_android
    build_web
    ;;
  *)
    echo "Usage: bash build_optimized.sh [android|ios|web|analyze|all]"
    exit 1
    ;;
esac

echo ""
echo "🎉  Done! Debug symbols saved to build/debug-info/ (keep private)."
