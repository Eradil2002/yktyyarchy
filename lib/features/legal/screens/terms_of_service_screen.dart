import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Пользовательское соглашение'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Пользовательское соглашение',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Дата последнего обновления: 14 апреля 2026 г.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              '1. Принятие условий',
              'Используя мобильное приложение Добро.КГ (Ыктыярчы.kg), вы соглашаетесь с настоящими Условиями использования.',
            ),

            _buildSection(
              '2. Описание сервиса',
              'Добро.КГ — это платформа, которая:\n\n'
              '• Соединяет волонтеров с НКО в Кыргызстане\n'
              '• Позволяет НКО публиковать мероприятия\n'
              '• Помогает волонтерам находить возможности для помощи\n'
              '• Предоставляет систему рейтингов и достижений',
            ),

            _buildSection(
              '3. Регистрация и аккаунт',
              'Требования:\n\n'
              '• Вам должно быть не менее 14 лет\n'
              '• Предоставьте точную информацию\n'
              '• Один человек — один аккаунт\n'
              '• Вы отвечаете за безопасность пароля',
            ),

            _buildSection(
              '4. Правила использования',
              'Вы ОБЯЗУЕТЕСЬ:\n'
              '• Предоставлять правдивую информацию\n'
              '• Уважительно относиться к другим\n'
              '• Соблюдать законы КР\n'
              '• Приходить на зарегистрированные мероприятия\n\n'
              'Вам ЗАПРЕЩАЕТСЯ:\n'
              '• Создавать фейковые аккаунты\n'
              '• Публиковать ложную информацию\n'
              '• Размещать оскорбительный контент\n'
              '• Спамить или использовать ботов',
            ),

            _buildSection(
              '5. Мероприятия',
              'Для волонтеров:\n'
              '• Регистрация не гарантирует участие\n'
              '• Вы обязаны прийти или отменить регистрацию\n'
              '• Систематические неявки → блокировка\n\n'
              'Для НКО:\n'
              '• Вы отвечаете за точность информации\n'
              '• Обеспечьте безопасные условия\n'
              '• Уведомляйте об изменениях',
            ),

            _buildSection(
              '6. Ограничение ответственности',
              'Платформа предоставляется "как есть":\n\n'
              '• Мы не гарантируем бесперебойную работу\n'
              '• Мы не отвечаем за действия НКО или волонтеров\n'
              '• Мы не отвечаем за несчастные случаи на мероприятиях\n'
              '• Вы участвуете на свой риск',
            ),

            _buildSection(
              '7. Блокировка аккаунта',
              'Мы можем заблокировать ваш аккаунт, если:\n\n'
              '• Вы нарушаете эти Условия\n'
              '• Систематически не приходите на мероприятия\n'
              '• Получаете множество негативных отзывов\n'
              '• Используете платформу в мошеннических целях',
            ),

            _buildSection(
              '8. Контакты',
              'По вопросам, связанным с Условиями использования:\n\n'
              'Email: support@yktyyarchy.kg\n'
              'Адрес: г. Бишкек, Кыргызская Республика',
            ),

            const SizedBox(height: 32),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Закрыть'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFF6B35),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
