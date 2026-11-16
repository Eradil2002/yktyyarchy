# API Documentation - Ыктыярчы.kg

Base URL: `http://localhost:8000/api`

## Authentication

All authenticated endpoints require JWT token in header:
```
Authorization: Bearer {access_token}
```

---

## 🔐 Auth Endpoints

### Register
**POST** `/users/auth/register/`

Create new user account.

**Request:**
```json
{
  "username": "aibek123",
  "email": "aibek@example.com",
  "password": "SecurePass123!",
  "password_confirm": "SecurePass123!",
  "first_name": "Айбек",
  "last_name": "Токтогулов",
  "phone": "+996555123456",
  "role": "volunteer"
}
```

**For NGO registration, add:**
```json
{
  "role": "ngo",
  "org_name": "Эко Кыргызстан"
}
```

**Response:** `201 Created`
```json
{
  "user": {
    "id": 1,
    "username": "aibek123",
    "email": "aibek@example.com",
    "first_name": "Айбек",
    "last_name": "Токтогулов",
    "role": "volunteer",
    "email_verified": false,
    "total_hours": 0,
    "rating": 0.0
  },
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "message": "Регистрация успешна. Проверьте email для подтверждения."
}
```

---

### Login
**POST** `/users/auth/login/`

**Request:**
```json
{
  "username": "aibek123",
  "password": "SecurePass123!"
}
```

**Response:** `200 OK`
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

---

### Refresh Token
**POST** `/users/auth/token/refresh/`

**Request:**
```json
{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Response:** `200 OK`
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

---

### Verify Email
**POST** `/users/auth/verify-email/`
🔒 Requires authentication

**Request:**
```json
{
  "code": "123456"
}
```

**Response:** `200 OK`
```json
{
  "detail": "Email успешно подтвержден.",
  "user": { ... }
}
```

---

### Resend Verification Code
**POST** `/users/auth/resend-verification/`
🔒 Requires authentication

**Response:** `200 OK`
```json
{
  "detail": "Код подтверждения отправлен на email."
}
```

---

### Password Reset Request
**POST** `/users/auth/password-reset/`

**Request:**
```json
{
  "email": "aibek@example.com",
  "reset_url": "https://app.volunteers.kg/reset-password"
}
```

**Response:** `200 OK`
```json
{
  "detail": "Инструкции по восстановлению пароля отправлены на email."
}
```

---

### Password Reset Confirm
**POST** `/users/auth/password-reset-confirm/`

**Request:**
```json
{
  "uid": "MQ",
  "token": "c4v8k3-a1b2c3d4e5f6g7h8i9j0",
  "new_password": "NewSecurePass123!",
  "new_password_confirm": "NewSecurePass123!"
}
```

**Response:** `200 OK`
```json
{
  "detail": "Пароль успешно изменен."
}
```

---

---
 
## 📱 WhatsApp Auth Endpoints
 
### Request WhatsApp OTP
**POST** `/users/auth/whatsapp/request-otp/`
 
Request a 6-digit verification code to be sent via WhatsApp.
 
**Request:**
```json
{
  "phone": "+996555123456"
}
```
 
**Response:** `200 OK`
```json
{
  "detail": "Код отправлен в WhatsApp.",
  "phone": "996555123456",
  "is_new_user": true
}
```
 
---
 
### Verify WhatsApp OTP
**POST** `/users/auth/whatsapp/verify-otp/`
 
Verify the code received via WhatsApp and receive JWT tokens.
 
**Request:**
```json
{
  "phone": "996555123456",
  "code": "123456"
}
```
 
**Response:** `200 OK`
```json
{
  "user": { ... },
  "access": "...",
  "refresh": "...",
  "detail": "Авторизация через WhatsApp успешна."
}
```
 
---
 
## 👤 User Endpoints


### Get My Profile
**GET** `/users/me/`
🔒 Requires authentication

**Response:** `200 OK`
```json
{
  "id": 1,
  "username": "aibek123",
  "email": "aibek@example.com",
  "phone": "+996555123456",
  "first_name": "Айбек",
  "last_name": "Токтогулов",
  "role": "volunteer",
  "avatar": null,
  "location": "Бишкек, Кыргызстан",
  "total_hours": 45,
  "rating": 4.8,
  "is_verified": false,
  "email_verified": true,
  "volunteer_profile": {
    "skills": ["Экология", "Работа с детьми"],
    "bio": "Активный волонтер"
  }
}
```

---

### Update My Profile
**PATCH** `/users/me/`
🔒 Requires authentication

**Request:**
```json
{
  "first_name": "Айбек",
  "last_name": "Токтогулов",
  "location": "Бишкек, Кыргызстан",
  "phone": "+996555999888"
}
```

**Response:** `200 OK`
```json
{
  "id": 1,
  "username": "aibek123",
  ...
}
```

---

### Get Volunteers List (Talent Radar)
**GET** `/users/volunteers/`
🔒 Requires authentication

Returns list of volunteers sorted by rating and hours.

**Response:** `200 OK`
```json
{
  "count": 3,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "username": "aibek_volunteer",
      "first_name": "Айбек",
      "last_name": "Токтогулов",
      "rating": 4.8,
      "total_hours": 45,
      "location": "Бишкек, Кыргызстан",
      "volunteer_profile": {
        "skills": ["Экология", "Работа с детьми"],
        "bio": "Активный волонтер"
      }
    }
  ]
}
```

---

### Get User Profile
**GET** `/users/{id}/`

**Response:** `200 OK`
```json
{
  "id": 1,
  "username": "aibek123",
  ...
}
```

---

## 📅 Events Endpoints

### List Events
**GET** `/events/`

**Query Parameters:**
- `category` - Filter by category
- `type` - Filter by type (online/offline)
- `status` - Filter by status (open/closed/completed)
- `is_urgent` - Filter urgent events (true/false)

**Response:** `200 OK`
```json
{
  "count": 4,
  "results": [
    {
      "id": 1,
      "title": "Уборка парка Ата-Тюрк",
      "description": "Приглашаем всех желающих...",
      "organizer": {
        "id": 4,
        "username": "eco_kg",
        "first_name": "Эко"
      },
      "category": "ecology",
      "date": "2026-04-16T10:00:00Z",
      "location": "Парк Ата-Тюрк, Бишкек",
      "latitude": 42.8746,
      "longitude": 74.5698,
      "type": "offline",
      "hours": 4,
      "spots_total": 50,
      "spots_booked": 2,
      "status": "open",
      "is_urgent": false
    }
  ]
}
```

---

### Create Event
**POST** `/events/`
🔒 Requires authentication (NGO only)

**Request:**
```json
{
  "title": "Уборка парка",
  "description": "Описание мероприятия",
  "category": "ecology",
  "date": "2026-04-20T10:00:00Z",
  "end_time": "2026-04-20T14:00:00Z",
  "location": "Парк Ата-Тюрк, Бишкек",
  "latitude": 42.8746,
  "longitude": 74.5698,
  "type": "offline",
  "hours": 4,
  "spots_total": 50,
  "is_urgent": false
}
```

**Response:** `201 Created`

---

## 🌟 Initiatives Endpoints

### List Initiatives
**GET** `/initiatives/`

**Query Parameters:**
- `status` - Filter by status (pending/approved/rejected)
- `category` - Filter by category

**Response:** `200 OK`

---

### Create Initiative
**POST** `/initiatives/`
🔒 Requires authentication

**Request:**
```json
{
  "title": "Уборка берега реки",
  "description": "Убрали мусор на берегу",
  "category": "ecology",
  "location": "Река Чу",
  "latitude": 42.8333,
  "longitude": 75.1167,
  "hours_claimed": 3,
  "before_photos": ["url1", "url2"],
  "after_photos": ["url1", "url2"]
}
```

**Response:** `201 Created`

---

## ⭐ Reviews Endpoints

### List Reviews
**GET** `/reviews/`

**Response:** `200 OK`

---

### Create Review
**POST** `/reviews/`
🔒 Requires authentication

**Request:**
```json
{
  "target_user": 1,
  "event": 1,
  "rating": 5,
  "text": "Отличный волонтер!"
}
```

**Response:** `201 Created`

---

## Error Responses

### 400 Bad Request
```json
{
  "field_name": ["Error message"]
}
```

### 401 Unauthorized
```json
{
  "detail": "Authentication credentials were not provided."
}
```

### 404 Not Found
```json
{
  "detail": "Not found."
}
```

### 500 Internal Server Error
```json
{
  "detail": "Internal server error."
}
```
