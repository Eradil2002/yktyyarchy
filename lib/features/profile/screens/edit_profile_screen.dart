import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _locationController;
  late TextEditingController _bioController;
  List<String> _skills = [];
  bool _isSaving = false;
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedAvatar;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    final userData = context.read<AuthProvider>().currentUser;
    _firstNameController = TextEditingController(text: userData?.firstName ?? '');
    _lastNameController = TextEditingController(text: userData?.lastName ?? '');
    _locationController = TextEditingController(text: userData?.location ?? '');
    _bioController = TextEditingController(text: userData?.bio ?? '');
    _skills = List<String>.from(userData?.skills ?? const <String>[]);
    _avatarUrl = userData?.avatarUrl;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(l10n.newSkill, style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(hintText: l10n.skillExampleHint),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel, style: GoogleFonts.inter(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() => _skills.add(controller.text));
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(100, 44)),
              child: Text(l10n.add),
            ),
          ],
        );
      },
    );
  }

  void _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final authProvider = context.read<AuthProvider>();
    final usersService = authProvider.usersService;
    final VolunteerUser? updatedUser = await usersService.updateProfileMultipartModel(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      location: _locationController.text.trim(),
      bio: _bioController.text.trim(),
      skills: _skills,
      avatarPath: _selectedAvatar?.path,
    );
    if (mounted) {
      setState(() => _isSaving = false);
      if (updatedUser != null) {
        await authProvider.loadCurrentUser();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.profileUpdatedSuccess,
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        navigator.pop();
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.savingError,
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickAvatar() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(l10n.camera, style: GoogleFonts.inter()),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.gallery, style: GoogleFonts.inter()),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final file = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    if (mounted) {
      setState(() => _selectedAvatar = file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.editProfile),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isSaving ? null : _handleSave,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    )
                  : Text(
                      l10n.save,
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar Section
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1),
                      boxShadow: AppShadows.medium,
                    ),
                    child: ClipOval(
                      child: _selectedAvatar != null
                          ? Image.file(
                              File(_selectedAvatar!.path),
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            )
                          : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                              ? Image.network(
                                  _avatarUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Center(
                                    child: Icon(Icons.person_rounded, size: 70, color: AppColors.primary),
                                  ),
                                )
                              : const Center(
                                  child: Icon(Icons.person_rounded, size: 70, color: AppColors.primary),
                                )),
                    ),
                  ),
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: AppShadows.small,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(l10n.mainInformation.toUpperCase()),
                  const SizedBox(height: 16),
                  _buildField(l10n.firstNameLabel, _firstNameController, Icons.person_outline_rounded),
                  const SizedBox(height: 20),
                  _buildField(l10n.lastNameLabel, _lastNameController, Icons.person_outline_rounded),
                  const SizedBox(height: 20),
                  _buildField(l10n.locationLabel, _locationController, Icons.location_on_outlined),
                  const SizedBox(height: 20),
                  _buildField(l10n.aboutMeLabel, _bioController, Icons.info_outline_rounded, maxLines: 3),
                  const SizedBox(height: 32),

                  _buildSectionHeader(l10n.skillsSection.toUpperCase()),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: [
                      ..._skills.map((skill) => _SkillChip(
                            label: skill,
                            onDelete: () => setState(() => _skills.remove(skill)),
                          )),
                      _AddSkillButton(onTap: _addSkill),
                    ],
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary.withValues(alpha: 0.6),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            hintText: l10n.enterField(label),
          ),
        ),
      ],
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  final VoidCallback onDelete;

  const _SkillChip({required this.label, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _AddSkillButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddSkillButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary, width: 1.5, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Text(
              l10n.add,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
