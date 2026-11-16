/// Web-only deferred route helpers — Code Splitting (#89)
///
/// Flutter Web automatically splits code into separate JS chunks when Dart
/// `deferred as` imports are used.  Each heavy feature screen is imported
/// lazily so the initial JavaScript bundle stays small.
///
/// Usage in onGenerateRoute (see main.dart):
/// ```dart
/// import 'package:volunteering/web_deferred_routes.dart';
///
/// case '/volunteer-book':
///   return buildDeferredRoute(
///     settings: settings,
///     loader: loadVolunteerBookScreen,
///     builder: (ctx) => const VolunteerBookScreen(),
///   );
/// ```

// ignore_for_file: avoid_classes_with_only_static_members

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Deferred library imports
// Each import becomes its own JS chunk in Flutter Web builds.
// On native targets these are loaded synchronously — no overhead.
// ---------------------------------------------------------------------------

import 'package:volunteering/features/profile/screens/volunteer_book_screen.dart'
    deferred as _volunteerBook;

import 'package:volunteering/features/profile/screens/ngo_profile_screen.dart'
    deferred as _ngoProfile;

import 'package:volunteering/features/talents/screens/volunteer_profile_screen.dart'
    deferred as _volunteerProfile;

import 'package:volunteering/features/events/screens/create_event_screen.dart'
    deferred as _createEvent;

import 'package:volunteering/features/initiatives/screens/create_initiative_screen.dart'
    deferred as _createInitiative;

import 'package:volunteering/features/profile/screens/edit_profile_screen.dart'
    deferred as _editProfile;

// ---------------------------------------------------------------------------
// Generic deferred route builder
// ---------------------------------------------------------------------------

/// Builds a [PageRoute] that shows a loading spinner while the deferred
/// library is downloaded, then renders [builder] once it is ready.
Route<T> buildDeferredRoute<T>({
  required RouteSettings settings,
  required Future<void> Function() loader,
  required WidgetBuilder builder,
}) {
  return MaterialPageRoute<T>(
    settings: settings,
    builder: (_) => _DeferredWidget(loader: loader, builder: builder),
  );
}

class _DeferredWidget extends StatefulWidget {
  final Future<void> Function() loader;
  final WidgetBuilder builder;

  const _DeferredWidget({required this.loader, required this.builder});

  @override
  State<_DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<_DeferredWidget> {
  late final Future<void> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (ctx, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Ошибка загрузки: ${snapshot.error}'),
            ),
          );
        }
        return widget.builder(ctx);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Typed loaders — one per deferred library
// ---------------------------------------------------------------------------

Future<void> loadVolunteerBookScreen() => _volunteerBook.loadLibrary();

Future<void> loadNgoProfileScreen() => _ngoProfile.loadLibrary();

Future<void> loadVolunteerProfileScreen() => _volunteerProfile.loadLibrary();

Future<void> loadCreateEventScreen() => _createEvent.loadLibrary();

Future<void> loadCreateInitiativeScreen() => _createInitiative.loadLibrary();

Future<void> loadEditProfileScreen() => _editProfile.loadLibrary();

// ---------------------------------------------------------------------------
// Route builders — drop-in replacements for MaterialPageRoute
// ---------------------------------------------------------------------------

Route<void> volunteerBookRoute(RouteSettings s) => buildDeferredRoute(
      settings: s,
      loader: loadVolunteerBookScreen,
      builder: (_) => _volunteerBook.VolunteerBookScreen(),
    );

Route<void> editProfileRoute(RouteSettings s) => buildDeferredRoute(
      settings: s,
      loader: loadEditProfileScreen,
      builder: (_) => _editProfile.EditProfileScreen(),
    );

Route<void> createEventRoute(RouteSettings s) => buildDeferredRoute(
      settings: s,
      loader: loadCreateEventScreen,
      builder: (_) => _createEvent.CreateEventScreen(),
    );

Route<void> createInitiativeRoute(RouteSettings s) => buildDeferredRoute(
      settings: s,
      loader: loadCreateInitiativeScreen,
      builder: (_) => _createInitiative.CreateInitiativeScreen(),
    );
