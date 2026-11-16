#!/bin/zsh
# Локальная проверка Flutter: analyze + tests + сборка web (логи в .check_*.log)
cd "$(dirname "$0")"
export PATH="$HOME/flutter/bin:$PATH"
flutter pub get > .check_pub.log 2>&1
flutter analyze --no-fatal-infos > .check_analyze.log 2>&1; echo "EXIT $?" >> .check_analyze.log
flutter test > .check_test.log 2>&1; echo "EXIT $?" >> .check_test.log
flutter build web --release --base-href /yktyyarchy/ > .check_build.log 2>&1; echo "EXIT $?" >> .check_build.log
echo "ГОТОВО" > .check_done
echo "Проверка завершена. Окно можно закрыть."
