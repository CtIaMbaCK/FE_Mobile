import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mobile/models/feedback_model.dart';

class FeedbackService {
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

  /// Lấy danh sách reviews nhận được
  Future<List<ReviewModel>> getMyReviews() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl/feedback/my-reviews'),
            headers: headers,
          )
          .timeout(
            _requestTimeout,
            onTimeout: () {
              throw Exception('Kết nối quá chậm. Vui lòng kiểm tra mạng.');
            },
          );

      print('⭐ Get reviews response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Lấy được ${data.length} reviews');
        return data.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        print('❌ Get reviews error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Get reviews exception: $e');
      return [];
    }
  }

  /// Lấy danh sách appreciations nhận được
  Future<List<AppreciationModel>> getMyAppreciations() async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse('$baseUrl/feedback/my-appreciations'),
            headers: headers,
          )
          .timeout(
            _requestTimeout,
            onTimeout: () {
              throw Exception('Kết nối quá chậm. Vui lòng kiểm tra mạng.');
            },
          );

      print('💖 Get appreciations response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Lấy được ${data.length} appreciations');
        return data.map((json) => AppreciationModel.fromJson(json)).toList();
      } else {
        print('❌ Get appreciations error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Get appreciations exception: $e');
      return [];
    }
  }

  /// Gửi lời cảm ơn đến tình nguyện viên
  Future<bool> sendAppreciation({
    required String activityId,
    required String receiverId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/feedback/appreciations'),
            headers: headers,
            body: json.encode({
              'activityId': activityId,
              'receiverId': receiverId,
            }),
          )
          .timeout(
            _requestTimeout,
            onTimeout: () {
              throw Exception('Kết nối quá chậm. Vui lòng kiểm tra mạng.');
            },
          );

      print('💖 Send appreciation response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Đã gửi lời cảm ơn thành công');
        return true;
      } else {
        print('❌ Send appreciation error: ${response.statusCode}');
        print('   Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Send appreciation exception: $e');
      return false;
    }
  }

  /// Gửi đánh giá (review) cho tình nguyện viên
  Future<bool> submitReview({
    required String activityId,
    required String targetId,
    required int rating,
    String? comment,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse('$baseUrl/feedback/reviews'),
            headers: headers,
            body: json.encode({
              'activityId': activityId,
              'targetId': targetId,
              'rating': rating,
              if (comment != null) 'comment': comment,
            }),
          )
          .timeout(
            _requestTimeout,
            onTimeout: () {
              throw Exception('Kết nối quá chậm. Vui lòng kiểm tra mạng.');
            },
          );

      print('⭐ Submit review response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Đã gửi đánh giá thành công');
        return true;
      } else {
        print('❌ Submit review error: ${response.statusCode}');
        print('   Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Submit review exception: $e');
      return false;
    }
  }

  /// Lấy danh sách comments từ TCXH/Admin
  Future<List<VolunteerCommentModel>> getMyComments() async {
    try {
      final headers = await _getHeaders();
      final token = await _storage.read(key: 'token');
      if (token == null) {
        print('❌ Không có token');
        return [];
      }

      // Lấy userId từ token hoặc user info
      final userId = await _getCurrentUserId();
      if (userId == null) {
        print('❌ Không lấy được userId');
        return [];
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/volunteer-rewards/comments/volunteer/$userId'),
            headers: headers,
          )
          .timeout(
            _requestTimeout,
            onTimeout: () {
              throw Exception('Kết nối quá chậm. Vui lòng kiểm tra mạng.');
            },
          );

      print('💬 Get comments response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Lấy được ${data.length} comments');
        return data
            .map((json) => VolunteerCommentModel.fromJson(json))
            .toList();
      } else {
        print('❌ Get comments error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Get comments exception: $e');
      return [];
    }
  }

  /// Lấy userId từ storage hoặc decode JWT token
  Future<String?> _getCurrentUserId() async {
    try {
      // Thử lấy từ storage trước
      final userId = await _storage.read(key: 'userId');
      if (userId != null) return userId;

      // Nếu không có, decode từ token
      final token = await _storage.read(key: 'token');
      if (token == null) return null;

      // Parse JWT token (format: header.payload.signature)
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (base64)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(decoded);

      // JWT payload thường có 'sub' hoặc 'userId'
      return payloadMap['sub'] ?? payloadMap['userId'];
    } catch (e) {
      print('❌ Error getting userId: $e');
      return null;
    }
  }
}
