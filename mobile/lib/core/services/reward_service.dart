import '../network/api_client.dart';

class RewardService {
  final _client = ApiClient();

  Future<List<Map<String, dynamic>>> getAllRewards() async {
    final response = await _client.dio.get('/api/v1/rewards');
    return (response.data as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> claimReward(int rewardId) async {
    final response =
        await _client.dio.post('/api/v1/rewards/$rewardId/claim');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getMyRewards() async {
    final response = await _client.dio.get('/api/v1/rewards/me');
    return (response.data as List)
        .map((e) => e as Map<String, dynamic>)
        .toList();
  }
}
