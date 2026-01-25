import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/models/campaign_model.dart';
import 'package:mobile/services/auth_service.dart';

class CampaignService {
  final String baseUrl =
      "https://frettiest-ariella-unnationally.ngrok-free.dev/api/v1";
  final AuthService _authService = AuthService();

  /// Lấy danh sách campaigns gợi ý (cùng quận ưu tiên)
  Future<List<CampaignModel>> getRecommendedCampaigns() async {
    try {
      String? token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/users/volunteer/campaigns/recommended'),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => CampaignModel.fromJson(item)).toList();
      } else {
        print("Lỗi lấy campaigns: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi kết nối API getRecommendedCampaigns: $e");
      return [];
    }
  }

  /// Lấy chi tiết campaign theo ID
  Future<CampaignModel?> getCampaignById(String id) async {
    try {
      String? token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/users/volunteer/campaigns/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return CampaignModel.fromJson(jsonDecode(response.body));
      } else {
        print("Lỗi lấy chi tiết campaign: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối API getCampaignById: $e");
      return null;
    }
  }

  /// Đăng ký tham gia campaign
  Future<bool> registerCampaign(String campaignId, {String? notes}) async {
    try {
      String? token = await _authService.getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/users/volunteer/campaigns/$campaignId/register'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({
          if (notes != null) 'notes': notes,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print("Lỗi đăng ký campaign: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Lỗi kết nối API registerCampaign: $e");
      return false;
    }
  }

  /// Lấy danh sách campaigns đã đăng ký
  Future<List<CampaignRegistrationModel>> getMyRegistrations() async {
    try {
      String? token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/users/volunteer/campaigns/my-registrations'),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => CampaignRegistrationModel.fromJson(item))
            .toList();
      } else {
        print("Lỗi lấy my registrations: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi kết nối API getMyRegistrations: $e");
      return [];
    }
  }

  /// Hủy đăng ký campaign
  Future<bool> cancelRegistration(String campaignId) async {
    try {
      String? token = await _authService.getToken();

      final response = await http.delete(
        Uri.parse('$baseUrl/users/volunteer/campaigns/$campaignId/cancel'),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Lỗi hủy đăng ký: ${response.statusCode} - ${response.body}");
        return false;
      }
    } catch (e) {
      print("Lỗi kết nối API cancelRegistration: $e");
      return false;
    }
  }
}
