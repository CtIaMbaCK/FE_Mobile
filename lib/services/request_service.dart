import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile/models/request_model.dart';
import 'package:mobile/services/auth_service.dart';

class RequestService {
  final String baseUrl =
      "https://frettiest-ariella-unnationally.ngrok-free.dev/api/v1";
  final AuthService _authService = AuthService();

  Future<List<HelpRequestModel>> getRequesterRequests() async {
    try {
      String? token = await _authService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/request/requesterRequests'),
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => HelpRequestModel.fromJson(item)).toList();
      } else {
        print("Lỗi Server: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Lỗi kết nối API: $e");
      return [];
    }
  }

  // lib/services/request_service.dart

  Future<List<HelpRequestModel>> getAllRequests({
    String? search,
    String? status,
  }) async {
    try {
      String? token = await _authService.getToken();

      Map<String, String> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null && status != 'ALL') queryParams['status'] = status;

      final uri = Uri.parse(
        '$baseUrl/request',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Chỗ này chính là nơi bị lỗi:
        final dynamic decodedData = jsonDecode(response.body);

        List<dynamic> list;
        if (decodedData is Map<String, dynamic>) {
          // Nếu là Map, hãy tìm xem mảng nằm ở đâu (thường là 'data' hoặc 'items')
          list = decodedData['data'] ?? decodedData['items'] ?? [];
        } else {
          // Nếu đã là List rồi thì dùng luôn
          list = decodedData;
        }

        return list.map((item) => HelpRequestModel.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Lỗi lấy lịch sử hoạt động: $e");
      return [];
    }
  }

  Future<bool> createRequest(Map<String, dynamic> data) async {
    try {
      String? token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/request'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print("Lỗi tạo yêu cầu: $e");
      return false;
    }
  }

  Future<bool> updateRequest(String id, Map<String, dynamic> data) async {
  try {
    String? token = await _authService.getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/request/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 403) {
      // In ra để xem Backend giải thích lý do bị cấm là gì
      print("LỖI 403: ${response.body}"); 
    }

    return response.statusCode == 200;
  } catch (e) {
    print("Lỗi kết nối: $e");
    return false;
  }
}
}
