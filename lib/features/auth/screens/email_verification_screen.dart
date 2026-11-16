import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/features/auth/screens/auth_widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isVerifying = false;
  bool _isResending = false;
  DateTime? _lastResendTime;
  int _resendCooldown = 0;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  bool get _canResend => _resendCooldown == 0;

  void _startResendCooldown() {
    _lastResendTime = DateTime.now();
    _resendCooldown = 60; // 60 seconds cooldown

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;

      final elapsed = DateTime.now().difference(_lastResendTime!).inSeconds;
      setState(() {
        _resendCooldown = 60 - elapsed;
      });

      return _resendCooldown > 0;
    });
  }

  Future<void> _verify() async {
    final l10n = AppLocalizations.of(context)!;
    if (_code.length != 6) {
      _showSnack(l10n.verificationCodeInvalid, isError: true);
      return;
    }
    setState(() => _isVerifying = true);
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.verifyEmail(_code);
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (result['success'] == true) {
      _showSnack(l10n.emailVerifiedSuccess);
      Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
    } else {
      _showSnack(result['error']?.toString() ?? l10n.verificationFailed, isError: true);
    }
  }

  Future<void> _resend() async {
    if (!_canResend) {
      _showSnack('Подождите $_resendCooldown сек. перед повторной отправкой', isError: true);
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isResending = true);
    final authProvider = context.read<AuthProvider>();
    final result = await authProvider.resendVerificationCode();
    if (!mounted) return;
    setState(() => _isResending = false);

    if (result['success'] == true) {
      _startResendCooldown();
    }

    _showSnack(
      (result['success'] == true)
          ? (result['message']?.toString() ?? l10n.verificationCodeResent)
          : (result['error']?.toString() ?? l10n.verificationResendFailed),
      isError: result['success'] != true,
    );
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
    final emailArg = ModalRoute.of(context)?.settings.arguments;
    final email = emailArg is String ? emailArg : '';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(title: Text(l10n.emailVerificationTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.emailVerificationSubtitle,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(email, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 44,
                  child: TextField(
                    controller: _controllers[index],
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
            const SizedBox(height: 28),
            AuthPrimaryButton(
              label: l10n.verifyEmailButton,
              isLoading: _isVerifying,
              onTap: _verify,
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: _isResending ? null : _resend,
              child: _isResending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.resendCode),
            ),
          ],
        ),
      ),
    );
  }
}

