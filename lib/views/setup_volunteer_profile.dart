import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/login.dart';
import 'package:mobile/views/widgets/build_widget.dart';

class SetupVolunteerProfile extends StatefulWidget {
  final String token;
  const SetupVolunteerProfile({super.key, required this.token});

  @override
  State<SetupVolunteerProfile> createState() => _SetupVolunteerProfileState();
}

class _SetupVolunteerProfileState extends State<SetupVolunteerProfile> {
  // Thống nhất các Controller
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _expController = TextEditingController();

  // Thống nhất các biến File
  File? _avatarFile;
  File? _cccdFrontFile;
  File? _cccdBackFile;

  Future<void> _submit() async {
    // 1. Kiểm tra các trường bắt buộc (fullName, exp, và 3 ảnh)
    if (_fullNameController.text.isEmpty ||
        _expController.text.isEmpty ||
        _avatarFile == null ||
        _cccdFrontFile == null ||
        _cccdBackFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Vui lòng điền đủ thông tin bắt buộc và tải lên 3 loại ảnh!",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Gọi Service createVolunteerProfile (Sử dụng PUT /auth/profile/tnv)
    bool success = await AuthService().createVolunteerProfile(
      token: widget.token,
      fullName: _fullNameController.text,
      experienceYears: int.tryParse(_expController.text) ?? 0,
      bio: _bioController.text, // Trường optional
      avatarUrl: _avatarFile!,
      cccdFront: _cccdFrontFile!,
      cccdBack: _cccdBackFile!,
    );

    if (mounted) Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hoàn thiện hồ sơ TNV thành công! Vui lòng đăng nhập."),
        ),
      );

      // Quay về màn hình Login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Có lỗi xảy ra khi tạo hồ sơ. Vui lòng thử lại!"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hoàn thiện hồ sơ TNV",
          style: GoogleFonts.roboto(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            buildFormTextField(
              controller: _fullNameController,
              label: "Họ và Tên (Bắt buộc)",
            ),
            buildFormTextField(
              controller: _expController,
              label: "Số năm kinh nghiệm (Bắt buộc)",
              keyboardType: TextInputType.number,
            ),
            buildFormTextArea(
              controller: _bioController,
              label: "Giới thiệu bản thân (Tùy chọn)",
              minLines: 3,
            ),

            const SizedBox(height: 20),
            Text(
              "Giấy tờ xác minh & Ảnh đại diện",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF008080),
              ),
            ),
            const SizedBox(height: 15),

            _buildFilePicker(
              "Ảnh đại diện chân dung",
              _avatarFile,
              (f) => setState(() => _avatarFile = f),
            ),
            _buildFilePicker(
              "CCCD Mặt trước",
              _cccdFrontFile,
              (f) => setState(() => _cccdFrontFile = f),
            ),
            _buildFilePicker(
              "CCCD Mặt sau",
              _cccdBackFile,
              (f) => setState(() => _cccdBackFile = f),
            ),

            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                "HOÀN TẤT ĐĂNG KÝ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget chọn file được thiết kế lại để đẹp hơn và đồng bộ với NCGD
  Widget _buildFilePicker(String label, File? file, Function(File) onPick) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: file == null ? Colors.black : Colors.green,
          width: 1,
        ),
      ),
      child: ListTile(
        title: Text(label, style: GoogleFonts.roboto(fontSize: 14)),
        trailing: Icon(
          file == null ? Icons.add_a_photo_outlined : Icons.check_circle,
          color: file == null ? Colors.black54 : Colors.green,
        ),
        onTap: () async {
          final img = await ImagePicker().pickImage(
            source: ImageSource.gallery,
          );
          if (img != null) onPick(File(img.path));
        },
      ),
    );
  }
}
