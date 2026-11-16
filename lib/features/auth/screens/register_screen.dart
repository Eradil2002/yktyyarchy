import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/features/auth/screens/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _orgNameController = TextEditingController();


  bool _obscurePassword = true;
  bool _obscurePasswordConfirm = true;
  String _selectedRole = 'volunteer';
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _orgNameController.dispose();

    super.dispose();
  }

  void _handleRegister() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;

    if (_usernameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _passwordConfirmController.text.trim().isEmpty ||
        _firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        (_selectedRole == 'ngo' && _orgNameController.text.trim().isEmpty)) {
      _showError(l10n.fillAllRequiredFields);
      return;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      _showError('Неверный формат email');
      return;
    }

    // Validate phone format if provided
    if (_phoneController.text.trim().isNotEmpty) {
      final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
      final cleanPhone = _phoneController.text.trim().replaceAll(RegExp(r'[\s\-\(\)]'), '');
      if (!phoneRegex.hasMatch(cleanPhone)) {
        _showError('Неверный формат телефона');
        return;
      }
    }

    if (!_agreedToTerms) {
      _showError(l10n.agreeToTermsRequired);
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      _showError(l10n.passwordsDoNotMatch);
      return;
    }

    if (_passwordController.text.length < 8) {
      _showError(l10n.passwordMinLength);
      return;
    }

    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      passwordConfirm: _passwordConfirmController.text.trim(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      role: _selectedRole,
      orgName: _selectedRole == 'ngo' ? _orgNameController.text.trim() : null,
    );


    if (success && mounted) {
      Navigator.pushReplacementNamed(
        context,
        '/verify-email',
        arguments: _emailController.text.trim(),
      );
    } else if (mounted && authProvider.error != null) {
      _showError(authProvider.error!);
    }
  }

  void _showError(String message) {
    AppSnackbar.showError(context, message);
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
                  Text(l10n.register, style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(l10n.registerSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  Text(
                    l10n.accountType,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleChip(
                          label: l10n.volunteer,
                          icon: Icons.volunteer_activism_rounded,
                          isSelected: _selectedRole == 'volunteer',
                          onTap: () => setState(() => _selectedRole = 'volunteer'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleChip(
                          label: l10n.ngo,
                          icon: Icons.business_rounded,
                          isSelected: _selectedRole == 'ngo',
                          onTap: () => setState(() => _selectedRole = 'ngo'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_selectedRole == 'ngo') ...[
                    AuthFormField(
                      label: l10n.orgNameLabel,
                      controller: _orgNameController,
                      prefixIcon: Icons.business_rounded,
                      hintText: 'ОО "Добрые дела"',
                    ),
                    const SizedBox(height: 16),
                  ],

                  AuthFormField(
                    label: l10n.firstName,
                    controller: _firstNameController,
                    prefixIcon: Icons.person_outline,
                    hintText: 'Айбек',
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    label: l10n.lastName,
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline,
                    hintText: 'Токтогулов',
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    label: l10n.username,
                    controller: _usernameController,
                    prefixIcon: Icons.alternate_email_rounded,
                    hintText: 'aibek_volunteer',
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    label: l10n.email,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    hintText: 'aibek@example.com',
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    label: l10n.phone,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    hintText: '+996555123456',
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    label: l10n.password,
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    hintText: l10n.passwordHint,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    label: l10n.passwordConfirm,
                    controller: _passwordConfirmController,
                    obscureText: _obscurePasswordConfirm,
                    prefixIcon: Icons.lock_outlined,
                    hintText: l10n.repeatPassword,
                    suffixIcon: GestureDetector(
                      onTap: () => setState(() => _obscurePasswordConfirm = !_obscurePasswordConfirm),
                      child: Icon(
                        _obscurePasswordConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreedToTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                              children: [
                                TextSpan(text: l10n.agreeWith),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/terms-of-service');
                                    },
                                    child: Text(
                                      l10n.termsOfService,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(text: l10n.and),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(context, '/privacy-policy');
                                    },
                                    child: Text(
                                      l10n.privacyPolicy,
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  AuthPrimaryButton(
                    label: l10n.registerButton,
                    isLoading: authProvider.isLoading,
                    onTap: _handleRegister,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
                        children: [
                          TextSpan(text: l10n.haveAccount),
                          WidgetSpan(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/login');
                              },
                              child: Text(
                                l10n.loginLink,
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

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primarySurface : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
