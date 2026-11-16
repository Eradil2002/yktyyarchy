part of 'home_screen.dart';

// ignore_for_file: invalid_use_of_protected_member

extension _HomeHeaderSection on _HomeScreenState {
  Widget _buildHeader(VolunteerUser? userData, AppLocalizations l10n) {
    final firstName = userData?.firstName.isNotEmpty == true ? userData!.firstName : l10n.guest;
    final location = userData?.location.isNotEmpty == true ? userData!.location : l10n.notSpecified;
    final role = (userData?.role ?? '').toLowerCase();
    final isNgo = role == 'ngo' || role == 'organization' || role == 'organizer';
    final totalHours = userData?.totalHours ?? 0;
    final badgesCount = userData?.badgesCount ?? 0;
    final rating = userData?.rating ?? 0.0;
    final projectsCount = userData?.eventsCount ?? 0;
    final volunteersCount = userData?.reviewCount ?? 0;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _showLocationPicker,
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.expand_more_rounded, color: Colors.white70, size: 18),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/notifications'),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👋', style: TextStyle(fontSize: 26)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.hello(firstName),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.schedule_rounded, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                isNgo ? l10n.projectsCountShort(projectsCount) : '$totalHours ${l10n.hours}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.emoji_events_rounded, color: Colors.white70, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                isNgo
                                    ? l10n.volunteersCountShort(volunteersCount)
                                    : '$badgesCount ${l10n.badges}',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isNgo ? '⭐ ${l10n.organizationRating}' : '⭐ ${l10n.rating}',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.inter(color: AppColors.textPrimary, fontSize: 15),
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: l10n.searchPlaceholder,
                          hintStyle: GoogleFonts.inter(color: AppColors.textHint, fontSize: 14),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: AppColors.textHint.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 16),
                        ),
                      ),
                    GestureDetector(
                      onTap: _showFilterSheet,
                      child: Container(
                        width: 36,
                        height: 36,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: (_filterType != null || _filterUrgentOnly)
                              ? AppColors.primary
                              : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: (_filterType != null || _filterUrgentOnly)
                              ? Colors.white
                              : AppColors.primary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
