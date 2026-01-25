import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/volunteer_honor_model.dart';

class VolunteerService {
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

  // Lấy danh sách volunteers (sắp xếp theo điểm giảm dần)
  Future<VolunteerListResponse?> getVolunteers({
    String? search,
    String? district,
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

      if (district != null && district.isNotEmpty) {
        queryParams['district'] = district;
      }

      final uri = Uri.parse('$baseUrl/admin/volunteers')
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
        return VolunteerListResponse.fromJson(data);
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
      }

      return null;
    } catch (e) {
      print('Error fetching volunteers: $e');
      return null;
    }
  }

  // Lấy top volunteers (theo điểm, cho home page)
  Future<List<VolunteerHonorModel>> getTopVolunteers({int limit = 5}) async {
    try {
      final response = await getVolunteers(page: 1, limit: limit);
      if (response != null && response.items.isNotEmpty) {
        // Sắp xếp theo điểm giảm dần
        final volunteers = response.items;
        volunteers.sort((a, b) {
          final pointsA = a.volunteerProfile?.points ?? 0;
          final pointsB = b.volunteerProfile?.points ?? 0;
          return pointsB.compareTo(pointsA);
        });
        return volunteers;
      }
      return [];
    } catch (e) {
      print('Error fetching top volunteers: $e');
      return [];
    }
  }
}
