import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'dart:typed_data';

class ImageDownloadUtils {
  static final Dio _dio = Dio();

  /// Download và lưu ảnh vào Gallery
  static Future<bool> saveImageToGallery({
    required String imageUrl,
    required BuildContext context,
    String? fileName,
  }) async {
    try {
      // 1. Kiểm tra permission (gal tự xin permission)
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        // Request permission
        final granted = await Gal.requestAccess();
        if (!granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cần cấp quyền truy cập bộ nhớ để lưu ảnh'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return false;
        }
      }

      // 2. Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 16),
                Text('Đang tải xuống...'),
              ],
            ),
            duration: Duration(seconds: 30),
            backgroundColor: Color(0xFF008080),
          ),
        );
      }

      // 3. Download ảnh
      final response = await _dio.get(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'ngrok-skip-browser-warning': 'true',
          },
        ),
      );

      print('📥 Downloaded image: ${response.data.length} bytes');

      // 4. Lưu vào Gallery với gal
      final Uint8List bytes = Uint8List.fromList(response.data);

      await Gal.putImageBytes(
        bytes,
        name: fileName ?? 'certificate_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('💾 Image saved to gallery successfully');

      // 5. Dismiss loading và show success
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Expanded(
                  child: Text('Đã lưu chứng nhận vào thư viện ảnh'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }

      return true;
    } catch (e) {
      print('❌ Save image error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lưu ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }
}
