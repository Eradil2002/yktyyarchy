#!/bin/zsh
# Отправка Ыктыярчы в новый репозиторий Eradil2002/yktyyarchy (чистая история, без старых ключей)
cd "$(dirname "$0")"
REPO="https://github.com/Eradil2002/yktyyarchy.git"
GHDIR="$HOME/.local/gh"; export PATH="$GHDIR/bin:$PATH"

echo "=== [1/4] GitHub CLI ==="
if ! command -v gh >/dev/null; then
  ARCH=$( [ "$(uname -m)" = "arm64" ] && echo arm64 || echo amd64 )
  VER=$(curl -s https://api.github.com/repos/cli/cli/releases/latest | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')
  echo "Скачиваю gh $VER ($ARCH)..."
  mkdir -p "$GHDIR" && cd /tmp && curl -sL -o gh.zip "https://github.com/cli/cli/releases/download/v$VER/gh_${VER}_macOS_${ARCH}.zip" \
    && unzip -oq gh.zip && cp -R gh_${VER}_macOS_${ARCH}/* "$GHDIR/" && cd - >/dev/null
fi
gh --version | head -1 || { echo "Не удалось установить gh"; read; exit 1; }

echo "=== [2/4] Вход в GitHub (аккаунт Eradil2002) ==="
if ! gh auth status -h github.com >/dev/null 2>&1; then
  echo ">>> Код уже скопирован в буфер. В открывшемся браузере нажмите Cmd+V, Continue, Authorize."
  printf '\n\n\n' | gh auth login -h github.com -p https -w -s workflow --clipboard || { echo "Вход не выполнен"; read; exit 1; }
fi
if ! gh auth status -h github.com 2>&1 | grep -q workflow; then
  echo ">>> Нужно право workflow. Код скопирован в буфер — подтвердите в браузере."
  printf '\n\n\n' | gh auth refresh -h github.com -s workflow --clipboard || { echo "Не получено право workflow"; read; exit 1; }
fi
gh auth setup-git

echo "=== [3/4] Коммит последних правок ==="
git add render.yaml push_new_repo.command
git commit -m "Hosting: CORS for eradil2002.github.io" 2>/dev/null || true

echo "=== [4/4] Чистая история -> $REPO ==="
git branch -D yk-main 2>/dev/null
git checkout --orphan yk-main && git commit -qm "Ыктыярчы: initial commit (Flutter + Django, free hosting config)" \
  && git push -f "$REPO" yk-main:main && OK=1
git checkout -q main
[ -n "$OK" ] && echo "\n✅ ГОТОВО: https://github.com/Eradil2002/yktyyarchy" || echo "\n❌ ОШИБКА push"
echo "Окно можно закрыть."
