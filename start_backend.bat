@echo off
echo ========================================
echo   Запуск Backend - Ыктыярчы.kg
echo ========================================
echo.

cd backend

echo [1/5] Проверка Python...
python --version
if %errorlevel% neq 0 (
    echo ОШИБКА: Python не установлен!
    pause
    exit /b 1
)
echo.

echo [2/5] Создание виртуального окружения...
if not exist venv (
    python -m venv venv
    echo Виртуальное окружение создано.
) else (
    echo Виртуальное окружение уже существует.
)
echo.

echo [3/5] Активация виртуального окружения...
call venv\Scripts\activate.bat
echo.

echo [4/5] Установка зависимостей...
pip install -r requirements.txt
echo.

echo [5/5] Применение миграций...
python manage.py migrate
echo.

echo ========================================
echo   Создание тестовых данных...
echo ========================================
python manage.py create_test_data
echo.

echo ========================================
echo   Запуск сервера на http://localhost:8000
echo ========================================
echo.
echo Нажмите Ctrl+C для остановки сервера
echo.
python manage.py runserver 0.0.0.0:8000
