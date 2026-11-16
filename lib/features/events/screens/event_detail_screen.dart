import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:volunteering/core/providers/events_provider.dart';
import 'package:volunteering/core/services/user_lists_service.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/core/widgets/shared_widgets.dart';
import 'package:volunteering/core/widgets/app_network_image.dart';

class EventDetailScreen extends StatefulWidget {
  final VolunteerEvent event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _isRegistered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isRegistered = widget.event.isRegistered;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<UserListsService>().recordEventView(widget.event.id);
    });
  }

  Future<void> _shareEvent(AppLocalizations l10n) async {
    final detail =
        '${widget.event.location}\n${DateFormat('d MMMM yyyy, HH:mm', l10n.localeName).format(widget.event.date)}';
    await SharePlus.instance.share(
      ShareParams(
        text: l10n.shareEventBody(widget.event.title, detail),
        subject: l10n.shareEventSubject(widget.event.title),
      ),
    );
  }

  EventCategory get _category => appCategories.firstWhere(
      (c) => c.id == widget.event.categoryId,
      orElse: () => appCategories[0]);

  List<Color> get _gradientColors {
    return [_category.color, _category.color.withValues(alpha: 0.7)];
  }

  void _handleRegister() async {
    if (_isRegistered) return;
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      AppSnackbar.showError(context, l10n.loginToRegister);
      return;
    }

    setState(() => _isLoading = true);
    final eventsProvider = Provider.of<EventsProvider>(context, listen: false);
    final success = await eventsProvider.registerForEvent(int.parse(widget.event.id));

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        setState(() => _isRegistered = true);
        AppSnackbar.showSuccess(context, l10n.registeredSuccess);
      } else {
        AppSnackbar.showError(context, l10n.registerFailed);
      }
    }
  }

  void _openNgoProfile() {
    if (widget.event.organizerId.isEmpty) return;
    Navigator.pushNamed(
      context,
      '/ngo-profile',
      arguments: <String, dynamic>{
        'organizationId': widget.event.organizerId,
        'initialName': widget.event.organizerName,
        'initialVerified': widget.event.organizerVerified,
        'initialRating': widget.event.organizerRating,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = context.watch<AuthProvider>();
    final lists = context.watch<UserListsService>();
    final isFavorite = lists.isFavorite(widget.event.id);
    final currentUserId = authProvider.currentUser?.id;
    final isAuthor = currentUserId != null && currentUserId == widget.event.organizerId;
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _gradientColors.first,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: () => lists.toggleFavorite(widget.event.id),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFavorite ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: widget.event.imageUrl != null && widget.event.imageUrl!.trim().isNotEmpty
                  ? AppNetworkImage(
                      imageUrl: widget.event.imageUrl!.trim(),
                      fit: BoxFit.cover,
                      placeholder: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _gradientColors,
                          ),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 36,
                            height: 36,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: _buildHeroFallback(),
                    )
                  : Image.asset(
                      'assets/images/${widget.event.categoryId}_cover.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildHeroFallback(),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _openNgoProfile,
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _category.bgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_category.icon, color: _category.color, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.event.organizerName,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (widget.event.organizerVerified) ...[
                                        const SizedBox(width: 6),
                                        const VerifiedBadge(),
                                      ],
                                    ],
                                  ),
                                  if (widget.event.organizerRating > 0)
                                    StarRating(
                                      rating: widget.event.organizerRating,
                                      reviewCount: 89,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        widget.event.title,
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      MetaItem(
                        icon: Icons.calendar_month_rounded,
                        title: l10n.dateAndTime,
                        value: DateFormat('d MMMM yyyy, HH:mm', l10n.localeName).format(widget.event.date),
                      ),
                      const SizedBox(height: 16),
                      MetaItem(
                        icon: Icons.location_on_rounded,
                        title: l10n.eventLocation,
                        value: widget.event.location,
                        trailing: GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(context, '/map'),
                          child: Text(
                            l10n.showOnMap,
                            style: GoogleFonts.inter(
                                fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      MetaItem(
                        icon: Icons.group_rounded,
                        title: l10n.participants,
                        value: l10n.participantsOf(widget.event.spotsBooked, widget.event.spotsTotal),
                      ),
                      const SizedBox(height: 16),
                      MetaItem(
                        icon: Icons.schedule_rounded,
                        title: l10n.volunteerHoursLabel,
                        value: l10n.hoursWillBeCredited(widget.event.hours),
                      ),
                      const SizedBox(height: 24),
                      Text(l10n.descriptionLabel,
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      Text(
                        widget.event.description,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary, height: 1.6),
                      ),
                      const SizedBox(height: 24),
                      if (widget.event.requirements.isNotEmpty) ...[
                        Text(l10n.requirementsLabel,
                            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.event.requirements.map((r) => TagChip(label: r)).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _category.bgColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(_category.icon, color: _category.color, size: 28),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.categories,
                                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                                Text(localizedCategoryLabel(context, _category),
                                    style: GoogleFonts.inter(
                                        fontSize: 16, fontWeight: FontWeight.w700, color: _category.color)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _shareEvent(l10n),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Icon(Icons.share_rounded, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: isAuthor ? _openManage : (_isRegistered ? null : _handleRegister),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: (isAuthor || _isRegistered)
                        ? null
                        : const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    color: (isAuthor || _isRegistered) ? AppColors.primarySurface : null,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: (isAuthor || _isRegistered) ? [] : AppShadows.primaryGlow,
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                (isAuthor || _isRegistered)
                                    ? Icons.check_circle_rounded
                                    : Icons.how_to_reg_rounded,
                                color: (isAuthor || _isRegistered) ? AppColors.primary : Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isAuthor ? l10n.manage : (_isRegistered ? l10n.registered : l10n.register),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: (isAuthor || _isRegistered) ? AppColors.primary : Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openManage() {
    Navigator.pushNamed(context, '/my-events');
  }

  Widget _buildHeroFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
        ),
      ),
      child: Center(
        child: Icon(_category.icon, color: Colors.white.withValues(alpha: 0.25), size: 120),
      ),
    );
  }
}

class MetaItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;

  const MetaItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.inter(
                      fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              if (trailing != null) ...[const SizedBox(height: 2), trailing!],
            ],
          ),
        ),
      ],
    );
  }
}

