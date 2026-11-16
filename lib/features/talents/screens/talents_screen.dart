import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volunteering/core/providers/auth_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/data/models/models.dart';
import 'package:volunteering/core/providers/events_provider.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/l10n/app_localizations.dart';

// ============================================================
// TALENT RADAR SCREEN
// ============================================================

class TalentsScreen extends StatefulWidget {
  const TalentsScreen({super.key});

  @override
  State<TalentsScreen> createState() => _TalentsScreenState();
}

class _TalentsScreenState extends State<TalentsScreen> {
  double _minRating = 4.0;
  double _radiusKm = 30;
  String? _selectedCity;
  String? _selectedSkill;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  List<VolunteerUser> _volunteers = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
    _loadVolunteers();
  }

  void _onSearchChanged() => _loadVolunteers();

  Future<void> _loadVolunteers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = ApiClient();
      final response = await apiClient.dio.get(
        'users/volunteers/',
        queryParameters: {
          'min_rating': _minRating,
          if (_selectedCity != null) 'city': _selectedCity,
          if (_selectedSkill != null) 'skill': _selectedSkill,
          'radius_km': _radiusKm.round(),
          if (_searchCtrl.text.trim().isNotEmpty) 'search': _searchCtrl.text.trim(),
        },
      );

      if (!mounted) return;

      final rawData = response.data;
      final List dataList = rawData is Map ? (rawData['results'] ?? []) : rawData;
      setState(() {
        _volunteers = dataList.map((json) => VolunteerUser.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = context.watch<AuthProvider>().currentUser;
    final role = user?.role ?? '';
    final isOrganizer = role == 'ngo' || role == 'organization' || role == 'organizer';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header AppBar
          SliverAppBar(
            pinned: true,
            expandedHeight: 140,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1a237e), Color(0xFF311b92)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.radar_rounded, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              l10n.talentRadarTitle,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.talentRadarSubtitle,
                          style: GoogleFonts.inter(
                              fontSize: 13, color: Colors.white.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Filters
          SliverToBoxAdapter(child: _buildFilters(l10n)),

          // Results header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _isLoading 
                  ? const SizedBox() 
                  : Text(
                      l10n.talentFoundCount(_volunteers.length),
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
            ),
          ),

          // Volunteers list
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: Center(
                child: Text(_error!, style: GoogleFonts.inter(color: AppColors.error)),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _VolunteerCard(
                    volunteer: _volunteers[index],
                    rank: index + 1,
                    canInvite: isOrganizer,
                  ),
                  childCount: _volunteers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(AppLocalizations l10n) {
    final cities = [l10n.bishkek, l10n.cityOsh, l10n.cityKarakol, l10n.cityNaryn, l10n.cityJalalAbad];
    final skills = [
      'IT',
      l10n.skillMedicine,
      l10n.skillPedagogy,
      l10n.categoryEcology,
      l10n.skillConstruction,
      l10n.skillPhotography,
    ];
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          TextField(
            controller: _searchCtrl,
            style: GoogleFonts.inter(fontSize: 15),
            decoration: InputDecoration(
              hintText: l10n.talentSearchHint,
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 14),

          // Min rating
          Row(
            children: [
              Text('${l10n.talentMinRating} ',
                  style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
              ...List.generate(5, (i) {
                final v = i + 1.0;
                return GestureDetector(
                  onTap: () {
                    setState(() => _minRating = v);
                    _loadVolunteers();
                  },
                  child: Icon(
                    _minRating >= v ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.accent,
                    size: 26,
                  ),
                );
              }),
              Text(' ${_minRating.toStringAsFixed(0)}+',
                  style: GoogleFonts.inter(
                      fontSize: 14, color: AppColors.accent, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 14),

          // City chips
          Text(l10n.talentCity,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: cities.map((city) {
              final isSelected = _selectedCity == city;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCity = isSelected ? null : city;
                  });
                  _loadVolunteers();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.divider),
                  ),
                  child: Text(
                    city,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Skills
          Text(l10n.talentSkill,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: skills.map((skill) {
              final isSelected = _selectedSkill == skill;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSkill = isSelected ? null : skill;
                  });
                  _loadVolunteers();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF311b92) : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: isSelected ? const Color(0xFF311b92) : AppColors.divider),
                  ),
                  child: Text(
                    skill,
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(l10n.talentRadius(_radiusKm.round()),
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500)),
          Slider(
            value: _radiusKm,
            min: 5,
            max: 100,
            divisions: 19,
            label: l10n.talentRadius(_radiusKm.round()),
            onChanged: (value) {
              setState(() => _radiusKm = value);
            },
            onChangeEnd: (_) => _loadVolunteers(),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _minRating = 4.0;
                  _radiusKm = 30;
                  _selectedCity = null;
                  _selectedSkill = null;
                  _searchCtrl.clear();
                });
                _loadVolunteers();
              },
              child: Text(l10n.talentResetFilters),
            ),
          ),
        ],
      ),
    );
  }
}

class _VolunteerCard extends StatelessWidget {
  final VolunteerUser volunteer;
  final int rank;
  final bool canInvite;

  const _VolunteerCard({required this.volunteer, required this.rank, required this.canInvite});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/volunteer-profile',
          arguments: volunteer,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppShadows.small,
          border: rank <= 3
              ? Border.all(color: _rankColor(rank).withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _rankColor(rank).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _rankColor(rank)),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
            ),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        volunteer.name,
                        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (volunteer.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, color: AppColors.info, size: 16),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text(volunteer.location,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    const Icon(Icons.schedule_rounded,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 2),
                    Text('${volunteer.totalHours} ${l10n.hours}',
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 8),
                if (volunteer.skills.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: volunteer.skills.take(3).map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(s,
                              style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500)),
                        )).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Rating + Invite
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: AppColors.accent, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      volunteer.rating.toStringAsFixed(1),
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.accent),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (canInvite)
                GestureDetector(
                  onTap: () => _showInviteDialog(context, volunteer),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1a237e), Color(0xFF311b92)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      l10n.invite,
                      style: GoogleFonts.inter(
                          fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.textSecondary;
  }

  void _showInviteDialog(BuildContext context, VolunteerUser volunteer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InviteBottomSheet(volunteer: volunteer),
    );
  }
}

class _InviteBottomSheet extends StatefulWidget {
  final VolunteerUser volunteer;

  const _InviteBottomSheet({required this.volunteer});

  @override
  State<_InviteBottomSheet> createState() => _InviteBottomSheetState();
}

class _InviteBottomSheetState extends State<_InviteBottomSheet> {
  List<VolunteerEvent> _events = [];
  bool _isLoadingEvents = true;
  String? _selectedEventId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final eventsProvider = context.read<EventsProvider>();
    // Load all events and filter those where organizer is current user
    // In a real app, we'd have a specific /events/my-organized/ endpoint
    await eventsProvider.loadEvents();
    if (!mounted) return;

    final userId = context.read<AuthProvider>().currentUser?.id;
    setState(() {
      _events = eventsProvider.events
          .where((e) => e.organizerId == userId)
          .toList();
      _isLoadingEvents = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.invitePerson(widget.volunteer.name.split(' ').first),
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.chooseEventForInvite,
            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Events to invite to
          if (_isLoadingEvents)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ))
          else if (_events.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                l10n.noEventsForInvite,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              ),
            )
          else
            ..._events.map((event) {
              final isSelected = _selectedEventId == event.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedEventId = event.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySurface : AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.divider,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20)
                      else
                        const Icon(Icons.radio_button_unchecked_rounded,
                            color: AppColors.divider, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event.title,
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppColors.primary : AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(event.location,
                                style: GoogleFonts.inter(
                                    fontSize: 12, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),

          // Send button
          GestureDetector(
            onTap: _selectedEventId == null
                ? null
                : () async {
                    setState(() => _isSending = true);
                    try {
                      final apiClient = ApiClient();
                      final event = _events.firstWhere((e) => e.id == _selectedEventId);
                      
                      await apiClient.dio.post('notifications/', data: {
                        'user': widget.volunteer.id,
                        'type': 'invitation',
                        'title': l10n.inviteProjectTitle,
                        'body': l10n.inviteProjectBody(event.title),
                        'data': {
                          'event_id': event.id,
                            'organizer_name': context.read<AuthProvider>().currentUser?.firstName ?? l10n.orgShort,
                        }
                      });

                      if (mounted) {
                        Navigator.pop(context);
                        AppSnackbar.showSuccess(context, l10n.inviteSentSuccess);
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() => _isSending = false);
                        AppSnackbar.showError(context, l10n.inviteSendError('$e'));
                      }
                    }
                  },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: _selectedEventId != null
                    ? const LinearGradient(
                        colors: [Color(0xFF1a237e), Color(0xFF311b92)])
                    : null,
                color: _selectedEventId == null ? AppColors.divider : null,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _isSending
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      )
                    : Text(
                        l10n.sendInvite,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _selectedEventId != null ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
