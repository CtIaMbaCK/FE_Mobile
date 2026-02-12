import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/data/notifiers.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/views/login.dart';
import 'package:mobile/views/widgets/modern_ui_widgets.dart';
import 'package:mobile/views/pages/profile/beneficiary_activity_history_page.dart';

class BeneficiaryProfileEditForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const BeneficiaryProfileEditForm({super.key, required this.initialData});

  @override
  State<BeneficiaryProfileEditForm> createState() =>
      _BeneficiaryProfileEditFormState();
}

class _BeneficiaryProfileEditFormState
    extends State<BeneficiaryProfileEditForm> {
  final _authService = AuthService();

  // Controllers
  final _nameController = TextEditingController();
  final _healthConditionController = TextEditingController();
  final _situationController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianRelationController = TextEditingController();

  // Dropdown
  String _vulnerabilityType = "POOR";

  // Files mới (chỉ khi user chọn ảnh mới)
  File? _newAvatar;
  File? _newFront;
  File? _newBack;
  List<File> _newProofFiles = [];

  // URLs ảnh cũ từ server (hiển thị khi không có File mới)
  String? _oldAvatarUrl;
  String? _oldFrontUrl;
  String? _oldBackUrl;
  List<String> _keepingProofUrls = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    print("DEBUG: Loading initial data...");
    print("DEBUG: widget.initialData keys: ${widget.initialData.keys}");

    // QUAN TRỌNG: fullName và avatarUrl nằm TRONG bficiaryProfile
    final profile = widget.initialData['bficiaryProfile'] ?? {};
    print("DEBUG: bficiaryProfile: $profile");

    final fullName = profile['fullName'] ?? "";
    print("DEBUG: fullName from bficiaryProfile: '$fullName'");
    _nameController.text = fullName;

    _vulnerabilityType = profile['vulnerabilityType'] ?? "POOR";
    _healthConditionController.text = profile['healthCondition'] ?? "";
    _situationController.text = profile['situationDescription'] ?? "";
    _guardianNameController.text = profile['guardianName'] ?? "";
    _guardianPhoneController.text = profile['guardianPhone'] ?? "";
    _guardianRelationController.text = profile['guardianRelation'] ?? "";

    // QUAN TRỌNG: Reset Files mới về null (chỉ hiển thị ảnh cũ)
    _newAvatar = null;
    _newFront = null;
    _newBack = null;
    _newProofFiles = [];

    // Load URLs ảnh cũ từ server (TRONG bficiaryProfile)
    _oldAvatarUrl = profile['avatarUrl'];
    _oldFrontUrl = profile['cccdFrontFile'];
    _oldBackUrl = profile['cccdBackFile'];

    print("DEBUG: Avatar URL: $_oldAvatarUrl");
    print("DEBUG: CCCD Front: $_oldFrontUrl");
    print("DEBUG: CCCD Back: $_oldBackUrl");

    // Load proofFiles cũ
    if (profile['proofFiles'] != null) {
      _keepingProofUrls = List<String>.from(profile['proofFiles']);
      print("DEBUG: Proof files count: ${_keepingProofUrls.length}");
    } else {
      _keepingProofUrls = [];
      print("DEBUG: No proof files");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _healthConditionController.dispose();
    _situationController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianRelationController.dispose();
    super.dispose();
  }

  // ==================== UI SECTIONS ====================

  /// Section 1: Avatar
  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF008080), width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: _newAvatar != null
                  ? Image.file(
                      _newAvatar!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                  : (_oldAvatarUrl != null && _oldAvatarUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: _oldAvatarUrl!,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          placeholder: (context, url) => Container(
                            color: const Color(0xFFF8FCFC),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF008080),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: const Color(0xFFF8FCFC),
                            child: const Icon(
                              Icons.person,
                              size: 60,
                              color: Color(0xFF008080),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF8FCFC),
                          child: const Icon(
                            Icons.person,
                            size: 60,
                            color: Color(0xFF008080),
                          ),
                        ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _pickImage('avatar'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF008080),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigation Card: Lịch sử hoạt động
  Widget _buildActivityHistoryCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BeneficiaryActivityHistoryPage(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.history,
                    color: Colors.blue[700],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lịch sử hoạt động',
                        style: GoogleFonts.roboto(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Xem các yêu cầu giúp đỡ của bạn',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: const Color(0xFF757575),
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow icon
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Section 2: Thông tin cơ bản
  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin cơ bản',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF008080),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Họ và Tên',
            controller: _nameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildDropdownField(),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Tình trạng sức khỏe',
            controller: _healthConditionController,
            icon: Icons.health_and_safety_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Mô tả hoàn cảnh',
            controller: _situationController,
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  /// Dropdown cho loại đối tượng
  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Loại đối tượng',
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _vulnerabilityType,
          items: [
            'POOR',
            'DISABLED',
            'ELDERLY',
            'ORPHAN',
            'CHRONIC_DISEASE',
            'OTHER',
          ].map((type) {
            return DropdownMenuItem(
              value: type,
              child: Text(_getVietnameseName(type)),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _vulnerabilityType = value);
            }
          },
          decoration: InputDecoration(
            prefixIcon:
                const Icon(Icons.category_outlined, color: Color(0xFF008080)),
            filled: true,
            fillColor: const Color(0xFFF8FCFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  String _getVietnameseName(String type) {
    switch (type) {
      case 'POOR':
        return 'Hộ nghèo';
      case 'DISABLED':
        return 'Người khuyết tật';
      case 'ELDERLY':
        return 'Người cao tuổi';
      case 'ORPHAN':
        return 'Trẻ mồ côi';
      case 'CHRONIC_DISEASE':
        return 'Bệnh hiểm nghèo';
      case 'OTHER':
        return 'Khác';
      default:
        return type;
    }
  }

  /// Section 3: Thông tin người giám hộ
  Widget _buildGuardianSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.family_restroom,
                color: Color(0xFF008080),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Thông tin người giám hộ',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF008080),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildTextField(
            label: 'Tên người giám hộ',
            controller: _guardianNameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Số điện thoại',
            controller: _guardianPhoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Quan hệ với người giám hộ',
            controller: _guardianRelationController,
            icon: Icons.link,
          ),
        ],
      ),
    );
  }

  /// Section 4: CCCD
  Widget _buildCCCDSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.badge_outlined,
                color: Color(0xFF008080),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Xác minh danh tính (CCCD)',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF008080),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildImagePreview(
                  'Mặt trước',
                  _oldFrontUrl,
                  _newFront,
                  () => _pickImage('front'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImagePreview(
                  'Mặt sau',
                  _oldBackUrl,
                  _newBack,
                  () => _pickImage('back'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Section 5: ProofFiles
  Widget _buildProofFilesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.folder_outlined,
                color: Color(0xFF008080),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Hồ sơ minh chứng',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF008080),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Grid hiển thị ảnh cũ + mới
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1,
            ),
            itemCount: _keepingProofUrls.length + _newProofFiles.length + 1,
            itemBuilder: (context, index) {
              // Hiển thị ảnh cũ
              if (index < _keepingProofUrls.length) {
                return _buildOldProofImage(_keepingProofUrls[index], index);
              }

              // Hiển thị ảnh mới
              final newIndex = index - _keepingProofUrls.length;
              if (newIndex < _newProofFiles.length) {
                return _buildNewProofImage(_newProofFiles[newIndex], newIndex);
              }

              // Nút thêm ảnh
              return _buildAddProofButton();
            },
          ),
        ],
      ),
    );
  }

  /// Hiển thị ảnh cũ với nút X
  Widget _buildOldProofImage(String url, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _replaceOldProofImage(index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF008080), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF008080)),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeOldProofImage(index),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Hiển thị ảnh mới với nút X
  Widget _buildNewProofImage(File file, int index) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () => _replaceNewProofImage(index),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF008080), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeNewProofImage(index),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Nút thêm ảnh mới
  Widget _buildAddProofButton() {
    return GestureDetector(
      onTap: _addNewProofImage,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF008080),
            width: 2,
            style: BorderStyle.solid,
          ),
          color: const Color(0xFFF8FCFC),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate,
              size: 48,
              color: Color(0xFF008080),
            ),
            const SizedBox(height: 8),
            Text(
              'Thêm ảnh',
              style: GoogleFonts.roboto(
                color: const Color(0xFF008080),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// TextField hiện đại
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: GoogleFonts.roboto(fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF008080)),
            filled: true,
            fillColor: const Color(0xFFF8FCFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF008080), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// Preview ảnh CCCD
  Widget _buildImagePreview(
    String label,
    String? oldUrl,
    File? newFile,
    VoidCallback onTap,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF008080), width: 2),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: newFile != null
                  ? Image.file(newFile, fit: BoxFit.cover)
                  : (oldUrl != null && oldUrl.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: oldUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF008080),
                            ),
                          ),
                          errorWidget: (context, url, error) => Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.broken_image_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Lỗi tải ảnh',
                                style: GoogleFonts.roboto(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_photo_alternate,
                              size: 48,
                              color: Color(0xFF008080),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Thêm ảnh',
                              style: GoogleFonts.roboto(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ],
    );
  }

  /// Nút Lưu
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF008080),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: _isLoading ? null : _submitUpdate,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'LƯU THAY ĐỔI',
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  /// Nút Đăng xuất
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFEBEE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
        onPressed: _confirmLogout,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout,
              color: Color(0xFFD32F2F),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Đăng xuất',
              style: GoogleFonts.roboto(
                color: const Color(0xFFD32F2F),
                fontWeight: FontWeight.w700,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== LOGIC ====================

  /// Chọn ảnh từ gallery
  Future<void> _pickImage(String source) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        setState(() {
          if (source == 'avatar') {
            _newAvatar = file;
          } else if (source == 'front') {
            _newFront = file;
          } else if (source == 'back') {
            _newBack = file;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Thêm ảnh proof mới
  Future<void> _addNewProofImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _newProofFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Xóa ảnh cũ (URL)
  void _removeOldProofImage(int index) {
    setState(() {
      _keepingProofUrls.removeAt(index);
    });
  }

  /// Xóa ảnh mới (File)
  void _removeNewProofImage(int index) {
    setState(() {
      _newProofFiles.removeAt(index);
    });
  }

  /// Thay thế ảnh cũ bằng ảnh mới
  Future<void> _replaceOldProofImage(int index) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          // Xóa URL cũ
          _keepingProofUrls.removeAt(index);
          // Thêm file mới
          _newProofFiles.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Thay thế ảnh mới
  Future<void> _replaceNewProofImage(int index) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _newProofFiles[index] = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Submit cập nhật
  Future<void> _submitUpdate() async {
    // Validation
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập họ và tên'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('Không tìm thấy token xác thực');
      }

      final success = await _authService.updateBeneficiaryProfile(
        token: token,
        fullName: _nameController.text.trim(),
        vulnerabilityType: _vulnerabilityType,
        healthCondition: _healthConditionController.text.trim(),
        situationDescription: _situationController.text.trim(),
        guardianName: _guardianNameController.text.trim(),
        guardianPhone: _guardianPhoneController.text.trim(),
        guardianRelation: _guardianRelationController.text.trim(),
        avatar: _newAvatar,
        cccdFront: _newFront,
        cccdBack: _newBack,
        proofFiles: _newProofFiles.isNotEmpty ? _newProofFiles : null,
        keepingProofFiles:
            _keepingProofUrls.isNotEmpty ? _keepingProofUrls : null,
      );

      if (mounted) {
        if (success) {
          print("DEBUG: Update success, reloading data...");

          // Reload lại dữ liệu mới từ server
          final updatedData = await _authService.getMyProfile();

          if (updatedData != null && mounted) {
            print("DEBUG: Got updated data, updating UI...");

            setState(() {
              // QUAN TRỌNG: fullName và avatarUrl nằm TRONG bficiaryProfile
              final profile = updatedData['bficiaryProfile'] ?? {};

              // Cập nhật lại text fields
              _nameController.text = profile['fullName'] ?? "";

              _vulnerabilityType = profile['vulnerabilityType'] ?? "POOR";
              _healthConditionController.text = profile['healthCondition'] ?? "";
              _situationController.text = profile['situationDescription'] ?? "";
              _guardianNameController.text = profile['guardianName'] ?? "";
              _guardianPhoneController.text = profile['guardianPhone'] ?? "";
              _guardianRelationController.text = profile['guardianRelation'] ?? "";

              // QUAN TRỌNG: Reset Files về null và load URLs mới
              _newAvatar = null;
              _newFront = null;
              _newBack = null;
              _newProofFiles = [];

              // URLs nằm TRONG bficiaryProfile
              _oldAvatarUrl = profile['avatarUrl'];
              _oldFrontUrl = profile['cccdFrontFile'];
              _oldBackUrl = profile['cccdBackFile'];

              if (profile['proofFiles'] != null) {
                _keepingProofUrls = List<String>.from(profile['proofFiles']);
              } else {
                _keepingProofUrls = [];
              }
            });

            print("DEBUG: UI updated with new data");
            print("DEBUG: New avatar URL: $_oldAvatarUrl");
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật hồ sơ thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thất bại. Vui lòng thử lại.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Confirm đăng xuất
  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Xác nhận đăng xuất',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF008080),
          ),
        ),
        content: Text(
          'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
          style: GoogleFonts.roboto(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Hủy',
              style: GoogleFonts.roboto(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Đăng xuất',
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        selectedPageNotifier.value = 0;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ),
        );
      }
    }
  }

  // ==================== BUILD ====================

  Future<void> _refreshData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final data = await _authService.getMyProfile();
      if (data != null && mounted) {
        setState(() {
          // QUAN TRỌNG: fullName và avatarUrl nằm TRONG bficiaryProfile
          final profile = data['bficiaryProfile'] ?? {};

          // Reload dữ liệu mới
          _nameController.text = profile['fullName'] ?? "";

          _vulnerabilityType = profile['vulnerabilityType'] ?? "POOR";
          _healthConditionController.text = profile['healthCondition'] ?? "";
          _situationController.text = profile['situationDescription'] ?? "";
          _guardianNameController.text = profile['guardianName'] ?? "";
          _guardianPhoneController.text = profile['guardianPhone'] ?? "";
          _guardianRelationController.text = profile['guardianRelation'] ?? "";

          // URLs nằm TRONG bficiaryProfile
          _oldAvatarUrl = profile['avatarUrl'];
          _oldFrontUrl = profile['cccdFrontFile'];
          _oldBackUrl = profile['cccdBackFile'];

          // QUAN TRỌNG: Reset ảnh mới về null sau khi reload
          _newAvatar = null;
          _newFront = null;
          _newBack = null;
          _newProofFiles = [];

          if (profile['proofFiles'] != null) {
            _keepingProofUrls = List<String>.from(profile['proofFiles']);
          } else {
            _keepingProofUrls = [];
          }

          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FCFC),
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa Hồ Sơ',
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF008080),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF008080)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF008080),
        backgroundColor: Colors.white,
        displacement: 40,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
          children: [
            // Section 1: Avatar
            _buildAvatarSection(),
            const SizedBox(height: 24),

            // Navigation: Lịch sử hoạt động
            _buildActivityHistoryCard(),
            const SizedBox(height: 32),

            // Section 2: Thông tin cơ bản
            _buildBasicInfoSection(),
            const SizedBox(height: 20),

            // Section 3: Thông tin người giám hộ
            _buildGuardianSection(),
            const SizedBox(height: 20),

            // Section 4: CCCD
            _buildCCCDSection(),
            const SizedBox(height: 20),

            // Section 5: ProofFiles
            _buildProofFilesSection(),
            const SizedBox(height: 32),

            // Nút Lưu
            _buildSaveButton(),
            const SizedBox(height: 16),

            // Nút Đăng xuất
            _buildLogoutButton(),
            const SizedBox(height: 20),
          ],
        ),
        ),
      ),
    );
  }
}
