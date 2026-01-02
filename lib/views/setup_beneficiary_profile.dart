import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/login.dart';

class SetupBeneficiaryProfile extends StatefulWidget {
  final String token;

  const SetupBeneficiaryProfile({super.key, required this.token});

  @override
  State<SetupBeneficiaryProfile> createState() =>
      _SetupBeneficiaryProfileState();
}

class _SetupBeneficiaryProfileState extends State<SetupBeneficiaryProfile> {
  final _fullName = TextEditingController();
  final _situationDesc = TextEditingController();
  String _vulnerabilityType = "POOR";
  File? _avatar, _front, _back;
  List<File> _proofFiles = [];

  Future<void> _submit() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await AuthService().updateBeneficiaryProfile(
      token: widget.token,
      fullName: _fullName.text,
      vulnerabilityType: _vulnerabilityType,
      situationDescription: _situationDesc.text,
      avatar: _avatar,
      cccdFront: _front,
      cccdBack: _back,
      proofFiles: _proofFiles,
    );

    if (mounted) Navigator.pop(context);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đăng ký thành công! Vui lòng đăng nhập."),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hoàn thiện hồ sơ NCGD",
          style: GoogleFonts.readexPro(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildField("Họ và Tên", _fullName),
            _buildDropdown(),
            _buildField("Mô tả hoàn cảnh", _situationDesc, maxLines: 3),
            const SizedBox(height: 20),
            _buildFilePicker(
              "Ảnh đại diện",
              _avatar,
              (f) => setState(() => _avatar = f),
            ),
            _buildFilePicker(
              "CCCD Mặt trước",
              _front,
              (f) => setState(() => _front = f),
            ),
            _buildFilePicker(
              "CCCD Mặt sau",
              _back,
              (f) => setState(() => _back = f),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () async {
                final images = await ImagePicker().pickMultiImage();
                setState(
                  () => _proofFiles = images.map((e) => File(e.path)).toList(),
                );
              },
              icon: const Icon(Icons.add_a_photo),
              label: Text("Tải tài liệu minh chứng (${_proofFiles.length})"),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                minimumSize: const Size(double.infinity, 55),
              ),
              onPressed: _submit,
              child: const Text(
                "TẠO TÀI KHOẢN",
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

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Loại đối tượng",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _vulnerabilityType,
          items: [
            "POOR",
            "ELDERLY",
            "DISABLED",
            "SICKNESS",
            "ORPHAN",
            "OTHER",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _vulnerabilityType = v!),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFilePicker(String label, File? file, Function(File) onPick) {
    return ListTile(
      title: Text(label),
      trailing: Icon(
        file == null ? Icons.upload_file : Icons.check_circle,
        color: file == null ? Colors.grey : Colors.green,
      ),
      onTap: () async {
        final img = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (img != null) onPick(File(img.path));
      },
    );
  }
}
