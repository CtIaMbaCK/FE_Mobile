import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;

Future<File> compressFile(File file) async {
  try {
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(p.extension(filePath));
    final targetPath =
        "${filePath.substring(0, lastIndex)}_compressed${p.extension(filePath)}";

    final result = await FlutterImageCompress.compressAndGetFile(
      filePath,
      targetPath,
      quality: 70,
    );

    if (result == null) return file;
    return File(result.path);
  } catch (e) {
    print("Lỗi nén ảnh: $e");
    return file;
  }
}
