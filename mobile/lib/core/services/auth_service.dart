import '../network/api_client.dart';

class AuthService {
  final _client = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _client.dio.post('/api/v1/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    await ApiClient.saveTokens(
      data['accessToken'] as String,
      data['refreshToken'] as String,
    );
    return data;
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await _client.dio.post('/api/v1/auth/register', data: {
      'email': email,
      'password': password,
    });
    final data = response.data as Map<String, dynamic>;
    await ApiClient.saveTokens(
      data['accessToken'] as String,
      data['refreshToken'] as String,
    );
    return data;
  }

  Future<void> logout() async {
    final refreshToken = await ApiClient.getRefreshToken();
    await ApiClient.clearTokens();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _client.dio.post('/api/v1/auth/logout', data: {
          'refreshToken': refreshToken,
        });
      } catch (_) {
        // Sunucu cevap vermese bile yerel oturum zaten kapandı.
      }
    }
  }
}
