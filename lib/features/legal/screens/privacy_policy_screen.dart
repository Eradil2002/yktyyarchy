import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Политика конфиденциальности'),
        backgroundColor: const Color(0xFFFF6B35),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Политика конфиденциальности',
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
              '1. Введение',
              'Добро пожаловать в Добро.КГ (Ыктыярчы.kg) — платформу для волонтеров Кыргызстана. '
              'Мы серьезно относимся к защите вашей конфиденциальности и персональных данных.',
            ),

            _buildSection(
              '2. Какую информацию мы собираем',
              'Мы собираем следующую информацию:\n\n'
              '• Регистрационные данные: имя, email, телефон\n'
              '• Профиль волонтера: фото, навыки, интересы\n'
              '• Геолокация (с вашего разрешения)\n'
              '• Данные использования приложения',
            ),

            _buildSection(
              '3. Как мы используем вашу информацию',
              'Мы используем собранную информацию для:\n\n'
              '• Создания и управления вашим аккаунтом\n'
              '• Подбора подходящих волонтерских мероприятий\n'
              '• Отправки уведомлений о новых событиях\n'
              '• Отображения мероприятий на карте\n'
              '• Формирования вашего рейтинга и достижений',
            ),

            _buildSection(
              '4. Как мы делимся вашей информацией',
              'Публичная информация:\n'
              '• Ваше имя, фото и навыки видны НКО при поиске волонтеров\n\n'
              'С третьими лицами:\n'
              '• Firebase (Google) для аналитики и уведомлений\n'
              '• Google Maps для отображения карты\n\n'
              'Мы НЕ продаем ваши персональные данные третьим лицам.',
            ),

            _buildSection(
              '5. Ваши права',
              'Вы имеете право:\n\n'
              '• Запросить копию ваших данных\n'
              '• Исправить неточную информацию\n'
              '• Удалить свой аккаунт\n'
              '• Отключить геолокацию или уведомления\n'
              '• Экспортировать ваши данные',
            ),

            _buildSection(
              '6. Контакты',
              'Если у вас есть вопросы о нашей Политике конфиденциальности:\n\n'
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
