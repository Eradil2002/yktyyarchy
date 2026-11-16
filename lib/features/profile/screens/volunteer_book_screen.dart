import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';

class VolunteerBookScreen extends StatefulWidget {
  const VolunteerBookScreen({super.key});

  @override
  State<VolunteerBookScreen> createState() => _VolunteerBookScreenState();
}

class _VolunteerBookScreenState extends State<VolunteerBookScreen> {
  final ApiClient _apiClient = ApiClient();
  final List<_BookEntry> _entries = [];
  bool _isLoading = true;
  String? _error;
  int _totalHours = 0;

  @override
  void initState() {
    super.initState();
    _loadBookData();
  }

  Future<void> _loadBookData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _entries.clear();
      _totalHours = 0;
    });

    try {
      final meResp = await _apiClient.dio.get('users/me/');
      final me = Map<String, dynamic>.from(meResp.data);
      final myId = me['id'];

      final registrationResp = await _apiClient.dio.get('events/my-registrations/');
      final registrations = _extractList(registrationResp.data);

      for (final reg in registrations) {
        final event = Map<String, dynamic>.from(reg['event'] ?? <String, dynamic>{});
        final dateRaw = event['date']?.toString() ?? '';
        final date = DateTime.tryParse(dateRaw);
        if (date == null) continue;

        final status = reg['status']?.toString() ?? '';
        final attended = status == 'attended';
        final hours = (event['hours'] as num?)?.toInt() ?? 0;
        final countedHours = attended ? hours : 0;

        _entries.add(
          _BookEntry(
            date: date,
            title: event['title']?.toString() ?? 'Untitled event',
            hours: countedHours,
            type: _EntryType.event,
            status: status,
          ),
        );
        _totalHours += countedHours;
      }

      final initiativesResp = await _apiClient.dio.get('initiatives/');
      final initiatives = _extractList(initiativesResp.data);

      for (final init in initiatives) {
        if (myId != null && init['creator'] != myId) continue;
        final dateRaw = init['created_at']?.toString() ?? '';
        final date = DateTime.tryParse(dateRaw);
        if (date == null) continue;

        final status = init['status']?.toString() ?? 'pending';
        final approved = status == 'approved';
        final hours = (init['hours'] as num?)?.toInt() ?? 0;
        final countedHours = approved ? hours : 0;

        _entries.add(
          _BookEntry(
            date: date,
            title: init['title']?.toString() ?? 'Untitled initiative',
            hours: countedHours,
            type: _EntryType.initiative,
            status: status,
          ),
        );
        _totalHours += countedHours;
      }

      _entries.sort((a, b) => b.date.compareTo(a.date));
      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data == null) return [];
    if (data is List) return List<Map<String, dynamic>>.from(data);
    if (data is Map && data.containsKey('results')) {
      final results = data['results'];
      if (results is List) return List<Map<String, dynamic>>.from(results);
    }
    return [];
  }

  Future<void> _exportPdf() async {
    final l10n = AppLocalizations.of(context)!;
    final bytes = await _buildPdfBytes(l10n);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'volunteer_book_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  Future<Uint8List> _buildPdfBytes(AppLocalizations l10n) async {
    final doc = pw.Document();
    final dateFmt = DateFormat('dd.MM.yyyy');

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(
            l10n.volunteerBook,
            style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            l10n.confirmedHours(_totalHours),
            style: const pw.TextStyle(fontSize: 14),
          ),
          pw.SizedBox(height: 16),
          pw.TableHelper.fromTextArray(
            headers: [l10n.dateLabel, l10n.activityLabel, l10n.hoursLabel, l10n.statusLabel],
            data: _entries
                .map((e) => [
                      dateFmt.format(e.date),
                      e.title,
                      e.hours.toString(),
                      e.status,
                    ])
                .toList(),
          ),
        ],
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final dateFmt = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.volunteerBook),
        actions: [
          IconButton(
            onPressed: _entries.isEmpty ? null : _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: l10n.exportPdf,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      l10n.loadingError(_error!),
                      style: GoogleFonts.inter(color: AppColors.error),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppShadows.small,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule_rounded, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            l10n.confirmedHours(_totalHours),
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _entries.isEmpty
                          ? Center(
                              child: Text(
                                l10n.noEntriesYet,
                                style: GoogleFonts.inter(color: AppColors.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              itemCount: _entries.length,
                              itemBuilder: (context, index) {
                                final entry = _entries[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: AppShadows.small,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        entry.type == _EntryType.event
                                            ? Icons.event_rounded
                                            : Icons.volunteer_activism_rounded,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.title,
                                              style: GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              dateFmt.format(entry.date),
                                              style: GoogleFonts.inter(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${entry.hours} ${l10n.hours}',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

enum _EntryType { event, initiative }

class _BookEntry {
  final DateTime date;
  final String title;
  final int hours;
  final _EntryType type;
  final String status;

  const _BookEntry({
    required this.date,
    required this.title,
    required this.hours,
    required this.type,
    required this.status,
  });
}
