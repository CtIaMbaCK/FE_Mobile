import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/login.dart';
import 'package:mobile/views/widgets/build_widget.dart';

class SetupBeneficiaryProfile extends StatefulWidget {
  final String token;
  const SetupBeneficiaryProfile({super.key, required this.token});

  @override
  State<SetupBeneficiaryProfile> createState() =>
      _SetupBeneficiaryProfileState();
}

class _SetupBeneficiaryProfileState extends State<SetupBeneficiaryProfile> {
  final _fullNameController = TextEditingController();
  final _situationDescController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();

  String _vulnerabilityType = "POOR";
  String? _selectedRelation;

  File? _avatarUrlFile;
  File? _cccdFrontFile;
  File? _cccdBackFile;
  List<File> _proofFiles = [];

  final Map<String, String> _vulnerabilityMap = {
    "POOR": "Hộ nghèo",
    "ELDERLY": "Người cao tuổi",
    "DISABLED": "Người khuyết tật",
    "SICKNESS": "Người bệnh tật",
    "ORPHAN": "Trẻ mồ côi",
    "OTHER": "Khác",
  };

  final Map<String, String> _relationMap = {
    "PARENT": "Cha/Mẹ",
    "SPOUSE": "Vợ/Chồng",
    "CHILD": "Con cái",
    "SIBLING": "Anh/Chị/Em",
    "RELATIVE": "Họ hàng",
    "FRIEND": "Bạn bè",
    "OTHER": "Khác",
  };

  Future<void> _submit() async {
    if (_fullNameController.text.isEmpty ||
        _avatarUrlFile == null ||
        _cccdFrontFile == null ||
        _cccdBackFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập họ tên và tải đầy đủ 3 ảnh bắt buộc!"),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    // GỌI ĐÚNG HÀM TRONG SERVICE
    bool success = await AuthService().createBeneficiaryProfile(
      token: widget.token,
      fullName: _fullNameController.text,
      vulnerabilityType: _vulnerabilityType,
      situationDescription: _situationDescController.text,
      guardianName: _guardianNameController.text,
      guardianPhone: _guardianPhoneController.text,
      guardianRelation: _selectedRelation,
      avatarUrl: _avatarUrlFile!,
      cccdFront: _cccdFrontFile!,
      cccdBack: _cccdBackFile!,
      proofFiles: _proofFiles,
    );

    if (mounted) Navigator.pop(context);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hoàn thiện hồ sơ thành công! Vui lòng đăng nhập."),
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thất bại, vui lòng kiểm tra lại dữ liệu."),
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
                                  Icons.info_outline,
                                  color: Color(0xFF64748B),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Người cần giúp đỡ (NCGD)",
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
                            label: "Họ và tên của bạn (Bắt buộc)",
                          ),
                          _buildVulnerabilityDropdown(),
                          buildFormTextArea(
                            controller: _situationDescController,
                            label: "Mô tả hoàn cảnh (Tùy chọn)",
                            minLines: 3,
                          ),

                          const Divider(height: 48, color: Color(0xFFE2E8F0)),
                          Text(
                            "Thông tin người bảo hộ (Tùy chọn)",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 20),

                          buildFormTextField(
                            label: "Tên người bảo hộ",
                            controller: _guardianNameController,
                          ),
                          buildFormTextField(
                            label: "Số điện thoại người bảo hộ",
                            controller: _guardianPhoneController,
                            keyboardType: TextInputType.phone,
                          ),
                          _buildRelationDropdown(),

                          const Divider(height: 48, color: Color(0xFFE2E8F0)),
                          Text(
                            "Giấy tờ xác minh (Bắt buộc)",
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _buildFilePicker(
                            "Ảnh chân dung",
                            _avatarUrlFile,
                            (f) => setState(() => _avatarUrlFile = f),
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

                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () async {
                              final images = await ImagePicker()
                                  .pickMultiImage();
                              if (images.isNotEmpty) {
                                setState(
                                  () => _proofFiles = images
                                      .map((e) => File(e.path))
                                      .toList(),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.add_a_photo_outlined,
                              color: Color(0xFF008080),
                            ),
                            label: Text(
                              "Tải thêm tài liệu minh chứng (${_proofFiles.length})",
                              style: GoogleFonts.roboto(
                                color: const Color(0xFF008080),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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

  // --- Các hàm build giao diện hỗ trợ ---
  Widget _buildVulnerabilityDropdown() => _buildBaseDropdown(
    label: "Loại đối tượng",
    value: _vulnerabilityType,
    itemsMap: _vulnerabilityMap,
    onChanged: (v) => setState(() => _vulnerabilityType = v!),
  );

  Widget _buildRelationDropdown() => _buildBaseDropdown(
    label: "Mối quan hệ bảo hộ (Tùy chọn)",
    value: _selectedRelation,
    hint: "Chọn mối quan hệ",
    itemsMap: _relationMap,
    onChanged: (v) => setState(() => _selectedRelation = v),
  );

  Widget _buildBaseDropdown({
    required String label,
    required String? value,
    required Map<String, String> itemsMap,
    required ValueChanged<String?> onChanged,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            hint: hint != null ? Text(hint) : null,
            items: itemsMap.entries
                .map(
                  (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                )
                .toList(),
            onChanged: onChanged,
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: const Color(0xFF334155),
              fontWeight: FontWeight.w500,
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF64748B),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF1F4F8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF008080),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
          file == null ? Icons.cloud_upload_outlined : Icons.check_circle,
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
