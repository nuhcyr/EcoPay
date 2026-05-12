import '../network/api_client.dart';

class ReportService {
  final _client = ApiClient();

  Future<Map<String, dynamic>> getMySummary() async {
    final response = await _client.dio.get('/api/v1/reports/me/summary');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyWeekly() async {
    final response = await _client.dio.get('/api/v1/reports/me/weekly');
    return response.data as Map<String, dynamic>;
  }
}

class UserService {
  final _client = ApiClient();

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _client.dio.get('/api/v1/users/me');
    return response.data as Map<String, dynamic>;
  }
}

class LeaderboardService {
  final _client = ApiClient();

  Future<List<Map<String, dynamic>>> getTopUsers({int limit = 10}) async {
    final response =
        await _client.dio.get('/api/v1/leaderboard?limit=$limit');
    return (response.data as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
