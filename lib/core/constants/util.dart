import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Same backend as the React web app (production default).
const String apiUrl =
    'https://final-year-project-2-entrance-exam.onrender.com/api';

const String publicApiOrigin =
    'https://final-year-project-2-entrance-exam.onrender.com';

/// Override for local backend during development.
/// const String apiUrl = 'http://10.0.2.2:5000/api'; // Android emulator → localhost:5000

const secureStorage = FlutterSecureStorage();

Future<String?> getAccessToken() => secureStorage.read(key: 'accessToken');

Future<void> saveAccessToken(String token) =>
    secureStorage.write(key: 'accessToken', value: token);

Future<void> clearAccessToken() => secureStorage.delete(key: 'accessToken');

String resolveMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http')) return path;
  final normalized = path.startsWith('/') ? path : '/$path';
  return '$publicApiOrigin$normalized';
}
