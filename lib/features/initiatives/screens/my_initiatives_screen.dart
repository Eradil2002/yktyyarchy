import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/core/providers/initiatives_provider.dart';
import 'package:volunteering/features/notifications/screens/notifications_widgets.dart';

class MyInitiativesScreen extends StatefulWidget {
  const MyInitiativesScreen({super.key});

  @override
  State<MyInitiativesScreen> createState() => _MyInitiativesScreenState();
}

class _MyInitiativesScreenState extends State<MyInitiativesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InitiativesProvider>().loadMyInitiatives();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<InitiativesProvider>();

    if (provider.isLoading && provider.initiatives.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.myInitiatives)),
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myInitiatives)),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          if (provider.loadedFromCache)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.offlineScheduleLoaded,
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.initiatives.length,
              itemBuilder: (context, index) {
                final init = provider.initiatives[index];
                return InitiativeCard(initiative: init);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/create-initiative');
          if (context.mounted) {
            context.read<InitiativesProvider>().loadMyInitiatives();
          }
        },
        backgroundColor: AppColors.primary,
        label: Text(l10n.newInitiative, style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white)),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }
}

