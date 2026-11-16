import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:volunteering/features/auth/screens/reset_password_screen.dart';

void main() {
  testWidgets('shows error for a link without uid/token', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResetPasswordScreen(uid: '', token: '')));
    expect(find.textContaining('недействительна'), findsOneWidget);
  });

  testWidgets('validates matching passwords before calling the API', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ResetPasswordScreen(uid: 'MQ', token: 'abc')));
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Password123!');
    await tester.enterText(fields.at(1), 'Different123!');
    await tester.tap(find.text('Сохранить пароль'));
    await tester.pump();
    expect(find.text('Пароли не совпадают'), findsOneWidget);
  });
}
