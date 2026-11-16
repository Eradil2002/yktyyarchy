import 'package:flutter_test/flutter_test.dart';
import 'package:volunteering/core/api/api_client.dart';

void main() {
  test('baseUrl is versioned and ends with a slash', () {
    final url = ApiClient.baseUrl;
    expect(url.endsWith('/'), isTrue);
    expect(url.contains('/api/v1/'), isTrue);
  });
}
