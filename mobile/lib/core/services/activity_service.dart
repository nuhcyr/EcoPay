import '../network/api_client.dart';

class ActivityService {
  final _client = ApiClient();

  Future<Map<String, dynamic>> createActivity({
    required String type,
    required double distance,
  }) async {
    final response = await _client.dio.post('/api/v1/activities', data: {
      'type': type,
      'distance': distance,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyActivities() async {
    final response = await _client.dio.get('/api/v1/activities/me');
    return (response.data as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
