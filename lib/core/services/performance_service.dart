/// Performance monitoring service — #90
/// Integrates Firebase Performance Monitoring and Sentry for:
///   • HTTP request traces (response time, success/failure rate)
///   • Custom screen render traces
///   • Error / crash reporting via Sentry
///
/// Setup steps:
///   1. Add to pubspec.yaml:
///        firebase_performance: ^0.9.4
///        sentry_flutter: ^8.3.0
///   2. Set SENTRY_DSN in your .env / flutter --dart-define
///   3. Wrap runApp with SentryFlutter.init() in main.dart (see bottom of file)

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

// ---------------------------------------------------------------------------
// Optional Firebase Performance import (graceful fallback if not available)
// ---------------------------------------------------------------------------
// Uncomment once firebase_performance is added to pubspec.yaml:
// import 'package:firebase_performance/firebase_performance.dart';

// ---------------------------------------------------------------------------
// Optional Sentry import (graceful fallback if not available)
// ---------------------------------------------------------------------------
// Uncomment once sentry_flutter is added to pubspec.yaml:
// import 'package:sentry_flutter/sentry_flutter.dart';

/// Central performance monitoring façade.
///
/// All calls are no-ops when running in debug mode or when the underlying
/// SDK is not initialised — so the app never crashes due to monitoring.
class AppPerformance {
  AppPerformance._();

  static bool _initialized = false;

  // -------------------------------------------------------------------------
  // Initialisation
  // -------------------------------------------------------------------------

  /// Call once from [main] before [runApp].
  static Future<void> init({String? sentryDsn}) async {
    if (_initialized) return;
    _initialized = true;

    // Firebase Performance is initialised automatically via firebase_core —
    // no extra call needed. We can customise collection here if required.
    if (!kDebugMode) {
      // FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
      debugPrint('[Perf] Firebase Performance enabled');
    } else {
      // Disable in debug to avoid polluting production metrics.
      // FirebasePerformance.instance.setPerformanceCollectionEnabled(false);
      debugPrint('[Perf] Firebase Performance disabled in debug mode');
    }

    // Sentry initialisation is done in main.dart via SentryFlutter.init().
    // See [sentryInit] below for the recommended wrapper.
  }

  // -------------------------------------------------------------------------
  // HTTP Traces
  // -------------------------------------------------------------------------

  /// Start a Firebase Performance HTTP metric trace.
  /// Returns an opaque token; pass it to [stopHttpTrace].
  static Object? startHttpTrace(String url, String method) {
    if (kDebugMode) return null;
    try {
      // final metric = FirebasePerformance.instance.newHttpMetric(url, method _toHttpMethod(method));
      // await metric.start();
      // return metric;
      return null; // placeholder until SDK is added
    } catch (_) {
      return null;
    }
  }

  /// Stop a previously started HTTP trace and record the response code.
  static Future<void> stopHttpTrace(
    Object? trace, {
    int? responseCode,
    int? responsePayloadSize,
  }) async {
    if (trace == null || kDebugMode) return;
    try {
      // final metric = trace as HttpMetric;
      // metric.httpResponseCode = responseCode;
      // metric.responsePayloadSize = responsePayloadSize;
      // await metric.stop();
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Custom traces (screen render, heavy computation, etc.)
  // -------------------------------------------------------------------------

  /// Start a named custom trace. Pass the returned token to [stopTrace].
  static Future<Object?> startTrace(String name) async {
    if (kDebugMode) return null;
    try {
      // final trace = FirebasePerformance.instance.newTrace(name);
      // await trace.start();
      // return trace;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> stopTrace(Object? trace) async {
    if (trace == null || kDebugMode) return;
    try {
      // await (trace as Trace).stop();
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Error reporting (Sentry)
  // -------------------------------------------------------------------------

  /// Report a caught exception to Sentry.
  static Future<void> reportError(
    Object exception,
    StackTrace? stackTrace, {
    String? hint,
    Map<String, dynamic>? extras,
  }) async {
    debugPrint('[Perf] Error reported: $exception');
    if (kDebugMode) return;
    try {
      // await Sentry.captureException(
      //   exception,
      //   stackTrace: stackTrace,
      //   hint: hint != null ? Hint.withMap({'message': hint}) : null,
      // );
    } catch (_) {}
  }

  /// Add a breadcrumb (user action trail) to Sentry sessions.
  static void addBreadcrumb(String message, {String? category}) {
    if (kDebugMode) return;
    try {
      // Sentry.addBreadcrumb(Breadcrumb(
      //   message: message,
      //   category: category ?? 'app',
      //   timestamp: DateTime.now().toUtc(),
      // ));
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Sentry initialisation wrapper for main.dart
// ---------------------------------------------------------------------------
///
/// Replace your current [runApp] call in main.dart with:
///
/// ```dart
/// await sentryInit(
///   dsn: const String.fromEnvironment('SENTRY_DSN'),
///   appRunner: () => runApp(VolunteeringApp(dependencies: dependencies)),
/// );
/// ```
///
/// Build with:
///   flutter run --dart-define=SENTRY_DSN=https://xxx@sentry.io/yyy
Future<void> sentryInit({
  required String dsn,
  required Future<void> Function() appRunner,
}) async {
  if (dsn.isEmpty || kDebugMode) {
    // Run without Sentry in debug or when DSN is not configured.
    await appRunner();
    return;
  }

  // Uncomment once sentry_flutter is in pubspec.yaml:
  // await SentryFlutter.init(
  //   (options) {
  //     options.dsn = dsn;
  //     options.tracesSampleRate = 0.2; // 20% of transactions sent
  //     options.profilesSampleRate = 0.1;
  //     options.environment = kReleaseMode ? 'production' : 'staging';
  //     options.release = 'volunteering@1.0.0';
  //   },
  //   appRunner: appRunner,
  // );

  // Fallback until SDK is added:
  await appRunner();
}

// ---------------------------------------------------------------------------
// Dio interceptor — wraps every API request with a Firebase HTTP metric
// ---------------------------------------------------------------------------
/// Add to ApiClient:
///   dio.interceptors.add(PerformanceDioInterceptor());

class PerformanceDioInterceptor extends Interceptor {
  // Uncomment with real implementation once firebase_performance is available:
  //
  // @override
  // void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  //   final trace = AppPerformance.startHttpTrace(options.uri.toString(), options.method);
  //   options.extra['_perf_trace'] = trace;
  //   handler.next(options);
  // }
  //
  // @override
  // void onResponse(Response response, ResponseInterceptorHandler handler) {
  //   AppPerformance.stopHttpTrace(
  //     response.requestOptions.extra['_perf_trace'],
  //     responseCode: response.statusCode,
  //     responsePayloadSize: response.data.toString().length,
  //   );
  //   handler.next(response);
  // }
  //
  // @override
  // void onError(DioException err, ErrorInterceptorHandler handler) {
  //   AppPerformance.stopHttpTrace(
  //     err.requestOptions.extra['_perf_trace'],
  //     responseCode: err.response?.statusCode,
  //   );
  //   AppPerformance.reportError(err, err.stackTrace);
  //   handler.next(err);
  // }
}
