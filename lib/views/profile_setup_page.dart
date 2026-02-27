import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ProfileSetupPage extends StatefulWidget {
  final Map<String, dynamic> basicData;
  final String role;
  const ProfileSetupPage({
    super.key,
    required this.basicData,
    required this.role,
  });

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  File? _avatar, _cccdFront, _cccdBack;

  // Logic xử lý chính
  Future<void> _submitAll() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. GỌI API REGISTER (Dữ liệu JSON - Hình 3)
      final regRes = await http.post(
        Uri.parse('https://your-api.com/api/v1/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({...widget.basicData, "role": widget.role}),
      );

      if (regRes.statusCode == 201 || regRes.statusCode == 200) {
        String token = jsonDecode(regRes.body)['accessToken'];

        // 2. GỌI API PROFILE (Dữ liệu Multipart - Hình 2 hoặc Hình 4)
        var uri = Uri.parse(
          widget.role == 'VOLUNTEER'
              ? 'https://your-api.com/api/v1/auth/profile/tnv'
              : 'https://your-api.com/api/v1/auth/profile/ncgd',
        );

        var request = http.MultipartRequest('PUT', uri);
        request.headers['Authorization'] = 'Bearer $token';
        request.fields['fullName'] = _nameController.text;

        if (widget.role == 'VOLUNTEER') {
          request.fields['bio'] = _addressController.text;
          request.fields['experienceYears'] = "1";
        } else {
          request.fields['vulnerabilityType'] = "POOR";
          request.fields['situationDescription'] = _addressController.text;
        }

        if (_avatar != null)
          request.files.add(
            await http.MultipartFile.fromPath('avatar', _avatar!.path),
          );
        if (_cccdFront != null)
          request.files.add(
            await http.MultipartFile.fromPath('cccdFront', _cccdFront!.path),
          );
        if (_cccdBack != null)
          request.files.add(
            await http.MultipartFile.fromPath('cccdBack', _cccdBack!.path),
          );

        var profileRes = await request.send();
        if (profileRes.statusCode == 200) {
          Navigator.pop(context); // Tắt loading
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Đăng ký thành công!")));
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    } catch (e) {
      Navigator.pop(context);
      print("Lỗi: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isTnv = widget.role == 'VOLUNTEER';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isTnv ? "Đăng ký Tình nguyện viên" : "Đăng ký Người cần giúp đỡ",
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildField("Họ và Tên", _nameController, "Nguyễn Văn A"),
            _buildField("Địa chỉ", _addressController, "Nhập địa chỉ cụ thể"),
            const SizedBox(height: 20),
            _uploadRow(
              "Hình đại diện",
              (file) => setState(() => _avatar = file),
              _avatar,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _uploadRow(
                    "CCCD Trước",
                    (file) => setState(() => _cccdFront = file),
                    _cccdFront,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _uploadRow(
                    "CCCD Sau",
                    (file) => setState(() => _cccdBack = file),
                    _cccdBack,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: _submitAll,
              child: const Text(
                "Tạo tài khoản",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _uploadRow(String label, Function(File) onPick, File? preview) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final XFile? img = await ImagePicker().pickImage(
              source: ImageSource.gallery,
            );
            if (img != null) onPick(File(img.path));
          },
          child: Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.05),
              border: Border.all(color: Colors.teal.shade100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: preview == null
                ? const Icon(Icons.add_a_photo, color: Color(0xFF008080))
                : Image.file(preview, fit: BoxFit.cover),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
