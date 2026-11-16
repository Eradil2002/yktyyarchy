#!/bin/zsh
# Запуск Ыктыярчы.kg: бэкенд (Django) + приложение (Flutter в Chrome)
cd "$(dirname "$0")"
ROOT="$PWD"

echo "=== [1/3] Бэкенд ==="
cd "$ROOT/backend"
[ -d venv ] || python3 -m venv venv
source venv/bin/activate
pip install -q -r requirements.txt || { echo "Ошибка установки зависимостей"; read; exit 1; }
python manage.py makemigrations --noinput
python manage.py migrate --noinput
# сервер только на localhost, в фоне; лог в backend/server.log
python manage.py runserver 127.0.0.1:8000 > server.log 2>&1 &
BACK_PID=$!
trap "kill $BACK_PID 2>/dev/null" EXIT
sleep 3
curl -s -o /dev/null -w "Бэкенд: http://127.0.0.1:8000  (health %{http_code})\n" http://127.0.0.1:8000/health/

echo "=== [2/3] Flutter ==="
cd "$ROOT"
export PATH="$HOME/flutter/bin:$PATH"
if ! command -v flutter >/dev/null; then
  command -v git >/dev/null || { echo "Нет git. Выполните: xcode-select --install"; read; exit 1; }
  echo "Flutter не найден — скачиваю в ~/flutter (stable, ~1 ГБ, несколько минут)..."
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git "$HOME/flutter" || { echo "Ошибка загрузки Flutter"; read; exit 1; }
  grep -q 'flutter/bin' "$HOME/.zshrc" 2>/dev/null || echo 'export PATH="$HOME/flutter/bin:$PATH"' >> "$HOME/.zshrc"
  flutter config --no-analytics >/dev/null
  flutter precache --web
fi
flutter pub get

echo "=== [3/3] Запуск приложения в Chrome ==="
echo "Тестовый вход: aibek_volunteer / test1234"
flutter run -d chrome --web-port=5050 --dart-define=API_URL=http://127.0.0.1:8000/api/v1/
