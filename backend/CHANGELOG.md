# Changelog - Backend API

## 2026-04-13

### ✅ Реализована система авторизации

#### Добавлено:
- **Email подтверждение при регистрации**
  - Генерация 6-значного кода
  - Отправка кода на email
  - Проверка кода с истечением через 24 часа
  - Повторная отправка кода

- **Восстановление пароля**
  - Запрос сброса пароля через email
  - Генерация токена сброса
  - Подтверждение нового пароля
  - Токен действителен 24 часа

- **Улучшенная регистрация**
  - Валидация пароля (Django password validators)
  - Подтверждение пароля
  - Автоматическая отправка кода подтверждения
  - Создание профилей (Volunteer/NGO) при регистрации

#### Новые endpoints:
- `POST /api/users/auth/verify-email/` - Подтверждение email
- `POST /api/users/auth/resend-verification/` - Повторная отправка кода
- `POST /api/users/auth/password-reset/` - Запрос сброса пароля
- `POST /api/users/auth/password-reset-confirm/` - Подтверждение нового пароля

#### Обновлены модели:
- `CustomUser`:
  - `email_verified` - статус подтверждения email
  - `email_verification_code` - код подтверждения
  - `email_verification_code_created` - время создания кода
  - `is_email_verification_code_valid()` - метод проверки валидности

#### Новые файлы:
- `apps/users/utils.py` - утилиты для отправки email
- `apps/users/management/commands/create_test_data.py` - команда для создания тестовых данных
- `backend/README.md` - документация по установке и использованию
- `backend/API_DOCS.md` - полная документация API
- `backend/QUICKSTART.md` - быстрый старт

#### Настройки:
- Email backend конфигурация в `settings.py`
- Переменные окружения в `.env.example`
- Console backend для разработки (письма в консоль)
- SMTP настройки для продакшена

#### Тестовые данные:
Команда `python manage.py create_test_data` создает:
- 3 волонтера (aibek_volunteer, gulnara_volunteer, bektur_volunteer)
- 2 НКО (eco_kg, help_children)
- 4 мероприятия (уборка парка, онлайн-тренинг, помощь детям, посадка деревьев)
- 3 инициативы (уборка реки, помощь соседке, ремонт площадки)
- 4 отзыва

Все тестовые аккаунты имеют пароль: `test1234`

### Следующие шаги:
- [ ] Установить зависимости и запустить сервер
- [ ] Протестировать все endpoints
- [ ] Добавить WhatsApp Business API для OTP
- [ ] Интеграция S3 для загрузки фото
- [ ] Реализовать Events API (CRUD)
- [ ] Реализовать Initiatives API (CRUD)
- [ ] Реализовать Reviews API (CRUD)
