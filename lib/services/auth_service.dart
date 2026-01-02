// lib/services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_model.dart';

class AuthService {
  // Link ngrok của bạn (Nhớ cập nhật nếu ngrok reset)
  final String baseUrl =
      "https://frettiest-ariella-unnationally.ngrok-free.dev/api/v1";
  final _storage = const FlutterSecureStorage();

  // Biến lưu user hiện tại để dùng toàn app
  static UserModel? currentUser;

  // ---------------------------------------------------------
  // 👇 HÀM LOGIN CỦA BẠN ĐÂY
  // ---------------------------------------------------------
  Future<bool> login(String phoneNumbner, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode({'phoneNumbner': phoneNumbner, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'token', value: data['accessToken']);

        // ĐỢI lấy xong data user rồi mới báo thành công
        UserModel? loadedUser = await getMe();

        return loadedUser != null; // Chỉ trả về true nếu lấy được cả profile
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<UserModel?> getMe() async {
    try {
      String? token = await _storage.read(key: 'token');
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // 👈 BẮT BUỘC phải có
          'Authorization': 'Bearer $token', // 👈 Chắc chắn có chữ Bearer
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        currentUser = UserModel.fromJson(userData);
        return currentUser;
      }
      return null;
    } catch (e) {
      print("Lỗi API getMe: $e"); // 👈 Xem ở console lỗi gì
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    currentUser = null;
  }

  Future<String?> getToken() async {
    try {
      // Đọc giá trị với key là 'token' từ bộ nhớ bảo mật
      String? token = await _storage.read(key: 'token');

      // Debug để kiểm tra xem đã lấy được token chưa (nên xóa khi release)
      print(
        "DEBUG: Lấy Token thành công: ${token != null ? 'Đã có' : 'Trống'}",
      );

      return token;
    } catch (e) {
      print("DEBUG: Lỗi khi đọc Token từ storage: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> registerUser(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(
          response.body,
        ); // Trả về {accessToken: "...", user: {...}}
      }
      print("Lỗi Register: ${response.body}");
      return null;
    } catch (e) {
      print("Lỗi kết nối: $e");
      return null;
    }
  }

  Future<bool> updateBeneficiaryProfile({
    required String token,
    required String fullName,
    required String vulnerabilityType,
    required String situationDescription,
    File? avatar,
    File? cccdFront,
    File? cccdBack,
    List<File>? proofFiles,
  }) async {
    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$baseUrl/users/profile/benificiary'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    // Fields
    request.fields['fullName'] = fullName;
    request.fields['vulnerabilityType'] = vulnerabilityType;
    request.fields['situationDescription'] = situationDescription;

    // Files
    if (avatar != null)
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatar.path),
      );
    if (cccdFront != null)
      request.files.add(
        await http.MultipartFile.fromPath('cccdFront', cccdFront.path),
      );
    if (cccdBack != null)
      request.files.add(
        await http.MultipartFile.fromPath('cccdBack', cccdBack.path),
      );

    if (proofFiles != null) {
      for (var file in proofFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('proofFiles', file.path),
        );
      }
    }

    var response = await request.send();
    return response.statusCode == 200;
  }

  // Bước 2b: Update Profile cho Tình nguyện viên (TNV)
  Future<bool> updateVolunteerProfile({
    required String token,
    required String fullName,
    required String bio,
    required int experienceYears,
    File? avatar,
    File? cccdFront,
    File? cccdBack,
  }) async {
    var request = http.MultipartRequest(
      'PATCH',
      Uri.parse('$baseUrl/users/profile/volunteer'),
    );
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['fullName'] = fullName;
    request.fields['bio'] = bio;
    request.fields['experienceYears'] = experienceYears.toString();

    if (avatar != null)
      request.files.add(
        await http.MultipartFile.fromPath('avatar', avatar.path),
      );
    if (cccdFront != null)
      request.files.add(
        await http.MultipartFile.fromPath('cccdFront', cccdFront.path),
      );
    if (cccdBack != null)
      request.files.add(
        await http.MultipartFile.fromPath('cccdBack', cccdBack.path),
      );

    var response = await request.send();
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      String? token = await getToken(); // Sử dụng hàm getToken có sẵn của bạn
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        // Cập nhật lại biến static currentUser để đồng bộ toàn app
        currentUser = UserModel.fromJson(userData);

        return userData; // Trả về Map để bạn dễ truy cập sâu vào các trường
      } else {
        print("Lỗi lấy Profile: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi API getMyProfile: $e");
      return null;
    }
  }
}
