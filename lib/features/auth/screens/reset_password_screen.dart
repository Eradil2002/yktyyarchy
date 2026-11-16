import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/core/services/auth_service.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/features/auth/screens/auth_widgets.dart';

/// Opened from the password-reset email link: /#/reset-password?uid=..&token=..
class ResetPasswordScreen extends StatefulWidget {
  final String uid;
  final String token;

  const ResetPasswordScreen({super.key, required this.uid, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _auth = AuthService(ApiClient());
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  bool _done = false;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_password.text.length < 8) {
      setState(() => _error = 'Пароль должен быть не короче 8 символов');
      return;
    }
    if (_password.text != _confirm.text) {
      setState(() => _error = 'Пароли не совпадают');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    final result = await _auth.confirmPasswordReset(
      uid: widget.uid,
      token: widget.token,
      password: _password.text,
      passwordConfirm: _confirm.text,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _done = result['success'] == true;
      _error = _done ? null : (result['error']?.toString() ?? 'Ссылка недействительна или устарела');
    });
  }

  @override
  Widget build(BuildContext context) {
    final invalidLink = widget.uid.isEmpty || widget.token.isEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('Новый пароль')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: invalidLink
                  ? _message('Ссылка для сброса пароля недействительна.')
                  : _done
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _message('Пароль изменён. Войдите с новым паролем.'),
                            const SizedBox(height: 24),
                            AuthPrimaryButton(
                              label: 'Войти',
                              isLoading: false,
                              onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AuthFormField(
                              label: 'Новый пароль',
                              controller: _password,
                              obscureText: _obscure,
                              prefixIcon: Icons.lock_outline,
                              hintText: 'Минимум 8 символов',
                              suffixIcon: IconButton(
                                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                            const SizedBox(height: 16),
                            AuthFormField(
                              label: 'Повторите пароль',
                              controller: _confirm,
                              obscureText: _obscure,
                              prefixIcon: Icons.lock_outline,
                              hintText: 'Ещё раз',
                            ),
                            if (_error != null) ...[
                              const SizedBox(height: 12),
                              Text(_error!, style: GoogleFonts.inter(color: AppColors.error, fontSize: 13)),
                            ],
                            const SizedBox(height: 24),
                            AuthPrimaryButton(label: 'Сохранить пароль', isLoading: _loading, onTap: _submit),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _message(String text) => Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
      );
}
