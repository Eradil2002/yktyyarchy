import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';

class NgoProfileScreen extends StatefulWidget {
  final String organizationId;
  final String initialName;
  final bool initialVerified;
  final double initialRating;

  const NgoProfileScreen({
    super.key,
    required this.organizationId,
    required this.initialName,
    this.initialVerified = false,
    this.initialRating = 0,
  });

  @override
  State<NgoProfileScreen> createState() => _NgoProfileScreenState();
}

class _NgoProfileScreenState extends State<NgoProfileScreen> {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _organization;
  List<Map<String, dynamic>> _events = <Map<String, dynamic>>[];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final responses = await Future.wait([
        _apiClient.dio.get('users/${widget.organizationId}/'),
        _apiClient.dio.get('events/', queryParameters: {'organizer': widget.organizationId}),
      ]);

      final userData = responses[0].data;
      final eventsData = responses[1].data;
      final rawEvents = eventsData is Map<String, dynamic>
          ? (eventsData['results'] as List? ?? <dynamic>[])
          : (eventsData as List? ?? <dynamic>[]);

      setState(() {
        _organization = userData is Map<String, dynamic> ? userData : <String, dynamic>{};
        _events = rawEvents
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      });
    } on DioException catch (e) {
      setState(() {
        _error = e.message ?? 'Network error';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final orgName = _displayName(l10n);
    final description = _description(l10n);
    final logoUrl = _logoUrl();
    final verified = _isVerified();
    final rating = _rating();
    final reviewCount = _reviewCount();
    final email = _email(l10n);
    final phone = _phone();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.ngoProfileTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.loadingError(_error!),
                            style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.small,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _LogoAvatar(name: orgName, logoUrl: logoUrl),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            orgName,
                                            style: GoogleFonts.inter(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        if (verified) const Icon(Icons.verified_rounded, color: AppColors.info),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$rating (${l10n.reviewsCount(reviewCount)})',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _InfoChip(
                                icon: Icons.check_circle_outline_rounded,
                                text: verified ? l10n.verifiedStatus : l10n.notVerifiedStatus,
                              ),
                              _InfoChip(
                                icon: Icons.event_rounded,
                                text: l10n.ngoEventsCount(_events.length),
                              ),
                              _InfoChip(
                                icon: Icons.email_outlined,
                                text: email,
                              ),
                              if (phone != null && phone.isNotEmpty)
                                _InfoChip(
                                  icon: Icons.phone_outlined,
                                  text: phone,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.ngoEventsListTitle,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_events.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          l10n.ngoNoEvents,
                          style: GoogleFonts.inter(color: AppColors.textSecondary),
                        ),
                      )
                    else
                      ..._events.map((event) => _NgoEventTile(event: event)),
                  ],
                ),
    );
  }

  String _displayName(AppLocalizations l10n) {
    final data = _organization;
    if (data == null) return widget.initialName;
    final orgProfile = data['ngo_profile'] as Map<String, dynamic>?;
    final fullName = '${data['first_name'] ?? ''} ${data['last_name'] ?? ''}'.trim();
    final candidate = (orgProfile?['organization_name'] ?? fullName).toString().trim();
    if (candidate.isNotEmpty) return candidate;
    final username = data['username']?.toString().trim() ?? '';
    if (username.isNotEmpty) return username;
    if (widget.initialName.isNotEmpty) return widget.initialName;
    return l10n.ngo;
  }

  String _description(AppLocalizations l10n) {
    final data = _organization;
    if (data == null) return l10n.ngoNoDescription;
    final orgProfile = data['ngo_profile'] as Map<String, dynamic>?;
    return (orgProfile?['description'] ?? data['bio'] ?? l10n.ngoNoDescription).toString();
  }

  String? _logoUrl() {
    final data = _organization;
    if (data == null) return null;
    final orgProfile = data['ngo_profile'] as Map<String, dynamic>?;
    return (orgProfile?['logo'] ?? data['avatar'])?.toString();
  }

  bool _isVerified() {
    final data = _organization;
    if (data == null) return widget.initialVerified;
    return data['is_verified'] == true;
  }

  String _rating() {
    final data = _organization;
    if (data == null) return widget.initialRating.toStringAsFixed(1);
    final value = (data['rating'] ?? widget.initialRating).toDouble();
    return value.toStringAsFixed(1);
  }

  int _reviewCount() {
    final data = _organization;
    if (data == null) return 0;
    return (data['reviews_count'] ?? 0) is int ? data['reviews_count'] as int : int.tryParse('${data['reviews_count']}') ?? 0;
  }

  String _email(AppLocalizations l10n) {
    final data = _organization;
    if (data == null) return l10n.notSpecified;
    return (data['email'] ?? l10n.notSpecified).toString();
  }

  String? _phone() {
    final data = _organization;
    if (data == null) return null;
    final orgProfile = data['ngo_profile'] as Map<String, dynamic>?;
    return (orgProfile?['phone'] ?? data['phone'])?.toString();
  }
}

class _LogoAvatar extends StatelessWidget {
  final String name;
  final String? logoUrl;

  const _LogoAvatar({required this.name, this.logoUrl});

  @override
  Widget build(BuildContext context) {
    final fallback = name.isNotEmpty ? name[0].toUpperCase() : 'N';
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: logoUrl != null && logoUrl!.isNotEmpty
            ? Image.network(
                logoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                  child: Text(
                    fallback,
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
                  ),
                ),
              )
            : Center(
                child: Text(
                  fallback,
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _NgoEventTile extends StatelessWidget {
  final Map<String, dynamic> event;

  const _NgoEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = (event['title'] ?? l10n.noTitle).toString();
    final location = (event['location'] ?? l10n.notSpecified).toString();
    final dateRaw = event['date']?.toString();
    DateTime? parsedDate;
    if (dateRaw != null && dateRaw.isNotEmpty) {
      parsedDate = DateTime.tryParse(dateRaw);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                parsedDate == null ? l10n.notSpecified : DateFormat('d MMM, HH:mm', l10n.localeName).format(parsedDate),
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  location,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
