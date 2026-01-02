import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/services/auth_service.dart';

class SetupVolunteerProfile extends StatefulWidget {
  final String token;

  const SetupVolunteerProfile({super.key, required this.token});

  @override
  State<SetupVolunteerProfile> createState() => _SetupVolunteerProfileState();
}

class _SetupVolunteerProfileState extends State<SetupVolunteerProfile> {
  final _fullName = TextEditingController();
  final _bio = TextEditingController();
  final _exp = TextEditingController();
  File? _avatar, _front, _back;

  Future<void> _submit() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await AuthService().updateVolunteerProfile(
      token: widget.token,
      fullName: _fullName.text,
      bio: _bio.text,
      experienceYears: int.tryParse(_exp.text) ?? 0,
      avatar: _avatar,
      cccdFront: _front,
      cccdBack: _back,
    );

    if (mounted) Navigator.pop(context);
    if (success) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hoàn thiện hồ sơ TNV",
          style: GoogleFonts.readexPro(fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildField("Họ và Tên", _fullName),
            _buildField("Giới thiệu ngắn (Bio)", _bio, maxLines: 3),
            _buildField(
              "Số năm kinh nghiệm",
              _exp,
              keyboardType: TextInputType.number,
            ),
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
            const SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF008080),
                minimumSize: const Size(double.infinity, 55),
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

  Widget _buildField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          maxLines: maxLines,
          keyboardType: keyboardType,
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
        file == null ? Icons.add_a_photo : Icons.check_circle,
        color: file == null ? Colors.grey : Colors.green,
      ),
      onTap: () async {
        final img = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (img != null) onPick(File(img.path));
      },
    );
  }
}
