import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // Background Decorative Elements for Soft UI
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF008080).withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF008080).withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Color(0xFF008080),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Hoàn thiện hồ sơ",
                        style: GoogleFonts.roboto(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF008080,
                            ).withValues(alpha: 0.06),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                            spreadRadius: -5,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.volunteer_activism,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Tình nguyện viên (TNV)",
                                    style: GoogleFonts.roboto(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

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

                          const Divider(height: 48, color: Color(0xFFE2E8F0)),
                          Text(
                            "Giấy tờ xác minh & Ảnh đại diện",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),

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

                          const SizedBox(height: 32),
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF008080,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF008080),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: _submit,
                              child: Text(
                                "HOÀN TẤT ĐĂNG KÝ",
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fade(duration: 500.ms).slideY(begin: 0.1, end: 0),
                ),
              ],
            ),
          ),
        ],
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
          color: file == null
              ? Colors.transparent
              : Colors.green.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF334155),
          ),
        ),
        trailing: Icon(
          file == null ? Icons.add_a_photo_outlined : Icons.check_circle,
          color: file == null ? const Color(0xFF64748B) : Colors.green,
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
