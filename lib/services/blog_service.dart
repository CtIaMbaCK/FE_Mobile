import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/blog_model.dart';

class BlogService {
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

  // Lấy danh sách blogs
  Future<BlogListResponse?> getBlogs({
    String? search,
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

      final uri = Uri.parse('$baseUrl/admin/content/posts')
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
        return BlogListResponse.fromJson(data);
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
      }

      return null;
    } catch (e) {
      print('Error fetching blogs: $e');
      return null;
    }
  }

  // Lấy chi tiết blog
  Future<BlogModel?> getBlogDetail(String id) async {
    try {
      // Lấy token từ storage
      final token = await _getToken();
      if (token == null) {
        print('Error: Token not found');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/admin/content/posts/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BlogModel.fromJson(data);
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
      }

      return null;
    } catch (e) {
      print('Error fetching blog detail: $e');
      return null;
    }
  }

  // Lấy top blogs (giới hạn số lượng cho home page)
  Future<List<BlogModel>> getTopBlogs({int limit = 2}) async {
    try {
      final response = await getBlogs(page: 1, limit: limit);
      return response?.items ?? [];
    } catch (e) {
      print('Error fetching top blogs: $e');
      return [];
    }
  }
}
