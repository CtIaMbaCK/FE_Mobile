import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/services/auth_service.dart';

class BeneficiaryProfileForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const BeneficiaryProfileForm({super.key, required this.initialData});

  @override
  State<BeneficiaryProfileForm> createState() => _BeneficiaryProfileFormState();
}

class _BeneficiaryProfileFormState extends State<BeneficiaryProfileForm> {
  final _authService = AuthService();

  // Controllers cho các trường text
  final _nameController = TextEditingController();
  final _situationController = TextEditingController();
  String _vulType = "POOR";

  // Biến lưu URL ảnh cũ từ Server
  String? _oldAvatarUrl;
  String? _oldFrontUrl;
  String? _oldBackUrl;

  // Biến lưu File ảnh mới (nếu người dùng chọn lại)
  File? _newAvatar, _newFront, _newBack;

  @override
  void initState() {
    super.initState();
    // 1. Lấy dữ liệu cũ đổ vào Form
    _nameController.text = widget.initialData['fullName'] ?? "";

    // Lưu ý: Dữ liệu lồng trong beneficiaryProfile
    final profile = widget.initialData['beneficiaryProfile'] ?? {};
    _situationController.text = profile['situationDescription'] ?? "";
    _vulType = profile['vulnerabilityType'] ?? "POOR";

    // 2. Lấy URL ảnh cũ để hiển thị
    _oldAvatarUrl = widget.initialData['avatarUrl'];
    _oldFrontUrl = profile['cccdFrontFile'];
    _oldBackUrl = profile['cccdBackFile'];
  }

  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage(String type) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        if (type == 'avatar') _newAvatar = File(pickedFile.path);
        if (type == 'front') _newFront = File(pickedFile.path);
        if (type == 'back') _newBack = File(pickedFile.path);
      });
    }
  }

  // Xử lý gửi dữ liệu cập nhật
  void _submitUpdate() async {
    // 1. Hiển thị Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF008080)),
      ),
    );

    try {
      String? token = await _authService.getToken();
      if (token == null) return;

      // 2. Gọi API PATCH
      // Chỉ truyền file nếu người dùng chọn mới (File != null)
      bool success = await _authService.updateBeneficiaryProfile(
        token: token,
        fullName: _nameController.text,
        vulnerabilityType: _vulType,
        situationDescription: _situationController.text,
        avatar: _newAvatar, // Nếu null, Backend giữ ảnh cũ
        cccdFront: _newFront,
        cccdBack: _newBack,
      );

      if (!mounted) return;
      Navigator.pop(context); // Đóng Loading

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật hồ sơ thành công!")),
        );
        // Có thể gọi lại hàm getMe() ở đây để cập nhật dữ liệu toàn app
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thất bại. Vui lòng thử lại.")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi hệ thống: $e")));
    }
  }

  // --- UI Helpers ---

  Widget _buildImagePreview(
    String label,
    String? oldUrl,
    File? newFile,
    String type,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _pickImage(type),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: newFile != null
                  ? Image.file(newFile, fit: BoxFit.cover)
                  : (oldUrl != null && oldUrl.isNotEmpty)
                  ? Image.network(
                      oldUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                    )
                  : const Icon(Icons.add_a_photo, color: Color(0xFF008080)),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.teal.shade50,
            backgroundImage: _newAvatar != null
                ? FileImage(_newAvatar!)
                : (_oldAvatarUrl != null ? NetworkImage(_oldAvatarUrl!) : null)
                      as ImageProvider?,
            child: (_newAvatar == null && _oldAvatarUrl == null)
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.teal,
              radius: 15,
              child: IconButton(
                icon: const Icon(
                  Icons.camera_alt,
                  size: 15,
                  color: Colors.white,
                ),
                onPressed: () => _pickImage('avatar'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController ctrl, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Loại đối tượng",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _vulType,
            items: [
              "POOR",
              "ELDERLY",
              "DISABLED",
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _vulType = v!),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F9),
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildTextField("Họ và Tên", _nameController),
            _buildDropdown(),
            _buildTextField(
              "Mô tả hoàn cảnh",
              _situationController,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Giấy tờ xác minh",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            _buildImagePreview(
              "CCCD Mặt trước",
              _oldFrontUrl,
              _newFront,
              'front',
            ),
            _buildImagePreview("CCCD Mặt sau", _oldBackUrl, _newBack, 'back'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF008080),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submitUpdate,
                child: const Text(
                  "LƯU THAY ĐỔI",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
