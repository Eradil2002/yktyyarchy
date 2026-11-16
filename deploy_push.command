#!/bin/zsh
# Коммит и пуш изменений для бесплатного хостинга (Render + GitHub Pages)
cd "$(dirname "$0")"
git add -u
git add render.yaml .github/workflows/pages.yml start_all.command deploy_push.command \
        backend/.gitignore backend/apps/initiatives/migrations/0007_*.py
echo "--- Файлы в коммите ---"; git diff --cached --name-only
git commit -m "Free hosting: Render blueprint, GitHub Pages workflow, prod settings (whitenoise, DATABASE_URL)" || true
git push origin main && echo "\n✅ ГОТОВО: изменения отправлены на GitHub" || echo "\n❌ ОШИБКА push"
echo "Окно можно закрыть."
