part of 'home_screen.dart';

// ignore_for_file: invalid_use_of_protected_member

extension _HomeFiltersSection on _HomeScreenState {
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _FilterBottomSheet(
        filterType: _filterType,
        filterUrgentOnly: _filterUrgentOnly,
        onApply: (type, urgent) {
          setState(() {
            _filterType = type;
            _filterUrgentOnly = urgent;
          });
          _loadEvents();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildQuickFilters(AppLocalizations l10n) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _QuickFilterChip(
            icon: Icons.location_on_rounded,
            label: l10n.nearby,
            color: const Color(0xFF667eea),
            onTap: () {
              setState(() {
                _filterNearby = !_filterNearby;
              });
              _loadEvents();
            },
            isActive: _filterNearby,
          ),
          const SizedBox(width: 8),
          _QuickFilterChip(
            icon: Icons.today_rounded,
            label: l10n.today,
            color: AppColors.primary,
            onTap: () {
              setState(() {
                _filterToday = !_filterToday;
                if (_filterToday) {
                  _filterUrgentOnly = false;
                  _filterNearby = false;
                }
                _selectedCategory = null;
              });
              _loadEvents();
            },
            isActive: _filterToday,
          ),
          const SizedBox(width: 8),
          _QuickFilterChip(
            icon: Icons.local_fire_department_rounded,
            label: l10n.urgent,
            color: AppColors.error,
            onTap: () {
              setState(() {
                _filterUrgentOnly = !_filterUrgentOnly;
                if (_filterUrgentOnly) {
                  _filterToday = false;
                  _filterNearby = false;
                }
              });
              _loadEvents();
            },
            isActive: _filterUrgentOnly,
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(AppLocalizations l10n) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.categories,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 4,
            childAspectRatio: 0.9,
            children: appCategories.map((cat) {
              return CategoryTile(
                category: cat,
                isSelected: _selectedCategory == cat.id,
                onTap: () {
                  setState(() {
                    _selectedCategory = _selectedCategory == cat.id ? null : cat.id;
                  });
                  _loadEvents();
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isActive;

  const _QuickFilterChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? color : color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: isActive ? 1.0 : 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? Colors.white : color, size: 16),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isActive ? Colors.white : color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  final String? filterType;
  final bool filterUrgentOnly;
  final void Function(String? type, bool urgent) onApply;

  const _FilterBottomSheet({
    required this.filterType,
    required this.filterUrgentOnly,
    required this.onApply,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String? _type;
  late bool _urgent;

  @override
  void initState() {
    super.initState();
    _type = widget.filterType;
    _urgent = widget.filterUrgentOnly;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              l10n.filters,
              style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.filtersSubtitle,
              style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Text(l10n.format, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _FilterOption(
                  icon: Icons.public_rounded,
                  label: l10n.all,
                  isSelected: _type == null,
                  onTap: () => setState(() => _type = null),
                ),
                const SizedBox(width: 8),
                _FilterOption(
                  icon: Icons.location_city_rounded,
                  label: l10n.offline,
                  isSelected: _type == 'offline',
                  onTap: () => setState(() => _type = 'offline'),
                ),
                const SizedBox(width: 8),
                _FilterOption(
                  icon: Icons.video_call_rounded,
                  label: l10n.online,
                  isSelected: _type == 'online',
                  onTap: () => setState(() => _type = 'online'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => setState(() => _urgent = !_urgent),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _urgent ? AppColors.error.withValues(alpha: 0.08) : AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _urgent ? AppColors.error : AppColors.divider,
                    width: _urgent ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      color: _urgent ? AppColors.error : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.urgentOnly,
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            l10n.urgentOnlySubtitle,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _urgent,
                      onChanged: (v) => setState(() => _urgent = v),
                      activeThumbColor: AppColors.error,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _type = null;
                        _urgent = false;
                      });
                    },
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Center(
                        child: Text(
                          l10n.reset,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () => widget.onApply(_type, _urgent),
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppShadows.primaryGlow,
                      ),
                      child: Center(
                        child: Text(
                          l10n.apply,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.icon,
    required this.label,
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
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
