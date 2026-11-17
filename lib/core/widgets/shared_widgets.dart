import 'package:flutter/material.dart';
import 'package:volunteering/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:volunteering/l10n/app_localizations.dart';

/// Category badge data model
class EventCategory {
  final String id;
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icon;

  const EventCategory({
    required this.id,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icon,
  });
}

final List<EventCategory> appCategories = [
  EventCategory(id: 'ecology', label: 'Ecology', color: AppColors.ecology, bgColor: AppColors.ecologyBg, icon: Icons.eco_rounded),
  EventCategory(id: 'animals', label: 'Animals', color: AppColors.animals, bgColor: AppColors.animalsBg, icon: Icons.pets_rounded),
  EventCategory(id: 'children', label: 'Children', color: AppColors.children, bgColor: AppColors.childrenBg, icon: Icons.child_friendly_rounded),
  EventCategory(id: 'elderly', label: 'Elderly', color: AppColors.elderly, bgColor: AppColors.elderlyBg, icon: Icons.favorite_rounded),
  EventCategory(id: 'it', label: 'IT', color: AppColors.it, bgColor: AppColors.itBg, icon: Icons.laptop_rounded),
  EventCategory(id: 'education', label: 'Education', color: AppColors.education, bgColor: AppColors.educationBg, icon: Icons.school_rounded),
  EventCategory(id: 'health', label: 'Health', color: AppColors.health, bgColor: AppColors.healthBg, icon: Icons.favorite_border_rounded),
  EventCategory(id: 'culture', label: 'Culture', color: AppColors.culture, bgColor: AppColors.cultureBg, icon: Icons.palette_rounded),
];

String localizedCategoryLabel(BuildContext context, EventCategory category) {
  final l10n = AppLocalizations.of(context)!;
  switch (category.id) {
    case 'ecology':
      return l10n.categoryEcology;
    case 'animals':
      return l10n.categoryAnimals;
    case 'children':
      return l10n.categoryChildren;
    case 'elderly':
      return l10n.categoryElderly;
    case 'it':
      return l10n.categoryIT;
    case 'education':
      return l10n.categoryEducation;
    case 'health':
      return l10n.categoryHealth;
    case 'culture':
      return l10n.categoryCulture;
    default:
      return category.label;
  }
}

/// Reusable gradient card
class GradientCard extends StatelessWidget {
  final Gradient gradient;
  final Widget child;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const GradientCard({
    super.key,
    required this.gradient,
    required this.child,
    this.height,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
      ),
      child: child,
    );
  }
}

/// Verified badge chip
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.verified_rounded,
      color: AppColors.info,
      size: 16,
    );
  }
}

/// Star rating display
class StarRating extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double size;
  final bool showCount;

  const StarRating({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.size = 14,
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.accent, size: size),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.inter(
            fontSize: size,
            fontWeight: FontWeight.w600,
            color: AppColors.accent,
          ),
        ),
        if (showCount && reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: GoogleFonts.inter(
              fontSize: size - 1,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Category icon tile
class CategoryTile extends StatelessWidget {
  final EventCategory category;
  final VoidCallback? onTap;
  final bool isSelected;

  const CategoryTile({
    super.key,
    required this.category,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected ? category.color : category.bgColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: isSelected ? AppShadows.small : null,
            ),
            child: Icon(
              category.icon,
              color: isSelected ? Colors.white : category.color,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            localizedCategoryLabel(context, category),
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isSelected ? category.color : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Hours badge
class HoursBadge extends StatelessWidget {
  final int hours;

  const HoursBadge({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule_rounded, size: 14, color: AppColors.primaryDark),
          const SizedBox(width: 4),
          Text(
            '$hours ${AppLocalizations.of(context)!.hours}',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag chip widget
class TagChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? bgColor;

  const TagChip({
    super.key,
    required this.label,
    this.color,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor ?? AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: color ?? AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Shimmer placeholder (simple version without package)
class LoadingPlaceholder extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const LoadingPlaceholder({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: AppColors.divider.withValues(alpha: 0.5),
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.sm),
      ),
    );
  }
}

/// Section header with "see all" link
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final IconData? icon;
  final Color? iconColor;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    this.icon,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (actionText != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle!,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Dots Progress Indicator for onboarding
class OnboardingDots extends StatelessWidget {
  final int current;
  final int count;

  const OnboardingDots({super.key, required this.current, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: i == current ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: i == current ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      }),
    );
  }
}
