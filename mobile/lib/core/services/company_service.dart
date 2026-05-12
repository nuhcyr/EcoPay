import 'package:dio/dio.dart';

import '../network/api_client.dart';

class CompanyService {
  final _client = ApiClient();

  /// 200: şirket var; 204: yok.
  Future<Map<String, dynamic>?> getMyCompany() async {
    final response = await _client.dio.get<Map<String, dynamic>>(
      '/api/v1/companies/me',
      options: Options(validateStatus: (s) => s == 200 || s == 204),
    );
    if (response.statusCode != 200 || response.data == null) {
      return null;
    }
    return response.data;
  }

  Future<Map<String, dynamic>> create({
    required String name,
    required String emailDomain,
  }) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/v1/companies',
      data: {'name': name, 'emailDomain': emailDomain},
    );
    return response.data!;
  }

  Future<Map<String, dynamic>> join(String inviteCode) async {
    final response = await _client.dio.post<Map<String, dynamic>>(
      '/api/v1/companies/join',
      data: {'inviteCode': inviteCode.trim()},
    );
    return response.data!;
  }

  Future<List<Map<String, dynamic>>> members() async {
    final response = await _client.dio.get<List<dynamic>>('/api/v1/companies/me/members');
    return (response.data ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<List<Map<String, dynamic>>> standings() async {
    final response = await _client.dio.get<List<dynamic>>('/api/v1/companies/standings');
    return (response.data ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }
}
