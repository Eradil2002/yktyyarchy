import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/features/auth/screens/auth_widgets.dart';

class WhatsAppLoginScreen extends StatefulWidget {
  const WhatsAppLoginScreen({super.key});

  @override
  State<WhatsAppLoginScreen> createState() => _WhatsAppLoginScreenState();
}

class _WhatsAppLoginScreenState extends State<WhatsAppLoginScreen> {
  final _phoneController = TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isCodeRequested = false;
  bool _isRequestingCode = false;
  bool _isVerifying = false;
  DateTime? _lastRequestTime;
  int _requestCooldown = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _codeControllers.map((c) => c.text).join();

  bool get _canRequestCode => _requestCooldown == 0;

  void _startRequestCooldown() {
    _lastRequestTime = DateTime.now();
    _requestCooldown = 60; // 60 seconds cooldown

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      final elapsed = DateTime.now().difference(_lastRequestTime!).inSeconds;
      setState(() {
        _requestCooldown = 60 - elapsed;
      });

      return _requestCooldown > 0;
    });
  }

  Future<void> _requestCode() async {
    if (!_canRequestCode) {
      _showSnack('Подождите $_requestCooldown сек. перед повторной отправкой', isError: true);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      _showSnack(l10n.whatsappPhoneRequired, isError: true);
      return;
    }

    // Validate phone format
    final phoneRegex = RegExp(r'^[\+]?[0-9]{10,15}$');
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      _showSnack('Неверный формат телефона. Используйте формат: +996555123456', isError: true);
      return;
    }

    setState(() => _isRequestingCode = true);
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.requestWhatsAppOtp(phone);
    if (!mounted) return;
    setState(() {
      _isRequestingCode = false;
      _isCodeRequested = result['success'] == true;
    });

    if (result['success'] == true) {
      _startRequestCooldown();
    }

    _showSnack(
      (result['success'] == true)
          ? (result['data']?['detail']?.toString() ?? l10n.whatsappCodeSent)
          : (result['error']?.toString() ?? l10n.whatsappCodeSendFailed),
      isError: result['success'] != true,
    );
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context)!;
    if (_otpCode.length != 6) {
      _showSnack(l10n.verificationCodeInvalid, isError: true);
      return;
    }
    setState(() => _isVerifying = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithWhatsApp(
      phone: _phoneController.text.trim(),
      code: _otpCode,
    );
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } else {
      _showSnack(authProvider.error ?? l10n.verificationFailed, isError: true);
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    if (isError) {
      AppSnackbar.showError(context, message);
    } else {
      AppSnackbar.showSuccess(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: Text(l10n.whatsappLoginTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.whatsappLoginSubtitle,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            AuthFormField(
              label: l10n.phone,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone_outlined,
              hintText: '+996555123456',
            ),
            const SizedBox(height: 12),
            AuthWhatsAppButton(
              label: _isRequestingCode ? l10n.submitting : l10n.sendCodeWhatsApp,
              onTap: _isRequestingCode ? () {} : _requestCode,
            ),
            if (_isCodeRequested) ...[
              const SizedBox(height: 24),
              Text(
                l10n.enterVerificationCode,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 44,
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(counterText: ''),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              AuthPrimaryButton(
                label: l10n.whatsappVerifyButton,
                isLoading: _isVerifying,
                onTap: _verifyCode,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

