# Быстрый старт Backend

## Шаг 1: Создание виртуального окружения

```bash
# Windows
cd backend
python -m venv venv
venv\Scripts\activate

# Linux/Mac
cd backend
python3 -m venv venv
source venv/bin/activate
```

## Шаг 2: Установка зависимостей

```bash
pip install -r requirements.txt
```

## Шаг 3: Настройка .env

```bash
# Windows
copy .env.example .env

# Linux/Mac
cp .env.example .env
```

## Шаг 4: Миграции базы данных

```bash
python manage.py makemigrations
python manage.py migrate
```

## Шаг 5: Создание тестовых данных

```bash
python manage.py create_test_data
```

## Шаг 6: Запуск сервера

```bash
python manage.py runserver
```

Сервер запустится на `http://localhost:8000`

## Проверка работы API

Откройте в браузере или Postman:
- `http://localhost:8000/api/users/auth/login/` - должна открыться страница DRF
- `http://localhost:8000/admin/` - админ-панель Django

## Тестовые аккаунты

**Волонтеры:**
- Username: `aibek_volunteer`, Password: `test1234`
- Username: `gulnara_volunteer`, Password: `test1234`
- Username: `bektur_volunteer`, Password: `test1234`

**НКО:**
- Username: `eco_kg`, Password: `test1234`
- Username: `help_children`, Password: `test1234`

## Тестирование API через curl

### Вход
```bash
curl -X POST http://localhost:8000/api/users/auth/login/ \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"aibek_volunteer\",\"password\":\"test1234\"}"
```

### Получение профиля
```bash
curl -X GET http://localhost:8000/api/users/me/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

## Возможные проблемы

### Django не установлен
```bash
pip install Django==5.0.3
```

### Ошибка миграций
```bash
python manage.py migrate --run-syncdb
```

### Порт занят
```bash
python manage.py runserver 8001
```
