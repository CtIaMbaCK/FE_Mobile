import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/services/auth_service.dart';

class ReviewService {
  final String baseUrl =
      "https://frettiest-ariella-unnationally.ngrok-free.dev/api/v1";
  final AuthService _authService = AuthService();

  /// Lấy review đã gửi cho activity
  Future<Map<String, dynamic>?> getMyReviewForActivity(String activityId) async {
    try {
      String? token = await _authService.getToken();
      if (token == null) return null;

      // Lấy danh sách reviews đã gửi từ backend
      final response = await http.get(
        Uri.parse('$baseUrl/feedback/my-reviews'),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final List reviews = jsonDecode(response.body);
        try {
          return reviews.firstWhere(
            (item) => item['activity'] != null && item['activity']['id'] == activityId,
          );
        } catch (e) {
          return null;
        }
      }
      return null;
    } catch (e) {
      print('❌ Lỗi lấy review: $e');
      return null;
    }
  }

  /// Kiểm tra đã gửi review chưa
  Future<bool> hasReviewed(String activityId) async {
    final review = await getMyReviewForActivity(activityId);
    return review != null;
  }

  /// Gửi đánh giá cho tình nguyện viên
  Future<bool> sendReview({
    required String activityId,
    required String targetId,
    required int rating,
    String? comment,
  }) async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        print('❌ Không có token');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/feedback/review'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          'activityId': activityId,
          'targetId': targetId,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        }),
      );

      print('📤 Gửi review cho activity: $activityId, target: $targetId - Rating: $rating');
      print('Response: ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Response body: ${response.body}');
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ Lỗi gửi review: $e');
      return false;
    }
  }
}
