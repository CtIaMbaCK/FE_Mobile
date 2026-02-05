import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EmergencyService {
  final String baseUrl =
      "https://frettiest-ariella-unnationally.ngrok-free.dev/api/v1";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'token');
  }

  // Tạo Emergency SOS request
  Future<Map<String, dynamic>> createEmergency({String? notes}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final uri = Uri.parse('$baseUrl/emergency');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lỗi khi gửi SOS: ${response.body}');
      }
    } catch (e) {
      print('Error createEmergency: $e');
      throw Exception('Không thể gửi SOS: $e');
    }
  }

  // Lấy danh sách SOS (Admin only - not used in mobile)
  Future<List<Map<String, dynamic>>> getEmergencies() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Chưa đăng nhập');
      }

      final uri = Uri.parse('$baseUrl/emergency');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Lỗi khi lấy danh sách SOS');
      }
    } catch (e) {
      print('Error getEmergencies: $e');
      return [];
    }
  }
}
