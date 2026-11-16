import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/core/providers/events_provider.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/core/widgets/shared_widgets.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  String _selectedCategory = 'ecology';
  EventType _selectedType = EventType.offline;
  int _hours = 4;
  int _spots = 20;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _handleCreate() async {
    final l10n = AppLocalizations.of(context)!;
    if (_titleController.text.trim().isEmpty ||
        _descController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      AppSnackbar.showError(context, l10n.fillAllFields);
      return;
    }

    setState(() => _isLoading = true);

    final eventsProvider = context.read<EventsProvider>();
    final success = await eventsProvider.createEvent({
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'location': _locationController.text.trim(),
      'category': _selectedCategory,
      'type': _selectedType.name,
      'hours': _hours,
      'spots_total': _spots,
      'date': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
    });

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        AppSnackbar.showSuccess(context, l10n.eventCreatedSuccess);
      } else {
        AppSnackbar.showError(context, l10n.error(eventsProvider.error ?? l10n.eventCreateFailed));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.createEventTitle),
        centerTitle: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.close_rounded),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.categories, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: appCategories.map((cat) {
                  final isSelected = _selectedCategory == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? cat.color : cat.bgColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat.icon, color: isSelected ? Colors.white : cat.color, size: 24),
                          const SizedBox(height: 4),
                          Text(localizedCategoryLabel(context, cat),
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: isSelected ? Colors.white : cat.color,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            CreateFormField(
              label: l10n.titleLabel,
              controller: _titleController,
              hintText: l10n.eventTitleHint,
            ),
            const SizedBox(height: 16),
            CreateFormField(
              label: l10n.descriptionLabel,
              controller: _descController,
              hintText: l10n.eventDescriptionHint,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            CreateFormField(
              label: l10n.eventLocation,
              controller: _locationController,
              hintText: l10n.eventLocationHint,
              prefix: Icons.location_on_rounded,
            ),
            const SizedBox(height: 20),
            Text(l10n.format, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Row(
              children: [
                TypeToggle(
                  label: l10n.offline,
                  icon: Icons.location_city_rounded,
                  isSelected: _selectedType == EventType.offline,
                  onTap: () => setState(() => _selectedType = EventType.offline),
                ),
                const SizedBox(width: 10),
                TypeToggle(
                  label: l10n.online,
                  icon: Icons.video_call_rounded,
                  isSelected: _selectedType == EventType.online,
                  onTap: () => setState(() => _selectedType = EventType.online),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: NumberStepper(
                    label: l10n.hoursLabelShort,
                    value: _hours,
                    min: 1,
                    max: 48,
                    onChanged: (v) => setState(() => _hours = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NumberStepper(
                    label: l10n.spotsLabel,
                    value: _spots,
                    min: 1,
                    max: 500,
                    step: 5,
                    onChanged: (v) => setState(() => _spots = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _handleCreate,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppShadows.primaryGlow,
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                        )
                      : Text(l10n.publishEvent,
                          style: GoogleFonts.inter(
                              fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class CreateFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final IconData? prefix;

  const CreateFormField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefix != null ? Icon(prefix, color: AppColors.textSecondary) : null,
          ),
        ),
      ],
    );
  }
}

class TypeToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const TypeToggle({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 52,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

class NumberStepper extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const NumberStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.step = 1,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Text(label,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: value > min ? () => onChanged(value - step) : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: value > min ? AppColors.primary : AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove_rounded, color: Colors.white, size: 18),
                ),
              ),
              Text(
                '$value',
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              GestureDetector(
                onTap: value < max ? () => onChanged(value + step) : null,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: value < max ? AppColors.primary : AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

