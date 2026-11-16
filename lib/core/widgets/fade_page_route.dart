import 'package:flutter/material.dart';

/// Slightly softer route than the default Material transition (UI/UX polish).
class FadePageRoute<T> extends PageRouteBuilder<T> {
  FadePageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 240),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return FadeTransition(opacity: curved, child: child);
          },
        );
}
