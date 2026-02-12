import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/models/certificate_model.dart';

class CertificateService {
  static const String baseUrl =
      'https://frettiest-ariella-unnationally.ngrok-free.dev/api/v1';
  final _storage = const FlutterSecureStorage();
  static const Duration _requestTimeout = Duration(seconds: 15);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Lấy userId từ token hoặc storage
  Future<String?> _getCurrentUserId() async {
    try {
      // Thử lấy từ storage trước
      final userId = await _storage.read(key: 'userId');
      if (userId != null && userId.isNotEmpty) {
        print('📝 UserId from storage: $userId');
        return userId;
      }

      // Nếu không có, decode từ token
      final token = await _storage.read(key: 'token');
      if (token == null) {
        print('❌ No token found');
        return null;
      }

      // Parse JWT token (format: header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) {
        print('❌ Invalid token format');
        return null;
      }

      // Decode payload (base64)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      // JWT payload thường có 'sub' hoặc 'userId'
      final extractedUserId = payloadMap['sub'] ?? payloadMap['userId'];
      print('📝 UserId from token: $extractedUserId');
      return extractedUserId;
    } catch (e) {
      print('❌ Error getting userId: $e');
      return null;
    }
  }

  /// Lấy danh sách chứng nhận của volunteer hiện tại
  Future<List<CertificateModel>> getMyCertificates() async {
    try {
      // Lấy userId
      final userId = await _getCurrentUserId();
      if (userId == null) {
        print('❌ Cannot get userId');
        return [];
      }

      final headers = await _getHeaders();
      final url = '$baseUrl/volunteer-rewards/certificates/volunteer/$userId';
      print('🔗 Fetching certificates from: $url');

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(
            _requestTimeout,
            onTimeout: () {
              throw Exception('Kết nối quá chậm. Vui lòng kiểm tra mạng.');
            },
          );

      print('📜 Get certificates response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Lấy được ${data.length} chứng nhận');
        print('📄 Response data: $data');
        return data.map((json) => CertificateModel.fromJson(json)).toList();
      } else {
        print('❌ Get certificates error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Get certificates exception: $e');
      return [];
    }
  }
}
