import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dio + token: hem `SharedPreferences` hem de bellekteki access token aynı anda güncellenir.
/// Çıkışta bellek sıfırlanır; interceptor yalnızca bu kaynaklardan okur (stale Bearer riski azalır).
class ApiClient {
  static const String _baseUrl = 'http://localhost:8080';
  static const String _tokenKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  /// Interceptor ve istekler için anlık access token (çıkışta mutlaka null).
  static String? _accessTokenMem;

  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final path = options.uri.path;
        final isAuthCall = path.startsWith('/api/v1/auth');

        if (isAuthCall) {
          // Login/register vb. isteklere asla eski Bearer gitmesin
          options.headers.remove('Authorization');
          return handler.next(options);
        }

        var token = _accessTokenMem;
        if (token == null || token.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          token = prefs.getString(_tokenKey);
          if (token != null && token.isNotEmpty) {
            _accessTokenMem = token;
          }
        }

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        } else {
          options.headers.remove('Authorization');
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        return handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  static Future<void> saveTokens(String access, String refresh) async {
    _accessTokenMem = access;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  static Future<void> clearTokens() async {
    _accessTokenMem = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }
}
