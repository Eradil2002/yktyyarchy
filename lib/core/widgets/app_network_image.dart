import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:volunteering/core/theme/app_theme.dart';

/// Unified lazy-loading network image widget.
///
/// Wraps [CachedNetworkImage] with a consistent placeholder, error state,
/// and optional fade-in animation. Use this widget everywhere you display
/// remote images so that caching / lazy-loading behaviour is centralised.
class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = _buildImage();

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _defaultError();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      // Trigger loading only when the widget enters the viewport.
      // CachedNetworkImage handles this automatically via a visible
      // check, but we still get lazy caching on first view.
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 150),
      placeholder: (context, url) =>
          placeholder ?? _defaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _defaultError(),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.divider.withValues(alpha: 0.4),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  Widget _defaultError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.divider.withValues(alpha: 0.3),
      child: const Icon(
        Icons.broken_image_rounded,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }
}

/// Circular avatar variant backed by [AppNetworkImage].
class AppAvatarImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? fallbackIcon;

  const AppAvatarImage({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: AppNetworkImage(
        imageUrl: imageUrl,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorWidget: Container(
          width: radius * 2,
          height: radius * 2,
          color: AppColors.primarySurface,
          child: fallbackIcon ??
              Icon(Icons.person_rounded,
                  color: AppColors.primary, size: radius),
        ),
      ),
    );
  }
}
