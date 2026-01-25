import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/organization_model.dart';

class OrganizationService {
  final String baseUrl =
      "https://frettiest-ariella-unnationally.ngrok-free.dev/api/v1";
  final _storage = const FlutterSecureStorage();

  // Lấy token từ storage
  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: 'token');
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }

  // Lấy danh sách organizations
  Future<OrganizationListResponse?> getOrganizations({
    String? search,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      // Lấy token từ storage
      final token = await _getToken();
      if (token == null) {
        print('Error: Token not found');
        return null;
      }

      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse('$baseUrl/admin/organizations')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return OrganizationListResponse.fromJson(data);
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
      }

      return null;
    } catch (e) {
      print('Error fetching organizations: $e');
      return null;
    }
  }

  // Lấy top organizations (chỉ ACTIVE, cho home page)
  Future<List<OrganizationModel>> getTopOrganizations({int limit = 5}) async {
    try {
      final response = await getOrganizations(
        status: 'ACTIVE',
        page: 1,
        limit: limit,
      );
      return response?.items ?? [];
    } catch (e) {
      print('Error fetching top organizations: $e');
      return [];
    }
  }
}
