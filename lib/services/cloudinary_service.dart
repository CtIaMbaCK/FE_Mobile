import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/services/auth_service.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class CloudinaryService {
  final String baseUrl =
      "https://frettiest-ariella-unnationally.ngrok-free.dev/api/v1";
  final AuthService _authService = AuthService();

  /// Upload một file ảnh lên Cloudinary và trả về URL
  Future<String?> uploadImage(File imageFile) async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        print('❌ Không có token');
        return null;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/cloudinary/upload'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['ngrok-skip-browser-warning'] = 'true';

      // Detect MIME type
      final mimeType = lookupMimeType(imageFile.path) ?? 'image/jpeg';
      final mimeTypeData = mimeType.split('/');

      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          imageFile.path,
          contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
        ),
      );

      print('📤 Đang upload: ${imageFile.path} (${mimeType})');

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);
        final url = data['url'];
        print('✅ Upload thành công: $url');
        return url;
      } else {
        final respStr = await response.stream.bytesToString();
        print('❌ Upload thất bại (${response.statusCode}): $respStr');
        return null;
      }
    } catch (e) {
      print('❌ Lỗi upload ảnh: $e');
      return null;
    }
  }

  /// Upload nhiều ảnh lên Cloudinary và trả về danh sách URL
  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    List<String> uploadedUrls = [];

    for (var imageFile in imageFiles) {
      final url = await uploadImage(imageFile);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    print('✅ Upload hoàn thành: ${uploadedUrls.length}/${imageFiles.length} ảnh');
    return uploadedUrls;
  }
}
