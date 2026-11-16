import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/core/widgets/shared_widgets.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:dio/dio.dart';

class CreateInitiativeScreen extends StatefulWidget {
  const CreateInitiativeScreen({super.key});

  @override
  State<CreateInitiativeScreen> createState() => _CreateInitiativeScreenState();
}

class _CreateInitiativeScreenState extends State<CreateInitiativeScreen>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  String _selectedCategory = 'ecology';
  Position? _currentPosition;
  final List<_EvidencePhoto> _beforePhotos = <_EvidencePhoto>[];
  final List<_EvidencePhoto> _afterPhotos = <_EvidencePhoto>[];
  bool _liveCamera = false;
  bool _isSubmitting = false;
  String _moderationStatus = 'draft';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      AppSnackbar.showError(context, l10n.fillAllFields);
      return;
    }
    if (_beforePhotos.isEmpty || _afterPhotos.isEmpty) {
      AppSnackbar.showError(context, l10n.initiativeAddBeforeAfterPhotos);
      return;
    }
    if (_currentPosition == null) {
      AppSnackbar.showError(context, l10n.initiativeNeedGps);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiClient = ApiClient();
      final formData = FormData.fromMap({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'category': _selectedCategory,
        'latitude': _currentPosition!.latitude,
        'longitude': _currentPosition!.longitude,
        'live_camera_enabled': _liveCamera,
        'moderation_status': 'pending',
        'before_meta': _beforePhotos.map((p) => p.toJson()).toList(),
        'after_meta': _afterPhotos.map((p) => p.toJson()).toList(),
      });
      for (final photo in _beforePhotos) {
        formData.files.add(
          MapEntry(
            'before_photos',
            await MultipartFile.fromFile(
              photo.file.path,
              filename: photo.file.name,
            ),
          ),
        );
      }
      for (final photo in _afterPhotos) {
        formData.files.add(
          MapEntry(
            'after_photos',
            await MultipartFile.fromFile(
              photo.file.path,
              filename: photo.file.name,
            ),
          ),
        );
      }

      await apiClient.dio.post(
        '/initiatives/',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      if (mounted) {
        setState(() {
          _moderationStatus = 'pending';
        });
        AppSnackbar.showSuccess(context, l10n.initiativeSuccess);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _moderationStatus = 'draft';
        });
        AppSnackbar.showError(context, l10n.error('$e'));
      }
      return;
    }
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _resolveLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    if (mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  Future<void> _pickEvidencePhoto({required bool isBefore}) async {
    ImageSource source = ImageSource.camera;
    if (!_liveCamera) {
      source = await _pickSourceBottomSheet() ?? ImageSource.camera;
    }
    final file = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    final position = _currentPosition;
    final evidence = _EvidencePhoto(
      file: file,
      latitude: position?.latitude,
      longitude: position?.longitude,
      capturedAt: DateTime.now(),
      source: source.name,
    );
    if (mounted) {
      setState(() {
        final target = isBefore ? _beforePhotos : _afterPhotos;
        if (target.length < 3) {
          target.add(evidence);
        }
      });
    }
  }

  Future<ImageSource?> _pickSourceBottomSheet() async {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text(l10n.camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text(l10n.gallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(l10n.createInitiativeTitle),
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
            // Info banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.initiativeInfoBanner,
                      style: GoogleFonts.inter(
                          fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category
            Text(l10n.categories, style: _labelStyle()),
            const SizedBox(height: 10),
            SizedBox(
              height: 76,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: appCategories.map((cat) {
                  final isSelected = _selectedCategory == cat.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? cat.color : cat.bgColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat.icon, color: isSelected ? Colors.white : cat.color, size: 22),
                          const SizedBox(height: 4),
                          Text(localizedCategoryLabel(context, cat),
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: isSelected ? Colors.white : cat.color,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(l10n.titleLabel, style: _labelStyle()),
            const SizedBox(height: 8),
            TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(hintText: l10n.initiativeTitleHint),
            ),
            const SizedBox(height: 16),

            // Description
            Text(l10n.descriptionLabel, style: _labelStyle()),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: InputDecoration(hintText: l10n.initiativeDescriptionHint),
            ),
            const SizedBox(height: 20),

            // Location
            Text(l10n.eventLocation, style: _labelStyle()),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _resolveLocation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 52,
                decoration: BoxDecoration(
                  color: _currentPosition != null ? AppColors.primarySurface : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _currentPosition != null ? AppColors.primary : AppColors.divider,
                    width: _currentPosition != null ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(
                      _currentPosition != null ? Icons.check_circle_rounded : Icons.gps_fixed_rounded,
                      color: _currentPosition != null ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _currentPosition != null
                          ? l10n.initiativeGpsCaptured(
                              _currentPosition!.latitude.toStringAsFixed(5),
                              _currentPosition!.longitude.toStringAsFixed(5),
                            )
                          : l10n.initiativeResolveGps,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: _currentPosition != null ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: _currentPosition != null ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Live Camera Toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _liveCamera ? const Color(0xFFE8F5E9) : AppColors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _liveCamera ? AppColors.primary : AppColors.divider,
                  width: _liveCamera ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  ScaleTransition(
                    scale: _liveCamera ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _liveCamera ? AppColors.error : AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.radio_button_on_rounded,
                        color: _liveCamera ? Colors.white : AppColors.textSecondary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.liveCamera,
                            style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Text(
                          l10n.liveCameraDescription,
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _liveCamera,
                    onChanged: (v) => setState(() => _liveCamera = v),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gpp_good_rounded, color: AppColors.info),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _moderationStatus == 'pending'
                          ? l10n.initiativeModerationPending
                          : l10n.initiativeModerationDraft,
                      style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Before photos
            Text(l10n.initiativeBeforePhotos(_beforePhotos.length), style: _labelStyle()),
            const SizedBox(height: 8),
            PhotoGrid(
              count: _beforePhotos.length,
              maxCount: 3,
              color: AppColors.info,
              onAdd: () => _pickEvidencePhoto(isBefore: true),
            ),
            const SizedBox(height: 20),

            // After photos
            Text(l10n.initiativeAfterPhotos(_afterPhotos.length), style: _labelStyle()),
            const SizedBox(height: 8),
            PhotoGrid(
              count: _afterPhotos.length,
              maxCount: 3,
              color: AppColors.primary,
              onAdd: () => _pickEvidencePhoto(isBefore: false),
            ),
            const SizedBox(height: 32),

            // Submit
            GestureDetector(
              onTap: _handleSubmit,
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
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.submitting,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.volunteer_activism_rounded, color: Colors.white),
                            const SizedBox(width: 10),
                            Text(l10n.sendForReview,
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  TextStyle _labelStyle() => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
}

class PhotoGrid extends StatelessWidget {
  final int count;
  final int maxCount;
  final Color color;
  final VoidCallback onAdd;

  const PhotoGrid({
    super.key,
    required this.count,
    required this.maxCount,
    required this.color,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: List.generate(maxCount, (i) {
        final hasPhoto = i < count;
        return Expanded(
          child: GestureDetector(
            onTap: hasPhoto ? null : onAdd,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 80,
              margin: EdgeInsets.only(right: i < maxCount - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: hasPhoto ? color.withValues(alpha: 0.12) : AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: hasPhoto ? color : AppColors.divider,
                  style: hasPhoto ? BorderStyle.solid : BorderStyle.none,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasPhoto ? Icons.check_circle_rounded : Icons.add_a_photo_rounded,
                    color: hasPhoto ? color : AppColors.textSecondary,
                    size: hasPhoto ? 28 : 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasPhoto ? l10n.added : l10n.photoNumber(i + 1),
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: hasPhoto ? color : AppColors.textSecondary,
                      fontWeight: hasPhoto ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EvidencePhoto {
  final XFile file;
  final double? latitude;
  final double? longitude;
  final DateTime capturedAt;
  final String source;

  const _EvidencePhoto({
    required this.file,
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    required this.source,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'captured_at': capturedAt.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'source': source,
    };
  }
}
