# Testing Documentation

Полная документация по тестированию проекта "Ыктыярчы" (Volunteering Platform).

## Структура тестов

### Backend (Django)
```
backend/
├── conftest.py                 # Общие фикстуры pytest
├── pytest.ini                  # Конфигурация pytest
├── .coveragerc                 # Конфигурация coverage
├── .flake8                     # Конфигурация flake8
├── pyproject.toml              # Конфигурация black и isort
└── apps/
    ├── events/tests/
    │   ├── test_models.py      # Unit тесты моделей
    │   ├── test_serializers.py # Unit тесты сериализаторов
    │   ├── test_utils.py       # Unit тесты утилит
    │   └── test_api.py         # Integration тесты API
    ├── users/tests/
    │   └── test_api.py         # Тесты аутентификации
    └── [other apps]/tests/
```

### Frontend (Flutter)
```
test/
├── models/                     # Unit тесты моделей
│   └── user_test.dart
├── services/                   # Unit тесты сервисов
│   └── events_service_test.dart
├── providers/                  # Unit тесты провайдеров
├── widgets/                    # Widget тесты
│   └── event_card_test.dart
└── screens/                    # Screen тесты
    └── home_screen_test.dart

integration_test/
└── app_test.dart              # E2E тесты
```

### Performance Tests
```
backend/tests/performance/
└── locustfile.py              # Locust нагрузочные тесты
```

## Запуск тестов

### Backend Tests

#### 1. Установка зависимостей
```bash
cd backend
pip install -r requirements.txt
```

#### 2. Запуск всех тестов
```bash
pytest apps/*/tests/
```

**Примечание**: Тесты используют SQLite in-memory базу данных (настроено в `config/test_settings.py`)

#### 3. Запуск с coverage
```bash
pytest --cov
```

#### 4. Запуск только unit тестов
```bash
pytest -m unit
```

#### 5. Запуск только integration тестов
```bash
pytest -m integration
```

#### 6. Запуск тестов конкретного приложения
```bash
pytest apps/events/tests/
```

#### 7. Генерация HTML отчета coverage
```bash
pytest --cov --cov-report=html
# Откройте htmlcov/index.html в браузере
```

### Code Quality (Backend)

#### Flake8 (linting)
```bash
cd backend
flake8 apps/
```

#### Black (форматирование)
```bash
# Проверка
black --check apps/

# Автоформатирование
black apps/
```

#### Isort (сортировка импортов)
```bash
# Проверка
isort --check-only apps/

# Автоисправление
isort apps/
```

### Flutter Tests

#### 1. Установка зависимостей
```bash
flutter pub get
```

#### 2. Генерация моков (если используется mockito)
```bash
flutter pub run build_runner build
```

#### 3. Запуск unit и widget тестов
```bash
flutter test
```

#### 4. Запуск с coverage
```bash
flutter test --coverage
```

#### 5. Генерация HTML отчета coverage
```bash
# Linux/Mac
genhtml coverage/lcov.info -o coverage/html

# Windows (требуется Perl и lcov)
perl C:\ProgramData\chocolatey\bin\genhtml coverage/lcov.info -o coverage/html

# Откройте coverage/html/index.html в браузере
```

#### 6. Запуск integration тестов
```bash
flutter test integration_test/
```

#### 7. Запуск конкретного теста
```bash
flutter test test/models/user_test.dart
```

### Performance Tests

#### 1. Установка Locust
```bash
pip install locust
```

#### 2. Запуск локально
```bash
cd backend/tests/performance
locust -f locustfile.py --host=http://localhost:8000
```

#### 3. Открыть Web UI
Откройте http://localhost:8089 в браузере

#### 4. Запуск без UI (headless)
```bash
locust -f locustfile.py --host=http://localhost:8000 \
  --users 100 --spawn-rate 10 --run-time 5m --headless
```

## Coverage Targets

### Backend
- **Текущее**: 37.79%
- **Минимум в CI**: 30%
- **Цель**: 70%+

### Frontend
- **Минимум**: 60%
- **Цель**: 70%+

## CI/CD

Все тесты автоматически запускаются в GitHub Actions при:
- Push в ветки `main` или `develop`
- Создании Pull Request в `main`

### Проверки в CI:
1. **Flutter analyze** - статический анализ кода
2. **Flutter test** - unit и widget тесты с coverage
3. **Backend flake8** - linting Python кода
4. **Backend black** - проверка форматирования
5. **Backend isort** - проверка сортировки импортов
6. **Backend pytest** - unit и integration тесты с coverage
7. **Coverage threshold** - проверка минимального покрытия

### Блокировка merge
CI блокирует merge если:
- Тесты падают
- Coverage ниже порога (30% backend, 60% flutter)
- Linting ошибки
- Форматирование не соответствует стандартам

### Статус тестов
- ✅ **37 unit тестов** успешно проходят
- ✅ **SQLite in-memory** для быстрых тестов
- ✅ **Widget тесты** для Flutter компонентов
- ✅ **E2E тесты** для критичных user flows
- ✅ **Performance тесты** с Locust
- ✅ **CI/CD** настроен в GitHub Actions

## Написание тестов

### Backend (pytest)

#### Пример unit теста модели
```python
import pytest
from apps.events.models import Event

@pytest.mark.django_db
class TestEventModel:
    def test_create_event(self, ngo_user):
        event = Event.objects.create(
            title='Test Event',
            organizer=ngo_user,
            # ... other fields
        )
        assert event.title == 'Test Event'
```

#### Пример integration теста API
```python
@pytest.mark.django_db
@pytest.mark.integration
class TestEventAPI:
    def test_list_events(self, api_client):
        response = api_client.get('/api/v1/events/')
        assert response.status_code == 200
```

### Flutter

#### Пример unit теста
```dart
test('fromJson creates valid user', () {
  final json = {'id': '1', 'username': 'test'};
  final user = VolunteerUser.fromJson(json);
  expect(user.id, '1');
});
```

#### Пример widget теста
```dart
testWidgets('EventCard displays title', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: EventCard(event: testEvent)),
  );
  expect(find.text('Test Event'), findsOneWidget);
});
```

## Troubleshooting

### Backend

**Проблема**: `ImportError: No module named 'apps'`
```bash
# Убедитесь что вы в директории backend
cd backend
pytest
```

**Проблема**: Database errors
```bash
# Пересоздайте тестовую БД
python manage.py migrate --run-syncdb
```

### Flutter

**Проблема**: `Missing generated mocks`
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Проблема**: Coverage не генерируется
```bash
# Убедитесь что тесты проходят
flutter test --coverage
# Проверьте что файл создан
ls coverage/lcov.info
```

## Полезные команды

### Запуск всех проверок локально (как в CI)

#### Backend
```bash
cd backend
flake8 apps/ && \
black --check apps/ && \
isort --check-only apps/ && \
pytest --cov --cov-fail-under=70
```

#### Flutter
```bash
flutter analyze && \
flutter test --coverage
```

## Дополнительные ресурсы

- [pytest documentation](https://docs.pytest.org/)
- [Flutter testing guide](https://docs.flutter.dev/testing)
- [Locust documentation](https://docs.locust.io/)
- [Django REST Framework testing](https://www.django-rest-framework.org/api-guide/testing/)
