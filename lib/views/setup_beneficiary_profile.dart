import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final List<String> _relationOptions = [
    "PARENT",
    "SPOUSE",
    "CHILD",
    "SIBLING",
    "RELATIVE",
    "FRIEND",
    "OTHER",
  ];

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
      appBar: AppBar(
        title: Text(
          "Hoàn thiện hồ sơ NCGD",
          style: GoogleFonts.roboto(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            const Divider(height: 40),
            Text(
              "Thông tin người bảo hộ (Tùy chọn)",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: const Color(0xFF008080),
              ),
            ),
            const SizedBox(height: 20),

            buildFormTextField(
              label: "Tên người bảo hộ (Tùy chọn)",
              controller: _guardianNameController,
            ),
            buildFormTextField(
              label: "Số điện thoại người bảo hộ (Tùy chọn)",
              controller: _guardianPhoneController,
              keyboardType: TextInputType.phone,
            ),
            _buildRelationDropdown(),

            const SizedBox(height: 20),
            Text(
              "Giấy tờ xác minh (Bắt buộc)",
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildFilePicker(
              "Ảnh đại diện chân dung",
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

            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () async {
                final images = await ImagePicker().pickMultiImage();
                if (images.isNotEmpty) {
                  setState(
                    () =>
                        _proofFiles = images.map((e) => File(e.path)).toList(),
                  );
                }
              },
              icon: const Icon(Icons.add_a_photo, color: Color(0xFF008080)),
              label: Text(
                "Tải thêm tài liệu minh chứng (${_proofFiles.length})",
                style: const TextStyle(color: Color(0xFF008080)),
              ),
            ),

            const SizedBox(height: 30),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Các hàm build giao diện hỗ trợ ---
  Widget _buildVulnerabilityDropdown() => _buildBaseDropdown(
    label: "Loại đối tượng",
    value: _vulnerabilityType,
    items: ["POOR", "ELDERLY", "DISABLED", "SICKNESS", "ORPHAN", "OTHER"],
    onChanged: (v) => setState(() => _vulnerabilityType = v!),
  );

  Widget _buildRelationDropdown() => _buildBaseDropdown(
    label: "Mối quan hệ bảo hộ",
    value: _selectedRelation,
    hint: "Chọn mối quan hệ (Tùy chọn)",
    items: _relationOptions,
    onChanged: (v) => setState(() => _selectedRelation = v),
  );

  Widget _buildBaseDropdown({
    required String label,
    required String? value,
    required List<String> items,
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
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: value,
            hint: hint != null ? Text(hint) : null,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF1F4F8),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black, width: 1.0),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: file == null ? Colors.black : Colors.green),
      ),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 14)),
        trailing: Icon(
          file == null ? Icons.cloud_upload_outlined : Icons.check_circle,
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
