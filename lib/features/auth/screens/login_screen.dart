import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/features/auth/screens/auth_widgets.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showError(l10n.fillAllFields);
      return;
    }

    // Basic username validation (alphanumeric, underscore, min 3 chars)
    if (username.length < 3) {
      _showError('Имя пользователя должно содержать минимум 3 символа');
      return;
    }

    final success = await authProvider.login(username, password);

    if (success && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } else if (mounted && authProvider.error != null) {
      _showError(authProvider.error!);
    }
  }

  void _showError(String message) {
    AppSnackbar.showError(context, message);
  }

  Future<void> _handleForgotPassword() async {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final emailController = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.forgotPassword),
          content: TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: l10n.email,
              hintText: 'name@example.com',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, emailController.text.trim()),
              child: Text(l10n.send),
            ),
          ],
        );
      },
    );

    emailController.dispose();
    if (!mounted || email == null || email.isEmpty) return;

    final isValidEmail = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!isValidEmail) {
      _showError('${l10n.email}: name@example.com');
      return;
    }

    final result = await authProvider.requestPasswordReset(email);
    if (!mounted) return;

    final isSuccess = result['success'] == true;
    final message = (isSuccess ? result['message'] : result['error'])?.toString() ??
        (isSuccess ? l10n.done : l10n.error('Unknown error'));

    if (isSuccess) {
      AppSnackbar.showSuccess(context, message);
    } else {
      AppSnackbar.showError(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(l10n.login, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(l10n.loginSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  AuthFormField(
                    label: l10n.usernameOrEmail,
                    controller: _usernameController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.person_outlined,
                    hintText: 'aibek_volunteer',
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    label: l10n.password,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    hintText: '••••••••',
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _handleForgotPassword,
                      child: Text(
                        l10n.forgotPassword,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  AuthPrimaryButton(
                    label: l10n.loginButton,
                    isLoading: authProvider.isLoading,
                    onTap: _handleLogin,
                  ),
                  const SizedBox(height: 12),
                  AuthWhatsAppButton(
                    label: l10n.whatsappAuthButton,
                    onTap: () => Navigator.pushNamed(context, '/login-whatsapp'),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                        children: [
                          TextSpan(text: l10n.noAccount),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/register');
                              },
                              child: Text(
                                l10n.registerLink,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
