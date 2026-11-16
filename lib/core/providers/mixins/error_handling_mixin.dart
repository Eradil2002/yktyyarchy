import 'package:flutter/foundation.dart';
import 'package:volunteering/core/api/api_client.dart';

mixin ErrorHandlingMixin on ChangeNotifier {
  String mapError(Object error, {String fallback = 'Something went wrong. Please try again.'}) {
    return ApiClient.formatError(error, fallback: fallback);
  }
}
