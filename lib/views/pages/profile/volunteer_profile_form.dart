import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/services/auth_service.dart';

class VolunteerProfileForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const VolunteerProfileForm({super.key, required this.initialData});

  @override
  State<VolunteerProfileForm> createState() => _VolunteerProfileFormState();
}

class _VolunteerProfileFormState extends State<VolunteerProfileForm> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _expController = TextEditingController();
  
  File? _avatar, _front, _back;
  String? _remoteAvatarUrl;

  @override
  void initState() {
    super.initState();
    // Đổ dữ liệu cũ vào Form từ initialData nhận được từ ProfilePage
    _nameController.text = widget.initialData['fullName'] ?? "";
    final profile = widget.initialData['volunteerProfile'] ?? {};
    _bioController.text = profile['bio'] ?? "";
    _expController.text = profile['experienceYears']?.toString() ?? "0";
    _remoteAvatarUrl = widget.initialData['avatarUrl'];
  }

  // --- UI HELPERS ---

  Widget _buildAvatarSection(String? currentUrl) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.teal.shade50,
            backgroundImage: _avatar != null
                ? FileImage(_avatar!)
                : (currentUrl != null ? NetworkImage(currentUrl) : null) as ImageProvider?,
            child: (_avatar == null && currentUrl == null)
                ? const Icon(Icons.person, size: 60, color: Colors.teal)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: () => _pickImage('avatar'),
              child: const CircleAvatar(
                backgroundColor: Color(0xFF008080),
                radius: 18,
                child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker(String label, File? file, Function(File) onPick) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _pickImage(label),
            child: Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: file != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(file, fit: BoxFit.cover))
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: Color(0xFF008080)),
                        Text("Tải ảnh lên", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC ---

  Future<void> _pickImage(String source) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      setState(() {
        if (source == 'avatar') _avatar = file;
        else if (source.contains("trước")) _front = file;
        else _back = file;
      });
    }
  }

  void _submitUpdate() async {
    // Hiện Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Color(0xFF008080))),
    );

    String? token = await _authService.getToken();

    bool success = await _authService.updateVolunteerProfile(
      token: token!,
      fullName: _nameController.text,
      bio: _bioController.text,
      experienceYears: int.tryParse(_expController.text) ?? 0,
      avatar: _avatar,
      cccdFront: _front,
      cccdBack: _back,
    );

    if (mounted) Navigator.pop(context); // Tắt Loading

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật hồ sơ Tình nguyện viên thành công!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thất bại. Vui lòng kiểm tra lại.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        title: Text("Chỉnh sửa hồ sơ TNV", style: GoogleFonts.readexPro(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatarSection(_remoteAvatarUrl),
            _buildField("Họ và Tên", _nameController),
            _buildField("Giới thiệu bản thân (Bio)", _bioController, maxLines: 3),
            _buildField("Số năm kinh nghiệm", _expController, keyboardType: TextInputType.number),
            
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Xác minh danh tính (CCCD)", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                Expanded(child: _buildImagePicker("Mặt trước", _front, (f) => setState(() => _front = f))),
                const SizedBox(width: 12),
                Expanded(child: _buildImagePicker("Mặt sau", _back, (f) => setState(() => _back = f))),
              ],
            ),

            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _submitUpdate,
                child: const Text("LƯU THAY ĐỔI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}