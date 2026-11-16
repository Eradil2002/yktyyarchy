import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _index = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final slides = <({String title, String body, IconData icon})>[
      (title: l10n.onboardingWelcome, body: l10n.onboardingStep1, icon: Icons.map_rounded),
      (title: '', body: l10n.onboardingStep2, icon: Icons.how_to_reg_rounded),
      (title: '', body: l10n.onboardingStep3, icon: Icons.notifications_active_rounded),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(l10n.close),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final s = slides[i];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(s.icon, size: 72, color: AppColors.primary),
                        const SizedBox(height: 28),
                        if (s.title.isNotEmpty)
                          Text(
                            s.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        if (s.title.isNotEmpty) const SizedBox(height: 14),
                        Text(
                          s.body,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: s.title.isEmpty ? 17 : 15,
                            fontWeight: s.title.isEmpty ? FontWeight.w600 : FontWeight.w400,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _index == i ? AppColors.primary : AppColors.divider,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_index < slides.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                      );
                    } else {
                      _finish();
                    }
                  },
                  child: Text(
                    _index < slides.length - 1 ? l10n.next : l10n.onboardingGetStarted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
