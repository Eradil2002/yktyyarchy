# Backend API - Ыктыярчы.kg

Django REST API для платформы волонтеров Кыргызстана.

## Установка и запуск

### 1. Установка зависимостей

```bash
cd backend
pip install -r requirements.txt
```

### 2. Настройка окружения

Создайте файл `.env` на основе `.env.example`:

```bash
cp .env.example .env
```

Отредактируйте `.env` и укажите свои настройки.

### 3. Применение миграций

```bash
python manage.py makemigrations
python manage.py migrate
```

### 4. Создание тестовых данных

```bash
python manage.py create_test_data
```

Это создаст тестовых пользователей, мероприятия, инициативы и отзывы.

### 5. Создание суперпользователя (опционально)

```bash
python manage.py createsuperuser
```

### 6. Запуск сервера

```bash
python manage.py runserver
```

API будет доступен по адресу: `http://localhost:8000`

## API Endpoints

### Авторизация

#### Регистрация
```
POST /api/users/auth/register/
```

**Body:**
```json
{
  "username": "test_user",
  "email": "test@example.com",
  "password": "securepass123",
  "password_confirm": "securepass123",
  "first_name": "Айбек",
  "last_name": "Токтогулов",
  "phone": "+996555123456",
  "role": "volunteer",
  "org_name": "Название НКО (только для role=ngo)"
}
```

**Response:**
```json
{
  "user": { ... },
  "access": "jwt_access_token",
  "refresh": "jwt_refresh_token",
  "message": "Регистрация успешна. Проверьте email для подтверждения."
}
```

#### Вход
```
POST /api/users/auth/login/
```

**Body:**
```json
{
  "username": "test_user",
  "password": "securepass123"
}
```

**Response:**
```json
{
  "access": "jwt_access_token",
  "refresh": "jwt_refresh_token"
}
```

#### Обновление токена
```
POST /api/users/auth/token/refresh/
```

**Body:**
```json
{
  "refresh": "jwt_refresh_token"
}
```

#### Подтверждение Email
```
POST /api/users/auth/verify-email/
Headers: Authorization: Bearer {access_token}
```

**Body:**
```json
{
  "code": "123456"
}
```

#### Повторная отправка кода подтверждения
```
POST /api/users/auth/resend-verification/
Headers: Authorization: Bearer {access_token}
```

#### Запрос восстановления пароля
```
POST /api/users/auth/password-reset/
```

**Body:**
```json
{
  "email": "test@example.com",
  "reset_url": "https://app.volunteers.kg/reset-password"
}
```

#### Подтверждение нового пароля
```
POST /api/users/auth/password-reset-confirm/
```

**Body:**
```json
{
  "uid": "encoded_user_id",
  "token": "reset_token",
  "new_password": "newpass123",
  "new_password_confirm": "newpass123"
}
```

### Пользователи

#### Получить свой профиль
```
GET /api/users/me/
Headers: Authorization: Bearer {access_token}
```

#### Обновить свой профиль
```
PATCH /api/users/me/
Headers: Authorization: Bearer {access_token}
```

**Body:**
```json
{
  "first_name": "Новое имя",
  "location": "Бишкек, Кыргызстан",
  "phone": "+996555123456"
}
```

#### Список волонтеров (Радар талантов)
```
GET /api/users/volunteers/
Headers: Authorization: Bearer {access_token}
```

#### Профиль пользователя
```
GET /api/users/{id}/
```

### Мероприятия

```
GET /api/events/ - Список мероприятий
POST /api/events/ - Создать мероприятие (только для НКО)
GET /api/events/{id}/ - Детали мероприятия
PATCH /api/events/{id}/ - Обновить мероприятие
DELETE /api/events/{id}/ - Удалить мероприятие
```

### Инициативы

```
GET /api/initiatives/ - Список инициатив
POST /api/initiatives/ - Создать инициативу
GET /api/initiatives/{id}/ - Детали инициативы
PATCH /api/initiatives/{id}/ - Обновить инициативу
```

### Отзывы

```
GET /api/reviews/ - Список отзывов
POST /api/reviews/ - Создать отзыв
GET /api/reviews/{id}/ - Детали отзыва
```

## Тестовые аккаунты

После выполнения `python manage.py create_test_data`:

**Волонтеры:**
- `aibek_volunteer` / `test1234`
- `gulnara_volunteer` / `test1234`
- `bektur_volunteer` / `test1234`

**НКО:**
- `eco_kg` / `test1234`
- `help_children` / `test1234`

## Структура проекта

```
backend/
├── apps/
│   ├── users/          # Пользователи и авторизация
│   ├── events/         # Мероприятия
│   ├── initiatives/    # Инициативы (Добрые дела)
│   └── reviews/        # Отзывы и рейтинги
├── config/             # Настройки Django
├── manage.py
└── requirements.txt
```

## Email настройки

Для разработки используется `console.EmailBackend` - письма выводятся в консоль.

Для продакшена настройте SMTP в `.env`:

```env
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@gmail.com
EMAIL_HOST_PASSWORD=your-app-password
DEFAULT_FROM_EMAIL=noreply@volunteers.kg
```

## Следующие шаги

- [ ] Добавить WhatsApp Business API для OTP
- [ ] Интеграция с S3 для загрузки фото
- [ ] PostGIS для геолокационных запросов
- [ ] Push-уведомления (Firebase)
- [ ] Rate limiting
- [ ] Админ-панель для модерации
- [ ] Redis для кэширования
