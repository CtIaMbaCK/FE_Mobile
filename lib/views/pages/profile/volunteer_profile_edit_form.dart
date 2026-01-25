import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile/services/auth_service.dart';
import 'package:mobile/helper/enum_helpers.dart';

class VolunteerProfileEditForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  const VolunteerProfileEditForm({super.key, required this.initialData});

  @override
  State<VolunteerProfileEditForm> createState() =>
      _VolunteerProfileEditFormState();
}

class _VolunteerProfileEditFormState extends State<VolunteerProfileEditForm> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _expController = TextEditingController();

  // Files ảnh mới (nếu user chọn)
  File? _avatar, _front, _back;

  // URLs ảnh cũ từ server
  String? _remoteAvatarUrl;
  String? _remoteFrontUrl;
  String? _remoteBackUrl;

  // Skills và Districts selection
  List<String> _selectedSkills = [];
  List<String> _selectedDistricts = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    // QUAN TRỌNG: fullName và avatarUrl nằm TRONG volunteerProfile
    final profile = widget.initialData['volunteerProfile'] ?? {};

    // Load dữ liệu cũ từ initialData
    _nameController.text = profile['fullName'] ?? "";
    _bioController.text = profile['bio'] ?? "";
    _expController.text = profile['experienceYears']?.toString() ?? "0";

    // Load skills và districts
    if (profile['skills'] != null) {
      _selectedSkills = List<String>.from(profile['skills']);
    } else {
      _selectedSkills = [];
    }

    if (profile['preferredDistricts'] != null) {
      _selectedDistricts = List<String>.from(profile['preferredDistricts']);
    } else {
      _selectedDistricts = [];
    }

    // QUAN TRỌNG: Reset ảnh mới về null
    _avatar = null;
    _front = null;
    _back = null;

    // Load URLs ảnh cũ (TRONG volunteerProfile)
    _remoteAvatarUrl = profile['avatarUrl'];
    _remoteFrontUrl = profile['cccdFrontFile'];
    _remoteBackUrl = profile['cccdBackFile'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _expController.dispose();
    super.dispose();
  }

  // ==================== UI SECTIONS ====================

  /// Section 1: Avatar với thiết kế hiện đại
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
              child: _avatar != null
                  ? Image.file(
                      _avatar!,
                      fit: BoxFit.cover,
                      width: 120,
                      height: 120,
                    )
                  : (_remoteAvatarUrl != null && _remoteAvatarUrl!.isNotEmpty)
                      ? CachedNetworkImage(
                          imageUrl: _remoteAvatarUrl!,
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

  /// Section 2: Thông tin cơ bản (Card trắng)
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
          _buildTextField(
            label: 'Giới thiệu bản thân',
            controller: _bioController,
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            label: 'Số năm kinh nghiệm',
            controller: _expController,
            icon: Icons.work_outline,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  /// Section 3: CCCD
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
                  _remoteFrontUrl,
                  _front,
                  () => _pickImage('front'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildImagePreview(
                  'Mặt sau',
                  _remoteBackUrl,
                  _back,
                  () => _pickImage('back'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Widget preview ảnh CCCD (hiển thị ảnh cũ hoặc mới)
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
                  ? Image.file(
                      newFile,
                      fit: BoxFit.cover,
                    )
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

  /// TextField hiện đại với icon
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

  /// Section 4: Kỹ năng tình nguyện
  Widget _buildSkillsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_objects, color: Color(0xFF008080), size: 24),
              const SizedBox(width: 8),
              Text(
                'Kỹ năng tình nguyện',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF008080),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Chọn các kỹ năng của bạn (có thể chọn nhiều)',
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SkillHelper.getAllSkills().map((skill) {
              final isSelected = _selectedSkills.contains(skill);
              return FilterChip(
                label: Text(SkillHelper.getDisplayName(skill)),
                selected: isSelected,
                selectedColor: const Color(0xFF008080).withOpacity(0.2),
                checkmarkColor: const Color(0xFF008080),
                backgroundColor: Colors.grey.shade100,
                labelStyle: GoogleFonts.roboto(
                  fontSize: 13,
                  color: isSelected ? const Color(0xFF008080) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF008080) : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSkills.add(skill);
                    } else {
                      _selectedSkills.remove(skill);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Section 5: Quận/Huyện ưu tiên
  Widget _buildDistrictsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFF008080), size: 24),
              const SizedBox(width: 8),
              Text(
                'Quận/Huyện ưu tiên',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF008080),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Chọn khu vực bạn muốn hoạt động tình nguyện',
            style: GoogleFonts.roboto(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: DistrictHelper.getAllDistricts().map((district) {
              final isSelected = _selectedDistricts.contains(district);
              return FilterChip(
                label: Text(DistrictHelper.getDisplayName(district)),
                selected: isSelected,
                selectedColor: const Color(0xFF008080).withOpacity(0.2),
                checkmarkColor: const Color(0xFF008080),
                backgroundColor: Colors.grey.shade100,
                labelStyle: GoogleFonts.roboto(
                  fontSize: 13,
                  color: isSelected ? const Color(0xFF008080) : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF008080) : Colors.grey.shade300,
                  width: isSelected ? 1.5 : 1,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedDistricts.add(district);
                    } else {
                      _selectedDistricts.remove(district);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Button Lưu thay đổi
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
            _avatar = file;
          } else if (source == 'front') {
            _front = file;
          } else if (source == 'back') {
            _back = file;
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

  /// Submit cập nhật profile
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

      final success = await _authService.updateVolunteerProfile(
        token: token,
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        experienceYears: int.tryParse(_expController.text.trim()) ?? 0,
        skills: _selectedSkills.isEmpty ? null : _selectedSkills,
        preferredDistricts: _selectedDistricts.isEmpty ? null : _selectedDistricts,
        avatar: _avatar,
        cccdFront: _front,
        cccdBack: _back,
      );

      if (mounted) {
        if (success) {
          // Reload profile data từ server
          final updatedData = await _authService.getMyProfile();

          if (updatedData != null && mounted) {
            // QUAN TRỌNG: fullName và avatarUrl nằm TRONG volunteerProfile
            final profile = updatedData['volunteerProfile'] ?? {};

            // Reset form với dữ liệu mới
            setState(() {
              _nameController.text = profile['fullName'] ?? "";
              _bioController.text = profile['bio'] ?? "";
              _expController.text = profile['experienceYears']?.toString() ?? "0";

              // Load skills và districts mới
              if (profile['skills'] != null) {
                _selectedSkills = List<String>.from(profile['skills']);
              } else {
                _selectedSkills = [];
              }

              if (profile['preferredDistricts'] != null) {
                _selectedDistricts = List<String>.from(profile['preferredDistricts']);
              } else {
                _selectedDistricts = [];
              }

              // QUAN TRỌNG: Reset ảnh mới về null
              _avatar = null;
              _front = null;
              _back = null;

              // Load URLs ảnh mới từ server (TRONG volunteerProfile)
              _remoteAvatarUrl = profile['avatarUrl'];
              _remoteFrontUrl = profile['cccdFrontFile'];
              _remoteBackUrl = profile['cccdBackFile'];
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Cập nhật hồ sơ thành công!',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF008080),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cập nhật thất bại. Vui lòng thử lại.',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
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

  // ==================== BUILD ====================

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Section 1: Avatar
            _buildAvatarSection(),
            const SizedBox(height: 32),

            // Section 2: Thông tin cơ bản
            _buildBasicInfoSection(),
            const SizedBox(height: 32),

            // Section 3: Kỹ năng
            _buildSkillsSection(),
            const SizedBox(height: 32),

            // Section 4: Quận/Huyện ưu tiên
            _buildDistrictsSection(),
            const SizedBox(height: 32),

            // Section 5: CCCD
            _buildCCCDSection(),
            const SizedBox(height: 32),

            // Save button
            _buildSaveButton(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
