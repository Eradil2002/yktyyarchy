import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:volunteering/l10n/app_localizations.dart';
import 'package:volunteering/core/utils/app_snackbar.dart';
import 'package:volunteering/core/api/api_client.dart';
import 'package:volunteering/features/notifications/screens/notifications_widgets.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  double _avgRating = 0.0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      final apiClient = ApiClient();
      final userResponse = await apiClient.dio.get('users/me/');
      final userId = userResponse.data['id'];

      final response = await apiClient.dio.get('reviews/?target=$userId');
      if (mounted) {
        final reviews = List<Map<String, dynamic>>.from(response.data);
        double avg = 0.0;
        if (reviews.isNotEmpty) {
          avg = reviews.fold(0.0, (sum, r) => sum + (r['rating'] ?? 0)) / reviews.length;
        }
        setState(() {
          _reviews = reviews;
          _avgRating = avg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppSnackbar.showError(context, l10n.loadingReviewsError('$e'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reviews)),
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviews)),
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        _avgRating.toStringAsFixed(1),
                        style: GoogleFonts.inter(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < _avgRating.round() ? Icons.star_rounded : Icons.star_border_rounded,
                            color: AppColors.accent,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.reviewsCount(_reviews.length),
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [5, 4, 3, 2, 1].map((star) {
                        final count = _reviews.where((r) => (r['rating'] ?? 0).round() == star).length;
                        final fraction = _reviews.isEmpty ? 0.0 : count / _reviews.length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Text('$star', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: fraction,
                                    backgroundColor: AppColors.divider,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                                    minHeight: 8,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text('$count', style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => ReviewCard(review: _reviews[index]),
                childCount: _reviews.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

