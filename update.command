#!/bin/zsh
# Обновление Ыктыярчы: коммит изменений -> GitHub (Eradil2002/yktyyarchy)
# -> GitHub Pages пересобирает веб-версию, Render пересобирает бэкенд (автоматически)
cd "$(dirname "$0")"
export PATH="$HOME/.local/gh/bin:$HOME/flutter/bin:$PATH"
REPO="https://github.com/Eradil2002/yktyyarchy.git"

# Разовая настройка: работаем в ветке yk-main (чистая история без старых ключей)
git remote get-url yk >/dev/null 2>&1 || git remote add yk "$REPO"
[ "$(git branch --show-current)" = "yk-main" ] || git checkout yk-main || { echo "Не удалось переключиться на yk-main"; read; exit 1; }
git fetch -q yk && git branch -q -u yk/main 2>/dev/null
git pull -q --rebase --autostash yk main || { echo "Конфликт при pull — нужна ручная правка"; read; exit 1; }

git add -A
# Защита от утечки секретов
BAD=$(git diff --cached --name-only | grep -iE 'serviceAccount|(^|/)\.env($|\.)|\.jks$|\.keystore$|key\.properties$|\.sqlite3$|\.pem$|\.key$' | grep -v '\.example$')
if [ -n "$BAD" ]; then
  echo "⛔ В коммит попали секреты, отмена:"; echo "$BAD"; git reset -q; read; exit 1
fi
if git diff --cached --quiet; then
  echo "Изменений нет."
else
  echo "--- Изменённые файлы ---"; git diff --cached --stat | tail -20
  MSG="Обновление $(date '+%Y-%m-%d %H:%M')"
  git commit -qm "$MSG" && git push yk yk-main:main \
    && echo "\n✅ Отправлено. Сайт обновится через ~3 мин: https://eradil2002.github.io/yktyyarchy/" \
    || echo "\n❌ Ошибка push"
fi
echo "Окно можно закрыть."
